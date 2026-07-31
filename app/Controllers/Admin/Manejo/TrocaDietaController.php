<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MovimentacaoDieta;
use App\Models\Nutricao\FormulaRacao;

class TrocaDietaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Trocas de Dieta",
            "active_menu" => "manejo-trocas-dieta",
            "page" => [
                "title" => "Trocas de Dieta",
                "desc" => "Histórico de mudança de fórmula alimentar dos lotes",
            ],
            "required" => implode(",", MovimentacaoDieta::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("troca_dieta_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Manejo" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Trocas de Dieta de " . $lote->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Trocas de Dieta"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = MovimentacaoDieta::leftJoin("lote as l", "md.id_lote", "=", "l.id")
            ->leftJoin("formula_racao as fr", "md.id_formula_racao", "=", "fr.id")
            ->select("md.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "fr.nome as formula_nome");

        if ($idLote) {
            $query = $query->where("md.id_lote", "=", $idLote);
        }

        $dados = $query->orderBy("md.data_troca", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
        }

        echo $this->view->render("admin/manejo/troca-dieta/index", [
            "dados" => $dados,
            "lote" => $lote,
            "permissao" => [
                "inserir" => $this->auth->allow("troca_dieta_inserir"),
                "editar" => $this->auth->allow("troca_dieta_editar"),
                "excluir" => $this->auth->allow("troca_dieta_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("troca_dieta_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;

        echo $this->view->render("admin/manejo/troca-dieta/form", [
            "csrf" => $this->csrf->generate(),
            "troca" => false,
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "formulas" => $this->formulas(),
            "url_action" => $this->router->route("admin.manejo.troca.dieta.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("troca_dieta_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("id_formula_racao") || !$data->has("data_troca")) {
            $this->message->warning("Selecione o lote, a fórmula de ração e a data da troca");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        MovimentacaoDieta::create($payload);
        $this->message->success("Troca de dieta registrada com sucesso");
        $this->router->redirect("admin.manejo.troca.dieta.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("troca_dieta_editar");
        $data = new Data($request->all());
        $troca = MovimentacaoDieta::find($data->id) ?: MovimentacaoDieta::findByMd5($data->id);

        if (!$troca) {
            $this->message->warning("Troca de dieta não encontrada");
            $this->router->redirect("admin.manejo.troca.dieta.index");
            return;
        }

        echo $this->view->render("admin/manejo/troca-dieta/form", [
            "csrf" => $this->csrf->generate(),
            "troca" => $troca,
            "id_lote" => (int) $troca->id_lote,
            "lotes" => $this->lotes(),
            "formulas" => $this->formulas(),
            "url_action" => $this->router->route("admin.manejo.troca.dieta.update"),
            "url_voltar" => $this->urlVoltar((int) $troca->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("troca_dieta_editar");
        $data = new Data($request->all());
        $troca = MovimentacaoDieta::find($data->id) ?: MovimentacaoDieta::findByMd5($data->id);

        if (!$troca) {
            $this->message->warning("Troca de dieta não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("id_formula_racao") || !$data->has("data_troca")) {
            $this->message->warning("Selecione o lote, a fórmula de ração e a data da troca");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        MovimentacaoDieta::updateBy($troca->id, $payload);
        $this->message->success("Troca de dieta atualizada com sucesso");
        $this->router->redirect("admin.manejo.troca.dieta.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("troca_dieta_excluir");
        $data = new Data($request->all());
        $troca = MovimentacaoDieta::find($data->id) ?: MovimentacaoDieta::findByMd5($data->id);

        if (!$troca) {
            $this->message->warning("Troca de dieta não encontrada");
            Redirect::referer();
            return;
        }

        MovimentacaoDieta::deleteById($troca->id);
        $this->message->success("Troca de dieta removida com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("motivo");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        return $payload;
    }

    private function urlVoltar(?int $idLote): string
    {
        return $idLote
            ? $this->router->route("admin.manejo.troca.dieta.index", ["id_lote" => $idLote])
            : $this->router->route("admin.manejo.troca.dieta.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function formulas(): array
    {
        return FormulaRacao::orderBy("nome")->get();
    }
}
