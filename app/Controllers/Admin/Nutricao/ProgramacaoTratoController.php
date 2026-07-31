<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Curral;
use App\Models\Manejo\Lote;
use App\Models\Nutricao\FormulaRacao;
use App\Models\Nutricao\ProgramacaoTrato;
use App\Services\Nutricao\PrevisaoTratoService;

class ProgramacaoTratoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Programação de Trato",
            "active_menu" => "nutricao-programacoes-trato",
            "page" => [
                "title" => "Programação de Trato",
                "desc" => "Planejamento diário do fornecimento de ração por lote/curral",
            ],
            "uppers" => implode(",", ProgramacaoTrato::getUppers()),
            "required" => implode(",", ProgramacaoTrato::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("programacao_trato_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Nutrição" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Programação de Trato de " . $lote->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Programação de Trato"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = ProgramacaoTrato::leftJoin("lote as l", "pt.id_lote", "=", "l.id")
            ->leftJoin("curral as c", "pt.id_curral", "=", "c.id")
            ->leftJoin("formula_racao as fr", "pt.id_formula_racao", "=", "fr.id")
            ->select("pt.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "c.nome as curral_nome", "fr.nome as formula_nome");

        if ($idLote) {
            $query = $query->where("pt.id_lote", "=", $idLote);
        }

        $dados = $query->orderBy("pt.data_programacao", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
        }

        echo $this->view->render("admin/nutricao/programacao-trato/index", [
            "dados" => $dados,
            "lote" => $lote,
            "permissao" => [
                "inserir" => $this->auth->allow("programacao_trato_inserir"),
                "editar" => $this->auth->allow("programacao_trato_editar"),
                "excluir" => $this->auth->allow("programacao_trato_excluir"),
                "gerar" => $this->auth->allow("programacao_trato_inserir"),
                "parametros" => $this->auth->allow("programacao_trato_gerenciar"),
            ],
            "turnosLabel" => PrevisaoTratoService::TURNOS_LABEL,
        ]);
    }

    public function gerarForm(Request $request): void
    {
        $this->authorize("programacao_trato_inserir");
        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Programação de Trato" => ["url" => $this->router->route("admin.nutricao.programacao.trato.index"), "current" => false],
                "Gerar previstos" => ["url" => false, "current" => true],
            ],
            "page" => [
                "title" => "Gerar previstos do dia",
                "desc" => "Motor: permanência → peso → %PV → MS→MN → 4 turnos",
            ],
        ]);

        echo $this->view->render("admin/nutricao/programacao-trato/gerar", [
            "csrf" => $this->csrf->generate(),
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "data_programacao" => date("Y-m-d"),
            "url_action" => $this->router->route("admin.nutricao.programacao.trato.gerar.executar"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function gerarExecutar(Request $request): void
    {
        $this->authorize("programacao_trato_inserir");
        $data = new Data($request->all());

        if (!$data->has("data_programacao")) {
            $this->message->warning("Informe a data da programação");
            Redirect::referer();
            return;
        }

        $dataRef = (string) $data->data_programacao;
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        if ($idLote <= 0) {
            $idLote = null;
        }
        $substituir = !empty($data->substituir);

        $service = new PrevisaoTratoService();
        $resultado = $service->gerar($dataRef, $idLote, (int) $this->user->uid, $substituir);

        if ($resultado["gerados"] > 0) {
            $this->message->success(
                "Gerados {$resultado["gerados"]} turnos em {$resultado["lotes"]} lote(s) para " . datebr($dataRef)
            );
        } else {
            $this->message->warning("Nenhuma programação gerada. Verifique entrada, fórmula, % MS e parâmetros.");
        }

        if (!empty($resultado["pulados"])) {
            $this->message->info("Pulados: " . implode(" · ", array_slice($resultado["pulados"], 0, 5)));
        }

        $this->router->redirect("admin.nutricao.programacao.trato.index", array_filter([
            "id_lote" => $idLote,
        ]));
    }

    public function new(Request $request): void
    {
        $this->authorize("programacao_trato_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;

        echo $this->view->render("admin/nutricao/programacao-trato/form", [
            "csrf" => $this->csrf->generate(),
            "programacao" => false,
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "formulas" => $this->formulas(),
            "url_action" => $this->router->route("admin.nutricao.programacao.trato.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("programacao_trato_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("data_programacao")) {
            $this->message->warning("Selecione o lote e informe a data da programação");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        ProgramacaoTrato::create($payload);
        $this->message->success("Programação registrada com sucesso");
        $this->router->redirect("admin.nutricao.programacao.trato.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("programacao_trato_editar");
        $data = new Data($request->all());
        $programacao = ProgramacaoTrato::find($data->id) ?: ProgramacaoTrato::findByMd5($data->id);

        if (!$programacao) {
            $this->message->warning("Programação não encontrada");
            $this->router->redirect("admin.nutricao.programacao.trato.index");
            return;
        }

        echo $this->view->render("admin/nutricao/programacao-trato/form", [
            "csrf" => $this->csrf->generate(),
            "programacao" => $programacao,
            "id_lote" => (int) $programacao->id_lote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "formulas" => $this->formulas(),
            "url_action" => $this->router->route("admin.nutricao.programacao.trato.update"),
            "url_voltar" => $this->urlVoltar((int) $programacao->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("programacao_trato_editar");
        $data = new Data($request->all());
        $programacao = ProgramacaoTrato::find($data->id) ?: ProgramacaoTrato::findByMd5($data->id);

        if (!$programacao) {
            $this->message->warning("Programação não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_programacao")) {
            $this->message->warning("Selecione o lote e informe a data da programação");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        ProgramacaoTrato::updateBy($programacao->id, $payload);
        $this->message->success("Programação atualizada com sucesso");
        $this->router->redirect("admin.nutricao.programacao.trato.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("programacao_trato_excluir");
        $data = new Data($request->all());
        $programacao = ProgramacaoTrato::find($data->id) ?: ProgramacaoTrato::findByMd5($data->id);

        if (!$programacao) {
            $this->message->warning("Programação não encontrada");
            Redirect::referer();
            return;
        }

        ProgramacaoTrato::deleteById($programacao->id);
        $this->message->success("Programação removida com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_curral");
        $data->nullIfEmpty("id_formula_racao");
        $data->nullIfEmpty("turno");
        $data->nullIfEmpty("quantidade_prevista");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        return $payload;
    }

    private function urlVoltar(?int $idLote): string
    {
        return $idLote
            ? $this->router->route("admin.nutricao.programacao.trato.index", ["id_lote" => $idLote])
            : $this->router->route("admin.nutricao.programacao.trato.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function currais(): array
    {
        return Curral::orderBy("nome")->get();
    }

    private function formulas(): array
    {
        return FormulaRacao::orderBy("nome")->get();
    }
}
