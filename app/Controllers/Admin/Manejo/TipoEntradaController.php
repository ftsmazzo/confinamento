<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\TipoEntrada;

class TipoEntradaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Tipos de Entrada",
            "active_menu" => "manejo-tipos-entrada",
            "page" => [
                "title" => "Tipos de Entrada",
                "desc" => "Classifique a forma de entrada dos animais no confinamento",
            ],
            "uppers" => implode(",", TipoEntrada::getUppers()),
            "required" => implode(",", TipoEntrada::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("tipo_entrada_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Manejo" => ["url" => false, "current" => false],
                "Tipos de Entrada" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = TipoEntrada::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/manejo/tipo-entrada/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("tipo_entrada_inserir"),
                "editar" => $this->auth->allow("tipo_entrada_editar"),
                "excluir" => $this->auth->allow("tipo_entrada_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("tipo_entrada_inserir");
        echo $this->view->render("admin/manejo/tipo-entrada/form", [
            "csrf" => $this->csrf->generate(),
            "tipoEntrada" => false,
            "url_action" => $this->router->route("admin.manejo.tipo.entrada.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("tipo_entrada_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do tipo de entrada");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        TipoEntrada::create($payload);
        $this->message->success("Tipo de entrada cadastrado com sucesso");
        $this->router->redirect("admin.manejo.tipo.entrada.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("tipo_entrada_editar");
        $data = new Data($request->all());
        $tipoEntrada = TipoEntrada::find($data->id) ?: TipoEntrada::findByMd5($data->id);

        if (!$tipoEntrada) {
            $this->message->warning("Tipo de entrada não encontrado");
            $this->router->redirect("admin.manejo.tipo.entrada.index");
        }

        echo $this->view->render("admin/manejo/tipo-entrada/form", [
            "csrf" => $this->csrf->generate(),
            "tipoEntrada" => $tipoEntrada,
            "url_action" => $this->router->route("admin.manejo.tipo.entrada.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("tipo_entrada_editar");
        $data = new Data($request->all());
        $tipoEntrada = TipoEntrada::find($data->id) ?: TipoEntrada::findByMd5($data->id);

        if (!$tipoEntrada) {
            $this->message->warning("Tipo de entrada não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do tipo de entrada");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        TipoEntrada::updateBy($tipoEntrada->id, $payload);
        $this->message->success("Tipo de entrada atualizado com sucesso");
        $this->router->redirect("admin.manejo.tipo.entrada.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("tipo_entrada_excluir");
        $data = new Data($request->all());
        $tipoEntrada = TipoEntrada::find($data->id) ?: TipoEntrada::findByMd5($data->id);

        if (!$tipoEntrada) {
            $this->message->warning("Tipo de entrada não encontrado");
            Redirect::referer();
            return;
        }

        TipoEntrada::deleteById($tipoEntrada->id);
        $this->message->success("Tipo de entrada removido com sucesso");
        Redirect::referer();
    }
}
