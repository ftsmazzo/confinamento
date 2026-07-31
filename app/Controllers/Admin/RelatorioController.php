<?php

namespace App\Controllers\Admin;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\DB;
use App\Core\Request;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MovimentacaoMortalidade;
use App\Models\Manejo\MovimentacaoPesagem;
use App\Models\Sanitario\AplicacaoSanitaria;
use App\Services\Nutricao\CustoFormulaService;

class RelatorioController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Relatórios",
        ]);
    }

    /**
     * Rentabilidade por lote: valor de entrada (compra) + custo de
     * ração consumida + custo sanitário vs. valor de saída (venda).
     * Lotes ainda sem nenhuma saida aparecem com resultado em aberto
     * (custo acumulado ate agora, sem receita).
     */
    public function rentabilidade(Request $request): void
    {
        $this->authorize("relatorio_rentabilidade_visualizar");

        $data = new Data($request->all());
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : null;
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : null;

        $this->view->addData([
            "active_menu" => "relatorios-rentabilidade",
            "page" => [
                "title" => "Rentabilidade por Lote",
                "desc" => "Compara o custo total (compra + ração + sanidade) com a receita de venda de cada lote",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Relatórios" => ["url" => false, "current" => false],
                "Rentabilidade por Lote" => ["url" => false, "current" => true],
            ],
        ]);

        $lotes = Lote::leftJoin("lote_entrada as le", "l.id", "=", "le.id_lote")
            ->leftJoin("movimentacao_entrada as me", "l.id", "=", "me.id_lote")
            ->select(
                "l.*",
                "le.quantidade as quantidade_entrada",
                "le.peso_total as peso_entrada",
                "me.valor_total as valor_entrada"
            )
            ->orderBy("l.nome")
            ->get();

        $custoFormulaPorKg = (new CustoFormulaService())->custoPorKg();
        $racaoPorLotePorFormula = $this->racaoPorLotePorFormula();
        $custoSanitarioPorLote = $this->custoSanitarioPorLote();
        $receitaPorLote = $this->somarPorLote("movimentacao_saida", "id_lote", "valor_total");
        $quantidadeSaidaPorLote = $this->somarPorLote("movimentacao_saida", "id_lote", "quantidade");
        $pesoSaidaPorLote = $this->somarPorLote("movimentacao_saida", "id_lote", "peso_total");

        foreach ($lotes as $lote) {
            $lote->hash = md5((string) $lote->id);

            $custoRacao = 0.0;
            $quantidadeRacao = 0.0;
            foreach ($racaoPorLotePorFormula[$lote->id] ?? [] as $idFormula => $quantidade) {
                $custoRacao += $quantidade * ($custoFormulaPorKg[$idFormula] ?? 0);
                $quantidadeRacao += $quantidade;
            }

            $lote->custo_entrada = (float) ($lote->valor_entrada ?? 0);
            $lote->custo_racao = round($custoRacao, 2);
            $lote->custo_sanitario = round($custoSanitarioPorLote[$lote->id] ?? 0, 2);
            $lote->custo_total = round($lote->custo_entrada + $lote->custo_racao + $lote->custo_sanitario, 2);

            $lote->quantidade_racao_kg = round($quantidadeRacao, 2);
            $lote->receita_saida = round($receitaPorLote[$lote->id] ?? 0, 2);
            $lote->quantidade_vendida = (int) ($quantidadeSaidaPorLote[$lote->id] ?? 0);
            $lote->peso_saida_kg = round($pesoSaidaPorLote[$lote->id] ?? 0, 2);

            $lote->resultado = round($lote->receita_saida - $lote->custo_total, 2);
            $lote->tem_saida = $lote->quantidade_vendida > 0;

            // Indicadores por unidade -- só fazem sentido com saída
            // registrada (senão não há base de cabeças/peso vendido).
            $arrobas = $lote->peso_saida_kg > 0 ? $lote->peso_saida_kg / 15 : 0;
            $lote->custo_por_arroba = $lote->tem_saida && $arrobas > 0 ? round($lote->custo_total / $arrobas, 2) : null;
            $lote->custo_por_cabeca = $lote->tem_saida && $lote->quantidade_vendida > 0 ? round($lote->custo_total / $lote->quantidade_vendida, 2) : null;
            $lote->margem_percentual = $lote->tem_saida && $lote->receita_saida > 0 ? round($lote->resultado / $lote->receita_saida * 100, 1) : null;
        }

        $receitaDiariaQuery = DB::table("movimentacao_saida")
            ->select("data_saida", "valor_total");

        if ($dataInicial) {
            $receitaDiariaQuery = $receitaDiariaQuery->where("data_saida", ">=", $dataInicial);
        }

        if ($dataFinal) {
            $receitaDiariaQuery = $receitaDiariaQuery->where("data_saida", "<=", $dataFinal);
        }

        $porDia = [];
        foreach ($receitaDiariaQuery->get() as $saida) {
            $dia = $saida->data_saida;
            $porDia[$dia] = ($porDia[$dia] ?? 0) + (float) ($saida->valor_total ?? 0);
        }

        ksort($porDia);
        $graficoReceitaDiaria = [];
        $acumulado = 0.0;
        foreach ($porDia as $dia => $valor) {
            $acumulado += $valor;
            $graficoReceitaDiaria[] = ["data" => $dia, "valor" => round($valor, 2), "acumulado" => round($acumulado, 2)];
        }

        echo $this->view->render("admin/relatorio/rentabilidade", [
            "lotes" => $lotes,
            "dataInicial" => $dataInicial,
            "dataFinal" => $dataFinal,
            "graficoReceitaDiaria" => $graficoReceitaDiaria,
        ]);
    }

    /**
     * Evolucao de peso / GMD por lote: lista as pesagens de cada lote
     * em ordem cronologica com o GMD calculado entre pesagens
     * consecutivas (mesmo calculo usado na tela de Pesagens).
     */
    public function evolucaoPeso(Request $request): void
    {
        $this->authorize("relatorio_evolucao_peso_visualizar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : null;
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : null;

        $this->view->addData([
            "active_menu" => "relatorios-evolucao-peso",
            "page" => [
                "title" => "Evolução de Peso / GMD",
                "desc" => "Peso ao longo do tempo e ganho médio diário por lote",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Relatórios" => ["url" => false, "current" => false],
                "Evolução de Peso / GMD" => ["url" => false, "current" => true],
            ],
        ]);

        $lotes = Lote::orderBy("nome")->get();

        $query = MovimentacaoPesagem::leftJoin("lote as l", "mp.id_lote", "=", "l.id")
            ->select("mp.*", "l.nome as lote_nome", "l.codigo as lote_codigo")
            ->whereNotNull("mp.id_lote");

        if ($idLote) {
            $query = $query->where("mp.id_lote", "=", $idLote);
        }

        if ($dataInicial) {
            $query = $query->where("mp.data_pesagem", ">=", $dataInicial);
        }

        if ($dataFinal) {
            $query = $query->where("mp.data_pesagem", "<=", $dataFinal);
        }

        $pesagens = $query->orderBy("mp.id_lote")->orderBy("mp.data_pesagem")->get();

        $anteriorPorLote = [];
        foreach ($pesagens as $pesagem) {
            $anterior = $anteriorPorLote[$pesagem->id_lote] ?? null;

            $pesagem->gmd = $anterior
                ? MovimentacaoPesagem::calcularGmd(
                    (float) $anterior->peso_medio,
                    $anterior->data_pesagem,
                    (float) $pesagem->peso_medio,
                    $pesagem->data_pesagem
                )
                : null;

            $anteriorPorLote[$pesagem->id_lote] = $pesagem;
        }

        $pesagensPorLote = [];
        foreach ($pesagens as $pesagem) {
            $pesagensPorLote[$pesagem->id_lote][] = $pesagem;
        }

        $graficoSeries = [];
        foreach ($pesagensPorLote as $idLoteGrupo => $pesagensDoLote) {
            $graficoSeries[] = [
                "nome" => $pesagensDoLote[0]->lote_nome . " (" . $pesagensDoLote[0]->lote_codigo . ")",
                "pontos" => array_map(fn ($p) => [
                    "data" => $p->data_pesagem,
                    "peso_medio" => $p->peso_medio !== null ? (float) $p->peso_medio : null,
                ], $pesagensDoLote),
            ];
        }

        echo $this->view->render("admin/relatorio/evolucao-peso", [
            "lotes" => $lotes,
            "idLote" => $idLote,
            "dataInicial" => $dataInicial,
            "dataFinal" => $dataFinal,
            "pesagensPorLote" => $pesagensPorLote,
            "graficoSeries" => $graficoSeries,
        ]);
    }

    /**
     * Mortalidade / perdas: quantidade e percentual de perda por lote
     * e por motivo, com valor estimado perdido (baseado no custo medio
     * de entrada por cabeca do lote).
     */
    public function mortalidade(Request $request): void
    {
        $this->authorize("relatorio_mortalidade_visualizar");

        $data = new Data($request->all());
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : null;
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : null;

        $this->view->addData([
            "active_menu" => "relatorios-mortalidade",
            "page" => [
                "title" => "Mortalidade / Perdas",
                "desc" => "Quantidade, percentual e valor estimado de perda por lote e motivo",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Relatórios" => ["url" => false, "current" => false],
                "Mortalidade / Perdas" => ["url" => false, "current" => true],
            ],
        ]);

        $lotes = Lote::leftJoin("lote_entrada as le", "l.id", "=", "le.id_lote")
            ->select("l.*", "le.quantidade as quantidade_entrada", "le.peso_total as peso_entrada")
            ->orderBy("l.nome")
            ->get();

        $valorEntradaPorLote = $this->somarPorLote("movimentacao_entrada", "id_lote", "valor_total");

        $perdasQuery = MovimentacaoMortalidade::leftJoin("lote as l", "mm.id_lote", "=", "l.id")
            ->leftJoin("motivo_perda as mtp", "mm.id_motivo_perda", "=", "mtp.id")
            ->select("mm.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "mtp.descricao as motivo_descricao");

        if ($dataInicial) {
            $perdasQuery = $perdasQuery->where("mm.data_ocorrencia", ">=", $dataInicial);
        }

        if ($dataFinal) {
            $perdasQuery = $perdasQuery->where("mm.data_ocorrencia", "<=", $dataFinal);
        }

        $perdas = $perdasQuery->orderBy("mm.data_ocorrencia", "desc")->get();

        $perdaPorLote = [];
        $porDia = [];
        foreach ($perdas as $perda) {
            $perda->hash = md5((string) $perda->id);
            $perdaPorLote[$perda->id_lote][] = $perda;

            $dia = $perda->data_ocorrencia;
            $porDia[$dia] = ($porDia[$dia] ?? 0) + (int) $perda->quantidade;
        }

        foreach ($lotes as $lote) {
            $lote->hash = md5((string) $lote->id);

            $quantidadeEntrada = (int) ($lote->quantidade_entrada ?? 0);
            $valorEntrada = (float) ($valorEntradaPorLote[$lote->id] ?? 0);
            $custoPorCabeca = $quantidadeEntrada > 0 ? $valorEntrada / $quantidadeEntrada : 0;

            $perdasDoLote = $perdaPorLote[$lote->id] ?? [];
            $totalPerdido = 0;
            foreach ($perdasDoLote as $perda) {
                $totalPerdido += (int) $perda->quantidade;
            }

            $lote->perdas = $perdasDoLote;
            $lote->total_perdido = $totalPerdido;
            $lote->percentual_perda = $quantidadeEntrada > 0
                ? round($totalPerdido / $quantidadeEntrada * 100, 2)
                : 0;
            $lote->valor_estimado_perdido = round($totalPerdido * $custoPorCabeca, 2);
        }

        ksort($porDia);
        $graficoPerdasDiarias = [];
        foreach ($porDia as $dia => $quantidade) {
            $graficoPerdasDiarias[] = ["data" => $dia, "quantidade" => $quantidade];
        }

        echo $this->view->render("admin/relatorio/mortalidade", [
            "lotes" => $lotes,
            "dataInicial" => $dataInicial,
            "dataFinal" => $dataFinal,
            "graficoPerdasDiarias" => $graficoPerdasDiarias,
        ]);
    }

    /**
     * Consumo de racao por lote: cruza fornecimento_trato com a
     * formula usada, agregando quantidade (kg) e custo estimado por
     * lote e por formula.
     */
    public function consumoRacao(Request $request): void
    {
        $this->authorize("relatorio_consumo_racao_visualizar");

        $data = new Data($request->all());
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : null;
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : null;

        $this->view->addData([
            "active_menu" => "relatorios-consumo-racao",
            "page" => [
                "title" => "Consumo de Ração por Lote",
                "desc" => "Quantidade e custo estimado de ração fornecida a cada lote, por fórmula",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Relatórios" => ["url" => false, "current" => false],
                "Consumo de Ração por Lote" => ["url" => false, "current" => true],
            ],
        ]);

        $custoFormulaPorKg = (new CustoFormulaService())->custoPorKg();

        $query = DB::table("fornecimento_trato", "ft")
            ->leftJoin("lote as l", "ft.id_lote", "=", "l.id")
            ->leftJoin("formula_racao as fr", "ft.id_formula_racao", "=", "fr.id")
            ->select(
                "ft.id_lote",
                "l.nome as lote_nome",
                "l.codigo as lote_codigo",
                "ft.id_formula_racao",
                "fr.nome as formula_nome",
                "ft.quantidade_fornecida",
                "ft.data_fornecimento"
            );

        if ($dataInicial) {
            $query = $query->where("ft.data_fornecimento", ">=", $dataInicial);
        }

        if ($dataFinal) {
            $query = $query->where("ft.data_fornecimento", "<=", $dataFinal);
        }

        $fornecimentos = $query->orderBy("l.nome")->get();

        $resumo = [];
        $porDia = [];
        foreach ($fornecimentos as $fornecimento) {
            $idFormula = $fornecimento->id_formula_racao ?? 0;
            $chave = $fornecimento->id_lote . "_" . $idFormula;

            if (!isset($resumo[$chave])) {
                $resumo[$chave] = (object) [
                    "id_lote" => $fornecimento->id_lote,
                    "lote_nome" => $fornecimento->lote_nome,
                    "lote_codigo" => $fornecimento->lote_codigo,
                    "id_formula_racao" => $idFormula,
                    "formula_nome" => $fornecimento->formula_nome ?: "Sem fórmula definida",
                    "quantidade_total" => 0.0,
                    "hash" => md5($chave),
                ];
            }

            $resumo[$chave]->quantidade_total += (float) $fornecimento->quantidade_fornecida;

            $dia = $fornecimento->data_fornecimento;
            $porDia[$dia] = ($porDia[$dia] ?? 0) + (float) $fornecimento->quantidade_fornecida;
        }

        foreach ($resumo as $item) {
            $item->quantidade_total = round($item->quantidade_total, 2);
            $item->custo_estimado = round($item->quantidade_total * ($custoFormulaPorKg[$item->id_formula_racao] ?? 0), 2);
        }

        ksort($porDia);
        $graficoConsumoDiario = [];
        foreach ($porDia as $dia => $quantidade) {
            $graficoConsumoDiario[] = ["data" => $dia, "quantidade" => round($quantidade, 2)];
        }

        echo $this->view->render("admin/relatorio/consumo-racao", [
            "dados" => array_values($resumo),
            "dataInicial" => $dataInicial,
            "dataFinal" => $dataFinal,
            "graficoConsumoDiario" => $graficoConsumoDiario,
        ]);
    }

    /**
     * Eficiencia de trato: compara, por lote, o total previsto em
     * programacao_trato (quantidade_prevista) com o total realmente
     * fornecido em fornecimento_trato (quantidade_fornecida) no mesmo
     * periodo, calculando o percentual de aderencia. Os dois lados sao
     * lancamentos manuais e independentes (o vinculo entre eles via
     * id_programacao_trato e opcional) -- por isso a comparacao aqui e
     * feita por LOTE + DATA, nao pelo vinculo direto, para nao perder
     * fornecimentos que nunca foram ligados a uma programacao.
     */
    public function eficienciaTrato(Request $request): void
    {
        $this->authorize("relatorio_eficiencia_trato_visualizar");

        $data = new Data($request->all());
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : null;
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : null;

        $this->view->addData([
            "active_menu" => "relatorios-eficiencia-trato",
            "page" => [
                "title" => "Eficiência de Trato",
                "desc" => "Compara a quantidade de ração programada com a efetivamente fornecida, por lote",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Relatórios" => ["url" => false, "current" => false],
                "Eficiência de Trato" => ["url" => false, "current" => true],
            ],
        ]);

        $programadoQuery = DB::table("programacao_trato")
            ->select("id_lote", "data_programacao", "quantidade_prevista");

        $fornecidoQuery = DB::table("fornecimento_trato")
            ->select("id_lote", "data_fornecimento", "quantidade_fornecida");

        if ($dataInicial) {
            $programadoQuery = $programadoQuery->where("data_programacao", ">=", $dataInicial);
            $fornecidoQuery = $fornecidoQuery->where("data_fornecimento", ">=", $dataInicial);
        }

        if ($dataFinal) {
            $programadoQuery = $programadoQuery->where("data_programacao", "<=", $dataFinal);
            $fornecidoQuery = $fornecidoQuery->where("data_fornecimento", "<=", $dataFinal);
        }

        $porLote = [];
        $porDia = [];

        foreach ($programadoQuery->get() as $linha) {
            $idLote = $linha->id_lote;
            $porLote[$idLote]["previsto"] = ($porLote[$idLote]["previsto"] ?? 0) + (float) ($linha->quantidade_prevista ?? 0);

            $dia = $linha->data_programacao;
            $porDia[$dia]["previsto"] = ($porDia[$dia]["previsto"] ?? 0) + (float) ($linha->quantidade_prevista ?? 0);
        }

        foreach ($fornecidoQuery->get() as $linha) {
            $idLote = $linha->id_lote;
            $porLote[$idLote]["realizado"] = ($porLote[$idLote]["realizado"] ?? 0) + (float) $linha->quantidade_fornecida;

            $dia = $linha->data_fornecimento;
            $porDia[$dia]["realizado"] = ($porDia[$dia]["realizado"] ?? 0) + (float) $linha->quantidade_fornecida;
        }

        $idsLote = array_keys($porLote);
        $lotesInfo = [];
        if (!empty($idsLote)) {
            foreach (Lote::whereIn("id", $idsLote)->select("id", "nome", "codigo")->get() as $l) {
                $lotesInfo[$l->id] = $l;
            }
        }

        $linhas = [];
        foreach ($porLote as $idLote => $valores) {
            $previsto = round($valores["previsto"] ?? 0, 2);
            $realizado = round($valores["realizado"] ?? 0, 2);
            $lote = $lotesInfo[$idLote] ?? null;

            $linhas[] = [
                "id_lote" => $idLote,
                "lote_nome" => $lote->nome ?? "Lote #{$idLote}",
                "lote_codigo" => $lote->codigo ?? "",
                "previsto" => $previsto,
                "realizado" => $realizado,
                "diferenca" => round($realizado - $previsto, 2),
                "percentual_aderencia" => $previsto > 0 ? round($realizado / $previsto * 100, 1) : null,
            ];
        }

        usort($linhas, fn ($a, $b) => strcmp($a["lote_nome"], $b["lote_nome"]));

        ksort($porDia);
        $graficoDiario = [];
        foreach ($porDia as $dia => $valores) {
            $graficoDiario[] = [
                "data" => $dia,
                "previsto" => round($valores["previsto"] ?? 0, 2),
                "realizado" => round($valores["realizado"] ?? 0, 2),
            ];
        }

        $totalPrevisto = round(array_sum(array_column($linhas, "previsto")), 2);
        $totalRealizado = round(array_sum(array_column($linhas, "realizado")), 2);

        echo $this->view->render("admin/relatorio/eficiencia-trato", [
            "linhas" => $linhas,
            "graficoDiario" => $graficoDiario,
            "totalPrevisto" => $totalPrevisto,
            "totalRealizado" => $totalRealizado,
            "percentualGeral" => $totalPrevisto > 0 ? round($totalRealizado / $totalPrevisto * 100, 1) : null,
            "dataInicial" => $dataInicial,
            "dataFinal" => $dataFinal,
        ]);
    }

    /**
     * Eficiencia Alimentar: Conversao Alimentar (CA) por formula de
     * racao -- kg de racao fornecida dividido pelo kg de peso vivo
     * ganho no periodo. Quanto MENOR a CA, mais eficiente a dieta
     * (menos racao para converter em peso).
     *
     * Premissa importante (documentada na tela): o ganho de peso e
     * calculado por LOTE (ultima pesagem - primeira pesagem do
     * periodo), nao por formula isoladamente. Quando um lote consome
     * mais de uma formula no periodo, o ganho de peso do lote e
     * rateado entre as formulas na mesma proporcao do kg fornecido de
     * cada uma -- e uma aproximacao, nao uma medicao direta por dieta
     * (o sistema nao isola fisicamente o efeito de cada racao).
     */
    public function eficienciaAlimentar(Request $request): void
    {
        $this->authorize("relatorio_eficiencia_alimentar_visualizar");

        $data = new Data($request->all());
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : null;
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : null;

        $this->view->addData([
            "active_menu" => "relatorios-eficiencia-alimentar",
            "page" => [
                "title" => "Eficiência Alimentar",
                "desc" => "Conversão alimentar (kg de ração ÷ kg de peso ganho) por fórmula de ração",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Relatórios" => ["url" => false, "current" => false],
                "Eficiência Alimentar" => ["url" => false, "current" => true],
            ],
        ]);

        $racaoPorLotePorFormula = $this->racaoPorLotePorFormula($dataInicial, $dataFinal);
        $ganhoPesoPorLote = $this->ganhoPesoPorLote($dataInicial, $dataFinal);

        $idsFormula = [];
        foreach ($racaoPorLotePorFormula as $porFormula) {
            foreach (array_keys($porFormula) as $idFormula) {
                $idsFormula[$idFormula] = true;
            }
        }

        $formulasInfo = [];
        if (!empty($idsFormula)) {
            foreach (DB::table("formula_racao")->whereIn("id", array_keys($idsFormula))->select("id", "nome")->get() as $f) {
                $formulasInfo[$f->id] = $f->nome;
            }
        }

        $porFormula = [];
        foreach ($racaoPorLotePorFormula as $idLote => $consumoPorFormula) {
            $ganhoLote = $ganhoPesoPorLote[$idLote] ?? null;
            $totalConsumidoLote = array_sum($consumoPorFormula);

            if ($ganhoLote === null || $totalConsumidoLote <= 0) {
                continue;
            }

            foreach ($consumoPorFormula as $idFormula => $quantidade) {
                $proporcao = $quantidade / $totalConsumidoLote;
                $ganhoAtribuido = $ganhoLote * $proporcao;

                if (!isset($porFormula[$idFormula])) {
                    $porFormula[$idFormula] = [
                        "nome" => $formulasInfo[$idFormula] ?? "Sem fórmula definida",
                        "racao_kg" => 0.0,
                        "ganho_kg" => 0.0,
                        "lotes" => [],
                    ];
                }

                $porFormula[$idFormula]["racao_kg"] += $quantidade;
                $porFormula[$idFormula]["ganho_kg"] += $ganhoAtribuido;
                $porFormula[$idFormula]["lotes"][$idLote] = true;
            }
        }

        $linhas = [];
        foreach ($porFormula as $idFormula => $dados) {
            $linhas[] = [
                "id_formula" => $idFormula,
                "nome" => $dados["nome"],
                "racao_kg" => round($dados["racao_kg"], 2),
                "ganho_kg" => round($dados["ganho_kg"], 2),
                "conversao_alimentar" => $dados["ganho_kg"] > 0 ? round($dados["racao_kg"] / $dados["ganho_kg"], 2) : null,
                "qtd_lotes" => count($dados["lotes"]),
            ];
        }

        usort($linhas, fn ($a, $b) => ($a["conversao_alimentar"] ?? PHP_FLOAT_MAX) <=> ($b["conversao_alimentar"] ?? PHP_FLOAT_MAX));

        echo $this->view->render("admin/relatorio/eficiencia-alimentar", [
            "linhas" => $linhas,
            "dataInicial" => $dataInicial,
            "dataFinal" => $dataFinal,
        ]);
    }

    /**
     * Ganho de peso vivo por lote no periodo: ultima pesagem menos
     * primeira pesagem do lote dentro do intervalo informado (ou de
     * todo o historico, se sem filtro). Lotes com menos de duas
     * pesagens no periodo ficam de fora (nao ha ganho calculavel).
     */
    private function ganhoPesoPorLote(?string $dataInicial, ?string $dataFinal): array
    {
        $query = MovimentacaoPesagem::whereNotNull("id_lote")
            ->select("id_lote", "data_pesagem", "peso_medio");

        if ($dataInicial) {
            $query = $query->where("data_pesagem", ">=", $dataInicial);
        }

        if ($dataFinal) {
            $query = $query->where("data_pesagem", "<=", $dataFinal);
        }

        $pesagens = $query->orderBy("id_lote")->orderBy("data_pesagem")->get();

        $primeiraPorLote = [];
        $ultimaPorLote = [];
        foreach ($pesagens as $p) {
            if (!isset($primeiraPorLote[$p->id_lote])) {
                $primeiraPorLote[$p->id_lote] = (float) $p->peso_medio;
            }
            $ultimaPorLote[$p->id_lote] = (float) $p->peso_medio;
        }

        $ganho = [];
        foreach ($ultimaPorLote as $idLote => $pesoFinal) {
            $diferenca = $pesoFinal - $primeiraPorLote[$idLote];
            if ($diferenca > 0) {
                $ganho[$idLote] = $diferenca;
            }
        }

        return $ganho;
    }

    /**
     * Quantidade (kg) fornecida por lote, quebrada por formula de
     * racao -- usada na Rentabilidade para aplicar o custo por kg de
     * cada formula separadamente (um lote pode ter trocado de dieta e
     * consumido mais de uma formula ao longo do confinamento).
     */
    private function racaoPorLotePorFormula(?string $dataInicial = null, ?string $dataFinal = null): array
    {
        $query = DB::table("fornecimento_trato")
            ->select("id_lote", "id_formula_racao", "quantidade_fornecida");

        if ($dataInicial) {
            $query = $query->where("data_fornecimento", ">=", $dataInicial);
        }

        if ($dataFinal) {
            $query = $query->where("data_fornecimento", "<=", $dataFinal);
        }

        $fornecimentos = $query->get();

        $resultado = [];
        foreach ($fornecimentos as $fornecimento) {
            $idFormula = $fornecimento->id_formula_racao ?? 0;
            $resultado[$fornecimento->id_lote][$idFormula] = ($resultado[$fornecimento->id_lote][$idFormula] ?? 0)
                + (float) $fornecimento->quantidade_fornecida;
        }

        return $resultado;
    }

    /**
     * Custo sanitario por lote: soma quantidade_produto x custo_unitario
     * do produto, tanto das aplicacoes diretas no lote quanto das
     * aplicacoes em animais individuais pertencentes ao lote.
     */
    private function custoSanitarioPorLote(): array
    {
        $aplicacoes = AplicacaoSanitaria::leftJoin("animal as a", "aps.id_animal", "=", "a.id")
            ->leftJoin("produto_estoque as pe", "aps.id_produto_estoque", "=", "pe.id")
            ->select(
                "aps.id_lote",
                "a.id_lote as animal_id_lote",
                "aps.quantidade_produto",
                "pe.custo_unitario"
            )
            ->get();

        $resultado = [];
        foreach ($aplicacoes as $aplicacao) {
            $idLote = $aplicacao->id_lote ?: $aplicacao->animal_id_lote;

            if (!$idLote || empty($aplicacao->quantidade_produto) || $aplicacao->custo_unitario === null) {
                continue;
            }

            $resultado[$idLote] = ($resultado[$idLote] ?? 0)
                + (float) $aplicacao->quantidade_produto * (float) $aplicacao->custo_unitario;
        }

        return $resultado;
    }

    /**
     * Helper generico: soma uma coluna numerica agrupada por id_lote em
     * qualquer tabela de movimentacao (entrada, saida etc).
     */
    private function somarPorLote(string $tabela, string $colunaLote, string $colunaValor): array
    {
        $linhas = DB::table($tabela)
            ->select($colunaLote, $colunaValor)
            ->get();

        $resultado = [];
        foreach ($linhas as $linha) {
            $idLote = $linha->{$colunaLote};
            if (!$idLote) {
                continue;
            }
            $resultado[$idLote] = ($resultado[$idLote] ?? 0) + (float) ($linha->{$colunaValor} ?? 0);
        }

        return $resultado;
    }
}
