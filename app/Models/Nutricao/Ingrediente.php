<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class Ingrediente extends Model
{
    public static string $table = "ingrediente";
    public static ?string $alias = "i";
    public static array $uppers = ["nome", "unidade_medida"];
    public static array $required = ["nome"];
}
