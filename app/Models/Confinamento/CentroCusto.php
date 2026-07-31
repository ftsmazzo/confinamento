<?php

namespace App\Models\Confinamento;

use App\Core\Model;

class CentroCusto extends Model
{
    public static string $table = "centro_custo";
    public static ?string $alias = "cc";
    public static array $uppers = ["nome", "codigo"];
    public static array $required = ["nome", "codigo"];
}
