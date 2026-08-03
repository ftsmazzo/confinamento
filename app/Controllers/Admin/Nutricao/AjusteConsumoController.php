<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\Lote;
use App\Models\Nutricao\AjusteConsumo;
use App\Models\Nutricao\LeituraCocho;
use App\Services\Nutricao\SugestaoAjusteCochoService;

class AjusteConsumoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Ajuste de Consumo",
            "active_menu" => "nutricao-ajustes-consumo",
            "page" => [
                "title" => "Ajuste de Consumo",
                "desc" => "Correção da quantidade de ração prevista a partir da leitura de cocho",
            ],
            "uppers" => implode(",", AjusteConsumo::getUppers()),
            "required" => implode(",", AjusteConsumo::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("ajuste_consumo_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Nutrição" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Ajustes de Consumo de " . $lote->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Ajuste de Consumo"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = AjusteConsumo::leftJoin("lote as l", "ac.id_lote", "=", "l.id")
            ->leftJoin("leitura_cocho as lc", "ac.id_leitura_cocho", "=", "lc.id")
            ->select("ac.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "lc.escore as leitura_escore");

        if ($idLote) {
            $query = $query->where("ac.id_lote", "=", $idLote);
        }

        $dados = $query->orderBy("ac.data_ajuste", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
            $item->leitura_escore_label = $item->leitura_escore !== null ? LeituraCocho::escoreLabel((int) $item->leitura_escore) : null;
        }

        echo $this->view->render("admin/nutricao/ajuste-consumo/index", [
            "dados" => $dados,
            "lote" => $lote,
            "permissao" => [
                "inserir" => $this->auth->allow("ajuste_consumo_inserir"),
                "editar" => $this->auth->allow("ajuste_consumo_editar"),
                "excluir" => $this->auth->allow("ajuste_consumo_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("ajuste_consumo_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $idLeitura = $data->has("id_leitura_cocho") ? (int) $data->id_leitura_cocho : null;

        $ajuste = $this->prefillNovo($idLote, $idLeitura);
        if (!empty($ajuste->id_lote)) {
            $idLote = (int) $ajuste->id_lote;
        }

        echo $this->view->render("admin/nutricao/ajuste-consumo/form", [
            "csrf" => $this->csrf->generate(),
            "ajuste" => $ajuste,
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "leituras" => $this->leituras($idLote),
            "sugestao" => $ajuste->sugestao ?? null,
            "url_action" => $this->router->route("admin.nutricao.ajuste.consumo.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("ajuste_consumo_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("data_ajuste") || (!$data->has("percentual_ajuste") && !$data->has("quantidade_ajustada"))) {
            $this->message->warning("Selecione o lote, a data e informe o percentual ou a quantidade ajustada");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        AjusteConsumo::create($payload);
        $this->message->success("Ajuste de consumo registrado com sucesso");
        $this->router->redirect("admin.nutricao.ajuste.consumo.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("ajuste_consumo_editar");
        $data = new Data($request->all());
        $ajuste = AjusteConsumo::find($data->id) ?: AjusteConsumo::findByMd5($data->id);

        if (!$ajuste) {
            $this->message->warning("Ajuste não encontrado");
            $this->router->redirect("admin.nutricao.ajuste.consumo.index");
            return;
        }

        echo $this->view->render("admin/nutricao/ajuste-consumo/form", [
            "csrf" => $this->csrf->generate(),
            "ajuste" => $ajuste,
            "id_lote" => (int) $ajuste->id_lote,
            "lotes" => $this->lotes(),
            "leituras" => $this->leituras((int) $ajuste->id_lote),
            "sugestao" => null,
            "url_action" => $this->router->route("admin.nutricao.ajuste.consumo.update"),
            "url_voltar" => $this->urlVoltar((int) $ajuste->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("ajuste_consumo_editar");
        $data = new Data($request->all());
        $ajuste = AjusteConsumo::find($data->id) ?: AjusteConsumo::findByMd5($data->id);

        if (!$ajuste) {
            $this->message->warning("Ajuste não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_ajuste") || (!$data->has("percentual_ajuste") && !$data->has("quantidade_ajustada"))) {
            $this->message->warning("Selecione o lote, a data e informe o percentual ou a quantidade ajustada");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        AjusteConsumo::updateBy($ajuste->id, $payload);
        $this->message->success("Ajuste de consumo atualizado com sucesso");
        $this->router->redirect("admin.nutricao.ajuste.consumo.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("ajuste_consumo_excluir");
        $data = new Data($request->all());
        $ajuste = AjusteConsumo::find($data->id) ?: AjusteConsumo::findByMd5($data->id);

        if (!$ajuste) {
            $this->message->warning("Ajuste não encontrado");
            Redirect::referer();
            return;
        }

        AjusteConsumo::deleteById($ajuste->id);
        $this->message->success("Ajuste de consumo removido com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_leitura_cocho");
        $data->nullIfEmpty("percentual_ajuste");
        $data->nullIfEmpty("quantidade_ajustada");
        $data->nullIfEmpty("motivo");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        if (!empty($payload["percentual_ajuste"])) {
            $payload["percentual_ajuste"] = (float) str_replace(",", ".", (string) $payload["percentual_ajuste"]);
        }

        if (!empty($payload["quantidade_ajustada"])) {
            $payload["quantidade_ajustada"] = (float) str_replace(",", ".", (string) $payload["quantidade_ajustada"]);
        }

        return $payload;
    }

    private function urlVoltar(?int $idLote): string
    {
        return $idLote
            ? $this->router->route("admin.nutricao.ajuste.consumo.index", ["id_lote" => $idLote])
            : $this->router->route("admin.nutricao.ajuste.consumo.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function leituras(?int $idLote): array
    {
        if (!$idLote) {
            return [];
        }

        return LeituraCocho::where("id_lote", "=", $idLote)
            ->orderBy("data_leitura", "desc")
            ->get();
    }

    /**
     * Prefill a partir da leitura (query) ou da última com escore do lote.
     * Apenas sugere — gravar o ajuste continua manual.
     */
    private function prefillNovo(?int $idLote, ?int $idLeitura): object
    {
        $ajuste = (object) [
            "id_lote" => $idLote,
            "id_leitura_cocho" => $idLeitura,
            "data_ajuste" => date("Y-m-d"),
            "percentual_ajuste" => null,
            "quantidade_ajustada" => null,
            "motivo" => null,
            "observacao" => null,
            "sugestao" => null,
        ];

        $leitura = null;
        if ($idLeitura) {
            $leitura = LeituraCocho::find($idLeitura);
        } elseif ($idLote) {
            $leituras = LeituraCocho::where("id_lote", "=", $idLote)
                ->whereNotNull("escore")
                ->orderBy("data_leitura", "desc")
                ->orderBy("id", "desc")
                ->limit(1)
                ->get();
            $leitura = $leituras[0] ?? null;
        }

        if (!$leitura || $leitura->escore === null || $leitura->escore === "") {
            return $ajuste;
        }

        $sugestao = (new SugestaoAjusteCochoService())->sugerir((int) $leitura->escore);
        if ($sugestao === null) {
            return $ajuste;
        }

        $ajuste->id_lote = (int) $leitura->id_lote;
        $ajuste->id_leitura_cocho = (int) $leitura->id;
        $ajuste->percentual_ajuste = $sugestao["percentual"];
        $ajuste->motivo = "Sugestão por escore " . $sugestao["escore"] . " (" . $sugestao["escore_label"] . ")";
        $ajuste->sugestao = $sugestao;

        return $ajuste;
    }
}
