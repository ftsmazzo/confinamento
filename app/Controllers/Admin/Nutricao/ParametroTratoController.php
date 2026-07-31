<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Request;
use App\Services\Nutricao\PrevisaoTratoService;

class ParametroTratoController extends ControllerAdmin
{
    private PrevisaoTratoService $service;

    public function __construct()
    {
        parent::__construct();
        $this->service = new PrevisaoTratoService();

        $this->view->addData([
            "title" => "Parâmetros do Trato",
            "active_menu" => "nutricao-parametros-trato",
            "page" => [
                "title" => "Parâmetros do Trato",
                "desc" => "GMD, % do peso vivo, rateio dos 4 turnos e limiares de alerta de permanência",
            ],
        ]);
    }

    public function edit(): void
    {
        $this->authorize("programacao_trato_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Parâmetros do Trato" => ["url" => false, "current" => true],
            ],
        ]);

        $params = $this->service->parametros();

        echo $this->view->render("admin/nutricao/parametro-trato/form", [
            "csrf" => $this->csrf->generate(),
            "params" => $params,
            "turnosLabel" => PrevisaoTratoService::TURNOS_LABEL,
            "url_action" => $this->router->route("admin.nutricao.parametro.trato.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("programacao_trato_gerenciar");
        $post = $request->all();

        $gmd = $this->parseDecimal($post["trato_gmd"] ?? "");
        $pctPv = $this->parseDecimal($post["trato_pct_peso_vivo"] ?? "");
        $t1 = $this->parseDecimal($post["trato_turno_1_pct"] ?? "");
        $t2 = $this->parseDecimal($post["trato_turno_2_pct"] ?? "");
        $t3 = $this->parseDecimal($post["trato_turno_3_pct"] ?? "");
        $t4 = $this->parseDecimal($post["trato_turno_4_pct"] ?? "");
        $alerta = (int) ($post["trato_alerta_dias"] ?? 100);
        $risco = (int) ($post["trato_alerta_risco_dias"] ?? 110);

        if ($gmd <= 0 || $pctPv <= 0) {
            $this->message->warning("Informe GMD e % do peso vivo válidos");
            $this->router->redirect("admin.nutricao.parametro.trato.editar");
            return;
        }

        $somaTurnos = $t1 + $t2 + $t3 + $t4;
        if (abs($somaTurnos - 100) > 0.05) {
            $this->message->warning("A soma dos % dos turnos deve ser 100% (atual: " . number_format($somaTurnos, 1, ",", ".") . "%)");
            $this->router->redirect("admin.nutricao.parametro.trato.editar");
            return;
        }

        if ($alerta <= 0 || $risco < $alerta) {
            $this->message->warning("Limiar de risco deve ser maior ou igual ao de atenção");
            $this->router->redirect("admin.nutricao.parametro.trato.editar");
            return;
        }

        $this->service->salvarParametros([
            "trato_gmd" => $gmd,
            "trato_pct_peso_vivo" => $pctPv,
            "trato_turno_1_pct" => $t1,
            "trato_turno_2_pct" => $t2,
            "trato_turno_3_pct" => $t3,
            "trato_turno_4_pct" => $t4,
            "trato_alerta_dias" => $alerta,
            "trato_alerta_risco_dias" => $risco,
        ], (int) $this->user->uid);

        $this->message->success("Parâmetros do trato atualizados");
        $this->router->redirect("admin.nutricao.parametro.trato.editar");
    }

    private function parseDecimal(mixed $valor): float
    {
        $valor = trim((string) $valor);
        if ($valor === "") {
            return 0.0;
        }

        if (function_exists("money2float")) {
            return (float) money2float($valor);
        }

        return (float) str_replace(",", ".", str_replace(".", "", $valor));
    }
}
