<?php

namespace App\Controllers\Admin\Financeiro;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\DB;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Financeiro\ContaPagar;
use App\Models\Financeiro\PlanoConta;
use App\Models\Confinamento\CentroCusto;
use App\Models\Fornecedor;
use App\Models\UsuarioPreferencia;

class ContaPagarController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Contas a Pagar",
            "active_menu" => "financeiro-contas-pagar",
            "page" => [
                "title" => "Contas a Pagar",
                "desc" => "Gerencie as contas e despesas a pagar",
            ],
            "uppers" => implode(",", ContaPagar::getUppers()),
            "required" => implode(",", ContaPagar::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("conta_pagar_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Financeiro" => ["url" => false, "current" => false],
                "Contas a Pagar" => ["url" => false, "current" => true],
            ],
        ]);

        $data = new Data($request->all());

        $pref = UsuarioPreferencia::porUsuario((int) $this->user->uid);

        if ($data->has("view")) {
            $viewMode = $data->view === "grouped" ? "grouped" : "list";
            if (!$pref) {
                $pref = new UsuarioPreferencia();
                $pref->id_user = (int) $this->user->uid;
            }
            $pref->contas_pagar_visao = $viewMode;
            $pref->save();
        } else {
            $viewMode = $pref && $pref->contas_pagar_visao ? $pref->contas_pagar_visao : "list";
        }

        $contas = DB::execute(
            "SELECT cp.*, f.nome AS fornecedor_nome, pc.nome AS plano_conta_nome
             FROM conta_pagar cp
             LEFT JOIN fornecedor f ON f.id = cp.id_fornecedor
             LEFT JOIN plano_conta pc ON pc.id = cp.id_plano_conta
             ORDER BY cp.data_vencimento DESC"
        );

        $permissao = [
            "inserir" => $this->auth->allow("conta_pagar_inserir"),
            "editar" => $this->auth->allow("conta_pagar_editar"),
            "excluir" => $this->auth->allow("conta_pagar_excluir"),
        ];

        echo $this->view->render("admin/financeiro/conta-pagar/index", [
            "dados" => $contas,
            "view_mode" => $viewMode,
            "permissao" => $permissao,
            "csrf" => $this->csrf->generate(),
        ]);
    }

    public function new(): void
    {
        $this->authorize("conta_pagar_inserir");

        $fornecedores = Fornecedor::orderBy("nome")->get();
        $planosConta = PlanoConta::where("ativo", "=", 1)->where("tipo", "=", "DESPESA")->orderBy("codigo")->get();
        $centrosCusto = CentroCusto::where("ativo", "=", 1)->orderBy("nome")->get();

        echo $this->view->render("admin/financeiro/conta-pagar/form", [
            "csrf" => $this->csrf->generate(),
            "conta" => false,
            "url_action" => $this->router->route("admin.financeiro.conta.pagar.insert"),
            "fornecedores" => $fornecedores,
            "planos_conta" => $planosConta,
            "centros_custo" => $centrosCusto,
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("conta_pagar_inserir");

        $data = new Data($request->all());

        if (!$data->has("descricao") || !$data->has("valor") || !$data->has("data_vencimento")) {
            $this->message->warning("Informe descrição, valor e data de vencimento");
            Redirect::referer();
            return;
        }

        $valorTotal = money2float((string) ($data->valor ?? "0"));
        $dataVencimento = (string) $data->data_vencimento;
        $numParcelas = max(1, (int) ($data->num_parcelas ?? 1));
        $intervaloDias = max(1, (int) ($data->intervalo_parcelas ?? 30));

        $payloadBase = $data->all();
        unset($payloadBase["csrf"], $payloadBase["id"], $payloadBase["num_parcelas"], $payloadBase["intervalo_parcelas"]);

        $payloadBase["id_fornecedor"] = !empty($payloadBase["id_fornecedor"]) ? (int) $payloadBase["id_fornecedor"] : null;
        $payloadBase["id_plano_conta"] = !empty($payloadBase["id_plano_conta"]) ? (int) $payloadBase["id_plano_conta"] : null;
        $payloadBase["id_centro_custo"] = !empty($payloadBase["id_centro_custo"]) ? (int) $payloadBase["id_centro_custo"] : null;
        $payloadBase["data_pagamento"] = !empty($payloadBase["data_pagamento"]) ? $payloadBase["data_pagamento"] : null;
        $payloadBase["created_by"] = $this->user->uid;
        $payloadBase["parcela_total"] = $numParcelas;

        $valorParcela = round($valorTotal / $numParcelas, 2);
        $somaParcelas = 0;
        $primeiroId = null;

        for ($i = 1; $i <= $numParcelas; $i++) {
            $payload = $payloadBase;

            $payload["parcela_numero"] = $i;

            if ($i < $numParcelas) {
                $payload["valor"] = $valorParcela;
                $somaParcelas += $valorParcela;
            } else {
                $payload["valor"] = round($valorTotal - $somaParcelas, 2);
            }

            $vencimento = date("Y-m-d", strtotime($dataVencimento . " + " . (($i - 1) * $intervaloDias) . " days"));
            $payload["data_vencimento"] = $vencimento;

            if ($i > 1) {
                $payload["parcela_origem_id"] = $primeiroId;
            }

            $result = ContaPagar::create($payload);

            if ($i === 1) {
                $primeiroId = $result->id;
                ContaPagar::updateBy($primeiroId, ["parcela_origem_id" => $primeiroId]);
            }
        }

        $msg = $numParcelas > 1
            ? "Conta cadastrada com sucesso em {$numParcelas} parcelas"
            : "Conta cadastrada com sucesso";
        $this->message->success($msg);
        $this->router->redirect("admin.financeiro.conta.pagar.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("conta_pagar_editar");

        $data = new Data($request->all());
        $conta = ContaPagar::find($data->id);

        if (!$conta) {
            $this->message->warning("Conta não encontrada");
            $this->router->redirect("admin.financeiro.conta.pagar.index");
            return;
        }

        $fornecedores = Fornecedor::orderBy("nome")->get();
        $planosConta = PlanoConta::where("ativo", "=", 1)->where("tipo", "=", "DESPESA")->orderBy("codigo")->get();
        $centrosCusto = CentroCusto::where("ativo", "=", 1)->orderBy("nome")->get();

        $parcelas = [];
        if ((int) $conta->parcela_total > 1) {
            $origemId = (int) ($conta->parcela_origem_id ?: $conta->id);
            $rows = DB::execute(
                "SELECT * FROM conta_pagar
                 WHERE parcela_origem_id = ?
                 ORDER BY parcela_numero",
                [$origemId]
            );
            if (is_array($rows) && count($rows) > 0) {
                $parcelas = $rows;
            } elseif (!empty($conta->documento)) {
                $rows = DB::execute(
                    "SELECT * FROM conta_pagar
                     WHERE documento = ?
                     ORDER BY parcela_numero",
                    [$conta->documento]
                );
                if (is_array($rows) && count($rows) > 1) {
                    $parcelas = $rows;
                }
            }
        }

        echo $this->view->render("admin/financeiro/conta-pagar/form", [
            "csrf" => $this->csrf->generate(),
            "conta" => $conta,
            "parcelas" => $parcelas,
            "url_action" => $this->router->route("admin.financeiro.conta.pagar.update"),
            "fornecedores" => $fornecedores,
            "planos_conta" => $planosConta,
            "centros_custo" => $centrosCusto,
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("conta_pagar_editar");

        $data = new Data($request->all());
        $conta = ContaPagar::find($data->id);

        if (!$conta) {
            $this->message->warning("Conta não encontrada");
            $this->router->redirect("admin.financeiro.conta.pagar.index");
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"], $payload["num_parcelas"], $payload["intervalo_parcelas"]);

        $payload["valor"] = money2float((string) ($payload["valor"] ?? "0"));
        $payload["id_fornecedor"] = !empty($payload["id_fornecedor"]) ? (int) $payload["id_fornecedor"] : null;
        $payload["id_plano_conta"] = !empty($payload["id_plano_conta"]) ? (int) $payload["id_plano_conta"] : null;
        $payload["id_centro_custo"] = !empty($payload["id_centro_custo"]) ? (int) $payload["id_centro_custo"] : null;
        $payload["data_pagamento"] = !empty($payload["data_pagamento"]) ? $payload["data_pagamento"] : null;
        $payload["updated_by"] = $this->user->uid;

        ContaPagar::updateBy($conta->id, $payload);

        $this->message->success("Conta atualizada com sucesso");
        $this->router->redirect("admin.financeiro.conta.pagar.index");
    }

    public function baixar(Request $request): void
    {
        header("Content-Type: application/json; charset=utf-8");

        if (!$this->auth->allow("conta_pagar_editar")) {
            http_response_code(403);
            echo json_encode(["error" => true, "message" => "Sem permissão."], JSON_UNESCAPED_UNICODE);
            return;
        }

        $data = new Data($request->all());
        $conta = ContaPagar::find($data->id);

        if (!$conta) {
            http_response_code(404);
            echo json_encode(["error" => true, "message" => "Conta não encontrada."], JSON_UNESCAPED_UNICODE);
            return;
        }

        if ($conta->status === "PAGO") {
            echo json_encode(["error" => true, "message" => "Conta já está paga."], JSON_UNESCAPED_UNICODE);
            return;
        }

        $dataPagamento = $data->has("data_pagamento") ? (string) $data->data_pagamento : date("Y-m-d");

        ContaPagar::updateBy($conta->id, [
            "status" => "PAGO",
            "data_pagamento" => $dataPagamento,
            "updated_by" => $this->user->uid,
        ]);

        echo json_encode(["error" => false, "message" => "Conta baixada com sucesso."], JSON_UNESCAPED_UNICODE);
    }

    public function delete(Request $request): void
    {
        $this->authorize("conta_pagar_excluir");

        $data = new Data($request->all());
        $conta = ContaPagar::find($data->id);

        if (!$conta) {
            $this->message->warning("Conta não encontrada");
            Redirect::referer();
            return;
        }

        ContaPagar::deleteById($conta->id);

        $this->message->success("Conta removida com sucesso");
        Redirect::referer();
    }
}
