<?php

namespace App\Controllers\Admin\Estoque;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Estoque\CategoriaProduto;
use App\Models\Estoque\LocalArmazenagemInterno;
use App\Models\Estoque\ProdutoEstoque;
use App\Models\Fornecedor;

class ProdutoEstoqueController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $somenteSanitarios = isset($_GET["sanitarios"]) && $_GET["sanitarios"] === "1";

        $this->view->addData([
            "title" => $somenteSanitarios ? "Medicamentos e Vacinas" : "Produtos de Estoque",
            "active_menu" => $somenteSanitarios ? "sanitario-medicamentos-vacinas" : "estoque-produtos",
            "page" => [
                "title" => $somenteSanitarios ? "Medicamentos e Vacinas" : "Produtos de Estoque",
                "desc" => $somenteSanitarios
                    ? "Medicamentos, vacinas e suplementos controlados em estoque"
                    : "Cadastre os itens controlados em estoque: medicamentos, materiais, combustível e uso geral",
            ],
            "uppers" => implode(",", ProdutoEstoque::getUppers()),
            "required" => implode(",", ProdutoEstoque::getRequired()),
        ]);
    }

    public function index(Request $request): void
    {
        $this->authorize("produto_estoque_gerenciar");

        $data = new Data($request->all());
        $somenteSanitarios = $data->has("sanitarios") && $data->sanitarios === "1";

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Estoque" => ["url" => false, "current" => false],
                $somenteSanitarios ? "Medicamentos e Vacinas" : "Produtos de Estoque" => ["url" => false, "current" => true],
            ],
        ]);

        $query = ProdutoEstoque::leftJoin("categoria_produto as cat", "pe.id_categoria_produto", "=", "cat.id")
            ->select("pe.*", "cat.descricao as categoria_descricao");

        if ($somenteSanitarios) {
            $query = $query->whereIn("pe.tipo_produto", ProdutoEstoque::TIPOS_SANITARIOS);
        }

        $dados = $query->orderBy("pe.nome")->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->estoque_baixo = $item->estoque_minimo !== null && (float) $item->saldo_atual < (float) $item->estoque_minimo;
            $item->tipo_produto_label = ProdutoEstoque::tipoProdutoLabel($item->tipo_produto);
        }

        echo $this->view->render("admin/estoque/produto-estoque/index", [
            "dados" => $dados,
            "somenteSanitarios" => $somenteSanitarios,
            "permissao" => [
                "inserir" => $this->auth->allow("produto_estoque_inserir"),
                "editar" => $this->auth->allow("produto_estoque_editar"),
                "excluir" => $this->auth->allow("produto_estoque_excluir"),
            ],
        ]);
    }

    public function new(Request $request): void
    {
        $this->authorize("produto_estoque_inserir");

        $data = new Data($request->all());

        echo $this->view->render("admin/estoque/produto-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "produto" => false,
            "tipoProdutoSugerido" => $data->has("tipo_produto") ? (string) $data->tipo_produto : null,
            "categorias" => $this->categorias(),
            "locaisInternos" => $this->locaisInternos(),
            "fornecedores" => $this->fornecedores(),
            "url_action" => $this->router->route("admin.estoque.produto.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("produto_estoque_inserir");

        $data = new Data($request->all());

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do produto");
            Redirect::referer();
            return;
        }

        if (!$data->has("tipo_produto")) {
            $this->message->warning("Informe o tipo do produto");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;
        $payload["created_by"] = $this->user->uid;

        ProdutoEstoque::create($payload);

        $this->message->success("Produto cadastrado com sucesso");
        $this->router->redirect("admin.estoque.produto.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("produto_estoque_editar");

        $data = new Data($request->all());
        $produto = ProdutoEstoque::find($data->id) ?: ProdutoEstoque::findByMd5($data->id);

        if (!$produto) {
            $this->message->warning("Produto não encontrado");
            $this->router->redirect("admin.estoque.produto.index");
            return;
        }

        echo $this->view->render("admin/estoque/produto-estoque/form", [
            "csrf" => $this->csrf->generate(),
            "produto" => $produto,
            "tipoProdutoSugerido" => null,
            "categorias" => $this->categorias(),
            "locaisInternos" => $this->locaisInternos(),
            "fornecedores" => $this->fornecedores(),
            "url_action" => $this->router->route("admin.estoque.produto.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("produto_estoque_editar");

        $data = new Data($request->all());
        $produto = ProdutoEstoque::find($data->id) ?: ProdutoEstoque::findByMd5($data->id);

        if (!$produto) {
            $this->message->warning("Produto não encontrado");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome do produto");
            Redirect::referer();
            return;
        }

        if (!$data->has("tipo_produto")) {
            $this->message->warning("Informe o tipo do produto");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 0;
        $payload["updated_by"] = $this->user->uid;

        ProdutoEstoque::updateBy($produto->id, $payload);

        $this->message->success("Produto atualizado com sucesso");
        $this->router->redirect("admin.estoque.produto.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("produto_estoque_excluir");

        $data = new Data($request->all());
        $produto = ProdutoEstoque::find($data->id) ?: ProdutoEstoque::findByMd5($data->id);

        if (!$produto) {
            $this->message->warning("Produto não encontrado");
            Redirect::referer();
            return;
        }

        ProdutoEstoque::deleteById($produto->id);

        $this->message->success("Produto removido com sucesso");
        Redirect::referer();
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_categoria_produto");
        $data->nullIfEmpty("id_local_armazenagem_interno");
        $data->nullIfEmpty("id_fornecedor_padrao");
        $data->nullIfEmpty("codigo");
        $data->nullIfEmpty("estoque_minimo");
        $data->nullIfEmpty("custo_unitario");
        $data->nullIfEmpty("observacao");
        $data->nullIfEmpty("principio_ativo");
        $data->nullIfEmpty("apresentacao");
        $data->nullIfEmpty("fabricante");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"], $payload["saldo_atual"]);

        if (!isset($payload["unidade_medida"]) || $payload["unidade_medida"] === "") {
            $payload["unidade_medida"] = "UN";
        }

        $payload["controla_lote"] = isset($payload["controla_lote"]) ? (int) $payload["controla_lote"] : 0;

        if (!empty($payload["estoque_minimo"])) {
            $payload["estoque_minimo"] = money2float((string) $payload["estoque_minimo"]);
        }

        if (!empty($payload["custo_unitario"])) {
            $payload["custo_unitario"] = money2float((string) $payload["custo_unitario"]);
        }

        return $payload;
    }

    private function categorias(): array
    {
        return CategoriaProduto::orderBy("descricao")->get();
    }

    private function locaisInternos(): array
    {
        return LocalArmazenagemInterno::orderBy("nome")->get();
    }

    private function fornecedores(): array
    {
        return Fornecedor::orderBy("razao")->get();
    }
}
