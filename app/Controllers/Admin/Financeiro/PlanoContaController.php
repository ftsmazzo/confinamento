<?php

namespace App\Controllers\Admin\Financeiro;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Financeiro\PlanoConta;

class PlanoContaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Plano de Contas",
            "active_menu" => "financeiro-plano-contas",
            "page" => [
                "title" => "Plano de Contas",
                "desc" => "Classificação contábil para receitas e despesas",
            ],
            "uppers" => implode(",", PlanoConta::getUppers()),
            "required" => implode(",", PlanoConta::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("plano_conta_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Financeiro" => ["url" => false, "current" => false],
                "Plano de Contas" => ["url" => false, "current" => true],
            ],
        ]);

        $contas = PlanoConta::orderBy("codigo")->get();

        foreach ($contas as $c) {
            $c->hash = md5((string) $c->id);
        }

        $permissao = [
            "inserir" => $this->auth->allow("plano_conta_inserir"),
            "editar" => $this->auth->allow("plano_conta_editar"),
            "excluir" => $this->auth->allow("plano_conta_excluir"),
        ];

        echo $this->view->render("admin/financeiro/plano-conta/index", [
            "dados" => $contas,
            "permissao" => $permissao,
        ]);
    }

    public function new(): void
    {
        $this->authorize("plano_conta_inserir");

        echo $this->view->render("admin/financeiro/plano-conta/form", [
            "csrf" => $this->csrf->generate(),
            "conta" => false,
            "url_action" => $this->router->route("admin.financeiro.plano.conta.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("plano_conta_inserir");

        $data = new Data($request->all());

        if (!$data->has("codigo") || !$data->has("nome") || !$data->has("tipo")) {
            $this->message->warning("Informe código, nome e tipo da conta");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        PlanoConta::create($payload);

        $this->message->success("Conta cadastrada com sucesso");
        $this->router->redirect("admin.financeiro.plano.conta.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("plano_conta_editar");

        $data = new Data($request->all());
        $conta = PlanoConta::find($data->id) ?: PlanoConta::findByMd5($data->id);

        if (!$conta) {
            $this->message->warning("Conta não encontrada");
            $this->router->redirect("admin.financeiro.plano.conta.index");
            return;
        }

        echo $this->view->render("admin/financeiro/plano-conta/form", [
            "csrf" => $this->csrf->generate(),
            "conta" => $conta,
            "url_action" => $this->router->route("admin.financeiro.plano.conta.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("plano_conta_editar");

        $data = new Data($request->all());
        $conta = PlanoConta::find($data->id) ?: PlanoConta::findByMd5($data->id);

        if (!$conta) {
            $this->message->warning("Conta não encontrada");
            $this->router->redirect("admin.financeiro.plano.conta.index");
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        PlanoConta::updateBy($conta->id, $payload);

        $this->message->success("Conta atualizada com sucesso");
        $this->router->redirect("admin.financeiro.plano.conta.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("plano_conta_excluir");

        $data = new Data($request->all());
        $conta = PlanoConta::find($data->id) ?: PlanoConta::findByMd5($data->id);

        if (!$conta) {
            $this->message->warning("Conta não encontrada");
            Redirect::referer();
            return;
        }

        PlanoConta::deleteById($conta->id);

        $this->message->success("Conta removida com sucesso");
        Redirect::referer();
    }
}
