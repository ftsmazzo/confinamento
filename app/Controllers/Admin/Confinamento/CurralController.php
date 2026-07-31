<?php

namespace App\Controllers\Admin\Confinamento;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Curral;
use App\Models\Confinamento\Unidade;

class CurralController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Currais",
            "active_menu" => "confinamento-currais",
            "page" => [
                "title" => "Currais / Baias",
                "desc" => "Cadastre os currais ou baias do confinamento",
            ],
            "uppers" => implode(",", Curral::getUppers()),
            "required" => implode(",", Curral::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("confinamento_curral_gerenciar");
        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Confinamento" => ["url" => false, "current" => false],
                "Currais" => ["url" => false, "current" => true],
            ],
        ]);

        $currais = Curral::leftJoin("unidade as cu", "cc.id_unidade", "=", "cu.id")
            ->select("cc.*", "cu.nome as unidade_nome", "cu.codigo as unidade_codigo")
            ->orderBy("cc.nome")
            ->get();

        foreach ($currais as $curral) {
            $curral->hash = md5((string) $curral->id);
        }

        echo $this->view->render("admin/confinamento/curral/index", [
            "dados" => $currais,
            "permissao" => [
                "inserir" => $this->auth->allow("confinamento_curral_inserir"),
                "editar" => $this->auth->allow("confinamento_curral_editar"),
                "excluir" => $this->auth->allow("confinamento_curral_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("confinamento_curral_inserir");
        echo $this->view->render("admin/confinamento/curral/form", [
            "csrf" => $this->csrf->generate(),
            "curral" => false,
            "unidades" => $this->unidades(),
            "url_action" => $this->router->route("admin.confinamento.curral.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("confinamento_curral_inserir");
        $data = new Data($request->all());
        if (!$data->has("nome") || !$data->has("codigo") || !$data->has("id_unidade")) {
            $this->message->warning("Informe nome, código e unidade do curral");
            Redirect::referer();
            return;
        }

        if (!$this->unidadeValida((int) $data->id_unidade)) {
            $this->message->warning("Selecione uma unidade válida para o curral");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("linha");
        $data->nullIfEmpty("capacidade");
        $data->nullIfEmpty("tipo_estrutura");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        Curral::create($payload);
        $this->message->success("Curral cadastrado com sucesso");
        $this->router->redirect("admin.confinamento.curral.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("confinamento_curral_editar");
        $data = new Data($request->all());
        $curral = Curral::find($data->id) ?: Curral::findByMd5($data->id);
        if (!$curral) {
            $this->message->warning("Curral não encontrado");
            $this->router->redirect("admin.confinamento.curral.index");
        }

        echo $this->view->render("admin/confinamento/curral/form", [
            "csrf" => $this->csrf->generate(),
            "curral" => $curral,
            "unidades" => $this->unidades(),
            "url_action" => $this->router->route("admin.confinamento.curral.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("confinamento_curral_editar");
        $data = new Data($request->all());
        $curral = Curral::find($data->id) ?: Curral::findByMd5($data->id);
        if (!$curral) {
            $this->message->warning("Curral não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome") || !$data->has("codigo") || !$data->has("id_unidade")) {
            $this->message->warning("Informe nome, código e unidade do curral");
            Redirect::referer();
            return;
        }

        if (!$this->unidadeValida((int) $data->id_unidade)) {
            $this->message->warning("Selecione uma unidade válida para o curral");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("linha");
        $data->nullIfEmpty("capacidade");
        $data->nullIfEmpty("tipo_estrutura");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        Curral::updateBy($curral->id, $payload);
        $this->message->success("Curral atualizado com sucesso");
        $this->router->redirect("admin.confinamento.curral.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("confinamento_curral_excluir");
        $data = new Data($request->all());
        $curral = Curral::find($data->id) ?: Curral::findByMd5($data->id);
        if (!$curral) {
            $this->message->warning("Curral não encontrado");
            Redirect::referer();
            return;
        }

        Curral::deleteById($curral->id);
        $this->message->success("Curral removido com sucesso");
        Redirect::referer();
    }

    private function unidades(): array
    {
        return Unidade::orderBy("nome")->get();
    }

    private function unidadeValida(int $id): bool
    {
        return $id > 0 && Unidade::find($id) !== null;
    }
}
