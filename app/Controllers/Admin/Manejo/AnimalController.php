<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Fornecedor;
use App\Models\Manejo\Animal;
use App\Models\Manejo\AnimalSituacao;
use App\Models\Manejo\Lote;
use App\Models\Manejo\TipoEntrada;

class AnimalController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Animais",
            "active_menu" => "manejo-animais",
            "page" => [
                "title" => "Animais",
                "desc" => "Cadastro individual dos animais do confinamento",
            ],
            "uppers" => implode(",", Animal::getUppers()),
            "required" => implode(",", Animal::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("animal_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Manejo" => ["url" => false, "current" => false],
                "Animais" => ["url" => false, "current" => true],
            ],
        ]);

        $animais = Animal::leftJoin("lote as l", "a.id_lote", "=", "l.id")
            ->leftJoin("fornecedor as f", "a.id_fornecedor", "=", "f.id")
            ->leftJoin("animal_situacao as asi", "a.id_situacao", "=", "asi.id")
            ->select("a.*", "l.nome as lote_nome", "l.codigo as lote_codigo", "f.razao as fornecedor_razao", "asi.descricao as situacao_descricao", "asi.cor as situacao_cor")
            ->orderBy("a.identificacao")
            ->get();

        foreach ($animais as $animal) {
            $animal->hash = md5((string) $animal->id);
            $animal->situacao_badge = $animal->situacao_descricao
                ? $this->badgeColor($animal->situacao_descricao, $animal->situacao_cor ?: "#6c757d")
                : null;
        }

        echo $this->view->render("admin/manejo/animal/index", [
            "dados" => $animais,
            "permissao" => [
                "inserir" => $this->auth->allow("animal_inserir"),
                "editar" => $this->auth->allow("animal_editar"),
                "excluir" => $this->auth->allow("animal_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("animal_inserir");
        echo $this->view->render("admin/manejo/animal/form", [
            "csrf" => $this->csrf->generate(),
            "animal" => false,
            "lotes" => $this->lotes(),
            "fornecedores" => $this->fornecedores(),
            "tiposEntrada" => $this->tiposEntrada(),
            "situacoes" => $this->situacoes(),
            "url_action" => $this->router->route("admin.manejo.animal.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("animal_inserir");
        $data = new Data($request->all());

        if (!$data->has("identificacao")) {
            $this->message->warning("Informe a identificação do animal");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("id_lote");
        $data->nullIfEmpty("id_fornecedor");
        $data->nullIfEmpty("id_tipo_entrada");
        $data->nullIfEmpty("id_situacao");
        $data->nullIfEmpty("data_nascimento");
        $data->nullIfEmpty("data_entrada");
        $data->nullIfEmpty("peso_entrada");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        if (!empty($payload["peso_entrada"])) {
            $payload["peso_entrada"] = money2float((string) $payload["peso_entrada"]);
        }

        Animal::create($payload);
        $this->message->success("Animal cadastrado com sucesso");
        $this->router->redirect("admin.manejo.animal.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("animal_editar");
        $data = new Data($request->all());
        $animal = Animal::find($data->id) ?: Animal::findByMd5($data->id);

        if (!$animal) {
            $this->message->warning("Animal não encontrado");
            $this->router->redirect("admin.manejo.animal.index");
        }

        echo $this->view->render("admin/manejo/animal/form", [
            "csrf" => $this->csrf->generate(),
            "animal" => $animal,
            "lotes" => $this->lotes(),
            "fornecedores" => $this->fornecedores(),
            "tiposEntrada" => $this->tiposEntrada(),
            "situacoes" => $this->situacoes(),
            "url_action" => $this->router->route("admin.manejo.animal.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("animal_editar");
        $data = new Data($request->all());
        $animal = Animal::find($data->id) ?: Animal::findByMd5($data->id);

        if (!$animal) {
            $this->message->warning("Animal não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("identificacao")) {
            $this->message->warning("Informe a identificação do animal");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("id_lote");
        $data->nullIfEmpty("id_fornecedor");
        $data->nullIfEmpty("id_tipo_entrada");
        $data->nullIfEmpty("id_situacao");
        $data->nullIfEmpty("data_nascimento");
        $data->nullIfEmpty("data_entrada");
        $data->nullIfEmpty("peso_entrada");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        if (!empty($payload["peso_entrada"])) {
            $payload["peso_entrada"] = money2float((string) $payload["peso_entrada"]);
        }

        Animal::updateBy($animal->id, $payload);
        $this->message->success("Animal atualizado com sucesso");
        $this->router->redirect("admin.manejo.animal.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("animal_excluir");
        $data = new Data($request->all());
        $animal = Animal::find($data->id) ?: Animal::findByMd5($data->id);

        if (!$animal) {
            $this->message->warning("Animal não encontrado");
            Redirect::referer();
            return;
        }

        Animal::deleteById($animal->id);
        $this->message->success("Animal removido com sucesso");
        Redirect::referer();
    }

    private function lotes(): array
    {
        return Lote::orderBy("nome")->get();
    }

    private function fornecedores(): array
    {
        return Fornecedor::orderBy("razao")->get();
    }

    private function tiposEntrada(): array
    {
        return TipoEntrada::orderBy("descricao")->get();
    }

    private function situacoes(): array
    {
        return AnimalSituacao::orderBy("descricao")->get();
    }

    private function badgeColor(string $label, string $color): string
    {
        $color = trim($color) ?: "#6c757d";
        $textColor = colorContrast($color);

        return '<span class="badge filled-outlined" style="background:' . htmlspecialchars($color, ENT_QUOTES, "UTF-8") . ';border-color:' . htmlspecialchars($color, ENT_QUOTES, "UTF-8") . ';color:' . htmlspecialchars($textColor, ENT_QUOTES, "UTF-8") . ';">' . htmlspecialchars($label, ENT_QUOTES, "UTF-8") . '</span>';
    }
}
