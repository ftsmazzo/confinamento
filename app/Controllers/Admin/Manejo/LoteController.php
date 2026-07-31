<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Curral;
use App\Models\Confinamento\Piquete;
use App\Models\Confinamento\Unidade;
use App\Models\Manejo\Lote;
use App\Models\Manejo\LoteEntrada;

class LoteController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Lotes",
            "active_menu" => "manejo-lotes",
            "page" => [
                "title" => "Lotes",
                "desc" => "Agrupe os animais por origem, fase ou objetivo",
            ],
            "uppers" => implode(",", Lote::getUppers()),
            "required" => implode(",", Lote::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("lote_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Manejo" => ["url" => false, "current" => false],
                "Lotes" => ["url" => false, "current" => true],
            ],
        ]);

        $lotes = Lote::leftJoin("unidade as u", "l.id_unidade", "=", "u.id")
            ->leftJoin("curral as c", "l.id_curral", "=", "c.id")
            ->leftJoin("piquete as p", "l.id_piquete", "=", "p.id")
            ->leftJoin("lote_entrada as le", "l.id", "=", "le.id_lote")
            ->select("l.*", "u.nome as unidade_nome", "c.nome as curral_nome", "p.nome as piquete_nome", "le.quantidade", "le.peso_medio", "le.peso_total")
            ->orderBy("l.nome")
            ->get();

        foreach ($lotes as $lote) {
            $lote->hash = md5((string) $lote->id);
        }

        echo $this->view->render("admin/manejo/lote/index", [
            "dados" => $lotes,
            "permissao" => [
                "inserir" => $this->auth->allow("lote_inserir"),
                "editar" => $this->auth->allow("lote_editar"),
                "excluir" => $this->auth->allow("lote_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("lote_inserir");
        echo $this->view->render("admin/manejo/lote/form", [
            "csrf" => $this->csrf->generate(),
            "lote" => false,
            "loteEntrada" => false,
            "unidades" => $this->unidades(),
            "currais" => $this->currais(),
            "piquetes" => $this->piquetes(),
            "url_action" => $this->router->route("admin.manejo.lote.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("lote_inserir");
        $data = new Data($request->all());

        if (!$data->has("nome") || !$data->has("codigo") || !$data->has("id_unidade")) {
            $this->message->warning("Informe nome, código e unidade do lote");
            Redirect::referer();
            return;
        }

        if (!$this->unidadeValida((int) $data->id_unidade)) {
            $this->message->warning("Selecione uma unidade válida para o lote");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("id_curral");
        $data->nullIfEmpty("id_piquete");
        $data->nullIfEmpty("data_formacao");

        $entradaPayload = $this->extractLoteEntradaPayload($data);

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"], $payload["quantidade"], $payload["peso_medio"], $payload["peso_total"], $payload["data_entrada"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        $lote = Lote::create($payload);

        if ($this->hasLoteEntradaData($entradaPayload)) {
            $entradaPayload["id_lote"] = $lote->id;
            $entradaPayload["created_by"] = $this->user->uid;
            LoteEntrada::create($entradaPayload);
        }

        $this->message->success("Lote cadastrado com sucesso");
        $this->router->redirect("admin.manejo.lote.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("lote_editar");
        $data = new Data($request->all());
        $lote = Lote::find($data->id) ?: Lote::findByMd5($data->id);

        if (!$lote) {
            $this->message->warning("Lote não encontrado");
            $this->router->redirect("admin.manejo.lote.index");
        }

        echo $this->view->render("admin/manejo/lote/form", [
            "csrf" => $this->csrf->generate(),
            "lote" => $lote,
            "loteEntrada" => LoteEntrada::where("id_lote", "=", $lote->id)->first(),
            "unidades" => $this->unidades(),
            "currais" => $this->currais(),
            "piquetes" => $this->piquetes(),
            "url_action" => $this->router->route("admin.manejo.lote.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("lote_editar");
        $data = new Data($request->all());
        $lote = Lote::find($data->id) ?: Lote::findByMd5($data->id);

        if (!$lote) {
            $this->message->warning("Lote não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome") || !$data->has("codigo") || !$data->has("id_unidade")) {
            $this->message->warning("Informe nome, código e unidade do lote");
            Redirect::referer();
            return;
        }

        if (!$this->unidadeValida((int) $data->id_unidade)) {
            $this->message->warning("Selecione uma unidade válida para o lote");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("id_curral");
        $data->nullIfEmpty("id_piquete");
        $data->nullIfEmpty("data_formacao");

        $entradaPayload = $this->extractLoteEntradaPayload($data);

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"], $payload["quantidade"], $payload["peso_medio"], $payload["peso_total"], $payload["data_entrada"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        Lote::updateBy($lote->id, $payload);

        $loteEntrada = LoteEntrada::where("id_lote", "=", $lote->id)->first();

        if ($loteEntrada) {
            $entradaPayload["updated_by"] = $this->user->uid;
            LoteEntrada::updateBy($loteEntrada->id, $entradaPayload);
        } elseif ($this->hasLoteEntradaData($entradaPayload)) {
            $entradaPayload["id_lote"] = $lote->id;
            $entradaPayload["created_by"] = $this->user->uid;
            LoteEntrada::create($entradaPayload);
        }

        $this->message->success("Lote atualizado com sucesso");
        $this->router->redirect("admin.manejo.lote.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("lote_excluir");
        $data = new Data($request->all());
        $lote = Lote::find($data->id) ?: Lote::findByMd5($data->id);

        if (!$lote) {
            $this->message->warning("Lote não encontrado");
            Redirect::referer();
            return;
        }

        Lote::deleteById($lote->id);
        $this->message->success("Lote removido com sucesso");
        Redirect::referer();
    }

    private function extractLoteEntradaPayload(Data $data): array
    {
        $data->nullIfEmpty("quantidade");
        $data->nullIfEmpty("peso_medio");
        $data->nullIfEmpty("peso_total");
        $data->nullIfEmpty("data_entrada");

        return [
            "quantidade" => $data->quantidade ?? null,
            "peso_medio" => $data->has("peso_medio") ? money2float((string) $data->peso_medio) : null,
            "peso_total" => $data->has("peso_total") ? money2float((string) $data->peso_total) : null,
            "data_entrada" => $data->data_entrada ?? null,
        ];
    }

    private function hasLoteEntradaData(array $entradaPayload): bool
    {
        return $entradaPayload["quantidade"] !== null
            || $entradaPayload["peso_medio"] !== null
            || $entradaPayload["peso_total"] !== null
            || $entradaPayload["data_entrada"] !== null;
    }

    private function unidades(): array
    {
        return Unidade::orderBy("nome")->get();
    }

    private function currais(): array
    {
        return Curral::orderBy("nome")->get();
    }

    private function piquetes(): array
    {
        return Piquete::orderBy("nome")->get();
    }

    private function unidadeValida(int $id): bool
    {
        return $id > 0 && Unidade::find($id) !== null;
    }
}
