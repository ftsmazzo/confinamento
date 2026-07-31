<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Cliente;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MovimentacaoSaida;
use App\Models\Manejo\TipoSaida;
use App\Models\Sanitario\AplicacaoSanitaria;

class SaidaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Saídas / Vendas / Abates",
            "active_menu" => "manejo-saidas",
            "page" => [
                "title" => "Saídas / Vendas / Abates",
                "desc" => "Registre a baixa de lotes por venda, abate ou outro destino",
            ],
            "required" => implode(",", MovimentacaoSaida::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("saida_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $lote = $idLote ? Lote::find($idLote) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Manejo" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Saídas de " . $lote->nome] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Saídas"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = MovimentacaoSaida::leftJoin("lote as l", "ms.id_lote", "=", "l.id")
            ->leftJoin("tipo_saida as ts", "ms.id_tipo_saida", "=", "ts.id")
            ->leftJoin("cliente as cl", "ms.id_cliente", "=", "cl.id")
            ->select("ms.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "ts.descricao as tipo_saida_descricao", "cl.razao as cliente_razao");

        if ($idLote) {
            $query = $query->where("ms.id_lote", "=", $idLote);
        }

        $dados = $query->orderBy("ms.data_saida", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
        }

        echo $this->view->render("admin/manejo/saida/index", [
            "dados" => $dados,
            "lote" => $lote,
            "permissao" => [
                "inserir" => $this->auth->allow("saida_inserir"),
                "editar" => $this->auth->allow("saida_editar"),
                "excluir" => $this->auth->allow("saida_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("saida_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;

        echo $this->view->render("admin/manejo/saida/form", [
            "csrf" => $this->csrf->generate(),
            "saida" => false,
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "tiposSaida" => $this->tiposSaida(),
            "clientes" => $this->clientes(),
            "url_action" => $this->router->route("admin.manejo.saida.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("saida_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_lote") || !$data->has("data_saida")) {
            $this->message->warning("Selecione o lote e informe a data da saída");
            Redirect::referer();
            return;
        }

        $carencia = $this->carenciaVigente((int) $data->id_lote, (string) $data->data_saida);
        if ($carencia !== null) {
            $this->message->warning($carencia);
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        MovimentacaoSaida::create($payload);
        $this->message->success("Saída registrada com sucesso");
        $this->router->redirect("admin.manejo.saida.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function edit(Request $request): void
    {
        $this->authorize("saida_editar");
        $data = new Data($request->all());
        $saida = MovimentacaoSaida::find($data->id) ?: MovimentacaoSaida::findByMd5($data->id);

        if (!$saida) {
            $this->message->warning("Saída não encontrada");
            $this->router->redirect("admin.manejo.saida.index");
            return;
        }

        echo $this->view->render("admin/manejo/saida/form", [
            "csrf" => $this->csrf->generate(),
            "saida" => $saida,
            "id_lote" => (int) $saida->id_lote,
            "lotes" => $this->lotes(),
            "tiposSaida" => $this->tiposSaida(),
            "clientes" => $this->clientes(),
            "url_action" => $this->router->route("admin.manejo.saida.update"),
            "url_voltar" => $this->urlVoltar((int) $saida->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("saida_editar");
        $data = new Data($request->all());
        $saida = MovimentacaoSaida::find($data->id) ?: MovimentacaoSaida::findByMd5($data->id);

        if (!$saida) {
            $this->message->warning("Saída não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_saida")) {
            $this->message->warning("Selecione o lote e informe a data da saída");
            Redirect::referer();
            return;
        }

        $carencia = $this->carenciaVigente((int) $data->id_lote, (string) $data->data_saida);
        if ($carencia !== null) {
            $this->message->warning($carencia);
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        MovimentacaoSaida::updateBy($saida->id, $payload);
        $this->message->success("Saída atualizada com sucesso");
        $this->router->redirect("admin.manejo.saida.index", ["id_lote" => $payload["id_lote"]]);
    }

    public function delete(Request $request): void
    {
        $this->authorize("saida_excluir");
        $data = new Data($request->all());
        $saida = MovimentacaoSaida::find($data->id) ?: MovimentacaoSaida::findByMd5($data->id);

        if (!$saida) {
            $this->message->warning("Saída não encontrada");
            Redirect::referer();
            return;
        }

        MovimentacaoSaida::deleteById($saida->id);
        $this->message->success("Saída removida com sucesso");
        Redirect::referer();
    }

    /**
     * Verifica se ha aplicacao sanitaria com carencia ainda vigente na
     * data da saida -- tanto vinculada diretamente ao lote quanto a
     * qualquer animal individual pertencente a ele. Retorna null se
     * pode prosseguir, ou uma mensagem de bloqueio caso contrario.
     */
    private function carenciaVigente(int $idLote, string $dataSaida): ?string
    {
        $aplicacao = AplicacaoSanitaria::leftJoin("animal as a", "aps.id_animal", "=", "a.id")
            ->select("aps.*")
            ->where("aps.data_carencia_fim", ">=", $dataSaida)
            ->whereRaw("(aps.id_lote = ? OR a.id_lote = ?)", [$idLote, $idLote])
            ->orderBy("aps.data_carencia_fim", "desc")
            ->first();

        if (!$aplicacao) {
            return null;
        }

        return "Este lote possui aplicação sanitária com carência vigente até "
            . datebr($aplicacao->data_carencia_fim)
            . ". A saída não pode ser registrada antes do fim da carência.";
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_tipo_saida");
        $data->nullIfEmpty("id_cliente");
        $data->nullIfEmpty("quantidade");
        $data->nullIfEmpty("peso_total");
        $data->nullIfEmpty("peso_medio");
        $data->nullIfEmpty("valor_total");
        $data->nullIfEmpty("resultado");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        if (!empty($payload["peso_medio"])) {
            $payload["peso_medio"] = money2float((string) $payload["peso_medio"]);
        }

        if (!empty($payload["peso_total"])) {
            $payload["peso_total"] = money2float((string) $payload["peso_total"]);
        }

        if (!empty($payload["valor_total"])) {
            $payload["valor_total"] = money2float((string) $payload["valor_total"]);
        }

        return $payload;
    }

    private function urlVoltar(?int $idLote): string
    {
        return $idLote
            ? $this->router->route("admin.manejo.saida.index", ["id_lote" => $idLote])
            : $this->router->route("admin.manejo.saida.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function tiposSaida(): array
    {
        return TipoSaida::orderBy("descricao")->get();
    }

    private function clientes(): array
    {
        return Cliente::orderBy("razao")->get();
    }
}
