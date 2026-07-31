<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class ConfeccaoRacao extends Model
{
    public static string $table = "confeccao_racao";
    public static ?string $alias = "cr";
    public static array $required = ["id_formula_racao", "data_confeccao", "quantidade_real"];
}
