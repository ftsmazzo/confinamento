<?php

namespace App\Services\Nutricao;

use App\Models\Nutricao\FormulaRacaoItem;

/**
 * Custo por kg da fórmula = Σ (percentual/100 × custo_unitario do ingrediente).
 * Ingredientes sem custo entram como 0 (total pode ficar subestimado).
 */
class CustoFormulaService
{
    /**
     * @return array<int, float> id_formula_racao => R$/kg
     */
    public function custoPorKg(): array
    {
        $itens = FormulaRacaoItem::leftJoin("ingrediente as i", "fri.id_ingrediente", "=", "i.id")
            ->select("fri.id_formula_racao", "fri.percentual", "i.custo_unitario")
            ->get();

        $custoPorFormula = [];
        foreach ($itens as $item) {
            $idFormula = (int) $item->id_formula_racao;
            $custoUnitario = (float) ($item->custo_unitario ?? 0);
            $custoPorFormula[$idFormula] = ($custoPorFormula[$idFormula] ?? 0.0)
                + ((float) $item->percentual / 100) * $custoUnitario;
        }

        return $custoPorFormula;
    }
}
