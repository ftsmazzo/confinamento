<?php

namespace App\Controllers\Admin\Confinamento;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Unidade;

class UnidadeController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Unidades",
            "active_menu" => "confinamento-unidades",
            "page" => [
                "title" => "Unidades / Fazendas",
                "desc" => "Cadastre as unidades operacionais do confinamento",
            ],
            "uppers" => implode(",", Unidade::getUppers()),
            "required" => implode(",", Unidade::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("confinamento_unidade_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Confinamento" => ["url" => false, "current" => false],
                "Unidades" => ["url" => false, "current" => true],
            ],
        ]);

        $unidades = Unidade::orderBy("nome")->get();

        foreach ($unidades as $unidade) {
            $unidade->hash = md5((string) $unidade->id);
        }

        $permissao = [
            "inserir" => $this->auth->allow("confinamento_unidade_inserir"),
            "editar" => $this->auth->allow("confinamento_unidade_editar"),
            "excluir" => $this->auth->allow("confinamento_unidade_excluir"),
        ];

        echo $this->view->render("admin/confinamento/unidade/index", [
            "dados" => $unidades,
            "permissao" => $permissao,
        ]);
    }

    public function new(): void
    {
        $this->authorize("confinamento_unidade_inserir");

        echo $this->view->render("admin/confinamento/unidade/form", [
            "csrf" => $this->csrf->generate(),
            "unidade" => false,
            "url_action" => $this->router->route("admin.confinamento.unidade.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("confinamento_unidade_inserir");

        $data = new Data($request->all());

        if (!$data->has("nome") || !$data->has("codigo")) {
            $this->message->warning("Informe nome e código da unidade");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        Unidade::create($payload);

        $this->message->success("Unidade cadastrada com sucesso");
        $this->router->redirect("admin.confinamento.unidade.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("confinamento_unidade_editar");

        $data = new Data($request->all());
        $unidade = Unidade::find($data->id) ?: Unidade::findByMd5($data->id);

        if (!$unidade) {
            $this->message->warning("Unidade não encontrada");
            $this->router->redirect("admin.confinamento.unidade.index");
        }

        echo $this->view->render("admin/confinamento/unidade/form", [
            "csrf" => $this->csrf->generate(),
            "unidade" => $unidade,
            "url_action" => $this->router->route("admin.confinamento.unidade.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("confinamento_unidade_editar");

        $data = new Data($request->all());
        $unidade = Unidade::find($data->id) ?: Unidade::findByMd5($data->id);

        if (!$unidade) {
            $this->message->warning("Unidade não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome") || !$data->has("codigo")) {
            $this->message->warning("Informe nome e código da unidade");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        Unidade::updateBy($unidade->id, $payload);

        $this->message->success("Unidade atualizada com sucesso");
        $this->router->redirect("admin.confinamento.unidade.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("confinamento_unidade_excluir");

        $data = new Data($request->all());
        $unidade = Unidade::find($data->id) ?: Unidade::findByMd5($data->id);

        if (!$unidade) {
            $this->message->warning("Unidade não encontrada");
            Redirect::referer();
            return;
        }

        Unidade::deleteById($unidade->id);

        $this->message->success("Unidade removida com sucesso");
        Redirect::referer();
    }
}
