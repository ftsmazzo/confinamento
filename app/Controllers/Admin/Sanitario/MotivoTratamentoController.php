<?php

namespace App\Controllers\Admin\Sanitario;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Sanitario\MotivoTratamento;

class MotivoTratamentoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Motivos de Tratamento",
            "active_menu" => "sanitario-motivos-tratamento",
            "page" => [
                "title" => "Motivos de Tratamento",
                "desc" => "Padronize as causas/motivos que levaram a um tratamento sanitário",
            ],
            "uppers" => implode(",", MotivoTratamento::getUppers()),
            "required" => implode(",", MotivoTratamento::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("motivo_tratamento_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Sanitário" => ["url" => false, "current" => false],
                "Motivos de Tratamento" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = MotivoTratamento::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/sanitario/motivo-tratamento/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("motivo_tratamento_inserir"),
                "editar" => $this->auth->allow("motivo_tratamento_editar"),
                "excluir" => $this->auth->allow("motivo_tratamento_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("motivo_tratamento_inserir");
        echo $this->view->render("admin/sanitario/motivo-tratamento/form", [
            "csrf" => $this->csrf->generate(),
            "motivoTratamento" => false,
            "url_action" => $this->router->route("admin.sanitario.motivo.tratamento.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("motivo_tratamento_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do motivo de tratamento");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        MotivoTratamento::create($payload);
        $this->message->success("Motivo de tratamento cadastrado com sucesso");
        $this->router->redirect("admin.sanitario.motivo.tratamento.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("motivo_tratamento_editar");
        $data = new Data($request->all());
        $motivoTratamento = MotivoTratamento::find($data->id) ?: MotivoTratamento::findByMd5($data->id);

        if (!$motivoTratamento) {
            $this->message->warning("Motivo de tratamento não encontrado");
            $this->router->redirect("admin.sanitario.motivo.tratamento.index");
        }

        echo $this->view->render("admin/sanitario/motivo-tratamento/form", [
            "csrf" => $this->csrf->generate(),
            "motivoTratamento" => $motivoTratamento,
            "url_action" => $this->router->route("admin.sanitario.motivo.tratamento.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("motivo_tratamento_editar");
        $data = new Data($request->all());
        $motivoTratamento = MotivoTratamento::find($data->id) ?: MotivoTratamento::findByMd5($data->id);

        if (!$motivoTratamento) {
            $this->message->warning("Motivo de tratamento não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do motivo de tratamento");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        MotivoTratamento::updateBy($motivoTratamento->id, $payload);
        $this->message->success("Motivo de tratamento atualizado com sucesso");
        $this->router->redirect("admin.sanitario.motivo.tratamento.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("motivo_tratamento_excluir");
        $data = new Data($request->all());
        $motivoTratamento = MotivoTratamento::find($data->id) ?: MotivoTratamento::findByMd5($data->id);

        if (!$motivoTratamento) {
            $this->message->warning("Motivo de tratamento não encontrado");
            Redirect::referer();
            return;
        }

        MotivoTratamento::deleteById($motivoTratamento->id);
        $this->message->success("Motivo de tratamento removido com sucesso");
        Redirect::referer();
    }
}
