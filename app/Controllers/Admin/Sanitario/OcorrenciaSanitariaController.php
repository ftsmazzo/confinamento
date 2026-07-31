<?php

namespace App\Controllers\Admin\Sanitario;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\Animal;
use App\Models\Manejo\Lote;
use App\Models\Sanitario\OcorrenciaSanitaria;

class OcorrenciaSanitariaController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Ocorrências Sanitárias",
            "active_menu" => "sanitario-ocorrencias",
            "page" => [
                "title" => "Ocorrências Sanitárias",
                "desc" => "Registre eventos sanitários relevantes, com gravidade e observações",
            ],
            "required" => implode(",", OcorrenciaSanitaria::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("ocorrencia_sanitaria_gerenciar");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $idAnimal = $data->has("id_animal") ? (int) $data->id_animal : null;

        $lote = $idLote ? Lote::find($idLote) : null;
        $animal = $idAnimal ? Animal::find($idAnimal) : null;

        $breadcrumb = [
            "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
            "Sanitário" => ["url" => false, "current" => false],
        ];

        if ($lote) {
            $breadcrumb["Lotes"] = ["url" => $this->router->route("admin.manejo.lote.index"), "current" => false];
            $breadcrumb["Ocorrências de " . $lote->nome] = ["url" => false, "current" => true];
        } elseif ($animal) {
            $breadcrumb["Animais"] = ["url" => $this->router->route("admin.manejo.animal.index"), "current" => false];
            $breadcrumb["Ocorrências de " . $animal->identificacao] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Ocorrências Sanitárias"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = OcorrenciaSanitaria::leftJoin("lote as l", "os.id_lote", "=", "l.id")
            ->leftJoin("animal as a", "os.id_animal", "=", "a.id")
            ->select("os.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "a.identificacao as animal_identificacao");

        if ($idLote) {
            $query = $query->where("os.id_lote", "=", $idLote);
        } elseif ($idAnimal) {
            $query = $query->where("os.id_animal", "=", $idAnimal);
        }

        $dados = $query->orderBy("os.data_ocorrencia", "desc")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome
                ? $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "")
                : ($item->animal_identificacao ?: "-");
        }

        echo $this->view->render("admin/sanitario/ocorrencia-sanitaria/index", [
            "dados" => $dados,
            "lote" => $lote,
            "animal" => $animal,
            "permissao" => [
                "inserir" => $this->auth->allow("ocorrencia_sanitaria_inserir"),
                "editar" => $this->auth->allow("ocorrencia_sanitaria_editar"),
                "excluir" => $this->auth->allow("ocorrencia_sanitaria_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("ocorrencia_sanitaria_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $idAnimal = $data->has("id_animal") ? (int) $data->id_animal : null;

        echo $this->view->render("admin/sanitario/ocorrencia-sanitaria/form", [
            "csrf" => $this->csrf->generate(),
            "ocorrencia" => false,
            "id_lote" => $idLote,
            "id_animal" => $idAnimal,
            "lotes" => $this->lotes(),
            "animais" => $this->animais(),
            "url_action" => $this->router->route("admin.sanitario.ocorrencia.insert"),
            "url_voltar" => $this->urlVoltar($idLote, $idAnimal),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("ocorrencia_sanitaria_inserir");
        $data = new Data($request->all());

        $validacao = $this->validarVinculoEDados($data);
        if ($validacao !== null) {
            $this->message->warning($validacao);
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        OcorrenciaSanitaria::create($payload);

        $this->message->success("Ocorrência registrada com sucesso");
        $this->router->redirect("admin.sanitario.ocorrencia.index", array_filter([
            "id_lote" => $payload["id_lote"] ?? null,
            "id_animal" => $payload["id_animal"] ?? null,
        ]));
    }

    public function edit(Request $request): void
    {
        $this->authorize("ocorrencia_sanitaria_editar");
        $data = new Data($request->all());
        $ocorrencia = OcorrenciaSanitaria::find($data->id) ?: OcorrenciaSanitaria::findByMd5($data->id);

        if (!$ocorrencia) {
            $this->message->warning("Ocorrência não encontrada");
            $this->router->redirect("admin.sanitario.ocorrencia.index");
            return;
        }

        echo $this->view->render("admin/sanitario/ocorrencia-sanitaria/form", [
            "csrf" => $this->csrf->generate(),
            "ocorrencia" => $ocorrencia,
            "id_lote" => $ocorrencia->id_lote,
            "id_animal" => $ocorrencia->id_animal,
            "lotes" => $this->lotes(),
            "animais" => $this->animais(),
            "url_action" => $this->router->route("admin.sanitario.ocorrencia.update"),
            "url_voltar" => $this->urlVoltar($ocorrencia->id_lote, $ocorrencia->id_animal),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("ocorrencia_sanitaria_editar");
        $data = new Data($request->all());
        $ocorrencia = OcorrenciaSanitaria::find($data->id) ?: OcorrenciaSanitaria::findByMd5($data->id);

        if (!$ocorrencia) {
            $this->message->warning("Ocorrência não encontrada");
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

        OcorrenciaSanitaria::updateBy($ocorrencia->id, $payload);

        $this->message->success("Ocorrência atualizada com sucesso");
        $this->router->redirect("admin.sanitario.ocorrencia.index", array_filter([
            "id_lote" => $payload["id_lote"] ?? null,
            "id_animal" => $payload["id_animal"] ?? null,
        ]));
    }

    public function delete(Request $request): void
    {
        $this->authorize("ocorrencia_sanitaria_excluir");
        $data = new Data($request->all());
        $ocorrencia = OcorrenciaSanitaria::find($data->id) ?: OcorrenciaSanitaria::findByMd5($data->id);

        if (!$ocorrencia) {
            $this->message->warning("Ocorrência não encontrada");
            Redirect::referer();
            return;
        }

        OcorrenciaSanitaria::deleteById($ocorrencia->id);
        $this->message->success("Ocorrência removida com sucesso");
        Redirect::referer();
    }

    private function validarVinculoEDados(Data $data): ?string
    {
        $temLote = $data->has("id_lote");
        $temAnimal = $data->has("id_animal");

        if ($temLote === $temAnimal) {
            return "Selecione um lote OU um animal para a ocorrência, nunca os dois nem nenhum.";
        }

        if (!$data->has("data_ocorrencia") || !$data->has("descricao") || !$data->has("gravidade")) {
            return "Informe a data, a descrição e a gravidade da ocorrência.";
        }

        return null;
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_lote");
        $data->nullIfEmpty("id_animal");
        $data->nullIfEmpty("responsavel");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        return $payload;
    }

    private function urlVoltar(?int $idLote, ?int $idAnimal): string
    {
        if ($idLote) {
            return $this->router->route("admin.sanitario.ocorrencia.index", ["id_lote" => $idLote]);
        }

        if ($idAnimal) {
            return $this->router->route("admin.sanitario.ocorrencia.index", ["id_animal" => $idAnimal]);
        }

        return $this->router->route("admin.sanitario.ocorrencia.index");
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
