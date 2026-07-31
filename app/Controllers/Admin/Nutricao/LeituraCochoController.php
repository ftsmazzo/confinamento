<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Curral;
use App\Models\Manejo\Lote;
use App\Models\Nutricao\LeituraCocho;

class LeituraCochoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Leitura de Cocho",
            "active_menu" => "nutricao-leituras-cocho",
            "page" => [
                "title" => "Leitura de Cocho",
                "desc" => "Escore de sobra do cocho para ajuste do consumo",
            ],
            "uppers" => implode(",", LeituraCocho::getUppers()),
            "required" => implode(",", LeituraCocho::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("leitura_cocho_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Nutrição" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Leituras de Cocho de " . $lote->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Leitura de Cocho"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = LeituraCocho::leftJoin("lote as l", "lc.id_lote", "=", "l.id")
            ->leftJoin("curral as c", "lc.id_curral", "=", "c.id")
            ->select("lc.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "c.nome as curral_nome");

        if ($idLote) {
            $query = $query->where("lc.id_lote", "=", $idLote);
        }

        $dados = $query->orderBy("lc.data_leitura", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
            $item->escore_label = LeituraCocho::escoreLabel((int) $item->escore);
        }

        echo $this->view->render("admin/nutricao/leitura-cocho/index", [
            "dados" => $dados,
            "lote" => $lote,
            "permissao" => [
                "inserir" => $this->auth->allow("leitura_cocho_inserir"),
                "editar" => $this->auth->allow("leitura_cocho_editar"),
                "excluir" => $this->auth->allow("leitura_cocho_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("leitura_cocho_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;

        echo $this->view->render("admin/nutricao/leitura-cocho/form", [
            "csrf" => $this->csrf->generate(),
            "leitura" => false,
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "url_action" => $this->router->route("admin.nutricao.leitura.cocho.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("leitura_cocho_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("data_leitura") || !$data->has("escore")) {
            $this->message->warning("Selecione o lote, a data e o escore de leitura");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        LeituraCocho::create($payload);
        $this->message->success("Leitura de cocho registrada com sucesso");
        $this->router->redirect("admin.nutricao.leitura.cocho.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("leitura_cocho_editar");
        $data = new Data($request->all());
        $leitura = LeituraCocho::find($data->id) ?: LeituraCocho::findByMd5($data->id);

        if (!$leitura) {
            $this->message->warning("Leitura não encontrada");
            $this->router->redirect("admin.nutricao.leitura.cocho.index");
            return;
        }

        echo $this->view->render("admin/nutricao/leitura-cocho/form", [
            "csrf" => $this->csrf->generate(),
            "leitura" => $leitura,
            "id_lote" => (int) $leitura->id_lote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "url_action" => $this->router->route("admin.nutricao.leitura.cocho.update"),
            "url_voltar" => $this->urlVoltar((int) $leitura->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("leitura_cocho_editar");
        $data = new Data($request->all());
        $leitura = LeituraCocho::find($data->id) ?: LeituraCocho::findByMd5($data->id);

        if (!$leitura) {
            $this->message->warning("Leitura não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_leitura") || !$data->has("escore")) {
            $this->message->warning("Selecione o lote, a data e o escore de leitura");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        LeituraCocho::updateBy($leitura->id, $payload);
        $this->message->success("Leitura de cocho atualizada com sucesso");
        $this->router->redirect("admin.nutricao.leitura.cocho.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("leitura_cocho_excluir");
        $data = new Data($request->all());
        $leitura = LeituraCocho::find($data->id) ?: LeituraCocho::findByMd5($data->id);

        if (!$leitura) {
            $this->message->warning("Leitura não encontrada");
            Redirect::referer();
            return;
        }

        LeituraCocho::deleteById($leitura->id);
        $this->message->success("Leitura de cocho removida com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_curral");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        $payload["escore"] = (int) ($payload["escore"] ?? 0);

        return $payload;
    }

    private function urlVoltar(?int $idLote): string
    {
        return $idLote
            ? $this->router->route("admin.nutricao.leitura.cocho.index", ["id_lote" => $idLote])
            : $this->router->route("admin.nutricao.leitura.cocho.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function currais(): array
    {
        return Curral::orderBy("nome")->get();
    }
}
