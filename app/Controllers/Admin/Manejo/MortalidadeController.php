<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MotivoPerda;
use App\Models\Manejo\MovimentacaoMortalidade;

class MortalidadeController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Mortalidade / Perda",
            "active_menu" => "manejo-mortalidades",
            "page" => [
                "title" => "Mortalidade / Perda",
                "desc" => "Registre baixas técnicas por morte, descarte ou perda",
            ],
            "uppers" => implode(",", MovimentacaoMortalidade::getUppers()),
            "required" => implode(",", MovimentacaoMortalidade::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("mortalidade_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Manejo" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Mortalidade de " . $lote->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Mortalidade / Perda"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = MovimentacaoMortalidade::leftJoin("lote as l", "mm.id_lote", "=", "l.id")
            ->leftJoin("motivo_perda as mp", "mm.id_motivo_perda", "=", "mp.id")
            ->select("mm.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "mp.descricao as motivo_descricao");

        if ($idLote) {
            $query = $query->where("mm.id_lote", "=", $idLote);
        }

        $dados = $query->orderBy("mm.data_ocorrencia", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
        }

        echo $this->view->render("admin/manejo/mortalidade/index", [
            "dados" => $dados,
            "lote" => $lote,
            "permissao" => [
                "inserir" => $this->auth->allow("mortalidade_inserir"),
                "editar" => $this->auth->allow("mortalidade_editar"),
                "excluir" => $this->auth->allow("mortalidade_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("mortalidade_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;

        echo $this->view->render("admin/manejo/mortalidade/form", [
            "csrf" => $this->csrf->generate(),
            "mortalidade" => false,
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "motivos" => $this->motivos(),
            "url_action" => $this->router->route("admin.manejo.mortalidade.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("mortalidade_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("data_ocorrencia") || !$data->has("quantidade")) {
            $this->message->warning("Selecione o lote, a data e a quantidade");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        MovimentacaoMortalidade::create($payload);
        $this->message->success("Ocorrência registrada com sucesso");
        $this->router->redirect("admin.manejo.mortalidade.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("mortalidade_editar");
        $data = new Data($request->all());
        $mortalidade = MovimentacaoMortalidade::find($data->id) ?: MovimentacaoMortalidade::findByMd5($data->id);

        if (!$mortalidade) {
            $this->message->warning("Ocorrência não encontrada");
            $this->router->redirect("admin.manejo.mortalidade.index");
            return;
        }

        echo $this->view->render("admin/manejo/mortalidade/form", [
            "csrf" => $this->csrf->generate(),
            "mortalidade" => $mortalidade,
            "id_lote" => (int) $mortalidade->id_lote,
            "lotes" => $this->lotes(),
            "motivos" => $this->motivos(),
            "url_action" => $this->router->route("admin.manejo.mortalidade.update"),
            "url_voltar" => $this->urlVoltar((int) $mortalidade->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("mortalidade_editar");
        $data = new Data($request->all());
        $mortalidade = MovimentacaoMortalidade::find($data->id) ?: MovimentacaoMortalidade::findByMd5($data->id);

        if (!$mortalidade) {
            $this->message->warning("Ocorrência não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_ocorrencia") || !$data->has("quantidade")) {
            $this->message->warning("Selecione o lote, a data e a quantidade");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        MovimentacaoMortalidade::updateBy($mortalidade->id, $payload);
        $this->message->success("Ocorrência atualizada com sucesso");
        $this->router->redirect("admin.manejo.mortalidade.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("mortalidade_excluir");
        $data = new Data($request->all());
        $mortalidade = MovimentacaoMortalidade::find($data->id) ?: MovimentacaoMortalidade::findByMd5($data->id);

        if (!$mortalidade) {
            $this->message->warning("Ocorrência não encontrada");
            Redirect::referer();
            return;
        }

        MovimentacaoMortalidade::deleteById($mortalidade->id);
        $this->message->success("Ocorrência removida com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_motivo_perda");
        $data->nullIfEmpty("responsavel");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        return $payload;
    }

    private function urlVoltar(?int $idLote): string
    {
        return $idLote
            ? $this->router->route("admin.manejo.mortalidade.index", ["id_lote" => $idLote])
            : $this->router->route("admin.manejo.mortalidade.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function motivos(): array
    {
        return MotivoPerda::orderBy("descricao")->get();
    }
}
