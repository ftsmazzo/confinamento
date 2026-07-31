<?php

namespace App\Controllers\Admin\Estoque;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Estoque\LoteEstoque;
use App\Models\Estoque\ProdutoEstoque;

class LoteEstoqueController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Lotes de Estoque",
            "active_menu" => "estoque-lotes",
            "page" => [
                "title" => "Lotes de Estoque",
                "desc" => "Controle por lote de compra, validade ou rastreabilidade",
            ],
            "uppers" => implode(",", LoteEstoque::getUppers()),
            "required" => implode(",", LoteEstoque::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("produto_estoque_gerenciar");

        $data = new Data($request->all());
        $idProduto = $data->has("id_produto") ? (int) $data->id_produto : null;
        $produto = $idProduto ? ProdutoEstoque::find($idProduto) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Estoque" => ["url" => false, "current" => false],
        ];

        if ($produto) {
            $breadcrumb["Produtos"] = ["url" => $this->router->route("admin.estoque.produto.index"), "current" => false];
            $breadcrumb["Lotes de " . $produto->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Lotes de Estoque"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = LoteEstoque::leftJoin("produto_estoque as pe", "le.id_produto_estoque", "=", "pe.id")
            ->select("le.*", "pe.nome as produto_nome", "pe.unidade_medida");

        if ($idProduto) {
            $query = $query->where("le.id_produto_estoque", "=", $idProduto);
        }

        $dados = $query->orderBy("le.data_validade")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/estoque/lote-estoque/index", [
            "dados" => $dados,
            "produto" => $produto,
            "permissao" => [
                "inserir" => $this->auth->allow("produto_estoque_inserir"),
                "editar" => $this->auth->allow("produto_estoque_editar"),
                "excluir" => $this->auth->allow("produto_estoque_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("produto_estoque_inserir");

        $data = new Data($request->all());
        $idProduto = $data->has("id_produto") ? (int) $data->id_produto : null;

        echo $this->view->render("admin/estoque/lote-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "lote" => false,
            "id_produto" => $idProduto,
            "produtos" => $this->produtos(),
            "url_action" => $this->router->route("admin.estoque.lote.insert"),
            "url_voltar" => $this->urlVoltar($idProduto),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("produto_estoque_inserir");

        $data = new Data($request->all());

        if (!$data->has("id_produto_estoque") || !$data->has("codigo_lote")) {
            $this->message->warning("Selecione o produto e informe o código do lote");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        LoteEstoque::create($payload);

        $this->message->success("Lote de estoque cadastrado com sucesso");
        $this->router->redirect("admin.estoque.lote.index", ["id_produto" => $payload["id_produto_estoque"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("produto_estoque_editar");

        $data = new Data($request->all());
        $lote = LoteEstoque::find($data->id) ?: LoteEstoque::findByMd5($data->id);

        if (!$lote) {
            $this->message->warning("Lote de estoque não encontrado");
            $this->router->redirect("admin.estoque.lote.index");
            return;
        }

        echo $this->view->render("admin/estoque/lote-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "lote" => $lote,
            "id_produto" => (int) $lote->id_produto_estoque,
            "produtos" => $this->produtos(),
            "url_action" => $this->router->route("admin.estoque.lote.update"),
            "url_voltar" => $this->urlVoltar((int) $lote->id_produto_estoque),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("produto_estoque_editar");

        $data = new Data($request->all());
        $lote = LoteEstoque::find($data->id) ?: LoteEstoque::findByMd5($data->id);

        if (!$lote) {
            $this->message->warning("Lote de estoque não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_produto_estoque") || !$data->has("codigo_lote")) {
            $this->message->warning("Selecione o produto e informe o código do lote");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        LoteEstoque::updateBy($lote->id, $payload);

        $this->message->success("Lote de estoque atualizado com sucesso");
        $this->router->redirect("admin.estoque.lote.index", ["id_produto" => $payload["id_produto_estoque"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("produto_estoque_excluir");

        $data = new Data($request->all());
        $lote = LoteEstoque::find($data->id) ?: LoteEstoque::findByMd5($data->id);

        if (!$lote) {
            $this->message->warning("Lote de estoque não encontrado");
            Redirect::referer();
            return;
        }

        LoteEstoque::deleteById($lote->id);

        $this->message->success("Lote de estoque removido com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("data_validade");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        $payload["quantidade_atual"] = isset($payload["quantidade_atual"]) && $payload["quantidade_atual"] !== ""
            ? (float) str_replace(",", ".", str_replace(".", "", (string) $payload["quantidade_atual"]))
            : 0;

        return $payload;
    }

    private function urlVoltar(?int $idProduto): string
    {
        return $idProduto
            ? $this->router->route("admin.estoque.lote.index", ["id_produto" => $idProduto])
            : $this->router->route("admin.estoque.lote.index");
    }

    private function produtos(): array
    {
        return ProdutoEstoque::orderBy("nome")->get();
    }
}
