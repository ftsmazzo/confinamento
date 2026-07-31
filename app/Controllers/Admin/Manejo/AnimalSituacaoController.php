<?php

namespace App\Controllers\Admin\Manejo;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Manejo\Animal;
use App\Models\Manejo\AnimalSituacao;

class AnimalSituacaoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Situações do Animal",
            "active_menu" => "manejo-situacoes-animal",
            "page" => [
                "title" => "Situações do Animal",
                "desc" => "Cadastre as situações possíveis do animal: ativo, vendido, abatido, morto etc",
            ],
            "uppers" => implode(",", AnimalSituacao::getUppers()),
            "required" => implode(",", AnimalSituacao::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("animal_situacao_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Manejo" => ["url" => false, "current" => false],
                "Situações do Animal" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = AnimalSituacao::orderBy("descricao")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->animais = Animal::where("id_situacao", "=", $item->id)->count();
            $item->badge = $this->badgeColor($item->descricao, $item->cor ?: "#6c757d");
        }

        echo $this->view->render("admin/manejo/animal-situacao/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("animal_situacao_inserir"),
                "editar" => $this->auth->allow("animal_situacao_editar"),
                "excluir" => $this->auth->allow("animal_situacao_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("animal_situacao_inserir");
        echo $this->view->render("admin/manejo/animal-situacao/form", [
            "csrf" => $this->csrf->generate(),
            "situacao" => false,
            "url_action" => $this->router->route("admin.manejo.animal.situacao.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("animal_situacao_inserir");
        $data = new Data($request->all());

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição da situação");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["created_by"] = $this->user->uid;

        AnimalSituacao::create($payload);
        $this->message->success("Situação cadastrada com sucesso");
        $this->router->redirect("admin.manejo.animal.situacao.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("animal_situacao_editar");
        $data = new Data($request->all());
        $situacao = AnimalSituacao::find($data->id) ?: AnimalSituacao::findByMd5($data->id);

        if (!$situacao) {
            $this->message->warning("Situação não encontrada");
            $this->router->redirect("admin.manejo.animal.situacao.index");
            return;
        }

        echo $this->view->render("admin/manejo/animal-situacao/form", [
            "csrf" => $this->csrf->generate(),
            "situacao" => $situacao,
            "url_action" => $this->router->route("admin.manejo.animal.situacao.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("animal_situacao_editar");
        $data = new Data($request->all());
        $situacao = AnimalSituacao::find($data->id) ?: AnimalSituacao::findByMd5($data->id);

        if (!$situacao) {
            $this->message->warning("Situação não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("descricao")) {
            $this->message->warning("Informe a descrição da situação");
            Redirect::referer();
            return;
        }

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);
        $payload["updated_by"] = $this->user->uid;

        AnimalSituacao::updateBy($situacao->id, $payload);
        $this->message->success("Situação atualizada com sucesso");
        $this->router->redirect("admin.manejo.animal.situacao.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("animal_situacao_excluir");
        $data = new Data($request->all());
        $situacao = AnimalSituacao::find($data->id) ?: AnimalSituacao::findByMd5($data->id);

        if (!$situacao) {
            $this->message->warning("Situação não encontrada");
            Redirect::referer();
            return;
        }

        if (Animal::where("id_situacao", "=", $situacao->id)->count() > 0) {
            $this->message->warning("Existem animais vinculados a esta situação");
            Redirect::referer();
            return;
        }

        AnimalSituacao::deleteById($situacao->id);
        $this->message->success("Situação removida com sucesso");
        Redirect::referer();
    }

    private function badgeColor(string $label, string $color): string
    {
        $color = trim($color) ?: "#6c757d";
        $textColor = colorContrast($color);

        return '<span class="badge filled-outlined" style="background:' . htmlspecialchars($color, ENT_QUOTES, "UTF-8") . ';border-color:' . htmlspecialchars($color, ENT_QUOTES, "UTF-8") . ';color:' . htmlspecialchars($textColor, ENT_QUOTES, "UTF-8") . ';">' . htmlspecialchars($label, ENT_QUOTES, "UTF-8") . '</span>';
    }
}
