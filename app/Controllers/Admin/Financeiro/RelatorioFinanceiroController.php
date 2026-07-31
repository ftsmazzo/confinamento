<?php

namespace App\Controllers\Admin\Financeiro;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\DB;
use App\Core\Request;

class RelatorioFinanceiroController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Relatórios Financeiros",
        ]);
    }

    public function extrato(Request $request): void
    {
        $this->authorize("relatorio_financeiro_visualizar");

        $data = new Data($request->all());
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : date("Y-m-d", strtotime("-3 months"));
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : date("Y-m-d");

        $this->view->addData([
            "active_menu" => "relatorios-financeiro-extrato",
            "page" => [
                "title" => "Extrato Financeiro",
                "desc" => "Todas as contas a pagar e receber em um período",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Financeiro" => ["url" => false, "current" => false],
                "Extrato Financeiro" => ["url" => false, "current" => true],
            ],
        ]);

        $contasPagar = DB::execute(
            "SELECT cp.*, f.nome AS pessoa_nome, pc.nome AS plano_conta_nome
             FROM conta_pagar cp
             LEFT JOIN fornecedor f ON f.id = cp.id_fornecedor
             LEFT JOIN plano_conta pc ON pc.id = cp.id_plano_conta
             WHERE cp.data_vencimento BETWEEN ? AND ?
             ORDER BY cp.data_vencimento",
            [$dataInicial, $dataFinal]
        );

        $contasReceber = DB::execute(
            "SELECT cr.*, cl.nome AS pessoa_nome, pc.nome AS plano_conta_nome
             FROM conta_receber cr
             LEFT JOIN cliente cl ON cl.id = cr.id_cliente
             LEFT JOIN plano_conta pc ON pc.id = cr.id_plano_conta
             WHERE cr.data_vencimento BETWEEN ? AND ?
             ORDER BY cr.data_vencimento",
            [$dataInicial, $dataFinal]
        );

        $lancamentos = [];
        foreach ($contasPagar as $c) {
            $c->tipo_label = "Pagar";
            $c->tipo_badge = "bg-danger";
            $lancamentos[] = $c;
        }
        foreach ($contasReceber as $c) {
            $c->tipo_label = "Receber";
            $c->tipo_badge = "bg-success";
            $lancamentos[] = $c;
        }

        usort($lancamentos, fn ($a, $b) => strcmp($a->data_vencimento, $b->data_vencimento));

        $totalReceber = 0;
        $totalPagar = 0;
        $pagos = 0;
        $pendentes = 0;
        foreach ($lancamentos as $l) {
            if ($l->tipo_badge === "bg-success") {
                $totalReceber += (float) $l->valor;
            } else {
                $totalPagar += (float) $l->valor;
            }
            if (in_array($l->status ?? "", ["PAGO", "RECEBIDO"])) {
                $pagos += (float) $l->valor;
            } else {
                $pendentes += (float) $l->valor;
            }
        }

        $graficoMensal = DB::execute(
            "SELECT
                DATE_FORMAT(data, '%Y-%m') AS mes,
                SUM(CASE WHEN tipo = 'RECEBER' THEN valor ELSE 0 END) AS entradas,
                SUM(CASE WHEN tipo = 'PAGAR' THEN valor ELSE 0 END) AS saidas
             FROM (
                SELECT data_vencimento AS data, valor, 'RECEBER' AS tipo FROM conta_receber
                UNION ALL
                SELECT data_vencimento AS data, valor, 'PAGAR' AS tipo FROM conta_pagar
             ) AS todos
             WHERE data BETWEEN ? AND ?
             GROUP BY DATE_FORMAT(data, '%Y-%m')
             ORDER BY mes",
            [$dataInicial, $dataFinal]
        );

        echo $this->view->render("admin/financeiro/relatorio/extrato", [
            "lancamentos" => $lancamentos,
            "dataInicial" => $dataInicial,
            "dataFinal" => $dataFinal,
            "totalReceber" => $totalReceber,
            "totalPagar" => $totalPagar,
            "pagos" => $pagos,
            "pendentes" => $pendentes,
            "graficoMensal" => $graficoMensal,
        ]);
    }

    public function fluxoCaixa(Request $request): void
    {
        $this->authorize("relatorio_financeiro_visualizar");

        $data = new Data($request->all());
        $meses = max(1, min(24, (int) ($data->meses ?? 6)));
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : date("Y-m-01");
        $dataFinal = date("Y-m-t", strtotime($dataInicial . " + " . ($meses - 1) . " months"));

        $this->view->addData([
            "active_menu" => "relatorios-financeiro-fluxo-caixa",
            "page" => [
                "title" => "Fluxo de Caixa",
                "desc" => "Projeção de entradas e saídas por mês",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Financeiro" => ["url" => false, "current" => false],
                "Fluxo de Caixa" => ["url" => false, "current" => true],
            ],
        ]);

        $mesesData = [];
        for ($i = 0; $i < $meses; $i++) {
            $mes = date("Y-m", strtotime($dataInicial . " + {$i} months"));
            $mesesData[$mes] = ["entradas" => 0, "saidas" => 0, "saldo" => 0];
        }

        $contasPagar = DB::execute(
            "SELECT cp.valor, cp.data_vencimento
             FROM conta_pagar cp
             WHERE cp.data_vencimento BETWEEN ? AND ?",
            [$dataInicial, $dataFinal]
        );

        foreach ((array) $contasPagar as $cp) {
            $mes = date("Y-m", strtotime($cp->data_vencimento));
            if (isset($mesesData[$mes])) {
                $mesesData[$mes]["saidas"] += (float) $cp->valor;
            }
        }

        $contasReceber = DB::execute(
            "SELECT cr.valor, cr.data_vencimento
             FROM conta_receber cr
             WHERE cr.data_vencimento BETWEEN ? AND ?",
            [$dataInicial, $dataFinal]
        );

        foreach ((array) $contasReceber as $cr) {
            $mes = date("Y-m", strtotime($cr->data_vencimento));
            if (isset($mesesData[$mes])) {
                $mesesData[$mes]["entradas"] += (float) $cr->valor;
            }
        }

        $acumulado = 0;
        foreach ($mesesData as $mes => &$vals) {
            $vals["entradas"] = round($vals["entradas"], 2);
            $vals["saidas"] = round($vals["saidas"], 2);
            $vals["saldo"] = round($vals["entradas"] - $vals["saidas"], 2);
            $acumulado += $vals["saldo"];
            $vals["acumulado"] = round($acumulado, 2);
        }
        unset($vals);

        echo $this->view->render("admin/financeiro/relatorio/fluxo-caixa", [
            "mesesData" => $mesesData,
            "dataInicial" => $dataInicial,
            "meses" => $meses,
        ]);
    }

    public function dre(Request $request): void
    {
        $this->authorize("relatorio_financeiro_visualizar");

        $data = new Data($request->all());
        $dataInicial = $data->has("data_inicial") ? (string) $data->data_inicial : date("Y-m-d", strtotime("-12 months"));
        $dataFinal = $data->has("data_final") ? (string) $data->data_final : date("Y-m-d");

        $this->view->addData([
            "active_menu" => "relatorios-financeiro-dre",
            "page" => [
                "title" => "DRE Simplificado",
                "desc" => "Demonstrativo de receitas e despesas por plano de contas",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Financeiro" => ["url" => false, "current" => false],
                "DRE Simplificado" => ["url" => false, "current" => true],
            ],
        ]);

        $receitas = DB::execute(
            "SELECT pc.id, pc.codigo, pc.nome, COALESCE(SUM(cr.valor), 0) AS total
             FROM plano_conta pc
             LEFT JOIN conta_receber cr ON cr.id_plano_conta = pc.id
                AND cr.status = 'RECEBIDO'
                AND cr.data_recebimento BETWEEN ? AND ?
             WHERE pc.tipo = 'RECEITA'
             GROUP BY pc.id, pc.codigo, pc.nome
             ORDER BY pc.codigo",
            [$dataInicial, $dataFinal]
        );

        $despesas = DB::execute(
            "SELECT pc.id, pc.codigo, pc.nome, COALESCE(SUM(cp.valor), 0) AS total
             FROM plano_conta pc
             LEFT JOIN conta_pagar cp ON cp.id_plano_conta = pc.id
                AND cp.status = 'PAGO'
                AND cp.data_pagamento BETWEEN ? AND ?
             WHERE pc.tipo = 'DESPESA'
             GROUP BY pc.id, pc.codigo, pc.nome
             ORDER BY pc.codigo",
            [$dataInicial, $dataFinal]
        );

        $totalReceitas = 0;
        foreach ((array) $receitas as $r) {
            $totalReceitas += (float) $r->total;
        }
        $totalDespesas = 0;
        foreach ((array) $despesas as $d) {
            $totalDespesas += (float) $d->total;
        }
        $resultado = $totalReceitas - $totalDespesas;

        echo $this->view->render("admin/financeiro/relatorio/dre", [
            "receitas" => $receitas,
            "despesas" => $despesas,
            "totalReceitas" => $totalReceitas,
            "totalDespesas" => $totalDespesas,
            "resultado" => $resultado,
            "dataInicial" => $dataInicial,
            "dataFinal" => $dataFinal,
        ]);
    }
}
