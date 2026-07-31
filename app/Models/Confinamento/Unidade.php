<?php

namespace App\Models\Confinamento;

use App\Core\Model;

class Unidade extends Model
{
    public static string $table = "unidade";
    public static ?string $alias = "cu";
    public static array $uppers = ["nome", "codigo"];
    public static array $required = ["nome", "codigo"];
}
