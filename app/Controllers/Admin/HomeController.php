<?php
namespace App\Controllers\Admin;

use App\Core\Config;
use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\DB;
use App\Core\Request;
use App\Models\Financeiro\ContaPagar;
use App\Models\Financeiro\ContaReceber;
use App\Models\Manejo\Animal;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MovimentacaoPesagem;
use App\Models\Nutricao\Ingrediente;
use App\Models\Sanitario\AplicacaoSanitaria;

class HomeController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData(
            [
                "title" => "Home",
                "page_title" => "Meu Painel",
                "active_menu" => "painel",
            ]
        );
    }

    public function index(): void
    {
        echo $this->view->render("admin/home/index", [
            "vapidKey" => Config::get("push.publicKey"),
            "userToken" => $this->user->token,
            "csrf" => $this->csrf->generate(),
            "indicadores" => $this->indicadores(),
            "atalhos" => $this->atalhos(),
        ]);
    }

    /**
     * Dados (JSON) para o gráfico de evolução de peso médio da Home,
     * com filtro opcional de data inicial/final sobre data_pesagem.
     * Consumido via AJAX pelo próprio index() para permitir refiltrar
     * sem recarregar a página inteira.
     */
    public function graficoPeso(Request $request): void
    {
        $data = new Data($request->all());
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : null;
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : null;

        $query = MovimentacaoPesagem::leftJoin("lote as l", "mp.id_lote", "=", "l.id")
            ->select("mp.id_lote", "mp.data_pesagem", "mp.peso_medio", "l.nome as lote_nome", "l.codigo as lote_codigo")
            ->whereNotNull("mp.id_lote");

        if ($dataInicial) {
            $query = $query->where("mp.data_pesagem", ">=", $dataInicial);
        }

        if ($dataFinal) {
            $query = $query->where("mp.data_pesagem", "<=", $dataFinal);
        }

        $pesagens = $query->orderBy("mp.id_lote")->orderBy("mp.data_pesagem")->get();

        $porLote = [];
        foreach ($pesagens as $pesagem) {
            $idLote = $pesagem->id_lote;
            if (!isset($porLote[$idLote])) {
                $porLote[$idLote] = [
                    "nome" => $pesagem->lote_nome . " (" . $pesagem->lote_codigo . ")",
                    "pontos" => [],
                ];
            }
            $porLote[$idLote]["pontos"][] = [
                "data" => $pesagem->data_pesagem,
                "peso_medio" => $pesagem->peso_medio !== null ? (float) $pesagem->peso_medio : null,
            ];
        }

        header("Content-Type: application/json; charset=utf-8");
        echo json_encode([
            "error" => false,
            "data" => array_values($porLote),
        ], JSON_UNESCAPED_UNICODE);
    }

    /**
     * Botões de atalho para os lançamentos mais frequentes do dia a
     * dia (entrada, pesagem, saída, leitura de cocho etc.). Cada
     * atalho só aparece se o usuário tiver a permissão de gerenciar
     * aquele módulo — mesma checagem usada para montar o menu lateral.
     */
    private function atalhos(): array
    {
        $permissoes = (array) $this->auth->permissions();

        $todos = [
            [
                "label" => "Entrada de Animais",
                "icon" => "uil-arrow-circle-down",
                "route" => "admin.manejo.entrada.novo",
                "permission" => "entrada_gerenciar",
                "cor" => "#0d6efd",
            ],
            [
                "label" => "Pesagem",
                "icon" => "uil-weight",
                "route" => "admin.manejo.pesagem.novo",
                "permission" => "pesagem_gerenciar",
                "cor" => "#198754",
            ],
            [
                "label" => "Saída",
                "icon" => "uil-sign-out-alt",
                "route" => "admin.manejo.saida.novo",
                "permission" => "saida_gerenciar",
                "cor" => "#dc3545",
            ],
            [
                "label" => "Mortalidade / Perda",
                "icon" => "uil-exclamation-triangle",
                "route" => "admin.manejo.mortalidade.novo",
                "permission" => "mortalidade_gerenciar",
                "cor" => "#6c757d",
            ],
            [
                "label" => "Localização",
                "icon" => "uil-map-marker",
                "route" => "admin.manejo.localizacao.novo",
                "permission" => "localizacao_gerenciar",
                "cor" => "#0dcaf0",
            ],
            [
                "label" => "Troca de Dieta",
                "icon" => "uil-sync",
                "route" => "admin.manejo.troca.dieta.novo",
                "permission" => "troca_dieta_gerenciar",
                "cor" => "#fd7e14",
            ],
            [
                "label" => "Fornecimento de Trato",
                "icon" => "uil-utensils",
                "route" => "admin.nutricao.fornecimento.trato.novo",
                "permission" => "fornecimento_trato_gerenciar",
                "cor" => "#20c997",
            ],
            [
                "label" => "Leitura de Cocho",
                "icon" => "uil-search",
                "route" => "admin.nutricao.leitura.cocho.novo",
                "permission" => "leitura_cocho_gerenciar",
                "cor" => "#6610f2",
            ],
            // [
            //     "label" => "Confecção de Ração",
            //     "icon" => "uil-flask",
            //     "route" => "admin.nutricao.confeccao.racao.novo",
            //     "permission" => "confeccao_racao_gerenciar",
            //     "cor" => "#d63384",
            // ],
        ];

        $atalhos = array_values(array_filter($todos, function ($item) use ($permissoes) {
            return in_array($item["permission"], $permissoes, true);
        }));

        foreach ($atalhos as &$item) {
            $item["url"] = $this->router->hasNamedRoute($item["route"])
                ? $this->router->route($item["route"])
                : "#";
        }

        return $atalhos;
    }

    /**
     * Monta os dados do dashboard da home. Cada bloco é independente
     * e best-effort: se uma tabela/coluna não existir no ambiente
     * (ex.: instalação antiga sem alguma migration), o indicador
     * correspondente é omitido em vez de quebrar a tela inteira.
     */
    private function indicadores(): array
    {
        return [
            "animais_por_situacao" => $this->animaisPorSituacao(),
            "animais_ativos_idade_sexo" => $this->animaisAtivosPorIdadeSexo(),
            "carencias_vigentes" => $this->carenciasVigentes(),
            "produtos_vencendo" => $this->produtosVencendo(),
            "estoque_baixo" => $this->estoqueBaixo(),
            "gmd_medio" => $this->gmdMedioRecente(),
            "resumo_mes" => $this->resumoMesAtual(),
            "lotes_ativos" => $this->contarLotesAtivos(),
            "financeiro" => $this->financeiroResumo(),
        ];
    }

    /**
     * Quantidade de animais em cada situação cadastrada (Ativo,
     * Vendido, Morto etc.), já com a cor definida no cadastro de
     * Situações do Animal para colorir o gráfico/badges.
     */
    private function animaisPorSituacao(): array
    {
        $linhas = Animal::leftJoin("animal_situacao as asi", "a.id_situacao", "=", "asi.id")
            ->select("asi.id", "asi.descricao", "asi.cor", "COUNT(a.id) as total")
            ->groupBy("asi.id", "asi.descricao", "asi.cor")
            ->get();

        $resultado = [];
        foreach ($linhas as $linha) {
            $resultado[] = [
                "descricao" => $linha->descricao ?? "Sem situação definida",
                "cor" => $linha->cor ?: "#6c757d",
                "total" => (int) $linha->total,
            ];
        }

        usort($resultado, fn ($a, $b) => $b["total"] <=> $a["total"]);

        return $resultado;
    }

    /**
     * Detalhamento dos animais na situação "Ativo": quantos caem em
     * cada faixa etária (calculada a partir de data_nascimento),
     * separados por sexo (M/F). Animais sem data de nascimento ou sem
     * sexo cadastrado entram na faixa/coluna "Não informado".
     */
    private function animaisAtivosPorIdadeSexo(): array
    {
        $faixas = [
            ["label" => "0 a 6 meses", "min" => 0, "max" => 6],
            ["label" => "6 a 12 meses", "min" => 6, "max" => 12],
            ["label" => "12 a 18 meses", "min" => 12, "max" => 18],
            ["label" => "18 a 24 meses", "min" => 18, "max" => 24],
            ["label" => "Acima de 24 meses", "min" => 24, "max" => null],
        ];

        $animais = Animal::leftJoin("animal_situacao as asi", "a.id_situacao", "=", "asi.id")
            ->select("a.sexo", "a.data_nascimento")
            ->where("asi.descricao", "=", "Ativo")
            ->get();

        $contagem = [];
        foreach ($faixas as $faixa) {
            $contagem[$faixa["label"]] = ["M" => 0, "F" => 0, "?" => 0];
        }
        $contagem["Idade não informada"] = ["M" => 0, "F" => 0, "?" => 0];

        $hoje = new \DateTime("today");
        foreach ($animais as $animal) {
            $sexo = in_array($animal->sexo, ["M", "F"], true) ? $animal->sexo : "?";

            if (empty($animal->data_nascimento)) {
                $contagem["Idade não informada"][$sexo]++;
                continue;
            }

            $nascimento = new \DateTime($animal->data_nascimento);
            $idadeMeses = ($hoje->diff($nascimento))->y * 12 + ($hoje->diff($nascimento))->m;

            $label = null;
            foreach ($faixas as $faixa) {
                if ($idadeMeses >= $faixa["min"] && ($faixa["max"] === null || $idadeMeses < $faixa["max"])) {
                    $label = $faixa["label"];
                    break;
                }
            }

            $contagem[$label ?? "Idade não informada"][$sexo]++;
        }

        $linhas = [];
        foreach ($contagem as $label => $porSexo) {
            $total = $porSexo["M"] + $porSexo["F"] + $porSexo["?"];
            if ($total === 0) {
                continue;
            }
            $linhas[] = [
                "faixa" => $label,
                "macho" => $porSexo["M"],
                "femea" => $porSexo["F"],
                "nao_informado" => $porSexo["?"],
                "total" => $total,
            ];
        }

        return $linhas;
    }

    /**
     * Lotes e animais com aplicação sanitária em período de carência
     * ainda vigente hoje, ordenados pela carência que termina mais
     * cedo primeiro (mais urgente) — mesma regra usada para bloquear
     * a tela de Saída de animais.
     */
    private function carenciasVigentes(): array
    {
        $aplicacoes = AplicacaoSanitaria::leftJoin("lote as l", "aps.id_lote", "=", "l.id")
            ->leftJoin("animal as a", "aps.id_animal", "=", "a.id")
            ->leftJoin("lote as la", "a.id_lote", "=", "la.id")
            ->select(
                "aps.id",
                "aps.data_carencia_fim",
                "aps.id_lote",
                "l.nome as lote_nome",
                "aps.id_animal",
                "a.identificacao as animal_identificacao",
                "la.id as animal_lote_id",
                "la.nome as animal_lote_nome"
            )
            ->whereNotNull("aps.data_carencia_fim")
            ->whereRaw("aps.data_carencia_fim >= CURDATE()")
            ->orderBy("aps.data_carencia_fim")
            ->get();

        $resultado = [];
        foreach ($aplicacoes as $aplicacao) {
            $hoje = new \DateTime("today");
            $fim = new \DateTime($aplicacao->data_carencia_fim);
            $diasRestantes = (int) $hoje->diff($fim)->format("%r%a");

            $resultado[] = [
                "referencia" => $aplicacao->id_lote
                    ? "Lote " . ($aplicacao->lote_nome ?? "#" . $aplicacao->id_lote)
                    : "Animal " . ($aplicacao->animal_identificacao ?? "#" . $aplicacao->id_animal)
                        . ($aplicacao->animal_lote_nome ? " (lote {$aplicacao->animal_lote_nome})" : ""),
                "data_carencia_fim" => $aplicacao->data_carencia_fim,
                "dias_restantes" => $diasRestantes,
            ];
        }

        return array_slice($resultado, 0, 8);
    }

    /**
     * Produtos de estoque com validade cadastrada (via lote_estoque)
     * vencendo nos próximos 30 dias ou já vencidos. Ingredientes de
     * ração não têm campo de validade no schema atual, então não
     * entram neste indicador.
     */
    private function produtosVencendo(): array
    {
        $linhas = DB::table("lote_estoque", "le")
            ->leftJoin("produto_estoque as pe", "le.id_produto_estoque", "=", "pe.id")
            ->select("le.id", "le.codigo_lote", "le.data_validade", "le.quantidade_atual", "pe.nome as produto_nome")
            ->whereNotNull("le.data_validade")
            ->whereRaw("le.quantidade_atual > 0")
            ->whereRaw("le.data_validade <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)")
            ->orderBy("le.data_validade")
            ->get();

        $resultado = [];
        foreach ($linhas as $linha) {
            $hoje = new \DateTime("today");
            $validade = new \DateTime($linha->data_validade);
            $diasRestantes = (int) $hoje->diff($validade)->format("%r%a");

            $resultado[] = [
                "produto_nome" => $linha->produto_nome ?? "Produto #" . $linha->id,
                "codigo_lote" => $linha->codigo_lote,
                "data_validade" => $linha->data_validade,
                "quantidade_atual" => (float) $linha->quantidade_atual,
                "dias_restantes" => $diasRestantes,
                "vencido" => $diasRestantes < 0,
            ];
        }

        return array_slice($resultado, 0, 8);
    }

    /**
     * Produtos de estoque e ingredientes de ração cujo saldo atual
     * está no ou abaixo do estoque mínimo cadastrado.
     */
    private function estoqueBaixo(): array
    {
        $resultado = [];

        $produtos = DB::table("produto_estoque")
            ->select("nome", "saldo_atual", "estoque_minimo", "unidade_medida")
            ->whereNotNull("estoque_minimo")
            ->whereRaw("saldo_atual <= estoque_minimo")
            ->orderBy("nome")
            ->get();

        foreach ($produtos as $produto) {
            $resultado[] = [
                "nome" => $produto->nome,
                "tipo" => "Produto",
                "saldo_atual" => (float) $produto->saldo_atual,
                "estoque_minimo" => (float) $produto->estoque_minimo,
                "unidade_medida" => $produto->unidade_medida,
            ];
        }

        $ingredientes = Ingrediente::select("nome", "estoque_atual", "estoque_minimo", "unidade_medida")
            ->whereNotNull("estoque_minimo")
            ->whereRaw("estoque_atual <= estoque_minimo")
            ->orderBy("nome")
            ->get();

        foreach ($ingredientes as $ingrediente) {
            $resultado[] = [
                "nome" => $ingrediente->nome,
                "tipo" => "Ingrediente",
                "saldo_atual" => (float) $ingrediente->estoque_atual,
                "estoque_minimo" => (float) $ingrediente->estoque_minimo,
                "unidade_medida" => $ingrediente->unidade_medida,
            ];
        }

        return $resultado;
    }

    /**
     * GMD médio (kg/dia) considerando apenas pesagens dos últimos 60
     * dias, comparadas com a pesagem anterior de cada lote/animal
     * (mesmo cálculo usado no relatório de Evolução de Peso).
     */
    private function gmdMedioRecente(): ?float
    {
        $pesagens = MovimentacaoPesagem::select("id_lote", "id_animal", "data_pesagem", "peso_medio")
            ->orderBy("id_lote")
            ->orderBy("id_animal")
            ->orderBy("data_pesagem")
            ->get();

        $anteriorPorChave = [];
        $gmds = [];
        $limite = (new \DateTime("today"))->modify("-60 days");

        foreach ($pesagens as $pesagem) {
            $chave = "l" . $pesagem->id_lote . "_a" . $pesagem->id_animal;
            $anterior = $anteriorPorChave[$chave] ?? null;

            if ($anterior) {
                $gmd = MovimentacaoPesagem::calcularGmd(
                    (float) $anterior->peso_medio,
                    $anterior->data_pesagem,
                    (float) $pesagem->peso_medio,
                    $pesagem->data_pesagem
                );

                if ($gmd !== null && new \DateTime($pesagem->data_pesagem) >= $limite) {
                    $gmds[] = $gmd;
                }
            }

            $anteriorPorChave[$chave] = $pesagem;
        }

        if (empty($gmds)) {
            return null;
        }

        return round(array_sum($gmds) / count($gmds), 3);
    }

    /**
     * Totais operacionais do mês corrente: entradas, saídas e
     * mortalidades registradas — visão rápida do movimento recente.
     */
    private function resumoMesAtual(): array
    {
        $inicioMes = date("Y-m-01");

        $entradas = DB::table("movimentacao_entrada")
            ->whereRaw("data_entrada >= ?", [$inicioMes])
            ->count();

        $saidas = DB::table("movimentacao_saida")
            ->whereRaw("data_saida >= ?", [$inicioMes])
            ->select("COALESCE(SUM(quantidade), 0) as total")
            ->first();

        $mortalidades = DB::table("movimentacao_mortalidade")
            ->whereRaw("data_ocorrencia >= ?", [$inicioMes])
            ->select("COALESCE(SUM(quantidade), 0) as total")
            ->first();

        return [
            "entradas" => (int) $entradas,
            "animais_vendidos" => (int) ($saidas->total ?? 0),
            "animais_perdidos" => (int) ($mortalidades->total ?? 0),
        ];
    }

    /**
     * Quantidade de lotes com status ATIVO — visão rápida do tamanho
     * da operação em confinamento neste momento.
     */
    private function contarLotesAtivos(): int
    {
        return (int) Lote::where("status", "=", "ATIVO")->count();
    }

    private function financeiroResumo(): array
    {
        $inicioMes = date("Y-m-01");
        $fimMes = date("Y-m-t");
        $inicioMesAnterior = date("Y-m-01", strtotime("-1 month"));
        $fimMesAnterior = date("Y-m-t", strtotime("-1 month"));

        $aPagar = ContaPagar::where("status", "=", "PENDENTE")
            ->where("data_vencimento", ">=", $inicioMes)
            ->where("data_vencimento", "<=", $fimMes)
            ->select("COALESCE(SUM(valor), 0) as total", "COUNT(*) as qtd")
            ->first();

        $aReceber = ContaReceber::where("status", "=", "PENDENTE")
            ->where("data_vencimento", ">=", $inicioMes)
            ->where("data_vencimento", "<=", $fimMes)
            ->select("COALESCE(SUM(valor), 0) as total", "COUNT(*) as qtd")
            ->first();

        $aPagarAnterior = ContaPagar::where("status", "=", "PENDENTE")
            ->where("data_vencimento", ">=", $inicioMesAnterior)
            ->where("data_vencimento", "<=", $fimMesAnterior)
            ->select("COALESCE(SUM(valor), 0) as total")
            ->first();

        $aReceberAnterior = ContaReceber::where("status", "=", "PENDENTE")
            ->where("data_vencimento", ">=", $inicioMesAnterior)
            ->where("data_vencimento", "<=", $fimMesAnterior)
            ->select("COALESCE(SUM(valor), 0) as total")
            ->first();

        $totalPagar = (float) ($aPagar->total ?? 0);
        $totalReceber = (float) ($aReceber->total ?? 0);
        $totalPagarAnt = (float) ($aPagarAnterior->total ?? 0);
        $totalReceberAnt = (float) ($aReceberAnterior->total ?? 0);

        $calcVariacao = function ($atual, $anterior): array {
            if ($anterior > 0) {
                $pct = (($atual - $anterior) / $anterior) * 100;
            } else {
                $pct = $atual > 0 ? 100 : 0;
            }
            return [
                "pct" => round($pct, 1),
                "direcao" => $pct > 0 ? "up" : ($pct < 0 ? "down" : "stable"),
            ];
        };

        $meses = ["", "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];

        return [
            "a_pagar" => $totalPagar,
            "a_receber" => $totalReceber,
            "saldo" => $totalReceber - $totalPagar,
            "qtd_pagar" => (int) ($aPagar->qtd ?? 0),
            "qtd_receber" => (int) ($aReceber->qtd ?? 0),
            "variacao_pagar" => $calcVariacao($totalPagar, $totalPagarAnt),
            "variacao_receber" => $calcVariacao($totalReceber, $totalReceberAnt),
            "variacao_saldo" => $calcVariacao($totalReceber - $totalPagar, $totalReceberAnt - $totalPagarAnt),
            "mes" => $meses[(int) date("n")] . " de " . date("Y"),
            "mes_anterior" => $meses[(int) date("n", strtotime("-1 month"))],
        ];
    }
}
