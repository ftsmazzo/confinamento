<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Nutricao\GrupoIngrediente;

class GrupoIngredienteController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Grupos de Ingredientes",
            "active_menu" => "nutricao-grupos-ingrediente",
            "page" => [
                "title" => "Grupos de Ingredientes",
                "desc" => "Classifique os ingredientes por grupo nutricional",
            ],
            "uppers" => implode(",", GrupoIngrediente::getUppers()),
            "required" => implode(",", GrupoIngrediente::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("grupo_ingrediente_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Grupos de Ingredientes" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = GrupoIngrediente::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/nutricao/grupo-ingrediente/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("grupo_ingrediente_inserir"),
                "editar" => $this->auth->allow("grupo_ingrediente_editar"),
                "excluir" => $this->auth->allow("grupo_ingrediente_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("grupo_ingrediente_inserir");
        echo $this->view->render("admin/nutricao/grupo-ingrediente/form", [
            "csrf" => $this->csrf->generate(),
            "grupo" => false,
            "url_action" => $this->router->route("admin.nutricao.grupo.ingrediente.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("grupo_ingrediente_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do grupo");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        GrupoIngrediente::create($payload);
        $this->message->success("Grupo cadastrado com sucesso");
        $this->router->redirect("admin.nutricao.grupo.ingrediente.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("grupo_ingrediente_editar");
        $data = new Data($request->all());
        $grupo = GrupoIngrediente::find($data->id) ?: GrupoIngrediente::findByMd5($data->id);

        if (!$grupo) {
            $this->message->warning("Grupo não encontrado");
            $this->router->redirect("admin.nutricao.grupo.ingrediente.index");
        }

        echo $this->view->render("admin/nutricao/grupo-ingrediente/form", [
            "csrf" => $this->csrf->generate(),
            "grupo" => $grupo,
            "url_action" => $this->router->route("admin.nutricao.grupo.ingrediente.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("grupo_ingrediente_editar");
        $data = new Data($request->all());
        $grupo = GrupoIngrediente::find($data->id) ?: GrupoIngrediente::findByMd5($data->id);

        if (!$grupo) {
            $this->message->warning("Grupo não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do grupo");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        GrupoIngrediente::updateBy($grupo->id, $payload);
        $this->message->success("Grupo atualizado com sucesso");
        $this->router->redirect("admin.nutricao.grupo.ingrediente.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("grupo_ingrediente_excluir");
        $data = new Data($request->all());
        $grupo = GrupoIngrediente::find($data->id) ?: GrupoIngrediente::findByMd5($data->id);

        if (!$grupo) {
            $this->message->warning("Grupo não encontrado");
            Redirect::referer();
            return;
        }

        GrupoIngrediente::deleteById($grupo->id);
        $this->message->success("Grupo removido com sucesso");
        Redirect::referer();
    }
}
