<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\File;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\Animal;
use App\Models\Manejo\Lote;
use App\Models\Manejo\Ocorrencia;
use App\Models\Manejo\OcorrenciaAnexo;

class OcorrenciaController extends ControllerAdmin
{
    private const MEDIA_PATH = "storage/media/ocorrencias/";
    private const EXTENSOES_PERMITIDAS = [
        "jpg", "jpeg", "png", "gif", "bmp", "webp",
        "mp4", "mov", "avi", "webm", "mkv",
        "mp3", "wav", "ogg", "m4a", "wma",
    ];

    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Ocorrências",
            "active_menu" => "manejo-ocorrencias",
            "page" => [
                "title" => "Ocorrências",
                "desc" => "Registre eventos do manejo com fotos, vídeos e áudios de apoio",
            ],
            "required" => implode(",", Ocorrencia::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("ocorrencia_gerenciar");

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
            $breadcrumb["Ocorrências de " . $lote->nome] = ["url" => false, "current" => true];
        } elseif ($animal) {
            $breadcrumb["Animais"] = ["url" => $this->router->route("admin.manejo.animal.index"), "current" => false];
            $breadcrumb["Ocorrências de " . $animal->identificacao] = ["url" => false, "current" => true];
        } else {
            $breadcrumb["Ocorrências"] = ["url" => false, "current" => true];
        }

        $this->view->addData(["breadcrumb" => $breadcrumb]);

        $query = Ocorrencia::leftJoin("lote as l", "o.id_lote", "=", "l.id")
            ->leftJoin("animal as a", "o.id_animal", "=", "a.id")
            ->select("o.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "a.identificacao as animal_identificacao");

        if ($idLote) {
            $query = $query->where("o.id_lote", "=", $idLote);
        } elseif ($idAnimal) {
            $query = $query->where("o.id_animal", "=", $idAnimal);
        }

        $dados = $query->orderBy("o.data_ocorrencia", "desc")->get();

        $qtdAnexosPorOcorrencia = $this->contarAnexosPorOcorrencia(array_map(fn ($d) => $d->id, $dados));

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome
                ? $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "")
                : ($item->animal_identificacao ?: "-");
            $item->total_anexos = $qtdAnexosPorOcorrencia[$item->id] ?? 0;
        }

        echo $this->view->render("admin/manejo/ocorrencia/index", [
            "dados" => $dados,
            "lote" => $lote,
            "animal" => $animal,
            "permissao" => [
                "inserir" => $this->auth->allow("ocorrencia_inserir"),
                "editar" => $this->auth->allow("ocorrencia_editar"),
                "excluir" => $this->auth->allow("ocorrencia_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("ocorrencia_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $idAnimal = $data->has("id_animal") ? (int) $data->id_animal : null;

        echo $this->view->render("admin/manejo/ocorrencia/form", [
            "csrf" => $this->csrf->generate(),
            "ocorrencia" => false,
            "anexos" => [],
            "id_lote" => $idLote,
            "id_animal" => $idAnimal,
            "lotes" => $this->lotes(),
            "animais" => $this->animais(),
            "url_action" => $this->router->route("admin.manejo.ocorrencia.insert"),
            "url_voltar" => $this->urlVoltar($idLote, $idAnimal),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("ocorrencia_inserir");
        $data = new Data($request->all());

        $validacao = $this->validarDados($data);
        if ($validacao !== null) {
            $this->message->warning($validacao);
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        $ocorrencia = Ocorrencia::create($payload);

        $this->salvarAnexos((int) $ocorrencia->id, $request);

        $this->message->success("Ocorrência registrada com sucesso");
        $this->router->redirect("admin.manejo.ocorrencia.index", array_filter([
            "id_lote" => $payload["id_lote"] ?? null,
            "id_animal" => $payload["id_animal"] ?? null,
        ]));
    }

    public function edit(Request $request): void
    {
        $this->authorize("ocorrencia_editar");
        $data = new Data($request->all());
        $ocorrencia = Ocorrencia::find($data->id) ?: Ocorrencia::findByMd5($data->id);

        if (!$ocorrencia) {
            $this->message->warning("Ocorrência não encontrada");
            $this->router->redirect("admin.manejo.ocorrencia.index");
            return;
        }

        echo $this->view->render("admin/manejo/ocorrencia/form", [
            "csrf" => $this->csrf->generate(),
            "ocorrencia" => $ocorrencia,
            "anexos" => $this->anexosDaOcorrencia($ocorrencia->id),
            "id_lote" => $ocorrencia->id_lote,
            "id_animal" => $ocorrencia->id_animal,
            "lotes" => $this->lotes(),
            "animais" => $this->animais(),
            "url_action" => $this->router->route("admin.manejo.ocorrencia.update"),
            "url_voltar" => $this->urlVoltar($ocorrencia->id_lote, $ocorrencia->id_animal),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("ocorrencia_editar");
        $data = new Data($request->all());
        $ocorrencia = Ocorrencia::find($data->id) ?: Ocorrencia::findByMd5($data->id);

        if (!$ocorrencia) {
            $this->message->warning("Ocorrência não encontrada");
            Redirect::referer();
            return;
        }

        $validacao = $this->validarDados($data);
        if ($validacao !== null) {
            $this->message->warning($validacao);
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        Ocorrencia::updateBy($ocorrencia->id, $payload);

        $this->salvarAnexos((int) $ocorrencia->id, $request);

        $this->message->success("Ocorrência atualizada com sucesso");
        $this->router->redirect("admin.manejo.ocorrencia.index", array_filter([
            "id_lote" => $payload["id_lote"] ?? null,
            "id_animal" => $payload["id_animal"] ?? null,
        ]));
    }

    public function delete(Request $request): void
    {
        $this->authorize("ocorrencia_excluir");
        $data = new Data($request->all());
        $ocorrencia = Ocorrencia::find($data->id) ?: Ocorrencia::findByMd5($data->id);

        if (!$ocorrencia) {
            $this->message->warning("Ocorrência não encontrada");
            Redirect::referer();
            return;
        }

        foreach ($this->anexosDaOcorrencia($ocorrencia->id) as $anexo) {
            File::remove(self::MEDIA_PATH . $anexo->arquivo);
        }

        Ocorrencia::deleteById($ocorrencia->id);
        $this->message->success("Ocorrência removida com sucesso");
        Redirect::referer();
    }

    public function deleteAnexo(Request $request): void
    {
        $this->authorize("ocorrencia_editar");
        $data = new Data($request->all());
        $anexo = OcorrenciaAnexo::find($data->id) ?: OcorrenciaAnexo::findByMd5($data->id);

        if (!$anexo) {
            $this->message->warning("Anexo não encontrado");
            Redirect::referer();
            return;
        }

        File::remove(self::MEDIA_PATH . $anexo->arquivo);
        OcorrenciaAnexo::deleteById($anexo->id);

        $this->message->success("Anexo removido com sucesso");
        Redirect::referer();
    }

    private function validarDados(Data $data): ?string
    {
        $temLote = $data->has("id_lote");
        $temAnimal = $data->has("id_animal");

        if ($temLote && $temAnimal) {
            return "Selecione apenas um vínculo: lote OU animal, nunca os dois.";
        }

        if (!$data->has("data_ocorrencia") || !$data->has("titulo")) {
            return "Informe a data e o título da ocorrência.";
        }

        return null;
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_lote");
        $data->nullIfEmpty("id_animal");
        $data->nullIfEmpty("categoria");
        $data->nullIfEmpty("responsavel");
        $data->nullIfEmpty("descricao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"], $payload["anexos"]);

        return $payload;
    }

    /**
     * Processa o campo de upload múltiplo "anexos" (DizUploader) e cria
     * um registro em ocorrencia_anexo para cada arquivo válido. Falhas
     * em um arquivo individual não interrompem os demais.
     */
    private function salvarAnexos(int $idOcorrencia, Request $request): void
    {
        $bruto = $request->file("anexos");

        if (empty($bruto) || empty($bruto["name"][0] ?? null)) {
            return;
        }

        $arquivos = File::rearrange($bruto);

        foreach ($arquivos as $arquivo) {
            if (($arquivo["error"] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
                continue;
            }

            if (!File::valid($arquivo["tmp_name"])) {
                continue;
            }

            $extensao = strtolower(File::extension($arquivo["name"]));
            if (!in_array($extensao, self::EXTENSOES_PERMITIDAS, true)) {
                continue;
            }

            $nomeArquivo = File::named(self::MEDIA_PATH, $arquivo["name"], true);
            $destino = self::MEDIA_PATH . $nomeArquivo;

            if (!File::upload($arquivo["tmp_name"], $destino)) {
                continue;
            }

            OcorrenciaAnexo::create([
                "id_ocorrencia" => $idOcorrencia,
                "arquivo" => $nomeArquivo,
                "nome_original" => $arquivo["name"],
                "tipo_midia" => OcorrenciaAnexo::tipoMidiaPorExtensao($extensao),
                "mime_type" => File::mime($destino),
                "tamanho" => (int) File::size($destino),
                "created_by" => $this->user->uid,
            ]);
        }
    }

    private function anexosDaOcorrencia(int $idOcorrencia): array
    {
        $anexos = OcorrenciaAnexo::where("id_ocorrencia", "=", $idOcorrencia)
            ->orderBy("id")
            ->get();

        foreach ($anexos as $anexo) {
            $anexo->hash = md5((string) $anexo->id);
            $anexo->url = "/" . self::MEDIA_PATH . $anexo->arquivo;
        }

        return $anexos;
    }

    private function contarAnexosPorOcorrencia(array $ids): array
    {
        $ids = array_values(array_filter($ids));
        if (empty($ids)) {
            return [];
        }

        $linhas = OcorrenciaAnexo::whereIn("id_ocorrencia", $ids)
            ->select("id_ocorrencia", "COUNT(*) as total")
            ->groupBy("id_ocorrencia")
            ->get();

        $resultado = [];
        foreach ($linhas as $linha) {
            $resultado[$linha->id_ocorrencia] = (int) $linha->total;
        }

        return $resultado;
    }

    private function urlVoltar(?int $idLote, ?int $idAnimal): string
    {
        if ($idLote) {
            return $this->router->route("admin.manejo.ocorrencia.index", ["id_lote" => $idLote]);
        }

        if ($idAnimal) {
            return $this->router->route("admin.manejo.ocorrencia.index", ["id_animal" => $idAnimal]);
        }

        return $this->router->route("admin.manejo.ocorrencia.index");
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
