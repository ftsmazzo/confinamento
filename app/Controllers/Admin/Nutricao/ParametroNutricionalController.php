<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Nutricao\ParametroNutricional;

class ParametroNutricionalController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Parâmetros Nutricionais",
            "active_menu" => "nutricao-parametros-nutricionais",
            "page" => [
                "title" => "Parâmetros Nutricionais",
                "desc" => "Cadastre indicadores como matéria seca, proteína bruta, fibra, energia e consumo previsto",
            ],
            "uppers" => implode(",", ParametroNutricional::getUppers()),
            "required" => implode(",", ParametroNutricional::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("parametro_nutricional_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Parâmetros Nutricionais" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = ParametroNutricional::orderBy("nome")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/nutricao/parametro-nutricional/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("parametro_nutricional_inserir"),
                "editar" => $this->auth->allow("parametro_nutricional_editar"),
                "excluir" => $this->auth->allow("parametro_nutricional_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("parametro_nutricional_inserir");
        echo $this->view->render("admin/nutricao/parametro-nutricional/form", [
            "csrf" => $this->csrf->generate(),
            "parametro" => false,
            "url_action" => $this->router->route("admin.nutricao.parametro.nutricional.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("parametro_nutricional_inserir");
        $data = new Data($request->all());

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do parâmetro");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("unidade_medida");
        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        ParametroNutricional::create($payload);
        $this->message->success("Parâmetro cadastrado com sucesso");
        $this->router->redirect("admin.nutricao.parametro.nutricional.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("parametro_nutricional_editar");
        $data = new Data($request->all());
        $parametro = ParametroNutricional::find($data->id) ?: ParametroNutricional::findByMd5($data->id);

        if (!$parametro) {
            $this->message->warning("Parâmetro não encontrado");
            $this->router->redirect("admin.nutricao.parametro.nutricional.index");
        }

        echo $this->view->render("admin/nutricao/parametro-nutricional/form", [
            "csrf" => $this->csrf->generate(),
            "parametro" => $parametro,
            "url_action" => $this->router->route("admin.nutricao.parametro.nutricional.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("parametro_nutricional_editar");
        $data = new Data($request->all());
        $parametro = ParametroNutricional::find($data->id) ?: ParametroNutricional::findByMd5($data->id);

        if (!$parametro) {
            $this->message->warning("Parâmetro não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do parâmetro");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("unidade_medida");
        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        ParametroNutricional::updateBy($parametro->id, $payload);
        $this->message->success("Parâmetro atualizado com sucesso");
        $this->router->redirect("admin.nutricao.parametro.nutricional.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("parametro_nutricional_excluir");
        $data = new Data($request->all());
        $parametro = ParametroNutricional::find($data->id) ?: ParametroNutricional::findByMd5($data->id);

        if (!$parametro) {
            $this->message->warning("Parâmetro não encontrado");
            Redirect::referer();
            return;
        }

        ParametroNutricional::deleteById($parametro->id);
        $this->message->success("Parâmetro removido com sucesso");
        Redirect::referer();
    }
}
