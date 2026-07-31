<?php

namespace App\Controllers\Admin\Sanitario;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Estoque\ProdutoEstoque;
use App\Models\Sanitario\ProtocoloSanitario;

class ProtocoloSanitarioController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Protocolos Sanitários",
            "active_menu" => "sanitario-protocolos",
            "page" => [
                "title" => "Protocolos Sanitários",
                "desc" => "Cadastre os protocolos padrão de vacinação, vermifugação e outros tratamentos",
            ],
            "uppers" => implode(",", ProtocoloSanitario::getUppers()),
            "required" => implode(",", ProtocoloSanitario::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("protocolo_sanitario_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Sanitário" => ["url" => false, "current" => false],
                "Protocolos Sanitários" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = ProtocoloSanitario::leftJoin("produto_estoque as pe", "ps.id_produto_estoque", "=", "pe.id")
            ->select("ps.*", "pe.nome as produto_nome")
            ->orderBy("ps.nome")
            ->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/sanitario/protocolo-sanitario/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("protocolo_sanitario_inserir"),
                "editar" => $this->auth->allow("protocolo_sanitario_editar"),
                "excluir" => $this->auth->allow("protocolo_sanitario_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("protocolo_sanitario_inserir");

        echo $this->view->render("admin/sanitario/protocolo-sanitario/form", [
            "csrf" => $this->csrf->generate(),
            "protocolo" => false,
            "produtos" => $this->produtos(),
            "url_action" => $this->router->route("admin.sanitario.protocolo.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("protocolo_sanitario_inserir");

        $data = new Data($request->all());

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do protocolo");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        ProtocoloSanitario::create($payload);

        $this->message->success("Protocolo cadastrado com sucesso");
        $this->router->redirect("admin.sanitario.protocolo.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("protocolo_sanitario_editar");

        $data = new Data($request->all());
        $protocolo = ProtocoloSanitario::find($data->id) ?: ProtocoloSanitario::findByMd5($data->id);

        if (!$protocolo) {
            $this->message->warning("Protocolo não encontrado");
            $this->router->redirect("admin.sanitario.protocolo.index");
            return;
        }

        echo $this->view->render("admin/sanitario/protocolo-sanitario/form", [
            "csrf" => $this->csrf->generate(),
            "protocolo" => $protocolo,
            "produtos" => $this->produtos(),
            "url_action" => $this->router->route("admin.sanitario.protocolo.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("protocolo_sanitario_editar");

        $data = new Data($request->all());
        $protocolo = ProtocoloSanitario::find($data->id) ?: ProtocoloSanitario::findByMd5($data->id);

        if (!$protocolo) {
            $this->message->warning("Protocolo não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do protocolo");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        ProtocoloSanitario::updateBy($protocolo->id, $payload);

        $this->message->success("Protocolo atualizado com sucesso");
        $this->router->redirect("admin.sanitario.protocolo.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("protocolo_sanitario_excluir");

        $data = new Data($request->all());
        $protocolo = ProtocoloSanitario::find($data->id) ?: ProtocoloSanitario::findByMd5($data->id);

        if (!$protocolo) {
            $this->message->warning("Protocolo não encontrado");
            Redirect::referer();
            return;
        }

        ProtocoloSanitario::deleteById($protocolo->id);

        $this->message->success("Protocolo removido com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_produto_estoque");
        $data->nullIfEmpty("descricao");
        $data->nullIfEmpty("dias_carencia_padrao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        return $payload;
    }

    private function produtos(): array
    {
        return ProdutoEstoque::orderBy("nome")->get();
    }
}
