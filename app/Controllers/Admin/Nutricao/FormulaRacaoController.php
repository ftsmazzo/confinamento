<?php

namespace App\Controllers\Admin\Nutricao;

use App\Core\ControllerAdmin;
use App\Core\Data;
use App\Core\Redirect;
use App\Core\Request;
use App\Models\Nutricao\FaseNutricional;
use App\Models\Nutricao\FormulaRacao;
use App\Models\Nutricao\FormulaRacaoItem;
use App\Models\Nutricao\FormulaRacaoParametro;
use App\Models\Nutricao\Ingrediente;
use App\Models\Nutricao\ParametroNutricional;
use App\Models\Nutricao\TipoDieta;

class FormulaRacaoController extends ControllerAdmin
{
    public function __construct()
    {
        parent::__construct();

        $this->view->addData([
            "title" => "Fórmulas de Ração",
            "active_menu" => "nutricao-formulas-racao",
            "page" => [
                "title" => "Fórmulas de Ração",
                "desc" => "Cadastre as composições de dieta usadas nos lotes",
            ],
            "uppers" => implode(",", FormulaRacao::getUppers()),
            "required" => implode(",", FormulaRacao::getRequired()),
        ]);
    }

    public function index(): void
    {
        $this->authorize("formula_racao_gerenciar");

        $this->view->addData([
            "breadcrumb" => [
                "Dashboard" => ["url" => $this->router->route("admin.home"), "current" => false],
                "Nutrição" => ["url" => false, "current" => false],
                "Fórmulas de Ração" => ["url" => false, "current" => true],
            ],
        ]);

        $dados = FormulaRacao::leftJoin("tipo_dieta as td", "fr.id_tipo_dieta", "=", "td.id")
            ->leftJoin("fase_nutricional as fn", "fr.id_fase_nutricional", "=", "fn.id")
            ->select("fr.*", "td.descricao as tipo_dieta_descricao", "fn.descricao as fase_descricao")
            ->orderBy("fr.nome")
            ->get();

        $msPorFormula = $this->mapaMateriaSeca();

        foreach ($dados as $item) {
            $item->hash = md5((string) $item->id);
            $item->total_percentual = (float) (FormulaRacaoItem::where("id_formula_racao", "=", $item->id)->select("SUM(percentual) as total")->first()->total ?? 0);
            $item->materia_seca = $msPorFormula[(int) $item->id] ?? null;
        }

        echo $this->view->render("admin/nutricao/formula-racao/index", [
            "dados" => $dados,
            "permissao" => [
                "inserir" => $this->auth->allow("formula_racao_inserir"),
                "editar" => $this->auth->allow("formula_racao_editar"),
                "excluir" => $this->auth->allow("formula_racao_excluir"),
            ],
        ]);
    }

    public function new(): void
    {
        $this->authorize("formula_racao_inserir");
        echo $this->view->render("admin/nutricao/formula-racao/form", [
            "csrf" => $this->csrf->generate(),
            "formula" => false,
            "itens" => [],
            "parametros" => $this->parametrosCatalogo(),
            "valoresParametros" => [],
            "tiposDieta" => $this->tiposDieta(),
            "fases" => $this->fases(),
            "ingredientes" => $this->ingredientes(),
            "url_action" => $this->router->route("admin.nutricao.formula.racao.insert"),
        ]);
    }

    public function create(Request $request): void
    {
        $this->authorize("formula_racao_inserir");
        $data = new Data($request->all());

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome da fórmula");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["created_by"] = $this->user->uid;

        $formula = FormulaRacao::create($payload);
        $this->salvarItens((int) $formula->id, $request);
        $this->salvarParametros((int) $formula->id, $request);

        $this->message->success("Fórmula cadastrada com sucesso");
        $this->router->redirect("admin.nutricao.formula.racao.index");
    }

    public function edit(Request $request): void
    {
        $this->authorize("formula_racao_editar");
        $data = new Data($request->all());
        $formula = FormulaRacao::find($data->id) ?: FormulaRacao::findByMd5($data->id);

        if (!$formula) {
            $this->message->warning("Fórmula não encontrada");
            $this->router->redirect("admin.nutricao.formula.racao.index");
            return;
        }

        $itens = FormulaRacaoItem::leftJoin("ingrediente as i", "fri.id_ingrediente", "=", "i.id")
            ->select("fri.*", "i.nome as ingrediente_nome")
            ->where("fri.id_formula_racao", "=", $formula->id)
            ->orderBy("i.nome")
            ->get();

        echo $this->view->render("admin/nutricao/formula-racao/form", [
            "csrf" => $this->csrf->generate(),
            "formula" => $formula,
            "itens" => $itens,
            "parametros" => $this->parametrosCatalogo(),
            "valoresParametros" => $this->valoresParametros((int) $formula->id),
            "tiposDieta" => $this->tiposDieta(),
            "fases" => $this->fases(),
            "ingredientes" => $this->ingredientes(),
            "url_action" => $this->router->route("admin.nutricao.formula.racao.update"),
        ]);
    }

    public function update(Request $request): void
    {
        $this->authorize("formula_racao_editar");
        $data = new Data($request->all());
        $formula = FormulaRacao::find($data->id) ?: FormulaRacao::findByMd5($data->id);

        if (!$formula) {
            $this->message->warning("Fórmula não encontrada");
            Redirect::referer();
            return;
        }

        if (!$data->has("nome")) {
            $this->message->warning("Informe o nome da fórmula");
            Redirect::referer();
            return;
        }

        $payload = $this->normalizarPayload($data);
        $payload["updated_by"] = $this->user->uid;

        FormulaRacao::updateBy($formula->id, $payload);
        $this->salvarItens((int) $formula->id, $request);
        $this->salvarParametros((int) $formula->id, $request);

        $this->message->success("Fórmula atualizada com sucesso");
        $this->router->redirect("admin.nutricao.formula.racao.index");
    }

    public function delete(Request $request): void
    {
        $this->authorize("formula_racao_excluir");
        $data = new Data($request->all());
        $formula = FormulaRacao::find($data->id) ?: FormulaRacao::findByMd5($data->id);

        if (!$formula) {
            $this->message->warning("Fórmula não encontrada");
            Redirect::referer();
            return;
        }

        FormulaRacao::deleteById($formula->id);
        $this->message->success("Fórmula removida com sucesso");
        Redirect::referer();
    }

    /**
     * Substitui a composicao inteira da formula pelos itens enviados no
     * formulario (arrays paralelos ingrediente[]/percentual[]). Ignora
     * linhas sem ingrediente selecionado.
     */
    private function salvarItens(int $idFormula, Request $request): void
    {
        $post = $request->all();
        $ingredientes = $post["item_ingrediente"] ?? [];
        $percentuais = $post["item_percentual"] ?? [];

        FormulaRacaoItem::where("id_formula_racao", "=", $idFormula)->delete();

        foreach ($ingredientes as $index => $idIngrediente) {
            $idIngrediente = (int) $idIngrediente;
            $percentual = isset($percentuais[$index]) ? (float) str_replace(",", ".", (string) $percentuais[$index]) : 0;

            if ($idIngrediente <= 0 || $percentual <= 0) {
                continue;
            }

            FormulaRacaoItem::create([
                "id_formula_racao" => $idFormula,
                "id_ingrediente" => $idIngrediente,
                "percentual" => $percentual,
                "created_by" => $this->user->uid,
            ]);
        }
    }

    /**
     * Substitui os parametros nutricionais da formula (ex.: % MS).
     * Campos vazios sao removidos; valores numericos sao gravados.
     */
    private function salvarParametros(int $idFormula, Request $request): void
    {
        $post = $request->all();
        $valores = $post["parametro_valor"] ?? [];

        FormulaRacaoParametro::where("id_formula_racao", "=", $idFormula)->delete();

        if (!is_array($valores)) {
            return;
        }

        foreach ($valores as $idParametro => $valorBruto) {
            $idParametro = (int) $idParametro;
            $valorBruto = trim((string) $valorBruto);

            if ($idParametro <= 0 || $valorBruto === "") {
                continue;
            }

            $valor = (float) str_replace(",", ".", $valorBruto);

            FormulaRacaoParametro::create([
                "id_formula_racao" => $idFormula,
                "id_parametro_nutricional" => $idParametro,
                "valor" => $valor,
                "created_by" => $this->user->uid,
            ]);
        }
    }

    private function normalizarPayload(Data $data): array
    {
        $data->nullIfEmpty("id_tipo_dieta");
        $data->nullIfEmpty("id_fase_nutricional");
        $data->nullIfEmpty("descricao");

        $payload = $data->all();
        unset(
            $payload["csrf"],
            $payload["id"],
            $payload["item_ingrediente"],
            $payload["item_percentual"],
            $payload["parametro_valor"]
        );

        $payload["ativo"] = isset($payload["ativo"]) ? (int) $payload["ativo"] : 1;

        return $payload;
    }

    private function tiposDieta(): array
    {
        return TipoDieta::orderBy("descricao")->get();
    }

    private function fases(): array
    {
        return FaseNutricional::orderBy("ordem")->get();
    }

    private function ingredientes(): array
    {
        return Ingrediente::orderBy("nome")->get();
    }

    private function parametrosCatalogo(): array
    {
        return ParametroNutricional::orderBy("nome")->get();
    }

    /**
     * @return array<int, float> id_parametro_nutricional => valor
     */
    private function valoresParametros(int $idFormula): array
    {
        $mapa = [];

        foreach (FormulaRacaoParametro::where("id_formula_racao", "=", $idFormula)->get() as $row) {
            $mapa[(int) $row->id_parametro_nutricional] = (float) $row->valor;
        }

        return $mapa;
    }

    /**
     * @return array<int, float> id_formula_racao => valor % MS
     */
    private function mapaMateriaSeca(): array
    {
        $paramMs = ParametroNutricional::where("nome", "=", "MATÉRIA SECA")->first();

        if (!$paramMs) {
            return [];
        }

        $mapa = [];

        foreach (FormulaRacaoParametro::where("id_parametro_nutricional", "=", $paramMs->id)->get() as $row) {
            $mapa[(int) $row->id_formula_racao] = (float) $row->valor;
        }

        return $mapa;
    }
}
