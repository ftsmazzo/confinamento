<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class FormulaRacao extends Model
{
    public static string $table = "formula_racao";
    public static ?string $alias = "fr";
    public static array $uppers = ["nome"];
    public static array $required = ["nome"];
}
