<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class GrupoIngrediente extends Model
{
    public static string $table = "grupo_ingrediente";
    public static ?string $alias = "gi";
    public static array $uppers = ["descricao"];
    public static array $required = ["descricao"];
}
