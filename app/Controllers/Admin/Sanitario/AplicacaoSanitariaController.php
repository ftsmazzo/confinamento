<?php

namespace App\Controllers\Admin\Sanitario;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Estoque\LoteEstoque;
use App\Models\Estoque\ProdutoEstoque;
use App\Models\Manejo\Animal;
use App\Models\Manejo\Lote;
use App\Models\Sanitario\AplicacaoSanitaria;
use App\Models\Sanitario\MotivoTratamento;
use App\Models\Sanitario\ProtocoloSanitario;
use App\Models\Sanitario\TipoAplicacao;

class AplicacaoSanitariaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Aplicações Sanitárias",
            "active_menu" => "sanitario-aplicacoes",
            "page" => [
                "title" => "Aplicações Sanitárias",
                "desc" => "Protocolos, tratamentos individuais e tratamentos em lote, com baixa automática de estoque",
            ],
            "uppers" => implode(",", AplicacaoSanitaria::getUppers()),
            "required" => implode(",", AplicacaoSanitaria::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("aplicacao_sanitaria_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $idAnimal = $data->has("id_animal") ? (int) $data->id_animal : null;

        $lote = $idLote ? Lote::find($idLote) : null;
        $animal = $idAnimal ? Animal::find($idAnimal) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Sanitário" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Aplicações Sanitárias de " . $lote->nome] = ["url" => false, "current" => true];
        } elseif ($animal) {
            $breadcrumb["Animais"] = ["url" => $this->router->route("admin.manejo.animal.index"), "current" => false];
            $breadcrumb["Aplicações Sanitárias de " . $animal->identificacao] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Aplicações Sanitárias"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = AplicacaoSanitaria::leftJoin("lote as l", "aps.id_lote", "=", "l.id")
            ->leftJoin("animal as a", "aps.id_animal", "=", "a.id")
            ->leftJoin("protocolo_sanitario as ps", "aps.id_protocolo_sanitario", "=", "ps.id")
            ->leftJoin("produto_estoque as pe", "aps.id_produto_estoque", "=", "pe.id")
            ->select(
                "aps.*",
                "l.nome as lote_nome",
                "l.codigo as lote_codigo",
                "a.identificacao as animal_identificacao",
                "ps.nome as protocolo_nome",
                "pe.nome as produto_nome",
                "pe.unidade_medida"
            );

        if ($idLote) {
            $query = $query->where("aps.id_lote", "=", $idLote);
        } elseif ($idAnimal) {
            $query = $query->where("aps.id_animal", "=", $idAnimal);
        }

        $dados = $query->orderBy("aps.data_aplicacao", "desc")->get();

        $hoje = date("Y-m-d");
        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome
                ? $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "")
                : ($item->animal_identificacao ?: "-");
            $item->tipo_label = AplicacaoSanitaria::tipoLabel($item->tipo);
            $item->em_carencia = !empty($item->data_carencia_fim) && $item->data_carencia_fim >= $hoje;
        }

        echo $this->view->render("admin/sanitario/aplicacao-sanitaria/index", [
            "dados" => $dados,
            "lote" => $lote,
            "animal" => $animal,
            "permissao" => [
                "inserir" => $this->auth->allow("aplicacao_sanitaria_inserir"),
                "editar" => $this->auth->allow("aplicacao_sanitaria_editar"),
                "excluir" => $this->auth->allow("aplicacao_sanitaria_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("aplicacao_sanitaria_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $idAnimal = $data->has("id_animal") ? (int) $data->id_animal : null;

        echo $this->view->render("admin/sanitario/aplicacao-sanitaria/form", [
            "csrf" => $this->csrf->generate(),
            "aplicacao" => false,
            "id_lote" => $idLote,
            "id_animal" => $idAnimal,
            "lotes" => $this->lotes(),
            "animais" => $this->animais(),
            "protocolos" => $this->protocolos(),
            "produtos" => $this->produtos(),
            "tiposAplicacao" => $this->tiposAplicacao(),
            "motivosTratamento" => $this->motivosTratamento(),
            "url_action" => $this->router->route("admin.sanitario.aplicacao.insert"),
            "url_voltar" => $this->urlVoltar($idLote, $idAnimal),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("aplicacao_sanitaria_inserir");
        $data = new Data($request->all());

        $validacao = $this->validarVinculoEDados($data);
        if ($validacao !== null) {
            $this->message->warning($validacao);
            Redirect::referer();
            return;
        }

        $produto = null;
        if ($data->has("id_produto_estoque")) {
            $produto = ProdutoEstoque::find((int) $data->id_produto_estoque);

            if (!$produto) {
                $this->message->warning("Produto não encontrado");
                Redirect::referer();
                return;
            }

            if ((int) $produto->controla_lote === 1 && !$data->has("id_lote_estoque")) {
                $this->message->warning("Este produto exige a informação do lote de estoque");
                Redirect::referer();
                return;
            }
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        $aplicacao = AplicacaoSanitaria::create($payload);

        if ($produto && !empty($payload["quantidade_produto"])) {
            $this->baixarEstoque($produto, (float) $payload["quantidade_produto"], $payload["id_lote_estoque"] ?? null);
        }

        $this->message->success("Aplicação registrada" . ($produto ? " e estoque baixado" : "") . " com sucesso");
        $this->router->redirect("admin.sanitario.aplicacao.index", array_filter([
            "id_lote" => $payload["id_lote"] ?? null,
            "id_animal" => $payload["id_animal"] ?? null,
        ]));
    }

    public function edit(Request $request): void
    {
        $this->authorize("aplicacao_sanitaria_editar");
        $data = new Data($request->all());
        $aplicacao = AplicacaoSanitaria::find($data->id) ?: AplicacaoSanitaria::findByMd5($data->id);

        if (!$aplicacao) {
            $this->message->warning("Aplicação não encontrada");
            $this->router->redirect("admin.sanitario.aplicacao.index");
            return;
        }

        $tipoAplicacao = !empty($aplicacao->id_tipo_aplicacao) ? TipoAplicacao::find((int) $aplicacao->id_tipo_aplicacao) : null;
        $motivoTratamento = !empty($aplicacao->id_motivo_tratamento) ? MotivoTratamento::find((int) $aplicacao->id_motivo_tratamento) : null;

        echo $this->view->render("admin/sanitario/aplicacao-sanitaria/visualizar", [
            "csrf" => $this->csrf->generate(),
            "aplicacao" => $aplicacao,
            "tipo_label" => AplicacaoSanitaria::tipoLabel($aplicacao->tipo),
            "tipo_aplicacao_descricao" => $tipoAplicacao->descricao ?? null,
            "motivo_tratamento_descricao" => $motivoTratamento->descricao ?? null,
        ]);
    }

    /**
     * Aplicacao ja baixou estoque e calculou carencia; edicao livre
     * poderia descontrolar o saldo e a carencia vigente. Por ora, so
     * permite editar observacao -- para corrigir, excluir (estorna) e
     * recriar.
     */
    public function update(Request $request): void
    {
        $this->authorize("aplicacao_sanitaria_editar");
        $data = new Data($request->all());
        $aplicacao = AplicacaoSanitaria::find($data->id) ?: AplicacaoSanitaria::findByMd5($data->id);

        if (!$aplicacao) {
            $this->message->warning("Aplicação não encontrada");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("observacao");

        AplicacaoSanitaria::updateBy($aplicacao->id, [
            "observacao" => $data->observacao ?? null,
            "updated_by" => $this->user->uid,
        ]);

        $this->message->success("Observação atualizada com sucesso");
        $this->router->redirect("admin.sanitario.aplicacao.index", array_filter([
            "id_lote" => $aplicacao->id_lote,
            "id_animal" => $aplicacao->id_animal,
        ]));
    }

    /**
     * Exclui a aplicacao e ESTORNA o estoque baixado (se houver) antes
     * de apagar.
     */
    public function delete(Request $request): void
    {
        $this->authorize("aplicacao_sanitaria_excluir");
        $data = new Data($request->all());
        $aplicacao = AplicacaoSanitaria::find($data->id) ?: AplicacaoSanitaria::findByMd5($data->id);

        if (!$aplicacao) {
            $this->message->warning("Aplicação não encontrada");
            Redirect::referer();
            return;
        }

        if (!empty($aplicacao->id_produto_estoque) && !empty($aplicacao->quantidade_produto)) {
            $produto = ProdutoEstoque::find((int) $aplicacao->id_produto_estoque);
            if ($produto) {
                $this->estornarEstoque($produto, (float) $aplicacao->quantidade_produto, $aplicacao->id_lote_estoque);
            }
        }

        $idLote = $aplicacao->id_lote;
        $idAnimal = $aplicacao->id_animal;

        AplicacaoSanitaria::deleteById($aplicacao->id);

        $this->message->success("Aplicação removida e estoque estornado com sucesso");
        $this->router->redirect("admin.sanitario.aplicacao.index", array_filter([
            "id_lote" => $idLote,
            "id_animal" => $idAnimal,
        ]));
    }

    private function baixarEstoque(ProdutoEstoque $produto, float $quantidade, $idLoteEstoque = null): void
    {
        ProdutoEstoque::updateBy($produto->id, [
            "saldo_atual" => (float) $produto->saldo_atual - $quantidade,
        ]);

        if (!empty($idLoteEstoque)) {
            $lote = LoteEstoque::find((int) $idLoteEstoque);
            if ($lote) {
                LoteEstoque::updateBy($lote->id, [
                    "quantidade_atual" => (float) $lote->quantidade_atual - $quantidade,
                ]);
            }
        }
    }

    private function estornarEstoque(ProdutoEstoque $produto, float $quantidade, $idLoteEstoque = null): void
    {
        ProdutoEstoque::updateBy($produto->id, [
            "saldo_atual" => (float) $produto->saldo_atual + $quantidade,
        ]);

        if (!empty($idLoteEstoque)) {
            $lote = LoteEstoque::find((int) $idLoteEstoque);
            if ($lote) {
                LoteEstoque::updateBy($lote->id, [
                    "quantidade_atual" => (float) $lote->quantidade_atual + $quantidade,
                ]);
            }
        }
    }

    /**
     * Garante que exatamente um vinculo (lote OU animal) foi informado,
     * que o tipo/data estao presentes, e que tipo bate com o vinculo
     * (TRATAMENTO_INDIVIDUAL exige animal, TRATAMENTO_LOTE exige lote).
     */
    private function validarVinculoEDados(Data $data): ?string
    {
        $temLote = $data->has("id_lote");
        $temAnimal = $data->has("id_animal");

        if ($temLote === $temAnimal) {
            return "Selecione um lote OU um animal para a aplicação, nunca os dois nem nenhum.";
        }

        if (!$data->has("tipo") || !$data->has("data_aplicacao")) {
            return "Informe o tipo e a data da aplicação.";
        }

        if ($data->tipo === "TRATAMENTO_INDIVIDUAL" && !$temAnimal) {
            return "Tratamento individual exige um animal selecionado.";
        }

        if ($data->tipo === "TRATAMENTO_LOTE" && !$temLote) {
            return "Tratamento em lote exige um lote selecionado.";
        }

        return null;
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_lote");
        $data->nullIfEmpty("id_animal");
        $data->nullIfEmpty("id_protocolo_sanitario");
        $data->nullIfEmpty("id_produto_estoque");
        $data->nullIfEmpty("id_lote_estoque");
        $data->nullIfEmpty("id_tipo_aplicacao");
        $data->nullIfEmpty("id_motivo_tratamento");
        $data->nullIfEmpty("quantidade_animais");
        $data->nullIfEmpty("quantidade_produto");
        $data->nullIfEmpty("dias_carencia");
        $data->nullIfEmpty("veterinario_responsavel");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        if (!empty($payload["quantidade_produto"])) {
            $payload["quantidade_produto"] = money2float((string) $payload["quantidade_produto"]);
        }

        // Se o protocolo foi selecionado e a carencia nao foi
        // sobrescrita manualmente, herda a carencia padrao do protocolo.
        if (empty($payload["dias_carencia"]) && !empty($payload["id_protocolo_sanitario"])) {
            $protocolo = ProtocoloSanitario::find((int) $payload["id_protocolo_sanitario"]);
            if ($protocolo && $protocolo->dias_carencia_padrao !== null) {
                $payload["dias_carencia"] = (int) $protocolo->dias_carencia_padrao;
            }
        }

        $payload["data_carencia_fim"] = null;
        if (!empty($payload["dias_carencia"]) && !empty($payload["data_aplicacao"])) {
            $intervalo = " +" . (int) $payload["dias_carencia"] . " days";
            $payload["data_carencia_fim"] = date("Y-m-d", strtotime($payload["data_aplicacao"] . $intervalo));
        }

        return $payload;
    }

    private function urlVoltar(?int $idLote, ?int $idAnimal): string
    {
        if ($idLote) {
            return $this->router->route("admin.sanitario.aplicacao.index", ["id_lote" => $idLote]);
        }

        if ($idAnimal) {
            return $this->router->route("admin.sanitario.aplicacao.index", ["id_animal" => $idAnimal]);
        }

        return $this->router->route("admin.sanitario.aplicacao.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function animais(): array
    {
        return Animal::orderBy("identificacao")->get();
    }

    private function protocolos(): array
    {
        return ProtocoloSanitario::orderBy("nome")->get();
    }

    private function produtos(): array
    {
        return ProdutoEstoque::whereIn("tipo_produto", ProdutoEstoque::TIPOS_SANITARIOS)
            ->orderBy("nome")
            ->get();
    }

    private function tiposAplicacao(): array
    {
        return TipoAplicacao::orderBy("descricao")->get();
    }

    private function motivosTratamento(): array
    {
        return MotivoTratamento::orderBy("descricao")->get();
    }
}
