<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Nutricao\ConfeccaoRacao;
use App\Models\Nutricao\ConfeccaoRacaoItem;
use App\Models\Nutricao\FormulaRacao;
use App\Models\Nutricao\FormulaRacaoItem;
use App\Models\Nutricao\Ingrediente;

class ConfeccaoRacaoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Confecção de Ração",
            "active_menu" => "nutricao-confeccoes-racao",
            "page" => [
                "title" => "Confecção de Ração",
                "desc" => "Registre cada batida produzida e baixe automaticamente o estoque de ingredientes",
            ],
            "required" => implode(",", ConfeccaoRacao::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("confeccao_racao_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Confecção de Ração" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = ConfeccaoRacao::leftJoin("formula_racao as fr", "cr.id_formula_racao", "=", "fr.id")
            ->leftJoin("usuario as u", "cr.id_operador", "=", "u.id")
            ->select("cr.*", "fr.nome as formula_nome", "u.nome as operador_nome")
            ->orderBy("cr.data_confeccao", "desc")
            ->get();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
        }

        echo $this->view->render("admin/nutricao/confeccao-racao/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("confeccao_racao_inserir"),
                "editar" => $this->auth->allow("confeccao_racao_editar"),
                "excluir" => $this->auth->allow("confeccao_racao_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("confeccao_racao_inserir");
        echo $this->view->render("admin/nutricao/confeccao-racao/form", [
            "csrf" => $this->csrf->generate(),
            "confeccao" => false,
            "itens" => [],
            "formulas" => $this->formulas(),
            "url_action" => $this->router->route("admin.nutricao.confeccao.racao.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("confeccao_racao_inserir");
        $data = new Data($request->all());

        if (!$data->has("id_formula_racao") || !$data->has("data_confeccao") || !$data->has("quantidade_real")) {
            $this->message->warning("Selecione a fórmula, a data e a quantidade real produzida");
            Redirect::referer();
            return;
        }

        $itensFormula = FormulaRacaoItem::where("id_formula_racao", "=", (int) $data->id_formula_racao)->get();

        if (empty($itensFormula)) {
            $this->message->warning("Esta fórmula não possui composição de ingredientes cadastrada");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["id_operador"] = $payload["id_operador"] ?? $this->user->uid;
        $payload["created_by"] = $this->user->uid;

        $confeccao = ConfeccaoRacao::create($payload);

        $this->registrarConsumoEBaixarEstoque((int) $confeccao->id, $itensFormula, (float) $payload["quantidade_real"]);

        $this->message->success("Confecção registrada e estoque de ingredientes baixado com sucesso");
        $this->router->redirect("admin.nutricao.confeccao.racao.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("confeccao_racao_editar");
        $data = new Data($request->all());
        $confeccao = ConfeccaoRacao::find($data->id) ?: ConfeccaoRacao::findByMd5($data->id);

        if (!$confeccao) {
            $this->message->warning("Confecção não encontrada");
            $this->router->redirect("admin.nutricao.confeccao.racao.index");
            return;
        }

        $formula = FormulaRacao::find((int) $confeccao->id_formula_racao);
        $confeccao->id_formula_racao_nome = $formula->nome ?? "";

        $itens = ConfeccaoRacaoItem::leftJoin("ingrediente as i", "cri.id_ingrediente", "=", "i.id")
            ->select("cri.*", "i.nome as ingrediente_nome")
            ->where("cri.id_confeccao_racao", "=", $confeccao->id)
            ->orderBy("i.nome")
            ->get();

        echo $this->view->render("admin/nutricao/confeccao-racao/visualizar", [
            "csrf" => $this->csrf->generate(),
            "confeccao" => $confeccao,
            "itens" => $itens,
        ]);
    }

    /**
     * Confeccao ja baixou estoque; edicao livre poderia descontrolar o
     * saldo. Por ora, so permite editar campos que nao afetam consumo
     * (observacao) — quantidade/formula exigiriam estornar e refazer a
     * baixa, o que fica para uma proxima iteracao.
     */
    public function update(Request $request): void
    {
        $this->authorize("confeccao_racao_editar");
        $data = new Data($request->all());
        $confeccao = ConfeccaoRacao::find($data->id) ?: ConfeccaoRacao::findByMd5($data->id);

        if (!$confeccao) {
            $this->message->warning("Confecção não encontrada");
            Redirect::referer();
            return;
        }

        $data->nullIfEmpty("observacao");
        ConfeccaoRacao::updateBy($confeccao->id, [
            "observacao" => $data->observacao ?? null,
            "updated_by" => $this->user->uid,
        ]);

        $this->message->success("Observação atualizada com sucesso");
        $this->router->redirect("admin.nutricao.confeccao.racao.index");
    }

    /**
     * Exclui a confeccao e ESTORNA o estoque baixado (devolve a
     * quantidade_consumida de cada ingrediente).
     */
    public function delete(Request $request): void
    {
        $this->authorize("confeccao_racao_excluir");
        $data = new Data($request->all());
        $confeccao = ConfeccaoRacao::find($data->id) ?: ConfeccaoRacao::findByMd5($data->id);

        if (!$confeccao) {
            $this->message->warning("Confecção não encontrada");
            Redirect::referer();
            return;
        }

        $itens = ConfeccaoRacaoItem::where("id_confeccao_racao", "=", $confeccao->id)->get();

        foreach ($itens as $item) {
            $ingrediente = Ingrediente::find((int) $item->id_ingrediente);
            if ($ingrediente) {
                Ingrediente::updateBy($ingrediente->id, [
                    "estoque_atual" => (float) $ingrediente->estoque_atual + (float) $item->quantidade_consumida,
                ]);
            }
        }

        ConfeccaoRacao::deleteById($confeccao->id);
        $this->message->success("Confecção removida e estoque estornado com sucesso");
        Redirect::referer();
    }

    /**
     * Para cada item da formula, calcula quanto foi consumido
     * (percentual * quantidade_real / 100), grava o snapshot em
     * confeccao_racao_item e baixa o estoque do ingrediente.
     */
    private function registrarConsumoEBaixarEstoque(int $idConfeccao, array $itensFormula, float $quantidadeReal): void
    {
        foreach ($itensFormula as $itemFormula) {
            $percentual = (float) $itemFormula->percentual;
            $quantidadeConsumida = round($quantidadeReal * $percentual / 100, 2);

            ConfeccaoRacaoItem::create([
                "id_confeccao_racao" => $idConfeccao,
                "id_ingrediente" => (int) $itemFormula->id_ingrediente,
                "percentual_formula" => $percentual,
                "quantidade_consumida" => $quantidadeConsumida,
            ]);

            $ingrediente = Ingrediente::find((int) $itemFormula->id_ingrediente);
            if ($ingrediente) {
                Ingrediente::updateBy($ingrediente->id, [
                    "estoque_atual" => (float) $ingrediente->estoque_atual - $quantidadeConsumida,
                ]);
            }
        }
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("quantidade_prevista");
        $data->nullIfEmpty("id_operador");
        $data->nullIfEmpty("observacao");

        $payload = $data->all();
        unset($payload["csrf"], $payload["id"]);

        $payload["quantidade_real"] = (float) str_replace(",", ".", (string) ($payload["quantidade_real"] ?? 0));

        return $payload;
    }

    private function formulas(): array
    {
        return FormulaRacao::orderBy("nome")->get();
    }
}
