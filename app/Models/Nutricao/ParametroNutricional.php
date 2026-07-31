<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class ParametroNutricional extends Model
{
    public static string $table = "parametro_nutricional";
    public static ?string $alias = "pn";
    public static array $uppers = ["nome", "unidade_medida"];
    public static array $required = ["nome"];
}
