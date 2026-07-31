<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\TipoSaida;

class TipoSaidaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Tipos de Saída",
            "active_menu" => "manejo-tipos-saida",
            "page" => [
                "title" => "Tipos de Saída",
                "desc" => "Classifique a forma de saída dos animais do confinamento",
            ],
            "uppers" => implode(",", TipoSaida::getUppers()),
            "required" => implode(",", TipoSaida::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("tipo_saida_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Manejo" => ["url" => false, "current" => false],
                "Tipos de Saída" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = TipoSaida::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/manejo/tipo-saida/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("tipo_saida_inserir"),
                "editar" => $this->auth->allow("tipo_saida_editar"),
                "excluir" => $this->auth->allow("tipo_saida_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("tipo_saida_inserir");
        echo $this->view->render("admin/manejo/tipo-saida/form", [
            "csrf" => $this->csrf->generate(),
            "tipoSaida" => false,
            "url_action" => $this->router->route("admin.manejo.tipo.saida.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("tipo_saida_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do tipo de saída");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        TipoSaida::create($payload);
        $this->message->success("Tipo de saída cadastrado com sucesso");
        $this->router->redirect("admin.manejo.tipo.saida.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("tipo_saida_editar");
        $data = new Data($request->all());
        $tipoSaida = TipoSaida::find($data->id) ?: TipoSaida::findByMd5($data->id);

        if (!$tipoSaida) {
            $this->message->warning("Tipo de saída não encontrado");
            $this->router->redirect("admin.manejo.tipo.saida.index");
        }

        echo $this->view->render("admin/manejo/tipo-saida/form", [
            "csrf" => $this->csrf->generate(),
            "tipoSaida" => $tipoSaida,
            "url_action" => $this->router->route("admin.manejo.tipo.saida.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("tipo_saida_editar");
        $data = new Data($request->all());
        $tipoSaida = TipoSaida::find($data->id) ?: TipoSaida::findByMd5($data->id);

        if (!$tipoSaida) {
            $this->message->warning("Tipo de saída não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do tipo de saída");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        TipoSaida::updateBy($tipoSaida->id, $payload);
        $this->message->success("Tipo de saída atualizado com sucesso");
        $this->router->redirect("admin.manejo.tipo.saida.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("tipo_saida_excluir");
        $data = new Data($request->all());
        $tipoSaida = TipoSaida::find($data->id) ?: TipoSaida::findByMd5($data->id);

        if (!$tipoSaida) {
            $this->message->warning("Tipo de saída não encontrado");
            Redirect::referer();
            return;
        }

        TipoSaida::deleteById($tipoSaida->id);
        $this->message->success("Tipo de saída removido com sucesso");
        Redirect::referer();
    }
}
