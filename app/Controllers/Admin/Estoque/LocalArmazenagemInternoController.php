<?php

namespace App\Controllers\Admin\Estoque;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\LocalEstoque;
use App\Models\Estoque\LocalArmazenagemInterno;

class LocalArmazenagemInternoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Locais Internos de Armazenagem",
            "active_menu" => "estoque-locais-armazenagem-interno",
            "page" => [
                "title" => "Locais Internos de Armazenagem",
                "desc" => "Subdivisões dentro de um local de estoque, como baias, prateleiras e geladeiras",
            ],
            "uppers" => implode(",", LocalArmazenagemInterno::getUppers()),
            "required" => implode(",", LocalArmazenagemInterno::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("local_armazenagem_interno_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Estoque" => ["url" => false, "current" => false],
                "Locais Internos de Armazenagem" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = LocalArmazenagemInterno::leftJoin("local_estoque as le", "lai.id_local_estoque", "=", "le.id")
            ->select("lai.*", "le.nome as local_estoque_nome")
            ->orderBy("le.nome")
            ->orderBy("lai.nome")
            ->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/estoque/local-armazenagem-interno/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("local_armazenagem_interno_inserir"),
                "editar" => $this->auth->allow("local_armazenagem_interno_editar"),
                "excluir" => $this->auth->allow("local_armazenagem_interno_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("local_armazenagem_interno_inserir");

        echo $this->view->render("admin/estoque/local-armazenagem-interno/form", [
            "csrf" => $this->csrf->generate(),
            "local" => false,
            "locaisEstoque" => $this->locaisEstoque(),
            "url_action" => $this->router->route("admin.estoque.local.armazenagem.interno.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("local_armazenagem_interno_inserir");

        $data = new Data($request->all());

        if (!$data->has("id_local_estoque") || !$data->has("nome")) {
            $this->message->warning("Selecione o local de estoque e informe o nome");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("descricao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        LocalArmazenagemInterno::create($payload);

        $this->message->success("Local interno cadastrado com sucesso");
        $this->router->redirect("admin.estoque.local.armazenagem.interno.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("local_armazenagem_interno_editar");

        $data = new Data($request->all());
        $local = LocalArmazenagemInterno::find($data->id) ?: LocalArmazenagemInterno::findByMd5($data->id);

        if (!$local) {
            $this->message->warning("Local interno não encontrado");
            $this->router->redirect("admin.estoque.local.armazenagem.interno.index");
            return;
        }

        echo $this->view->render("admin/estoque/local-armazenagem-interno/form", [
            "csrf" => $this->csrf->generate(),
            "local" => $local,
            "locaisEstoque" => $this->locaisEstoque(),
            "url_action" => $this->router->route("admin.estoque.local.armazenagem.interno.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("local_armazenagem_interno_editar");

        $data = new Data($request->all());
        $local = LocalArmazenagemInterno::find($data->id) ?: LocalArmazenagemInterno::findByMd5($data->id);

        if (!$local) {
            $this->message->warning("Local interno não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_local_estoque") || !$data->has("nome")) {
            $this->message->warning("Selecione o local de estoque e informe o nome");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("descricao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        LocalArmazenagemInterno::updateBy($local->id, $payload);

        $this->message->success("Local interno atualizado com sucesso");
        $this->router->redirect("admin.estoque.local.armazenagem.interno.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("local_armazenagem_interno_excluir");

        $data = new Data($request->all());
        $local = LocalArmazenagemInterno::find($data->id) ?: LocalArmazenagemInterno::findByMd5($data->id);

        if (!$local) {
            $this->message->warning("Local interno não encontrado");
            Redirect::referer();
            return;
        }

        LocalArmazenagemInterno::deleteById($local->id);

        $this->message->success("Local interno removido com sucesso");
        Redirect::referer();
    }

    private function locaisEstoque(): array
    {
        return LocalEstoque::orderBy("nome")->get();
    }
}
