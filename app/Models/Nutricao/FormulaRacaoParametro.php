<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class FormulaRacaoParametro extends Model
{
    public static string $table = "formula_racao_parametro";
    public static ?string $alias = "frp";
    public static array $required = ["id_formula_racao", "id_parametro_nutricional", "valor"];
}
