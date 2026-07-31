<?php

namespace App\Controllers\Admin\Confinamento;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\LocalEstoque;
use App\Models\Confinamento\Unidade;

class LocalEstoqueController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Locais de Estoque",
            "active_menu" => "confinamento-locais-estoque",
            "page" => [
                "title" => "Locais de Estoque",
                "desc" => "Cadastre os locais de armazenamento do confinamento",
            ],
            "uppers" => implode(",", LocalEstoque::getUppers()),
            "required" => implode(",", LocalEstoque::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("confinamento_local_estoque_gerenciar");
        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Confinamento" => ["url" => false, "current" => false],
                "Locais de Estoque" => ["url" => false, "current" => true],
            ],
        ]);

        $locais = LocalEstoque::leftJoin("unidade as cu", "cle.id_unidade", "=", "cu.id")
            ->select("cle.*", "cu.nome as unidade_nome", "cu.codigo as unidade_codigo")
            ->orderBy("cle.nome")
            ->get();
        foreach ($locais as $local) {
            $local->hash = md5((string) $local->id);
        }

        echo $this->view->render("admin/confinamento/local-estoque/index", [
            "dados" => $locais,
            "permissao" => [
                "inserir" => $this->auth->allow("confinamento_local_estoque_inserir"),
                "editar" => $this->auth->allow("confinamento_local_estoque_editar"),
                "excluir" => $this->auth->allow("confinamento_local_estoque_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("confinamento_local_estoque_inserir");
        echo $this->view->render("admin/confinamento/local-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "local" => false,
            "unidades" => $this->unidades(),
            "url_action" => $this->router->route("admin.confinamento.local.estoque.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("confinamento_local_estoque_inserir");
        $data = new Data($request->all());
        if (!$data->has("nome") || !$data->has("codigo") || !$data->has("id_unidade")) {
            $this->message->warning("Informe nome, código e unidade do local de estoque");
            Redirect::referer();
            return;
        }

        if (!$this->unidadeValida((int) $data->id_unidade)) {
            $this->message->warning("Selecione uma unidade válida para o local de estoque");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        LocalEstoque::create($payload);
        $this->message->success("Local de estoque cadastrado com sucesso");
        $this->router->redirect("admin.confinamento.local.estoque.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("confinamento_local_estoque_editar");
        $data = new Data($request->all());
        $local = LocalEstoque::find($data->id) ?: LocalEstoque::findByMd5($data->id);
        if (!$local) {
            $this->message->warning("Local de estoque não encontrado");
            $this->router->redirect("admin.confinamento.local.estoque.index");
        }

        echo $this->view->render("admin/confinamento/local-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "local" => $local,
            "unidades" => $this->unidades(),
            "url_action" => $this->router->route("admin.confinamento.local.estoque.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("confinamento_local_estoque_editar");
        $data = new Data($request->all());
        $local = LocalEstoque::find($data->id) ?: LocalEstoque::findByMd5($data->id);
        if (!$local) {
            $this->message->warning("Local de estoque não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome") || !$data->has("codigo") || !$data->has("id_unidade")) {
            $this->message->warning("Informe nome, código e unidade do local de estoque");
            Redirect::referer();
            return;
        }

        if (!$this->unidadeValida((int) $data->id_unidade)) {
            $this->message->warning("Selecione uma unidade válida para o local de estoque");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        LocalEstoque::updateBy($local->id, $payload);
        $this->message->success("Local de estoque atualizado com sucesso");
        $this->router->redirect("admin.confinamento.local.estoque.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("confinamento_local_estoque_excluir");
        $data = new Data($request->all());
        $local = LocalEstoque::find($data->id) ?: LocalEstoque::findByMd5($data->id);
        if (!$local) {
            $this->message->warning("Local de estoque não encontrado");
            Redirect::referer();
            return;
        }

        LocalEstoque::deleteById($local->id);
        $this->message->success("Local de estoque removido com sucesso");
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
