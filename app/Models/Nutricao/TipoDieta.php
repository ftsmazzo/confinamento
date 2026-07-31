<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class TipoDieta extends Model
{
    public static string $table = "tipo_dieta";
    public static ?string $alias = "td";
    public static array $uppers = ["descricao"];
    public static array $required = ["descricao"];
}
