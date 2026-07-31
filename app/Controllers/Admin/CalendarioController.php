<?php

namespace App\Controllers\Admin;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\DB;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Estoque\LoteEstoque;
use App\Models\Manejo\Animal;
use App\Models\Manejo\Lembrete;
use App\Models\Manejo\Lote;
use App\Models\Nutricao\ProgramacaoTrato;
use App\Models\UsuarioPreferencia;
use App\Services\UsuarioPreferenciaService;

class CalendarioController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Calendário",
            "active_menu" => "calendario",
            "page" => [
                "title" => "Calendário",
                "desc" => "Programação de trato, fim de carências, validade de insumos e lembretes",
            ],
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Calendário" => ["url" => false, "current" => true],
            ],
            "required" => implode(",", Lembrete::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("calendario_visualizar");

        $pref = UsuarioPreferencia::porUsuario((int) $this->user->uid);
        $eventosVisiveis = $pref && $pref->calendario_eventos ? $pref->calendario_eventos : "trato,carencia,validade,lembrete,conta-pagar,conta-receber";
        $calendarioVisao = $pref && $pref->calendario_visao ? $pref->calendario_visao : "dayGridMonth";

        echo $this->view->render("admin/calendario/index", [
            "csrf" => $this->csrf->generate(),
            "lotes" => Lote::orderBy("nome")->get(),
            "animais" => Animal::orderBy("identificacao")->get(),
            "calendario_eventos" => $eventosVisiveis,
            "calendario_visao" => $calendarioVisao,
            "permissao" => [
                "inserir" => $this->auth->allow("lembrete_inserir"),
                "editar" => $this->auth->allow("lembrete_editar"),
                "excluir" => $this->auth->allow("lembrete_excluir"),
                "editar_trato" => $this->auth->allow("programacao_trato_editar"),
                "editar_validade" => $this->auth->allow("produto_estoque_editar"),
            ],
        ]);
    }

    /**
     * Endpoint JSON consumido pelo calendário: agrega, para o intervalo
     * de datas informado, os 4 tipos de evento — programação de trato,
     * fim de carência sanitária, validade de insumo em estoque, e
     * lembretes manuais. Cada evento sai com "tipo" (usado para cor e
     * ícone) e "data" (Y-m-d).
     */
    public function eventos(Request $request): void
    {
        $this->authorize("calendario_visualizar");

        $data = new Data($request->all());
        $dataInicial = (string) ($data->has("data_inicial") ? $data->data_inicial : date("Y-m-01"));
        $dataFinal = (string) ($data->has("data_final") ? $data->data_final : date("Y-m-t"));

        $eventos = array_merge(
            $this->eventosProgramacaoTrato($dataInicial, $dataFinal),
            $this->eventosCarenciaSanitaria($dataInicial, $dataFinal),
            $this->eventosValidadeInsumo($dataInicial, $dataFinal),
            $this->eventosLembretes($dataInicial, $dataFinal),
            $this->eventosContasPagar($dataInicial, $dataFinal),
            $this->eventosContasReceber($dataInicial, $dataFinal)
        );

        header("Content-Type: application/json; charset=utf-8");
        echo json_encode([
            "error" => false,
            "data" => $eventos,
        ], JSON_UNESCAPED_UNICODE);
    }

    private function eventosProgramacaoTrato(string $dataInicial, string $dataFinal): array
    {
        $linhas = DB::table("programacao_trato", "pt")
            ->leftJoin("lote as l", "pt.id_lote", "=", "l.id")
            ->select("pt.id", "pt.data_programacao", "pt.turno", "pt.quantidade_prevista", "l.nome as lote_nome")
            ->where("pt.data_programacao", ">=", $dataInicial)
            ->where("pt.data_programacao", "<=", $dataFinal)
            ->get();

        $eventos = [];
        foreach ($linhas as $linha) {
            $eventos[] = [
                "tipo" => "trato",
                "id" => $linha->id,
                "hash" => md5((string) $linha->id),
                "data" => $linha->data_programacao,
                "titulo" => "Trato" . ($linha->turno ? " ({$linha->turno})" : "") . ($linha->lote_nome ? " — {$linha->lote_nome}" : ""),
                "detalhe" => $linha->quantidade_prevista !== null ? number_format((float) $linha->quantidade_prevista, 2, ",", ".") . " kg previstos" : null,
                "url" => $this->router->route("admin.nutricao.programacao.trato.index"),
            ];
        }

        return $eventos;
    }

    private function eventosCarenciaSanitaria(string $dataInicial, string $dataFinal): array
    {
        $linhas = DB::table("aplicacao_sanitaria", "aps")
            ->leftJoin("lote as l", "aps.id_lote", "=", "l.id")
            ->leftJoin("animal as a", "aps.id_animal", "=", "a.id")
            ->select("aps.id", "aps.data_carencia_fim", "l.nome as lote_nome", "a.identificacao as animal_identificacao")
            ->whereNotNull("aps.data_carencia_fim")
            ->where("aps.data_carencia_fim", ">=", $dataInicial)
            ->where("aps.data_carencia_fim", "<=", $dataFinal)
            ->get();

        $eventos = [];
        foreach ($linhas as $linha) {
            $referencia = $linha->lote_nome ?: $linha->animal_identificacao ?: "";
            $eventos[] = [
                "tipo" => "carencia",
                "data" => $linha->data_carencia_fim,
                "titulo" => "Fim de carência" . ($referencia ? " — {$referencia}" : ""),
                "detalhe" => "Liberado para saída a partir desta data",
                "url" => $this->router->route("admin.sanitario.aplicacao.index"),
            ];
        }

        return $eventos;
    }

    private function eventosValidadeInsumo(string $dataInicial, string $dataFinal): array
    {
        $linhas = DB::table("lote_estoque", "le")
            ->leftJoin("produto_estoque as pe", "le.id_produto_estoque", "=", "pe.id")
            ->select("le.id", "le.data_validade", "le.codigo_lote", "pe.nome as produto_nome")
            ->whereNotNull("le.data_validade")
            ->where("le.data_validade", ">=", $dataInicial)
            ->where("le.data_validade", "<=", $dataFinal)
            ->get();

        $eventos = [];
        foreach ($linhas as $linha) {
            $eventos[] = [
                "tipo" => "validade",
                "id" => $linha->id,
                "hash" => md5((string) $linha->id),
                "data" => $linha->data_validade,
                "titulo" => "Vencimento — " . ($linha->produto_nome ?: "Produto"),
                "detalhe" => "Lote " . $linha->codigo_lote,
                "url" => $this->router->route("admin.estoque.produto.index"),
            ];
        }

        return $eventos;
    }

    private function eventosLembretes(string $dataInicial, string $dataFinal): array
    {
        $linhas = Lembrete::leftJoin("lote as l", "lb.id_lote", "=", "l.id")
            ->leftJoin("animal as a", "lb.id_animal", "=", "a.id")
            ->select("lb.*", "l.nome as lote_nome", "a.identificacao as animal_identificacao")
            ->where("lb.data_lembrete", ">=", $dataInicial)
            ->where("lb.data_lembrete", "<=", $dataFinal)
            ->get();

        $eventos = [];
        foreach ($linhas as $linha) {
            $referencia = $linha->lote_nome ?: $linha->animal_identificacao ?: null;
            $eventos[] = [
                "tipo" => "lembrete",
                "id" => $linha->id,
                "hash" => md5((string) $linha->id),
                "data" => $linha->data_lembrete,
                "titulo" => $linha->titulo,
                "detalhe" => $referencia,
                "descricao" => $linha->descricao,
                "concluido" => (bool) $linha->concluido,
            ];
        }

        return $eventos;
    }

    private function eventosContasPagar(string $dataInicial, string $dataFinal): array
    {
        $linhas = DB::table("conta_pagar", "cp")
            ->select("cp.id", "cp.descricao", "cp.data_vencimento", "cp.valor")
            ->where("cp.status", "=", "PENDENTE")
            ->where("cp.data_vencimento", ">=", $dataInicial)
            ->where("cp.data_vencimento", "<=", $dataFinal)
            ->get();

        $eventos = [];
        foreach ($linhas as $linha) {
            $eventos[] = [
                "tipo" => "conta-pagar",
                "id" => $linha->id,
                "hash" => md5((string) $linha->id),
                "data" => $linha->data_vencimento,
                "titulo" => "Pagar — " . ($linha->descricao ?? "Conta #{$linha->id}"),
                "detalhe" => "Valor: R$ " . number_format((float) $linha->valor, 2, ",", "."),
                "url" => $this->router->route("admin.financeiro.conta.pagar.index"),
            ];
        }

        return $eventos;
    }

    private function eventosContasReceber(string $dataInicial, string $dataFinal): array
    {
        $linhas = DB::table("conta_receber", "cr")
            ->select("cr.id", "cr.descricao", "cr.data_vencimento", "cr.valor")
            ->where("cr.status", "=", "PENDENTE")
            ->where("cr.data_vencimento", ">=", $dataInicial)
            ->where("cr.data_vencimento", "<=", $dataFinal)
            ->get();

        $eventos = [];
        foreach ($linhas as $linha) {
            $eventos[] = [
                "tipo" => "conta-receber",
                "id" => $linha->id,
                "hash" => md5((string) $linha->id),
                "data" => $linha->data_vencimento,
                "titulo" => "Receber — " . ($linha->descricao ?? "Conta #{$linha->id}"),
                "detalhe" => "Valor: R$ " . number_format((float) $linha->valor, 2, ",", "."),
                "url" => $this->router->route("admin.financeiro.conta.receber.index"),
            ];
        }

        return $eventos;
    }

    public function novoLembrete(Request $request): void
    {
        $this->authorize("lembrete_inserir");

        $data = new Data($request->all());

        echo $this->view->render("admin/calendario/lembrete-form", [
            "csrf" => $this->csrf->generate(),
            "lembrete" => false,
            "data_lembrete" => $data->has("data") ? (string) $data->data : "",
            "lotes" => Lote::orderBy("nome")->get(),
            "animais" => Animal::orderBy("identificacao")->get(),
            "url_action" => $this->router->route("admin.calendario.lembrete.insert"),
        ]);
    }

    public function criarLembrete(Request $request): void
    {
        $this->authorize("lembrete_inserir");
        $data = new Data($request->all());

        if (!$data->has("data_lembrete") || !$data->has("titulo")) {
            $this->message->warning("Informe a data e o título do lembrete.");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("id_lote");
        $data->nullIfEmpty("id_animal");
        $data->nullIfEmpty("descricao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        Lembrete::create($payload);

        $this->message->success("Lembrete criado com sucesso");
        $this->router->redirect("admin.calendario.index");
    }

    public function editarLembrete(Request $request): void
    {
        $this->authorize("lembrete_editar");
        $data = new Data($request->all());
        $lembrete = Lembrete::find($data->id) ?: Lembrete::findByMd5($data->id);

        if (!$lembrete) {
            $this->message->warning("Lembrete não encontrado");
            $this->router->redirect("admin.calendario.index");
            return;
        }

        echo $this->view->render("admin/calendario/lembrete-form", [
            "csrf" => $this->csrf->generate(),
            "lembrete" => $lembrete,
            "data_lembrete" => $lembrete->data_lembrete,
            "lotes" => Lote::orderBy("nome")->get(),
            "animais" => Animal::orderBy("identificacao")->get(),
            "url_action" => $this->router->route("admin.calendario.lembrete.update"),
        ]);
    }

    public function atualizarLembrete(Request $request): void
    {
        $this->authorize("lembrete_editar");
        $data = new Data($request->all());
        $lembrete = Lembrete::find($data->id) ?: Lembrete::findByMd5($data->id);

        if (!$lembrete) {
            $this->message->warning("Lembrete não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("data_lembrete") || !$data->has("titulo")) {
            $this->message->warning("Informe a data e o título do lembrete.");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("id_lote");
        $data->nullIfEmpty("id_animal");
        $data->nullIfEmpty("descricao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["concluido"] = $data->has("concluido") ? 1 : 0;
        $payload["updated_by"] = $this->user->uid;

        Lembrete::updateBy($lembrete->id, $payload);

        $this->message->success("Lembrete atualizado com sucesso");
        $this->router->redirect("admin.calendario.index");
    }

    /**
     * Atualiza apenas a data de um lembrete, chamado via AJAX quando o
     * usuário arrasta o evento para outro dia no calendário (drag and
     * drop do FullCalendar). Só lembretes são arrastáveis -- os demais
     * tipos de evento vêm de outras tabelas e não têm edição de data
     * aqui.
     */
    public function moverLembrete(Request $request): void
    {
        header("Content-Type: application/json; charset=utf-8");

        if (!$this->auth->allow("lembrete_editar")) {
            http_response_code(403);
            echo json_encode(["error" => true, "message" => "Sem permissão."], JSON_UNESCAPED_UNICODE);
            return;
        }

        $data = new Data($request->all());
        $lembrete = Lembrete::find($data->id) ?: Lembrete::findByMd5($data->id);

        if (!$lembrete || !$data->has("data_lembrete")) {
            http_response_code(404);
            echo json_encode(["error" => true, "message" => "Lembrete não encontrado."], JSON_UNESCAPED_UNICODE);
            return;
        }

        Lembrete::updateBy($lembrete->id, [
            "data_lembrete" => (string) $data->data_lembrete,
            "updated_by" => $this->user->uid,
        ]);

        echo json_encode(["error" => false], JSON_UNESCAPED_UNICODE);
    }

    /**
     * Atualiza apenas data_programacao de uma programação de trato,
     * chamado via AJAX ao arrastar o evento no calendário.
     */
    public function moverProgramacaoTrato(Request $request): void
    {
        header("Content-Type: application/json; charset=utf-8");

        if (!$this->auth->allow("programacao_trato_editar")) {
            http_response_code(403);
            echo json_encode(["error" => true, "message" => "Sem permissão."], JSON_UNESCAPED_UNICODE);
            return;
        }

        $data = new Data($request->all());
        $programacao = ProgramacaoTrato::find($data->id) ?: ProgramacaoTrato::findByMd5($data->id);

        if (!$programacao || !$data->has("data")) {
            http_response_code(404);
            echo json_encode(["error" => true, "message" => "Programação não encontrada."], JSON_UNESCAPED_UNICODE);
            return;
        }

        ProgramacaoTrato::updateBy($programacao->id, [
            "data_programacao" => (string) $data->data,
            "updated_by" => $this->user->uid,
        ]);

        echo json_encode(["error" => false], JSON_UNESCAPED_UNICODE);
    }

    /**
     * Atualiza apenas data_validade de um lote de estoque, chamado via
     * AJAX ao arrastar o evento de vencimento no calendário.
     */
    public function moverValidadeInsumo(Request $request): void
    {
        header("Content-Type: application/json; charset=utf-8");

        if (!$this->auth->allow("produto_estoque_editar")) {
            http_response_code(403);
            echo json_encode(["error" => true, "message" => "Sem permissão."], JSON_UNESCAPED_UNICODE);
            return;
        }

        $data = new Data($request->all());
        $loteEstoque = LoteEstoque::find($data->id) ?: LoteEstoque::findByMd5($data->id);

        if (!$loteEstoque || !$data->has("data")) {
            http_response_code(404);
            echo json_encode(["error" => true, "message" => "Lote de estoque não encontrado."], JSON_UNESCAPED_UNICODE);
            return;
        }

        LoteEstoque::updateBy($loteEstoque->id, [
            "data_validade" => (string) $data->data,
            "updated_by" => $this->user->uid,
        ]);

        echo json_encode(["error" => false], JSON_UNESCAPED_UNICODE);
    }

    public function excluirLembrete(Request $request): void
    {
        $this->authorize("lembrete_excluir");
        $data = new Data($request->all());
        $lembrete = Lembrete::find($data->id) ?: Lembrete::findByMd5($data->id);

        if (!$lembrete) {
            $this->message->warning("Lembrete não encontrado");
            Redirect::referer();
            return;
        }

        Lembrete::deleteById($lembrete->id);
        $this->message->success("Lembrete removido com sucesso");
        Redirect::referer();
    }

    public function salvarPreferenciaEventos(Request $request): void
    {
        header("Content-Type: application/json; charset=utf-8");

        $data = new Data($request->all());
        $service = new UsuarioPreferenciaService();

        $dados = [];
        if ($data->has("eventos")) {
            $dados["calendario_eventos"] = (string) $data->eventos;
        }
        if ($data->has("visao")) {
            $dados["calendario_visao"] = (string) $data->visao;
        }

        if (!empty($dados)) {
            $service->atualizar((int) $this->user->uid, $dados);
        }

        echo json_encode(["error" => false], JSON_UNESCAPED_UNICODE);
    }
}
