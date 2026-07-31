<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\Animal;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MovimentacaoPesagem;

class PesagemController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Pesagens",
            "active_menu" => "manejo-pesagens",
            "page" => [
                "title" => "Pesagens",
                "desc" => "Acompanhe o peso e o ganho médio diário dos lotes e animais",
            ],
            "uppers" => implode(",", MovimentacaoPesagem::getUppers()),
            "required" => implode(",", MovimentacaoPesagem::getRequired()),
        ]);
    }

    /**
     * Lista as pesagens filtradas por lote OU por animal (um dos dois via querystring).
     * Sem filtro, lista as pesagens mais recentes de todos os lotes/animais.
     */
    public function index(Request $request): void
    {
        $this->authorize("pesagem_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $idAnimal = $data->has("id_animal") ? (int) $data->id_animal : null;

        $lote = $idLote ? Lote::find($idLote) : null;
        $animal = $idAnimal ? Animal::find($idAnimal) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Manejo" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Pesagens de " . $lote->nome] = ["url" => false, "current" => true];
        } elseif ($animal) {
            $breadcrumb["Animais"] = ["url" => $this->router->route("admin.manejo.animal.index"), "current" => false];
            $breadcrumb["Pesagens de " . $animal->identificacao] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Pesagens"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = MovimentacaoPesagem::leftJoin("lote as l", "mp.id_lote", "=", "l.id")
            ->leftJoin("animal as a", "mp.id_animal", "=", "a.id")
            ->select("mp.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "a.identificacao as animal_identificacao");

        if ($idLote) {
            $query = $query->where("mp.id_lote", "=", $idLote);
        } elseif ($idAnimal) {
            $query = $query->where("mp.id_animal", "=", $idAnimal);
        }

        $pesagens = $query->orderBy("mp.id_lote")->orderBy("mp.id_animal")->orderBy("mp.data_pesagem")->get();

        // GMD e calculado comparando cada pesagem com a anterior do MESMO
        // lote/animal, na ordem cronologica. Como a query ja vem ordenada
        // por vinculo e depois por data, um cursor sequencial resolve sem
        // precisar de janela SQL.
        $anteriorPorChave = [];
        foreach ($pesagens as $pesagem) {
            $chave = $pesagem->id_lote ? "lote_{$pesagem->id_lote}" : "animal_{$pesagem->id_animal}";
            $anterior = $anteriorPorChave[$chave] ?? null;

            $pesagem->hash = md5((string) $pesagem->id);
            $pesagem->gmd = $anterior
                ? MovimentacaoPesagem::calcularGmd((float) $anterior->peso_medio, $anterior->data_pesagem, (float) $pesagem->peso_medio, $pesagem->data_pesagem)
                : null;
            $pesagem->vinculo_print = $pesagem->lote_nome
                ? $pesagem->lote_nome . ($pesagem->lote_codigo ? " ({$pesagem->lote_codigo})" : "")
                : ($pesagem->animal_identificacao ?: "-");

            $anteriorPorChave[$chave] = $pesagem;
        }

        // Para exibicao, a listagem mostra as mais recentes primeiro.
        $pesagens = array_reverse($pesagens);

        echo $this->view->render("admin/manejo/pesagem/index", [
            "dados" => $pesagens,
            "lote" => $lote,
            "animal" => $animal,
            "permissao" => [
                "inserir" => $this->auth->allow("pesagem_inserir"),
                "editar" => $this->auth->allow("pesagem_editar"),
                "excluir" => $this->auth->allow("pesagem_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("pesagem_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $idAnimal = $data->has("id_animal") ? (int) $data->id_animal : null;

        echo $this->view->render("admin/manejo/pesagem/form", [
            "csrf" => $this->csrf->generate(),
            "pesagem" => false,
            "id_lote" => $idLote,
            "id_animal" => $idAnimal,
            "lotes" => $this->lotes(),
            "animais" => $this->animais(),
            "url_action" => $this->router->route("admin.manejo.pesagem.insert"),
            "url_voltar" => $this->urlVoltar($idLote, $idAnimal),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("pesagem_inserir");
        $data = new Data($request->all());

        $validacao = $this->validarVinculoEDados($data);
        if ($validacao !== null) {
            $this->message->warning($validacao);
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        MovimentacaoPesagem::create($payload);

        $this->message->success("Pesagem registrada com sucesso");
        $this->router->redirect("admin.manejo.pesagem.index", array_filter([
            "id_lote" => $payload["id_lote"] ?? null,
            "id_animal" => $payload["id_animal"] ?? null,
        ]));
    }

    public function edit(Request $request): void
    {
        $this->authorize("pesagem_editar");
        $data = new Data($request->all());
        $pesagem = MovimentacaoPesagem::find($data->id) ?: MovimentacaoPesagem::findByMd5($data->id);

        if (!$pesagem) {
            $this->message->warning("Pesagem não encontrada");
            $this->router->redirect("admin.manejo.pesagem.index");
            return;
        }

        echo $this->view->render("admin/manejo/pesagem/form", [
            "csrf" => $this->csrf->generate(),
            "pesagem" => $pesagem,
            "id_lote" => $pesagem->id_lote,
            "id_animal" => $pesagem->id_animal,
            "lotes" => $this->lotes(),
            "animais" => $this->animais(),
            "url_action" => $this->router->route("admin.manejo.pesagem.update"),
            "url_voltar" => $this->urlVoltar($pesagem->id_lote, $pesagem->id_animal),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("pesagem_editar");
        $data = new Data($request->all());
        $pesagem = MovimentacaoPesagem::find($data->id) ?: MovimentacaoPesagem::findByMd5($data->id);

        if (!$pesagem) {
            $this->message->warning("Pesagem não encontrada");
            Redirect::referer();
            return;
        }

        $validacao = $this->validarVinculoEDados($data);
        if ($validacao !== null) {
            $this->message->warning($validacao);
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        MovimentacaoPesagem::updateBy($pesagem->id, $payload);

        $this->message->success("Pesagem atualizada com sucesso");
        $this->router->redirect("admin.manejo.pesagem.index", array_filter([
            "id_lote" => $payload["id_lote"] ?? null,
            "id_animal" => $payload["id_animal"] ?? null,
        ]));
    }

    public function delete(Request $request): void
    {
        $this->authorize("pesagem_excluir");
        $data = new Data($request->all());
        $pesagem = MovimentacaoPesagem::find($data->id) ?: MovimentacaoPesagem::findByMd5($data->id);

        if (!$pesagem) {
            $this->message->warning("Pesagem não encontrada");
            Redirect::referer();
            return;
        }

        MovimentacaoPesagem::deleteById($pesagem->id);
        $this->message->success("Pesagem removida com sucesso");
        Redirect::referer();
    }

    /**
     * Garante que exatamente um vinculo (lote OU animal) foi informado e
     * que os campos obrigatorios de peso/data estao presentes.
     */
    private function validarVinculoEDados(Data $data): ?string
    {
        $temLote = $data->has("id_lote");
        $temAnimal = $data->has("id_animal");

        if ($temLote === $temAnimal) {
            return "Selecione um lote OU um animal para a pesagem, nunca os dois nem nenhum.";
        }

        if (!$data->has("tipo") || !$data->has("data_pesagem") || !$data->has("peso_medio")) {
            return "Informe tipo, data e peso da pesagem.";
        }

        return null;
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_lote");
        $data->nullIfEmpty("id_animal");
        $data->nullIfEmpty("quantidade");
        $data->nullIfEmpty("peso_total");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        if (!empty($payload["peso_medio"])) {
            $payload["peso_medio"] = money2float((string) $payload["peso_medio"]);
        }

        if (!empty($payload["peso_total"])) {
            $payload["peso_total"] = money2float((string) $payload["peso_total"]);
        }

        return $payload;
    }

    private function urlVoltar(?int $idLote, ?int $idAnimal): string
    {
        if ($idLote) {
            return $this->router->route("admin.manejo.pesagem.index", ["id_lote" => $idLote]);
        }

        if ($idAnimal) {
            return $this->router->route("admin.manejo.pesagem.index", ["id_animal" => $idAnimal]);
        }

        return $this->router->route("admin.manejo.pesagem.index");
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function animais(): array
    {
        return Animal::orderBy("identificacao")->get();
    }
}
