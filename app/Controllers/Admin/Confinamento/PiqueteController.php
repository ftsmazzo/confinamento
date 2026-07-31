<?php

namespace App\Controllers\Admin\Confinamento;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Piquete;
use App\Models\Confinamento\Unidade;

class PiqueteController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Piquetes",
            "active_menu" => "confinamento-piquetes",
            "page" => [
                "title" => "Piquetes",
                "desc" => "Cadastre os piquetes do confinamento",
            ],
            "uppers" => implode(",", Piquete::getUppers()),
            "required" => implode(",", Piquete::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("confinamento_piquete_gerenciar");
        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Confinamento" => ["url" => false, "current" => false],
                "Piquetes" => ["url" => false, "current" => true],
            ],
        ]);

        $piquetes = Piquete::leftJoin("unidade as cu", "cp.id_unidade", "=", "cu.id")
            ->select("cp.*", "cu.nome as unidade_nome", "cu.codigo as unidade_codigo")
            ->orderBy("cp.nome")
            ->get();
        foreach ($piquetes as $piquete) {
            $piquete->hash = md5((string) $piquete->id);
        }

        echo $this->view->render("admin/confinamento/piquete/index", [
            "dados" => $piquetes,
            "permissao" => [
                "inserir" => $this->auth->allow("confinamento_piquete_inserir"),
                "editar" => $this->auth->allow("confinamento_piquete_editar"),
                "excluir" => $this->auth->allow("confinamento_piquete_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("confinamento_piquete_inserir");
        echo $this->view->render("admin/confinamento/piquete/form", [
            "csrf" => $this->csrf->generate(),
            "piquete" => false,
            "unidades" => $this->unidades(),
            "url_action" => $this->router->route("admin.confinamento.piquete.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("confinamento_piquete_inserir");
        $data = new Data($request->all());
        if (!$data->has("nome") || !$data->has("codigo") || !$data->has("id_unidade")) {
            $this->message->warning("Informe nome, código e unidade do piquete");
            Redirect::referer();
            return;
        }

        if (!$this->unidadeValida((int) $data->id_unidade)) {
            $this->message->warning("Selecione uma unidade válida para o piquete");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        Piquete::create($payload);
        $this->message->success("Piquete cadastrado com sucesso");
        $this->router->redirect("admin.confinamento.piquete.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("confinamento_piquete_editar");
        $data = new Data($request->all());
        $piquete = Piquete::find($data->id) ?: Piquete::findByMd5($data->id);
        if (!$piquete) {
            $this->message->warning("Piquete não encontrado");
            $this->router->redirect("admin.confinamento.piquete.index");
        }

        echo $this->view->render("admin/confinamento/piquete/form", [
            "csrf" => $this->csrf->generate(),
            "piquete" => $piquete,
            "unidades" => $this->unidades(),
            "url_action" => $this->router->route("admin.confinamento.piquete.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("confinamento_piquete_editar");
        $data = new Data($request->all());
        $piquete = Piquete::find($data->id) ?: Piquete::findByMd5($data->id);
        if (!$piquete) {
            $this->message->warning("Piquete não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome") || !$data->has("codigo") || !$data->has("id_unidade")) {
            $this->message->warning("Informe nome, código e unidade do piquete");
            Redirect::referer();
            return;
        }

        if (!$this->unidadeValida((int) $data->id_unidade)) {
            $this->message->warning("Selecione uma unidade válida para o piquete");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        Piquete::updateBy($piquete->id, $payload);
        $this->message->success("Piquete atualizado com sucesso");
        $this->router->redirect("admin.confinamento.piquete.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("confinamento_piquete_excluir");
        $data = new Data($request->all());
        $piquete = Piquete::find($data->id) ?: Piquete::findByMd5($data->id);
        if (!$piquete) {
            $this->message->warning("Piquete não encontrado");
            Redirect::referer();
            return;
        }

        Piquete::deleteById($piquete->id);
        $this->message->success("Piquete removido com sucesso");
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
