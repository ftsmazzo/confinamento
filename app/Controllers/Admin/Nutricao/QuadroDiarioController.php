<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Request;
use App\Models\Confinamento\Curral;
use App\Services\Nutricao\QuadroDiarioService;

class QuadroDiarioController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Quadro do Dia",
            "active_menu" => "nutricao-quadro-diario",
            "page" => [
                "title" => "Quadro do Dia",
                "desc" => "Previsto × ocorrido por turno, dieta e custo alimentar do dia",
            ],
        ]);
    }

    public function index(Request $request): void
    {
        if (
            !$this->auth->allow("programacao_trato_gerenciar")
            && !$this->auth->allow("fornecimento_trato_gerenciar")
        ) {
            $this->authorize("programacao_trato_gerenciar");
            return;
        }

        $data = new Data($request->all());
        $dataRef = $data->has("data") ? (string) $data->data : date("Y-m-d");
        $linha = $data->has("linha") ? trim((string) $data->linha) : "";
        $idCurral = $data->has("id_curral") ? (int) $data->id_curral : 0;

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Quadro do Dia" => ["url" => false, "current" => true],
            ],
        ]);

        $service = new QuadroDiarioService();
        $quadro = $service->montar(
            $dataRef,
            $linha !== "" ? $linha : null,
            $idCurral > 0 ? $idCurral : null
        );

        $currais = Curral::orderBy("nome")->get();
        $linhasFiltro = [];
        foreach ($currais as $c) {
            if (!empty($c->linha)) {
                $linhasFiltro[(string) $c->linha] = true;
            }
        }
        ksort($linhasFiltro);

        echo $this->view->render("admin/nutricao/quadro-diario/index", [
            "data" => $dataRef,
            "linha" => $linha,
            "id_curral" => $idCurral > 0 ? $idCurral : null,
            "linhas" => $quadro["linhas"],
            "totais" => $quadro["totais"],
            "turnosLabel" => $quadro["turnos_label"],
            "turnos" => QuadroDiarioService::TURNOS,
            "currais" => $currais,
            "linhasFiltro" => array_keys($linhasFiltro),
            "podeGerar" => $this->auth->allow("programacao_trato_inserir"),
            "podeFornecer" => $this->auth->allow("fornecimento_trato_inserir"),
            "podeAjustar" => $this->auth->allow("ajuste_consumo_inserir"),
        ]);
    }
}
