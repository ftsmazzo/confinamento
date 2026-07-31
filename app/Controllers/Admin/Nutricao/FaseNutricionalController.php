<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Nutricao\FaseNutricional;

class FaseNutricionalController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Fases Nutricionais",
            "active_menu" => "nutricao-fases-nutricionais",
            "page" => [
                "title" => "Fases Nutricionais",
                "desc" => "Cadastre as fases: adaptação, crescimento, terminação e dietas especiais",
            ],
            "uppers" => implode(",", FaseNutricional::getUppers()),
            "required" => implode(",", FaseNutricional::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("fase_nutricional_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Fases Nutricionais" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = FaseNutricional::orderBy("ordem")->orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/nutricao/fase-nutricional/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("fase_nutricional_inserir"),
                "editar" => $this->auth->allow("fase_nutricional_editar"),
                "excluir" => $this->auth->allow("fase_nutricional_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("fase_nutricional_inserir");
        echo $this->view->render("admin/nutricao/fase-nutricional/form", [
            "csrf" => $this->csrf->generate(),
            "fase" => false,
            "url_action" => $this->router->route("admin.nutricao.fase.nutricional.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("fase_nutricional_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição da fase");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("ordem");
        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ordem"] = isset($payload["ordem"]) ? (int) $payload["ordem"] : 0;
        $payload["created_by"] = $this->user->uid;

        FaseNutricional::create($payload);
        $this->message->success("Fase cadastrada com sucesso");
        $this->router->redirect("admin.nutricao.fase.nutricional.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("fase_nutricional_editar");
        $data = new Data($request->all());
        $fase = FaseNutricional::find($data->id) ?: FaseNutricional::findByMd5($data->id);

        if (!$fase) {
            $this->message->warning("Fase não encontrada");
            $this->router->redirect("admin.nutricao.fase.nutricional.index");
        }

        echo $this->view->render("admin/nutricao/fase-nutricional/form", [
            "csrf" => $this->csrf->generate(),
            "fase" => $fase,
            "url_action" => $this->router->route("admin.nutricao.fase.nutricional.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("fase_nutricional_editar");
        $data = new Data($request->all());
        $fase = FaseNutricional::find($data->id) ?: FaseNutricional::findByMd5($data->id);

        if (!$fase) {
            $this->message->warning("Fase não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição da fase");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("ordem");
        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ordem"] = isset($payload["ordem"]) ? (int) $payload["ordem"] : 0;
        $payload["updated_by"] = $this->user->uid;

        FaseNutricional::updateBy($fase->id, $payload);
        $this->message->success("Fase atualizada com sucesso");
        $this->router->redirect("admin.nutricao.fase.nutricional.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("fase_nutricional_excluir");
        $data = new Data($request->all());
        $fase = FaseNutricional::find($data->id) ?: FaseNutricional::findByMd5($data->id);

        if (!$fase) {
            $this->message->warning("Fase não encontrada");
            Redirect::referer();
            return;
        }

        FaseNutricional::deleteById($fase->id);
        $this->message->success("Fase removida com sucesso");
        Redirect::referer();
    }
}
