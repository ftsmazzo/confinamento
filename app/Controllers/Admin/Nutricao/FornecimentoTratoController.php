<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Curral;
use App\Models\Manejo\Lote;
use App\Models\Nutricao\FormulaRacao;
use App\Models\Nutricao\FornecimentoTrato;
use App\Models\Nutricao\ProgramacaoTrato;

class FornecimentoTratoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Fornecimento de Trato",
            "active_menu" => "nutricao-fornecimentos-trato",
            "page" => [
                "title" => "Fornecimento de Trato",
                "desc" => "Registro do que foi efetivamente fornecido aos lotes",
            ],
            "uppers" => implode(",", FornecimentoTrato::getUppers()),
            "required" => implode(",", FornecimentoTrato::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("fornecimento_trato_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Nutrição" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Fornecimentos de Trato de " . $lote->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Fornecimento de Trato"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = FornecimentoTrato::leftJoin("lote as l", "ft.id_lote", "=", "l.id")
            ->leftJoin("curral as c", "ft.id_curral", "=", "c.id")
            ->leftJoin("formula_racao as fr", "ft.id_formula_racao", "=", "fr.id")
            ->select("ft.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "c.nome as curral_nome", "fr.nome as formula_nome");

        if ($idLote) {
            $query = $query->where("ft.id_lote", "=", $idLote);
        }

        $dados = $query->orderBy("ft.data_fornecimento", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
        }

        echo $this->view->render("admin/nutricao/fornecimento-trato/index", [
            "dados" => $dados,
            "lote" => $lote,
            "permissao" => [
                "inserir" => $this->auth->allow("fornecimento_trato_inserir"),
                "editar" => $this->auth->allow("fornecimento_trato_editar"),
                "excluir" => $this->auth->allow("fornecimento_trato_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("fornecimento_trato_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;

        echo $this->view->render("admin/nutricao/fornecimento-trato/form", [
            "csrf" => $this->csrf->generate(),
            "fornecimento" => false,
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "formulas" => $this->formulas(),
            "programacoes" => $this->programacoes($idLote),
            "url_action" => $this->router->route("admin.nutricao.fornecimento.trato.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("fornecimento_trato_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("data_fornecimento") || !$data->has("quantidade_fornecida")) {
            $this->message->warning("Selecione o lote, a data e a quantidade fornecida");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        FornecimentoTrato::create($payload);
        $this->message->success("Fornecimento registrado com sucesso");
        $this->router->redirect("admin.nutricao.fornecimento.trato.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("fornecimento_trato_editar");
        $data = new Data($request->all());
        $fornecimento = FornecimentoTrato::find($data->id) ?: FornecimentoTrato::findByMd5($data->id);

        if (!$fornecimento) {
            $this->message->warning("Fornecimento não encontrado");
            $this->router->redirect("admin.nutricao.fornecimento.trato.index");
            return;
        }

        echo $this->view->render("admin/nutricao/fornecimento-trato/form", [
            "csrf" => $this->csrf->generate(),
            "fornecimento" => $fornecimento,
            "id_lote" => (int) $fornecimento->id_lote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "formulas" => $this->formulas(),
            "programacoes" => $this->programacoes((int) $fornecimento->id_lote),
            "url_action" => $this->router->route("admin.nutricao.fornecimento.trato.update"),
            "url_voltar" => $this->urlVoltar((int) $fornecimento->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("fornecimento_trato_editar");
        $data = new Data($request->all());
        $fornecimento = FornecimentoTrato::find($data->id) ?: FornecimentoTrato::findByMd5($data->id);

        if (!$fornecimento) {
            $this->message->warning("Fornecimento não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_fornecimento") || !$data->has("quantidade_fornecida")) {
            $this->message->warning("Selecione o lote, a data e a quantidade fornecida");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        FornecimentoTrato::updateBy($fornecimento->id, $payload);
        $this->message->success("Fornecimento atualizado com sucesso");
        $this->router->redirect("admin.nutricao.fornecimento.trato.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("fornecimento_trato_excluir");
        $data = new Data($request->all());
        $fornecimento = FornecimentoTrato::find($data->id) ?: FornecimentoTrato::findByMd5($data->id);

        if (!$fornecimento) {
            $this->message->warning("Fornecimento não encontrado");
            Redirect::referer();
            return;
        }

        FornecimentoTrato::deleteById($fornecimento->id);
        $this->message->success("Fornecimento removido com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_curral");
        $data->nullIfEmpty("id_formula_racao");
        $data->nullIfEmpty("id_programacao_trato");
        $data->nullIfEmpty("hora_fornecimento");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        // fornecimento_trato não tem coluna turno (turno vem da programação ou da hora)
        unset($payload["csrf"], $payload["id"], $payload["turno"]);

        $qtd = (string) ($payload["quantidade_fornecida"] ?? 0);
        $payload["quantidade_fornecida"] = function_exists("money2float")
            ? (float) money2float($qtd)
            : (float) str_replace(",", ".", $qtd);

        return $payload;
    }

    private function urlVoltar(?int $idLote): string
    {
        return $idLote
            ? $this->router->route("admin.nutricao.fornecimento.trato.index", ["id_lote" => $idLote])
            : $this->router->route("admin.nutricao.fornecimento.trato.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function currais(): array
    {
        return Curral::comLoteAtivo();
    }

    private function formulas(): array
    {
        return FormulaRacao::orderBy("nome")->get();
    }

    private function programacoes(?int $idLote): array
    {
        if (!$idLote) {
            return [];
        }

        return ProgramacaoTrato::where("id_lote", "=", $idLote)
            ->orderBy("data_programacao", "desc")
            ->get();
    }
}
