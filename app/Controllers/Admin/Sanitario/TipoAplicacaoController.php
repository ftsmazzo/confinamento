<?php

namespace App\Controllers\Admin\Sanitario;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Sanitario\TipoAplicacao;

class TipoAplicacaoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Tipos de Aplicação",
            "active_menu" => "sanitario-tipos-aplicacao",
            "page" => [
                "title" => "Tipos de Aplicação",
                "desc" => "Padronize as vias/formas de administração de medicamentos e vacinas",
            ],
            "uppers" => implode(",", TipoAplicacao::getUppers()),
            "required" => implode(",", TipoAplicacao::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("tipo_aplicacao_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Sanitário" => ["url" => false, "current" => false],
                "Tipos de Aplicação" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = TipoAplicacao::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/sanitario/tipo-aplicacao/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("tipo_aplicacao_inserir"),
                "editar" => $this->auth->allow("tipo_aplicacao_editar"),
                "excluir" => $this->auth->allow("tipo_aplicacao_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("tipo_aplicacao_inserir");
        echo $this->view->render("admin/sanitario/tipo-aplicacao/form", [
            "csrf" => $this->csrf->generate(),
            "tipoAplicacao" => false,
            "url_action" => $this->router->route("admin.sanitario.tipo.aplicacao.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("tipo_aplicacao_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do tipo de aplicação");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        TipoAplicacao::create($payload);
        $this->message->success("Tipo de aplicação cadastrado com sucesso");
        $this->router->redirect("admin.sanitario.tipo.aplicacao.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("tipo_aplicacao_editar");
        $data = new Data($request->all());
        $tipoAplicacao = TipoAplicacao::find($data->id) ?: TipoAplicacao::findByMd5($data->id);

        if (!$tipoAplicacao) {
            $this->message->warning("Tipo de aplicação não encontrado");
            $this->router->redirect("admin.sanitario.tipo.aplicacao.index");
        }

        echo $this->view->render("admin/sanitario/tipo-aplicacao/form", [
            "csrf" => $this->csrf->generate(),
            "tipoAplicacao" => $tipoAplicacao,
            "url_action" => $this->router->route("admin.sanitario.tipo.aplicacao.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("tipo_aplicacao_editar");
        $data = new Data($request->all());
        $tipoAplicacao = TipoAplicacao::find($data->id) ?: TipoAplicacao::findByMd5($data->id);

        if (!$tipoAplicacao) {
            $this->message->warning("Tipo de aplicação não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do tipo de aplicação");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        TipoAplicacao::updateBy($tipoAplicacao->id, $payload);
        $this->message->success("Tipo de aplicação atualizado com sucesso");
        $this->router->redirect("admin.sanitario.tipo.aplicacao.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("tipo_aplicacao_excluir");
        $data = new Data($request->all());
        $tipoAplicacao = TipoAplicacao::find($data->id) ?: TipoAplicacao::findByMd5($data->id);

        if (!$tipoAplicacao) {
            $this->message->warning("Tipo de aplicação não encontrado");
            Redirect::referer();
            return;
        }

        TipoAplicacao::deleteById($tipoAplicacao->id);
        $this->message->success("Tipo de aplicação removido com sucesso");
        Redirect::referer();
    }
}
