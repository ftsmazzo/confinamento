<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Curral;
use App\Models\Confinamento\Piquete;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MovimentacaoLocalizacao;

class LocalizacaoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Localizações",
            "active_menu" => "manejo-localizacoes",
            "page" => [
                "title" => "Localizações",
                "desc" => "Histórico de alocação e transferência de lotes entre currais/piquetes",
            ],
            "required" => implode(",", MovimentacaoLocalizacao::getRequired()),
        ]);
    }

    /**
     * Lista o historico de localizacao, opcionalmente filtrado por lote
     * (?id_lote=).
     */
    public function index(Request $request): void
    {
        $this->authorize("localizacao_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Manejo" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Localizações de " . $lote->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Localizações"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = MovimentacaoLocalizacao::leftJoin("lote as l", "ml.id_lote", "=", "l.id")
            ->leftJoin("curral as co", "ml.id_curral_origem", "=", "co.id")
            ->leftJoin("piquete as po", "ml.id_piquete_origem", "=", "po.id")
            ->leftJoin("curral as cd", "ml.id_curral_destino", "=", "cd.id")
            ->leftJoin("piquete as pd", "ml.id_piquete_destino", "=", "pd.id")
            ->select(
                "ml.*",
                "l.nome as lote_nome",
                "l.codigo as lote_codigo",
                "co.nome as curral_origem_nome",
                "po.nome as piquete_origem_nome",
                "cd.nome as curral_destino_nome",
                "pd.nome as piquete_destino_nome"
            );

        if ($idLote) {
            $query = $query->where("ml.id_lote", "=", $idLote);
        }

        $dados = $query->orderBy("ml.data_movimentacao", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->origem_print = $item->curral_origem_nome ?: ($item->piquete_origem_nome ?: "Entrada inicial");
            $item->destino_print = $item->curral_destino_nome ?: ($item->piquete_destino_nome ?: "-");
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
        }

        echo $this->view->render("admin/manejo/localizacao/index", [
            "dados" => $dados,
            "lote" => $lote,
            "permissao" => [
                "inserir" => $this->auth->allow("localizacao_inserir"),
                "editar" => $this->auth->allow("localizacao_editar"),
                "excluir" => $this->auth->allow("localizacao_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("localizacao_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        echo $this->view->render("admin/manejo/localizacao/form", [
            "csrf" => $this->csrf->generate(),
            "localizacao" => false,
            "id_lote" => $idLote,
            "lote" => $lote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "piquetes" => $this->piquetes(),
            "url_action" => $this->router->route("admin.manejo.localizacao.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("localizacao_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("data_movimentacao")) {
            $this->message->warning("Selecione o lote e informe a data da movimentação");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_curral_destino") && !$data->has("id_piquete_destino")) {
            $this->message->warning("Informe o curral ou piquete de destino");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        MovimentacaoLocalizacao::create($payload);

        // Espelha a localizacao atual no proprio lote, para leitura rapida
        // sem precisar consultar o historico toda vez.
        Lote::updateBy((int) $payload["id_lote"], [
            "id_curral" => $payload["id_curral_destino"] ?? null,
            "id_piquete" => $payload["id_piquete_destino"] ?? null,
            "updated_by" => $this->user->uid,
        ]);

        $this->message->success("Localização registrada com sucesso");
        $this->router->redirect("admin.manejo.localizacao.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("localizacao_editar");
        $data = new Data($request->all());
        $localizacao = MovimentacaoLocalizacao::find($data->id) ?: MovimentacaoLocalizacao::findByMd5($data->id);

        if (!$localizacao) {
            $this->message->warning("Registro de localização não encontrado");
            $this->router->redirect("admin.manejo.localizacao.index");
            return;
        }

        echo $this->view->render("admin/manejo/localizacao/form", [
            "csrf" => $this->csrf->generate(),
            "localizacao" => $localizacao,
            "id_lote" => $localizacao->id_lote,
            "lote" => Lote::find($localizacao->id_lote),
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "piquetes" => $this->piquetes(),
            "url_action" => $this->router->route("admin.manejo.localizacao.update"),
            "url_voltar" => $this->urlVoltar((int) $localizacao->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("localizacao_editar");
        $data = new Data($request->all());
        $localizacao = MovimentacaoLocalizacao::find($data->id) ?: MovimentacaoLocalizacao::findByMd5($data->id);

        if (!$localizacao) {
            $this->message->warning("Registro de localização não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_movimentacao")) {
            $this->message->warning("Selecione o lote e informe a data da movimentação");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_curral_destino") && !$data->has("id_piquete_destino")) {
            $this->message->warning("Informe o curral ou piquete de destino");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        MovimentacaoLocalizacao::updateBy($localizacao->id, $payload);

        // Se este for o registro mais recente do lote, reflete no lote tambem.
        $maisRecente = MovimentacaoLocalizacao::where("id_lote", "=", (int) $payload["id_lote"])
            ->orderBy("data_movimentacao", "desc")
            ->first();

        if ($maisRecente && (int) $maisRecente->id === (int) $localizacao->id) {
            Lote::updateBy((int) $payload["id_lote"], [
                "id_curral" => $payload["id_curral_destino"] ?? null,
                "id_piquete" => $payload["id_piquete_destino"] ?? null,
                "updated_by" => $this->user->uid,
            ]);
        }

        $this->message->success("Localização atualizada com sucesso");
        $this->router->redirect("admin.manejo.localizacao.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("localizacao_excluir");
        $data = new Data($request->all());
        $localizacao = MovimentacaoLocalizacao::find($data->id) ?: MovimentacaoLocalizacao::findByMd5($data->id);

        if (!$localizacao) {
            $this->message->warning("Registro de localização não encontrado");
            Redirect::referer();
            return;
        }

        MovimentacaoLocalizacao::deleteById($localizacao->id);
        $this->message->success("Registro de localização removido com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_curral_origem");
        $data->nullIfEmpty("id_piquete_origem");
        $data->nullIfEmpty("id_curral_destino");
        $data->nullIfEmpty("id_piquete_destino");
        $data->nullIfEmpty("quantidade");
        $data->nullIfEmpty("motivo");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        return $payload;
    }

    private function urlVoltar(?int $idLote): string
    {
        return $idLote
            ? $this->router->route("admin.manejo.localizacao.index", ["id_lote" => $idLote])
            : $this->router->route("admin.manejo.localizacao.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function currais(): array
    {
        return Curral::orderBy("nome")->get();
    }

    private function piquetes(): array
    {
        return Piquete::orderBy("nome")->get();
    }
}
