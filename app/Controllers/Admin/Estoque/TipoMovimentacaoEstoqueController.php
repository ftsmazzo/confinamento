<?php

namespace App\Controllers\Admin\Estoque;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Estoque\TipoMovimentacaoEstoque;

class TipoMovimentacaoEstoqueController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Tipos de Movimentação de Estoque",
            "active_menu" => "estoque-tipos-movimentacao",
            "page" => [
                "title" => "Tipos de Movimentação de Estoque",
                "desc" => "Padronize as operações: entrada, saída, ajuste, transferência, perda, inventário",
            ],
            "uppers" => implode(",", TipoMovimentacaoEstoque::getUppers()),
            "required" => implode(",", TipoMovimentacaoEstoque::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("tipo_movimentacao_estoque_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Estoque" => ["url" => false, "current" => false],
                "Tipos de Movimentação" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = TipoMovimentacaoEstoque::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/estoque/tipo-movimentacao-estoque/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("tipo_movimentacao_estoque_inserir"),
                "editar" => $this->auth->allow("tipo_movimentacao_estoque_editar"),
                "excluir" => $this->auth->allow("tipo_movimentacao_estoque_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("tipo_movimentacao_estoque_inserir");

        echo $this->view->render("admin/estoque/tipo-movimentacao-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "tipo" => false,
            "url_action" => $this->router->route("admin.estoque.tipo.movimentacao.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("tipo_movimentacao_estoque_inserir");

        $data = new Data($request->all());

        if (!$data->has("descricao") || !$data->has("natureza")) {
            $this->message->warning("Informe a descrição e a natureza do tipo de movimentação");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        TipoMovimentacaoEstoque::create($payload);

        $this->message->success("Tipo de movimentação cadastrado com sucesso");
        $this->router->redirect("admin.estoque.tipo.movimentacao.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("tipo_movimentacao_estoque_editar");

        $data = new Data($request->all());
        $tipo = TipoMovimentacaoEstoque::find($data->id) ?: TipoMovimentacaoEstoque::findByMd5($data->id);

        if (!$tipo) {
            $this->message->warning("Tipo de movimentação não encontrado");
            $this->router->redirect("admin.estoque.tipo.movimentacao.index");
            return;
        }

        echo $this->view->render("admin/estoque/tipo-movimentacao-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "tipo" => $tipo,
            "url_action" => $this->router->route("admin.estoque.tipo.movimentacao.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("tipo_movimentacao_estoque_editar");

        $data = new Data($request->all());
        $tipo = TipoMovimentacaoEstoque::find($data->id) ?: TipoMovimentacaoEstoque::findByMd5($data->id);

        if (!$tipo) {
            $this->message->warning("Tipo de movimentação não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao") || !$data->has("natureza")) {
            $this->message->warning("Informe a descrição e a natureza do tipo de movimentação");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        TipoMovimentacaoEstoque::updateBy($tipo->id, $payload);

        $this->message->success("Tipo de movimentação atualizado com sucesso");
        $this->router->redirect("admin.estoque.tipo.movimentacao.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("tipo_movimentacao_estoque_excluir");

        $data = new Data($request->all());
        $tipo = TipoMovimentacaoEstoque::find($data->id) ?: TipoMovimentacaoEstoque::findByMd5($data->id);

        if (!$tipo) {
            $this->message->warning("Tipo de movimentação não encontrado");
            Redirect::referer();
            return;
        }

        TipoMovimentacaoEstoque::deleteById($tipo->id);

        $this->message->success("Tipo de movimentação removido com sucesso");
        Redirect::referer();
    }
}
