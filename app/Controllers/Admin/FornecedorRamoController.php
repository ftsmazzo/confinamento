<?php

namespace App\Controllers\Admin;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Fornecedor;
use App\Models\FornecedorRamo;

class FornecedorRamoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Ramos",
            "active_menu" => "fornecedores-ramos",
            "page" => [
                "title" => "Ramos",
                "desc" => "Cadastre os ramos usados nos fornecedores",
            ],
        ]);
    }

    public function index(): void
    {
        $this->authorize("fornecedor_ramo_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Fornecedores" => ["url" => $this->router->route("admin.fornecedor.index"), "current" => false],
                "Ramos" => ["url" => false, "current" => true],
            ],
            "page" => [
                "title" => "Ramos",
                "desc" => "Cadastre os ramos usados nos fornecedores",
            ],
        ]);

        $ramos = FornecedorRamo::orderBy("descricao")->get();

        foreach ($ramos as $ramo) {
            $ramo->hash = md5((string) $ramo->id);
            $ramo->fornecedores = Fornecedor::where("id_ramo", "=", $ramo->id)->count();
            $ramo->disabled = "";
            $ramo->title = $ramo->fornecedores > 0 ? "Existem fornecedores vinculados à este ramo" : "Excluir ramo";
            $ramo->action = $ramo->fornecedores > 0 ? "" : 'onclick="Delete(\'fornecedores/ramos/delete\', \'' . $ramo->id . '\')"';
        }

        $permissao = [
            "fornecedor" => $this->auth->allow("fornecedor_gerenciar"),
            "inserir" => $this->auth->allow("fornecedor_ramo_inserir"),
            "editar" => $this->auth->allow("fornecedor_ramo_editar"),
            "excluir" => $this->auth->allow("fornecedor_ramo_excluir"),
        ];

        echo $this->view->render("admin/fornecedor/ramo/index", [
            "dados" => $ramos,
            "permissao" => $permissao,
        ]);
    }

    public function new(): void
    {
        $this->authorize("fornecedor_ramo_inserir");

        echo $this->view->render("admin/fornecedor/ramo/form", [
            "csrf" => $this->csrf->generate(),
            "ramo" => false,
            "url_action" => $this->router->route("admin.fornecedor.ramo.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("fornecedor_ramo_inserir");

        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        FornecedorRamo::create($payload);

        $this->message->success("Ramo cadastrado com sucesso");
        $this->router->redirect("admin.fornecedor.ramo.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("fornecedor_ramo_editar");

        $data = new Data($request->all());
        $ramo = FornecedorRamo::find($data->id);

        if (!$ramo) {
            $this->message->warning("Ramo não encontrado");
            $this->router->redirect("admin.fornecedor.ramo.index");
        }

        echo $this->view->render("admin/fornecedor/ramo/form", [
            "csrf" => $this->csrf->generate(),
            "ramo" => $ramo,
            "url_action" => $this->router->route("admin.fornecedor.ramo.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("fornecedor_ramo_editar");

        $data = new Data($request->all());
        $ramo = FornecedorRamo::find($data->id) ?: FornecedorRamo::findByMd5($data->id);

        if (!$ramo) {
            $this->message->warning("Ramo não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        FornecedorRamo::updateBy($ramo->id, $payload);

        $this->message->success("Ramo atualizado com sucesso");
        $this->router->redirect("admin.fornecedor.ramo.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("fornecedor_ramo_excluir");

        $data = new Data($request->all());
        $ramo = FornecedorRamo::find($data->id) ?: FornecedorRamo::findByMd5($data->id);

        if (!$ramo) {
            $this->message->warning("Ramo não encontrado");
            Redirect::referer();
            return;
        }

        if (Fornecedor::where("id_ramo", "=", $ramo->id)->count() > 0) {
            $this->message->warning("Existem fornecedores vinculados à este ramo");
            Redirect::referer();
            return;
        }

        FornecedorRamo::deleteById($ramo->id);

        $this->message->success("Ramo removido com sucesso");
        Redirect::referer();
    }
}
