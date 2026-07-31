<?php

namespace App\Controllers\Admin\Estoque;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\CentroCusto;
use App\Models\Estoque\LocalArmazenagemInterno;
use App\Models\Estoque\LoteEstoque;
use App\Models\Estoque\MovimentacaoEstoque;
use App\Models\Estoque\ProdutoEstoque;
use App\Models\Estoque\TipoMovimentacaoEstoque;
use App\Models\Fornecedor;

class MovimentacaoEstoqueController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Movimentações de Estoque",
            "active_menu" => "estoque-movimentacoes",
            "page" => [
                "title" => "Movimentações de Estoque",
                "desc" => "Entradas, saídas, ajustes, transferências, perdas e inventário",
            ],
            "required" => implode(",", MovimentacaoEstoque::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("movimentacao_estoque_gerenciar");

        $data = new Data($request->all());
        $idProduto = $data->has("id_produto") ? (int) $data->id_produto : null;
        $produto = $idProduto ? ProdutoEstoque::find($idProduto) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Estoque" => ["url" => false, "current" => false],
        ];

        if ($produto) {
            $breadcrumb["Produtos"] = [
                "url" => $this->router->route("admin.estoque.produto.index"),
                "current" => false,
            ];
            $breadcrumb["Movimentações de " . $produto->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Movimentações de Estoque"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = MovimentacaoEstoque::leftJoin("produto_estoque as pe", "me.id_produto_estoque", "=", "pe.id")
            ->leftJoin("tipo_movimentacao_estoque as tme", "me.id_tipo_movimentacao_estoque", "=", "tme.id")
            ->leftJoin("lote_estoque as le", "me.id_lote_estoque", "=", "le.id")
            ->select(
                "me.*",
                "pe.nome as produto_nome",
                "pe.unidade_medida",
                "tme.descricao as tipo_descricao",
                "tme.natureza",
                "le.codigo_lote"
            );

        if ($idProduto) {
            $query = $query->where("me.id_produto_estoque", "=", $idProduto);
        }

        $dados = $query->orderBy("me.data_movimentacao", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/estoque/movimentacao-estoque/index", [
            "dados" => $dados,
            "produto" => $produto,
            "permissao" => [
                "inserir" => $this->auth->allow("movimentacao_estoque_inserir"),
                "editar" => $this->auth->allow("movimentacao_estoque_editar"),
                "excluir" => $this->auth->allow("movimentacao_estoque_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("movimentacao_estoque_inserir");

        $data = new Data($request->all());
        $idProduto = $data->has("id_produto") ? (int) $data->id_produto : null;

        echo $this->view->render("admin/estoque/movimentacao-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "movimentacao" => false,
            "id_produto" => $idProduto,
            "produtos" => $this->produtos(),
            "tipos" => $this->tipos(),
            "lotes" => $this->lotes($idProduto),
            "locaisInternos" => $this->locaisInternos(),
            "centrosCusto" => $this->centrosCusto(),
            "fornecedores" => $this->fornecedores(),
            "url_action" => $this->router->route("admin.estoque.movimentacao.insert"),
            "url_voltar" => $this->urlVoltar($idProduto),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("movimentacao_estoque_inserir");

        $data = new Data($request->all());

        $camposObrigatorios = !$data->has("id_produto_estoque")
            || !$data->has("id_tipo_movimentacao_estoque")
            || !$data->has("data_movimentacao")
            || !$data->has("quantidade");

        if ($camposObrigatorios) {
            $this->message->warning("Selecione o produto, o tipo, a data e informe a quantidade");
            Redirect::referer();
            return;
        }

        $tipo = TipoMovimentacaoEstoque::find((int) $data->id_tipo_movimentacao_estoque);

        if (!$tipo) {
            $this->message->warning("Tipo de movimentação inválido");
            Redirect::referer();
            return;
        }

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

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        $movimentacao = MovimentacaoEstoque::create($payload);

        $this->aplicarSaldo($produto, $tipo, (float) $payload["quantidade"], $payload["id_lote_estoque"] ?? null);

        $this->message->success("Movimentação registrada e saldo atualizado com sucesso");
        $this->router->redirect("admin.estoque.movimentacao.index", ["id_produto" => $produto->id]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("movimentacao_estoque_editar");

        $data = new Data($request->all());
        $movimentacao = MovimentacaoEstoque::find($data->id) ?: MovimentacaoEstoque::findByMd5($data->id);

        if (!$movimentacao) {
            $this->message->warning("Movimentação não encontrada");
            $this->router->redirect("admin.estoque.movimentacao.index");
            return;
        }

        echo $this->view->render("admin/estoque/movimentacao-estoque/visualizar", [
            "csrf" => $this->csrf->generate(),
            "movimentacao" => $movimentacao,
        ]);
    }

    /**
     * Movimentacao ja aplicou o saldo; edicao livre poderia descontrolar
     * o estoque. Por ora, so permite editar observacao/motivo -- para
     * corrigir quantidade/tipo, o caminho e excluir (estorna) e recriar.
     */
    public function update(Request $request): void
    {
        $this->authorize("movimentacao_estoque_editar");

        $data = new Data($request->all());
        $movimentacao = MovimentacaoEstoque::find($data->id) ?: MovimentacaoEstoque::findByMd5($data->id);

        if (!$movimentacao) {
            $this->message->warning("Movimentação não encontrada");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("motivo");
        $data->nullIfEmpty("observacao");

        MovimentacaoEstoque::updateBy($movimentacao->id, [
            "motivo" => $data->motivo ?? null,
            "observacao" => $data->observacao ?? null,
            "updated_by" => $this->user->uid,
        ]);

        $this->message->success("Movimentação atualizada com sucesso");
        $this->router->redirect("admin.estoque.movimentacao.index", [
            "id_produto" => $movimentacao->id_produto_estoque,
        ]);
    }

    /**
     * Exclui a movimentacao e ESTORNA o saldo (aplica o efeito
     * inverso da natureza original) antes de apagar.
     */
    public function delete(Request $request): void
    {
        $this->authorize("movimentacao_estoque_excluir");

        $data = new Data($request->all());
        $movimentacao = MovimentacaoEstoque::find($data->id) ?: MovimentacaoEstoque::findByMd5($data->id);

        if (!$movimentacao) {
            $this->message->warning("Movimentação não encontrada");
            Redirect::referer();
            return;
        }

        $produto = ProdutoEstoque::find((int) $movimentacao->id_produto_estoque);
        $tipo = TipoMovimentacaoEstoque::find((int) $movimentacao->id_tipo_movimentacao_estoque);

        if ($produto && $tipo) {
            $tipoInvertido = (object) ["natureza" => $tipo->natureza === "ENTRADA" ? "SAIDA" : "ENTRADA"];
            $this->aplicarSaldo(
                $produto,
                $tipoInvertido,
                (float) $movimentacao->quantidade,
                $movimentacao->id_lote_estoque
            );
        }

        $idProduto = (int) $movimentacao->id_produto_estoque;
        MovimentacaoEstoque::deleteById($movimentacao->id);

        $this->message->success("Movimentação removida e saldo estornado com sucesso");
        $this->router->redirect("admin.estoque.movimentacao.index", ["id_produto" => $idProduto]);
    }

    private function aplicarSaldo(ProdutoEstoque $produto, object $tipo, float $quantidade, $idLoteEstoque = null): void
    {
        $sinal = $tipo->natureza === "ENTRADA" ? 1 : -1;
        $delta = $sinal * $quantidade;

        ProdutoEstoque::updateBy($produto->id, [
            "saldo_atual" => (float) $produto->saldo_atual + $delta,
        ]);

        if (!empty($idLoteEstoque)) {
            $lote = LoteEstoque::find((int) $idLoteEstoque);
            if ($lote) {
                LoteEstoque::updateBy($lote->id, [
                    "quantidade_atual" => (float) $lote->quantidade_atual + $delta,
                ]);
            }
        }
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_lote_estoque");
        $data->nullIfEmpty("id_local_armazenagem_interno_origem");
        $data->nullIfEmpty("id_local_armazenagem_interno_destino");
        $data->nullIfEmpty("id_centro_custo");
        $data->nullIfEmpty("id_fornecedor");
        $data->nullIfEmpty("id_operador");
        $data->nullIfEmpty("motivo");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        $payload["id_operador"] = $payload["id_operador"] ?? $this->user->uid;

        $payload["quantidade"] = (float) money2float((string) ($payload["quantidade"] ?? 0));

        return $payload;
    }

    private function urlVoltar(?int $idProduto): string
    {
        return $idProduto
            ? $this->router->route("admin.estoque.movimentacao.index", ["id_produto" => $idProduto])
            : $this->router->route("admin.estoque.movimentacao.index");
    }

    private function produtos(): array
    {
        return ProdutoEstoque::orderBy("nome")->get();
    }

    private function tipos(): array
    {
        return TipoMovimentacaoEstoque::orderBy("descricao")->get();
    }

    private function lotes(?int $idProduto): array
    {
        if (!$idProduto) {
            return [];
        }

        return LoteEstoque::where("id_produto_estoque", "=", $idProduto)
            ->orderBy("data_validade")
            ->get();
    }

    private function locaisInternos(): array
    {
        return LocalArmazenagemInterno::orderBy("nome")->get();
    }

    private function centrosCusto(): array
    {
        return CentroCusto::orderBy("nome")->get();
    }

    private function fornecedores(): array
    {
        return Fornecedor::orderBy("razao")->get();
    }
}
