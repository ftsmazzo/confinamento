<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Curral;
use App\Models\Fornecedor;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MovimentacaoEntrada;
use App\Models\Manejo\TipoEntrada;

class EntradaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Entradas de Animais",
            "active_menu" => "manejo-entradas",
            "page" => [
                "title" => "Entradas de Animais",
                "desc" => "Registre a chegada de lotes ao confinamento",
            ],
            "uppers" => implode(",", MovimentacaoEntrada::getUppers()),
            "required" => implode(",", MovimentacaoEntrada::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("entrada_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Manejo" => ["url" => false, "current" => false],
                "Entradas de Animais" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = MovimentacaoEntrada::leftJoin("lote as l", "me.id_lote", "=", "l.id")
            ->leftJoin("fornecedor as f", "me.id_fornecedor", "=", "f.id")
            ->leftJoin("curral as c", "me.id_curral_destino", "=", "c.id")
            ->select("me.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "f.razao as fornecedor_razao", "c.nome as curral_nome")
            ->orderBy("me.data_entrada", "desc")
            ->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/manejo/entrada/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("entrada_inserir"),
                "editar" => $this->auth->allow("entrada_editar"),
                "excluir" => $this->auth->allow("entrada_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("entrada_inserir");
        echo $this->view->render("admin/manejo/entrada/form", [
            "csrf" => $this->csrf->generate(),
            "entrada" => false,
            "lotes" => $this->lotesSemEntrada(),
            "fornecedores" => $this->fornecedores(),
            "currais" => $this->currais(),
            "tiposEntrada" => $this->tiposEntrada(),
            "url_action" => $this->router->route("admin.manejo.entrada.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("entrada_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("data_entrada")) {
            $this->message->warning("Selecione o lote e informe a data de entrada");
            Redirect::referer();
            return;
        }

        if (MovimentacaoEntrada::where("id_lote", "=", (int) $data->id_lote)->count() > 0) {
            $this->message->warning("Este lote já possui um registro de entrada");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        MovimentacaoEntrada::create($payload);
        $this->message->success("Entrada registrada com sucesso");
        $this->router->redirect("admin.manejo.entrada.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("entrada_editar");
        $data = new Data($request->all());
        $entrada = MovimentacaoEntrada::find($data->id) ?: MovimentacaoEntrada::findByMd5($data->id);

        if (!$entrada) {
            $this->message->warning("Entrada não encontrada");
            $this->router->redirect("admin.manejo.entrada.index");
        }

        echo $this->view->render("admin/manejo/entrada/form", [
            "csrf" => $this->csrf->generate(),
            "entrada" => $entrada,
            "lotes" => $this->lotesSemEntrada($entrada->id_lote ?? null),
            "fornecedores" => $this->fornecedores(),
            "currais" => $this->currais(),
            "tiposEntrada" => $this->tiposEntrada(),
            "url_action" => $this->router->route("admin.manejo.entrada.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("entrada_editar");
        $data = new Data($request->all());
        $entrada = MovimentacaoEntrada::find($data->id) ?: MovimentacaoEntrada::findByMd5($data->id);

        if (!$entrada) {
            $this->message->warning("Entrada não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_entrada")) {
            $this->message->warning("Selecione o lote e informe a data de entrada");
            Redirect::referer();
            return;
        }

        if (MovimentacaoEntrada::where("id_lote", "=", (int) $data->id_lote)->where("id", "!=", $entrada->id)->count() > 0) {
            $this->message->warning("Este lote já possui um registro de entrada");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        MovimentacaoEntrada::updateBy($entrada->id, $payload);
        $this->message->success("Entrada atualizada com sucesso");
        $this->router->redirect("admin.manejo.entrada.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("entrada_excluir");
        $data = new Data($request->all());
        $entrada = MovimentacaoEntrada::find($data->id) ?: MovimentacaoEntrada::findByMd5($data->id);

        if (!$entrada) {
            $this->message->warning("Entrada não encontrada");
            Redirect::referer();
            return;
        }

        MovimentacaoEntrada::deleteById($entrada->id);
        $this->message->success("Entrada removida com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_fornecedor");
        $data->nullIfEmpty("id_curral_destino");
        $data->nullIfEmpty("id_tipo_entrada");
        $data->nullIfEmpty("documento");
        $data->nullIfEmpty("tipo_documento");
        $data->nullIfEmpty("valor_total");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        if (!empty($payload["valor_total"])) {
            $payload["valor_total"] = money2float((string) $payload["valor_total"]);
        }

        return $payload;
    }

    /**
     * Lotes disponiveis para vincular a uma entrada: os que ainda nao tem
     * registro de entrada, mais o lote atual (quando editando).
     */
    private function lotesSemEntrada(?int $idLoteAtual = null): array
    {
        $lotesComEntrada = array_map(
            static fn ($row) => (int) $row->id_lote,
            MovimentacaoEntrada::select("id_lote")->get()
        );

        return array_values(array_filter(
            Lote::orderBy("nome")->get(),
            static fn ($lote) => !in_array((int) $lote->id, $lotesComEntrada, true) || (int) $lote->id === $idLoteAtual
        ));
    }

    private function fornecedores(): array
    {
        return Fornecedor::orderBy("razao")->get();
    }

    private function currais(): array
    {
        return Curral::orderBy("nome")->get();
    }

    private function tiposEntrada(): array
    {
        return TipoEntrada::orderBy("descricao")->get();
    }
}
