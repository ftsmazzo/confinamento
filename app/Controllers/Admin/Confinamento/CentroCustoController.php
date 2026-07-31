<?php

namespace App\Controllers\Admin\Confinamento;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\CentroCusto;

class CentroCustoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Centros de Custo",
            "active_menu" => "confinamento-centros-custo",
            "page" => [
                "title" => "Centros de Custo",
                "desc" => "Classifique os gastos da operação: alimentação, sanidade, frete, mão de obra, manutenção",
            ],
            "uppers" => implode(",", CentroCusto::getUppers()),
            "required" => implode(",", CentroCusto::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("centro_custo_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Confinamento" => ["url" => false, "current" => false],
                "Centros de Custo" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = CentroCusto::orderBy("nome")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/confinamento/centro-custo/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("centro_custo_inserir"),
                "editar" => $this->auth->allow("centro_custo_editar"),
                "excluir" => $this->auth->allow("centro_custo_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("centro_custo_inserir");

        echo $this->view->render("admin/confinamento/centro-custo/form", [
            "csrf" => $this->csrf->generate(),
            "centro" => false,
            "url_action" => $this->router->route("admin.confinamento.centro.custo.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("centro_custo_inserir");

        $data = new Data($request->all());

        if (!$data->has("nome") || !$data->has("codigo")) {
            $this->message->warning("Informe nome e código do centro de custo");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("descricao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        CentroCusto::create($payload);

        $this->message->success("Centro de custo cadastrado com sucesso");
        $this->router->redirect("admin.confinamento.centro.custo.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("centro_custo_editar");

        $data = new Data($request->all());
        $centro = CentroCusto::find($data->id) ?: CentroCusto::findByMd5($data->id);

        if (!$centro) {
            $this->message->warning("Centro de custo não encontrado");
            $this->router->redirect("admin.confinamento.centro.custo.index");
            return;
        }

        echo $this->view->render("admin/confinamento/centro-custo/form", [
            "csrf" => $this->csrf->generate(),
            "centro" => $centro,
            "url_action" => $this->router->route("admin.confinamento.centro.custo.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("centro_custo_editar");

        $data = new Data($request->all());
        $centro = CentroCusto::find($data->id) ?: CentroCusto::findByMd5($data->id);

        if (!$centro) {
            $this->message->warning("Centro de custo não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome") || !$data->has("codigo")) {
            $this->message->warning("Informe nome e código do centro de custo");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("descricao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        CentroCusto::updateBy($centro->id, $payload);

        $this->message->success("Centro de custo atualizado com sucesso");
        $this->router->redirect("admin.confinamento.centro.custo.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("centro_custo_excluir");

        $data = new Data($request->all());
        $centro = CentroCusto::find($data->id) ?: CentroCusto::findByMd5($data->id);

        if (!$centro) {
            $this->message->warning("Centro de custo não encontrado");
            Redirect::referer();
            return;
        }

        CentroCusto::deleteById($centro->id);

        $this->message->success("Centro de custo removido com sucesso");
        Redirect::referer();
    }
}
