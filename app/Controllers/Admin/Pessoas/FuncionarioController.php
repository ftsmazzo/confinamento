<?php

namespace App\Controllers\Admin\Pessoas;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Confinamento\Unidade;
use App\Models\Pessoas\Funcionario;
use App\Models\Usuario;

class FuncionarioController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Funcionários",
            "active_menu" => "pessoas-funcionarios",
            "page" => [
                "title" => "Funcionários",
                "desc" => "Cadastre a equipe operacional, técnica, administrativa e de apoio",
            ],
            "uppers" => implode(",", Funcionario::getUppers()),
            "required" => implode(",", Funcionario::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("funcionario_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Pessoas" => ["url" => false, "current" => false],
                "Funcionários" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = Funcionario::leftJoin("unidade as u", "func.id_unidade", "=", "u.id")
            ->select("func.*", "u.nome as unidade_nome")
            ->orderBy("func.nome")
            ->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/pessoas/funcionario/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("funcionario_inserir"),
                "editar" => $this->auth->allow("funcionario_editar"),
                "excluir" => $this->auth->allow("funcionario_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("funcionario_inserir");

        echo $this->view->render("admin/pessoas/funcionario/form", [
            "csrf" => $this->csrf->generate(),
            "funcionario" => false,
            "unidades" => $this->unidades(),
            "usuarios" => $this->usuarios(),
            "url_action" => $this->router->route("admin.pessoas.funcionario.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("funcionario_inserir");

        $data = new Data($request->all());

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do funcionário");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        Funcionario::create($payload);

        $this->message->success("Funcionário cadastrado com sucesso");
        $this->router->redirect("admin.pessoas.funcionario.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("funcionario_editar");

        $data = new Data($request->all());
        $funcionario = Funcionario::find($data->id) ?: Funcionario::findByMd5($data->id);

        if (!$funcionario) {
            $this->message->warning("Funcionário não encontrado");
            $this->router->redirect("admin.pessoas.funcionario.index");
            return;
        }

        echo $this->view->render("admin/pessoas/funcionario/form", [
            "csrf" => $this->csrf->generate(),
            "funcionario" => $funcionario,
            "unidades" => $this->unidades(),
            "usuarios" => $this->usuarios(),
            "url_action" => $this->router->route("admin.pessoas.funcionario.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("funcionario_editar");

        $data = new Data($request->all());
        $funcionario = Funcionario::find($data->id) ?: Funcionario::findByMd5($data->id);

        if (!$funcionario) {
            $this->message->warning("Funcionário não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do funcionário");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        Funcionario::updateBy($funcionario->id, $payload);

        $this->message->success("Funcionário atualizado com sucesso");
        $this->router->redirect("admin.pessoas.funcionario.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("funcionario_excluir");

        $data = new Data($request->all());
        $funcionario = Funcionario::find($data->id) ?: Funcionario::findByMd5($data->id);

        if (!$funcionario) {
            $this->message->warning("Funcionário não encontrado");
            Redirect::referer();
            return;
        }

        Funcionario::deleteById($funcionario->id);

        $this->message->success("Funcionário removido com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_usuario");
        $data->nullIfEmpty("id_unidade");
        $data->nullIfEmpty("cpf");
        $data->nullIfEmpty("cargo");
        $data->nullIfEmpty("setor");
        $data->nullIfEmpty("telefone");
        $data->nullIfEmpty("email");
        $data->nullIfEmpty("data_admissao");
        $data->nullIfEmpty("data_demissao");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        return $payload;
    }

    private function unidades(): array
    {
        return Unidade::orderBy("nome")->get();
    }

    private function usuarios(): array
    {
        return Usuario::orderBy("nome")->get();
    }
}
