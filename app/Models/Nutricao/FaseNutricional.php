<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class FaseNutricional extends Model
{
    public static string $table = "fase_nutricional";
    public static ?string $alias = "fn";
    public static array $uppers = ["descricao"];
    public static array $required = ["descricao"];
}
