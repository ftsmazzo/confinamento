<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Nutricao\GrupoIngrediente;
use App\Models\Nutricao\Ingrediente;

class IngredienteController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Ingredientes",
            "active_menu" => "nutricao-ingredientes",
            "page" => [
                "title" => "Ingredientes",
                "desc" => "Cadastre os itens que compõem as fórmulas de ração",
            ],
            "uppers" => implode(",", Ingrediente::getUppers()),
            "required" => implode(",", Ingrediente::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("ingrediente_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Ingredientes" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = Ingrediente::leftJoin("grupo_ingrediente as gi", "i.id_grupo_ingrediente", "=", "gi.id")
            ->select("i.*", "gi.descricao as grupo_descricao")
            ->orderBy("i.nome")
            ->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->estoque_baixo = $item->estoque_minimo !== null && (float) $item->estoque_atual < (float) $item->estoque_minimo;
        }

        echo $this->view->render("admin/nutricao/ingrediente/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("ingrediente_inserir"),
                "editar" => $this->auth->allow("ingrediente_editar"),
                "excluir" => $this->auth->allow("ingrediente_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("ingrediente_inserir");
        echo $this->view->render("admin/nutricao/ingrediente/form", [
            "csrf" => $this->csrf->generate(),
            "ingrediente" => false,
            "grupos" => $this->grupos(),
            "url_action" => $this->router->route("admin.nutricao.ingrediente.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("ingrediente_inserir");
        $data = new Data($request->all());

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do ingrediente");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        Ingrediente::create($payload);
        $this->message->success("Ingrediente cadastrado com sucesso");
        $this->router->redirect("admin.nutricao.ingrediente.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("ingrediente_editar");
        $data = new Data($request->all());
        $ingrediente = Ingrediente::find($data->id) ?: Ingrediente::findByMd5($data->id);

        if (!$ingrediente) {
            $this->message->warning("Ingrediente não encontrado");
            $this->router->redirect("admin.nutricao.ingrediente.index");
        }

        echo $this->view->render("admin/nutricao/ingrediente/form", [
            "csrf" => $this->csrf->generate(),
            "ingrediente" => $ingrediente,
            "grupos" => $this->grupos(),
            "url_action" => $this->router->route("admin.nutricao.ingrediente.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("ingrediente_editar");
        $data = new Data($request->all());
        $ingrediente = Ingrediente::find($data->id) ?: Ingrediente::findByMd5($data->id);

        if (!$ingrediente) {
            $this->message->warning("Ingrediente não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do ingrediente");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        Ingrediente::updateBy($ingrediente->id, $payload);
        $this->message->success("Ingrediente atualizado com sucesso");
        $this->router->redirect("admin.nutricao.ingrediente.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("ingrediente_excluir");
        $data = new Data($request->all());
        $ingrediente = Ingrediente::find($data->id) ?: Ingrediente::findByMd5($data->id);

        if (!$ingrediente) {
            $this->message->warning("Ingrediente não encontrado");
            Redirect::referer();
            return;
        }

        Ingrediente::deleteById($ingrediente->id);
        $this->message->success("Ingrediente removido com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_grupo_ingrediente");
        $data->nullIfEmpty("estoque_minimo");
        $data->nullIfEmpty("custo_unitario");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        if (!isset($payload["unidade_medida"]) || $payload["unidade_medida"] === "") {
            $payload["unidade_medida"] = "KG";
        }

        if (!isset($payload["estoque_atual"]) || $payload["estoque_atual"] === "") {
            $payload["estoque_atual"] = 0;
        }

        if (!empty($payload["custo_unitario"])) {
            $payload["custo_unitario"] = money2float((string) $payload["custo_unitario"]);
        }

        return $payload;
    }

    private function grupos(): array
    {
        return GrupoIngrediente::orderBy("descricao")->get();
    }
}
