<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Nutricao\TipoDieta;

class TipoDietaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Tipos de Dieta",
            "active_menu" => "nutricao-tipos-dieta",
            "page" => [
                "title" => "Tipos de Dieta",
                "desc" => "Padronize: total, trato, suplemento, pré-mistura, núcleo ou concentrado",
            ],
            "uppers" => implode(",", TipoDieta::getUppers()),
            "required" => implode(",", TipoDieta::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("tipo_dieta_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Tipos de Dieta" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = TipoDieta::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/nutricao/tipo-dieta/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("tipo_dieta_inserir"),
                "editar" => $this->auth->allow("tipo_dieta_editar"),
                "excluir" => $this->auth->allow("tipo_dieta_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("tipo_dieta_inserir");
        echo $this->view->render("admin/nutricao/tipo-dieta/form", [
            "csrf" => $this->csrf->generate(),
            "tipo" => false,
            "url_action" => $this->router->route("admin.nutricao.tipo.dieta.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("tipo_dieta_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do tipo de dieta");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        TipoDieta::create($payload);
        $this->message->success("Tipo de dieta cadastrado com sucesso");
        $this->router->redirect("admin.nutricao.tipo.dieta.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("tipo_dieta_editar");
        $data = new Data($request->all());
        $tipo = TipoDieta::find($data->id) ?: TipoDieta::findByMd5($data->id);

        if (!$tipo) {
            $this->message->warning("Tipo de dieta não encontrado");
            $this->router->redirect("admin.nutricao.tipo.dieta.index");
        }

        echo $this->view->render("admin/nutricao/tipo-dieta/form", [
            "csrf" => $this->csrf->generate(),
            "tipo" => $tipo,
            "url_action" => $this->router->route("admin.nutricao.tipo.dieta.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("tipo_dieta_editar");
        $data = new Data($request->all());
        $tipo = TipoDieta::find($data->id) ?: TipoDieta::findByMd5($data->id);

        if (!$tipo) {
            $this->message->warning("Tipo de dieta não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do tipo de dieta");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        TipoDieta::updateBy($tipo->id, $payload);
        $this->message->success("Tipo de dieta atualizado com sucesso");
        $this->router->redirect("admin.nutricao.tipo.dieta.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("tipo_dieta_excluir");
        $data = new Data($request->all());
        $tipo = TipoDieta::find($data->id) ?: TipoDieta::findByMd5($data->id);

        if (!$tipo) {
            $this->message->warning("Tipo de dieta não encontrado");
            Redirect::referer();
            return;
        }

        TipoDieta::deleteById($tipo->id);
        $this->message->success("Tipo de dieta removido com sucesso");
        Redirect::referer();
    }
}
