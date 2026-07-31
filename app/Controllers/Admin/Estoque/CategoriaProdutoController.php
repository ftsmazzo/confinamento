<?php

namespace App\Controllers\Admin\Estoque;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Estoque\CategoriaProduto;

class CategoriaProdutoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Categorias de Produto",
            "active_menu" => "estoque-categorias-produto",
            "page" => [
                "title" => "Categorias de Produto",
                "desc" => "Classifique os produtos por família: nutrição, sanitário, manutenção, combustível, uso geral",
            ],
            "uppers" => implode(",", CategoriaProduto::getUppers()),
            "required" => implode(",", CategoriaProduto::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("categoria_produto_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Estoque" => ["url" => false, "current" => false],
                "Categorias de Produto" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = CategoriaProduto::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/estoque/categoria-produto/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("categoria_produto_inserir"),
                "editar" => $this->auth->allow("categoria_produto_editar"),
                "excluir" => $this->auth->allow("categoria_produto_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("categoria_produto_inserir");

        echo $this->view->render("admin/estoque/categoria-produto/form", [
            "csrf" => $this->csrf->generate(),
            "categoria" => false,
            "url_action" => $this->router->route("admin.estoque.categoria.produto.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("categoria_produto_inserir");

        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição da categoria");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        CategoriaProduto::create($payload);

        $this->message->success("Categoria cadastrada com sucesso");
        $this->router->redirect("admin.estoque.categoria.produto.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("categoria_produto_editar");

        $data = new Data($request->all());
        $categoria = CategoriaProduto::find($data->id) ?: CategoriaProduto::findByMd5($data->id);

        if (!$categoria) {
            $this->message->warning("Categoria não encontrada");
            $this->router->redirect("admin.estoque.categoria.produto.index");
            return;
        }

        echo $this->view->render("admin/estoque/categoria-produto/form", [
            "csrf" => $this->csrf->generate(),
            "categoria" => $categoria,
            "url_action" => $this->router->route("admin.estoque.categoria.produto.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("categoria_produto_editar");

        $data = new Data($request->all());
        $categoria = CategoriaProduto::find($data->id) ?: CategoriaProduto::findByMd5($data->id);

        if (!$categoria) {
            $this->message->warning("Categoria não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição da categoria");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        CategoriaProduto::updateBy($categoria->id, $payload);

        $this->message->success("Categoria atualizada com sucesso");
        $this->router->redirect("admin.estoque.categoria.produto.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("categoria_produto_excluir");

        $data = new Data($request->all());
        $categoria = CategoriaProduto::find($data->id) ?: CategoriaProduto::findByMd5($data->id);

        if (!$categoria) {
            $this->message->warning("Categoria não encontrada");
            Redirect::referer();
            return;
        }

        CategoriaProduto::deleteById($categoria->id);

        $this->message->success("Categoria removida com sucesso");
        Redirect::referer();
    }
}
