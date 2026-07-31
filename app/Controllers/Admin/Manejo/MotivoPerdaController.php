<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\MotivoPerda;

class MotivoPerdaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Motivos de Perda",
            "active_menu" => "manejo-motivos-perda",
            "page" => [
                "title" => "Motivos de Perda / Mortalidade",
                "desc" => "Padronize as causas de morte, descarte ou perdas técnicas",
            ],
            "uppers" => implode(",", MotivoPerda::getUppers()),
            "required" => implode(",", MotivoPerda::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("motivo_perda_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Manejo" => ["url" => false, "current" => false],
                "Motivos de Perda" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = MotivoPerda::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/manejo/motivo-perda/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("motivo_perda_inserir"),
                "editar" => $this->auth->allow("motivo_perda_editar"),
                "excluir" => $this->auth->allow("motivo_perda_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("motivo_perda_inserir");
        echo $this->view->render("admin/manejo/motivo-perda/form", [
            "csrf" => $this->csrf->generate(),
            "motivoPerda" => false,
            "url_action" => $this->router->route("admin.manejo.motivo.perda.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("motivo_perda_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do motivo de perda");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        MotivoPerda::create($payload);
        $this->message->success("Motivo de perda cadastrado com sucesso");
        $this->router->redirect("admin.manejo.motivo.perda.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("motivo_perda_editar");
        $data = new Data($request->all());
        $motivoPerda = MotivoPerda::find($data->id) ?: MotivoPerda::findByMd5($data->id);

        if (!$motivoPerda) {
            $this->message->warning("Motivo de perda não encontrado");
            $this->router->redirect("admin.manejo.motivo.perda.index");
        }

        echo $this->view->render("admin/manejo/motivo-perda/form", [
            "csrf" => $this->csrf->generate(),
            "motivoPerda" => $motivoPerda,
            "url_action" => $this->router->route("admin.manejo.motivo.perda.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("motivo_perda_editar");
        $data = new Data($request->all());
        $motivoPerda = MotivoPerda::find($data->id) ?: MotivoPerda::findByMd5($data->id);

        if (!$motivoPerda) {
            $this->message->warning("Motivo de perda não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição do motivo de perda");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        MotivoPerda::updateBy($motivoPerda->id, $payload);
        $this->message->success("Motivo de perda atualizado com sucesso");
        $this->router->redirect("admin.manejo.motivo.perda.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("motivo_perda_excluir");
        $data = new Data($request->all());
        $motivoPerda = MotivoPerda::find($data->id) ?: MotivoPerda::findByMd5($data->id);

        if (!$motivoPerda) {
            $this->message->warning("Motivo de perda não encontrado");
            Redirect::referer();
            return;
        }

        MotivoPerda::deleteById($motivoPerda->id);
        $this->message->success("Motivo de perda removido com sucesso");
        Redirect::referer();
    }
}
