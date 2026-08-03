<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\File;
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
        $visao = $data->has("visao") && $data->visao === "historico" ? "historico" : "dia";
        $dataFiltro = $data->has("data") ? (string) $data->data : date("Y-m-d");
        $turnoFiltro = $data->has("turno") ? strtoupper(trim((string) $data->turno)) : "";

        if (!isset(LeituraCocho::turnosLabel()[$turnoFiltro])) {
            $turnoFiltro = "";
        }

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

        if ($visao === "dia") {
            $query = $query->where("lc.data_leitura", "=", $dataFiltro);
            if ($turnoFiltro !== "") {
                $query = $query->where("lc.turno", "=", $turnoFiltro);
            }
            $dados = $query->orderBy("lc.turno")->orderBy("l.nome")->get();
        } else {
            $dados = $query->orderBy("lc.data_leitura", "desc")->orderBy("lc.id", "desc")->get();
        }

        $porTurno = [];
        foreach (array_keys(LeituraCocho::turnosLabel()) as $turno) {
            $porTurno[$turno] = [];
        }
        $porTurno[""] = [];

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->vinculo_print = $item->lote_nome . ($item->lote_codigo ? " ({$item->lote_codigo})" : "");
            $escore = $item->escore === null || $item->escore === "" ? null : (int) $item->escore;
            $item->escore_valor = $escore;
            $item->escore_label = LeituraCocho::escoreLabel($escore);
            $item->turno_label = LeituraCocho::turnoLabel($item->turno ?? null);
            $item->foto_url = !empty($item->foto)
                ? media(LeituraCocho::MEDIA_URL_PATH, $item->foto)
                : null;

            $chave = (string) ($item->turno ?? "");
            if (!isset($porTurno[$chave])) {
                $porTurno[$chave] = [];
            }
            $porTurno[$chave][] = $item;
        }

        echo $this->view->render("admin/nutricao/leitura-cocho/index", [
            "dados" => $dados,
            "por_turno" => $porTurno,
            "turnos_label" => LeituraCocho::turnosLabel(),
            "lote" => $lote,
            "visao" => $visao,
            "data_filtro" => $dataFiltro,
            "turno_filtro" => $turnoFiltro,
            "permissao" => [
                "inserir" => $this->auth->allow("leitura_cocho_inserir"),
                "editar" => $this->auth->allow("leitura_cocho_editar"),
                "excluir" => $this->auth->allow("leitura_cocho_excluir"),
                "dar_nota" => $this->auth->allow("dieta_dar_nota"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("leitura_cocho_inserir");

        $data = new Data($request->all());
        $idLote = $data->has("id_lote") ? (int) $data->id_lote : null;
        $canDarNota = $this->auth->allow("dieta_dar_nota");

        echo $this->view->render("admin/nutricao/leitura-cocho/form", [
            "csrf" => $this->csrf->generate(),
            "leitura" => false,
            "id_lote" => $idLote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "turnos_label" => LeituraCocho::turnosLabel(),
            "can_dar_nota" => $canDarNota,
            "url_action" => $this->router->route("admin.nutricao.leitura.cocho.insert"),
            "url_voltar" => $this->urlVoltar($idLote),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("leitura_cocho_inserir");
        $data = new Data($request->all());
        $canDarNota = $this->auth->allow("dieta_dar_nota");

        if (!$data->has("id_lote") || !$data->has("data_leitura")) {
            $this->message->warning("Selecione o lote e informe a data da leitura");
            Redirect::referer();
            return;
        }

        if ($canDarNota && $data->has("escore") && !$this->escoreValido($data->escore)) {
            $this->message->warning("Escore inválido (use 0 a 4)");
            Redirect::referer();
            return;
        }

        try {
            $payload = $this->normalizarPayload($data, $canDarNota);
            $foto = $this->processarFoto($_FILES["foto"] ?? []);
            if ($foto) {
                $payload["foto"] = $foto;
            }
            $payload["created_by"] = $this->user->uid;

            LeituraCocho::create($payload);
            $this->message->success("Leitura de cocho registrada com sucesso");
            $this->router->redirect("admin.nutricao.leitura.cocho.index", [
                "id_lote" => $payload["id_lote"],
                "data" => $payload["data_leitura"],
                "visao" => "dia",
            ]);
        } catch (\Throwable $e) {
            $this->message->warning($e->getMessage());
            Redirect::referer();
        }
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

        $canDarNota = $this->auth->allow("dieta_dar_nota");

        echo $this->view->render("admin/nutricao/leitura-cocho/form", [
            "csrf" => $this->csrf->generate(),
            "leitura" => $leitura,
            "id_lote" => (int) $leitura->id_lote,
            "lotes" => $this->lotes(),
            "currais" => $this->currais(),
            "turnos_label" => LeituraCocho::turnosLabel(),
            "can_dar_nota" => $canDarNota,
            "url_action" => $this->router->route("admin.nutricao.leitura.cocho.update"),
            "url_voltar" => $this->urlVoltar((int) $leitura->id_lote),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("leitura_cocho_editar");
        $data = new Data($request->all());
        $leitura = LeituraCocho::find($data->id) ?: LeituraCocho::findByMd5($data->id);
        $canDarNota = $this->auth->allow("dieta_dar_nota");

        if (!$leitura) {
            $this->message->warning("Leitura não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("id_lote") || !$data->has("data_leitura")) {
            $this->message->warning("Selecione o lote e informe a data da leitura");
            Redirect::referer();
            return;
        }

        if ($canDarNota && $data->has("escore") && !$this->escoreValido($data->escore)) {
            $this->message->warning("Escore inválido (use 0 a 4)");
            Redirect::referer();
            return;
        }

        try {
            $payload = $this->normalizarPayload($data, $canDarNota, $leitura);
            $foto = $this->processarFoto($_FILES["foto"] ?? [], $leitura->foto ?? null);
            if ($foto) {
                $payload["foto"] = $foto;
            } elseif (!empty($data->remover_foto)) {
                if (!empty($leitura->foto)) {
                    File::remove(LeituraCocho::MEDIA_PATH . $leitura->foto);
                }
                $payload["foto"] = null;
            }
            $payload["updated_by"] = $this->user->uid;

            LeituraCocho::updateBy($leitura->id, $payload);
            $this->message->success("Leitura de cocho atualizada com sucesso");
            $this->router->redirect("admin.nutricao.leitura.cocho.index", [
                "id_lote" => $payload["id_lote"],
                "data" => $payload["data_leitura"],
                "visao" => "dia",
            ]);
        } catch (\Throwable $e) {
            $this->message->warning($e->getMessage());
            Redirect::referer();
        }
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

        if (!empty($leitura->foto)) {
            File::remove(LeituraCocho::MEDIA_PATH . $leitura->foto);
        }

        LeituraCocho::deleteById($leitura->id);
        $this->message->success("Leitura de cocho removida com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data, bool $canDarNota, ?object $atual = null): array
    {
        $data->nullIfEmpty("id_curral");
        $data->nullIfEmpty("observacao");
        $data->nullIfEmpty("turno");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"], $payload["remover_foto"], $payload["foto"]);

        $turno = strtoupper(trim((string) ($payload["turno"] ?? "")));
        if ($turno !== "" && !isset(LeituraCocho::turnosLabel()[$turno])) {
            $turno = "";
        }
        $payload["turno"] = $turno !== "" ? $turno : null;

        if ($canDarNota) {
            if (!array_key_exists("escore", $payload) || $payload["escore"] === "" || $payload["escore"] === null) {
                $payload["escore"] = null;
            } else {
                $payload["escore"] = (int) $payload["escore"];
            }
        } elseif ($atual) {
            unset($payload["escore"]);
        } else {
            $payload["escore"] = null;
        }

        return $payload;
    }

    private function escoreValido(mixed $escore): bool
    {
        if ($escore === "" || $escore === null) {
            return true;
        }

        if (!is_numeric($escore)) {
            return false;
        }

        $valor = (int) $escore;
        return $valor >= 0 && $valor <= 4;
    }

    /**
     * @param array<string, mixed> $file
     */
    private function processarFoto(array $file, ?string $fotoAtual = null): ?string
    {
        $tmp = $file["tmp_name"] ?? null;
        $name = $file["name"] ?? null;
        $error = (int) ($file["error"] ?? UPLOAD_ERR_NO_FILE);

        if ($error === UPLOAD_ERR_NO_FILE || !$tmp || !$name) {
            return null;
        }

        if ($error !== UPLOAD_ERR_OK || !File::valid($tmp)) {
            throw new \RuntimeException("Falha no upload da foto do cocho");
        }

        $ext = strtolower((string) pathinfo((string) $name, PATHINFO_EXTENSION));
        if (!in_array($ext, ["jpg", "jpeg", "png", "gif", "webp"], true)) {
            throw new \RuntimeException("Formato de imagem não permitido (use JPG, PNG, GIF ou WEBP)");
        }

        if (!is_dir(LeituraCocho::MEDIA_PATH)) {
            mkdir(LeituraCocho::MEDIA_PATH, 0775, true);
        }

        if ($fotoAtual) {
            File::remove(LeituraCocho::MEDIA_PATH . $fotoAtual);
        }

        $nomeArquivo = File::named(LeituraCocho::MEDIA_PATH, (string) $name, true);
        $destino = LeituraCocho::MEDIA_PATH . $nomeArquivo;

        if (!File::upload($tmp, $destino)) {
            throw new \RuntimeException("Não foi possível salvar a foto do cocho");
        }

        return $nomeArquivo;
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
        return Curral::comLoteAtivo();
    }
}
