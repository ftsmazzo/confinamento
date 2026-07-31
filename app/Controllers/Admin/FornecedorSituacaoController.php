<?php

namespace App\Controllers\Admin;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Fornecedor;
use App\Models\FornecedorSituacao;

class FornecedorSituacaoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Situações",
            "active_menu" => "fornecedores-situacoes",
            "page" => [
                "title" => "Situações",
                "desc" => "Cadastre as situações usadas nos fornecedores",
            ],
            "uppers"   => implode(",", FornecedorSituacao::getUppers()),
            "required" => implode(",", FornecedorSituacao::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("fornecedor_situacao_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Fornecedores" => ["url" => $this->router->route("admin.fornecedor.index"), "current" => false],
                "Situações" => ["url" => false, "current" => true],
            ],
            "page" => [
                "title" => "Situações",
                "desc" => "Cadastre as situações usadas nos fornecedores",
            ],
        ]);

        $situacoes = FornecedorSituacao::orderBy("descricao")->get();

        foreach ($situacoes as $situacao) {
            $situacao->hash = md5((string) $situacao->id);
            $situacao->fornecedores = Fornecedor::where("id_situacao", "=", $situacao->id)->count();
            $situacao->badge = $this->badgeColor($situacao->descricao, $situacao->cor ?: "#6c757d");
            $situacao->disabled = "";
            $situacao->title = $situacao->fornecedores > 0 ? "Existem fornecedores vinculados à esta situação" : "Excluir situação";
            $situacao->action = $situacao->fornecedores > 0 ? "" : 'onclick="Delete(\'fornecedores/situacoes/delete\', \'' . $situacao->id . '\')"';
        }

        $permissao = [
            "fornecedor" => $this->auth->allow("fornecedor_gerenciar"),
            "inserir" => $this->auth->allow("fornecedor_situacao_inserir"),
            "editar" => $this->auth->allow("fornecedor_situacao_editar"),
            "excluir" => $this->auth->allow("fornecedor_situacao_excluir"),
        ];

        echo $this->view->render("admin/fornecedor/situacao/index", [
            "dados" => $situacoes,
            "permissao" => $permissao,
        ]);
    }

    public function new(): void
    {
        $this->authorize("fornecedor_situacao_inserir");

        echo $this->view->render("admin/fornecedor/situacao/form", [
            "csrf" => $this->csrf->generate(),
            "situacao" => false,
            "url_action" => $this->router->route("admin.fornecedor.situacao.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("fornecedor_situacao_inserir");

        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição");
            Redirect::referer();
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        FornecedorSituacao::create($payload);

        $this->message->success("Situação cadastrada com sucesso");
        $this->router->redirect("admin.fornecedor.situacao.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("fornecedor_situacao_editar");

        $data = new Data($request->all());
        $situacao = FornecedorSituacao::find($data->id);

        if (!$situacao) {
            $this->message->warning("Situação não encontrada");
            $this->router->redirect("admin.fornecedor.situacao.index");
        }

        echo $this->view->render("admin/fornecedor/situacao/form", [
            "csrf" => $this->csrf->generate(),
            "situacao" => $situacao,
            "url_action" => $this->router->route("admin.fornecedor.situacao.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("fornecedor_situacao_editar");

        $data = new Data($request->all());
        $situacao = FornecedorSituacao::find($data->id) ?: FornecedorSituacao::findByMd5($data->id);

        if (!$situacao) {
            $this->message->warning("Situação não encontrada");
            Redirect::referer();
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição");
            Redirect::referer();
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        FornecedorSituacao::updateBy($situacao->id, $payload);

        $this->message->success("Situação atualizada com sucesso");
        $this->router->redirect("admin.fornecedor.situacao.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("fornecedor_situacao_excluir");

        $data = new Data($request->all());
        $situacao = FornecedorSituacao::find($data->id) ?: FornecedorSituacao::findByMd5($data->id);

        if (!$situacao) {
            $this->message->warning("Situação não encontrada");
            Redirect::referer();
            return;
        }

        if (Fornecedor::where("id_situacao", "=", $situacao->id)->count() > 0) {
            $this->message->warning("Existem fornecedores vinculados à esta situação");
            Redirect::referer();
            return;
        }

        FornecedorSituacao::deleteById($situacao->id);

        $this->message->success("Situação removida com sucesso");
        Redirect::referer();
    }

    private function badgeColor(string $label, string $color): string
    {
        $color = trim($color) ?: "#6c757d";
        $textColor = colorContrast($color);

        return '<span class="badge filled-outlined" style="background:' . htmlspecialchars($color, ENT_QUOTES, "UTF-8") . ';border-color:' . htmlspecialchars($color, ENT_QUOTES, "UTF-8") . ';color:' . htmlspecialchars($textColor, ENT_QUOTES, "UTF-8") . ';">' . htmlspecialchars($label, ENT_QUOTES, "UTF-8") . '</span>';
    }
}
