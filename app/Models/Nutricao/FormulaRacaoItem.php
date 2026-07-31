<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class FormulaRacaoItem extends Model
{
    public static string $table = "formula_racao_item";
    public static ?string $alias = "fri";
    public static array $required = ["id_formula_racao", "id_ingrediente", "percentual"];
}
