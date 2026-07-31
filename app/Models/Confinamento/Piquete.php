<?php

namespace App\Models\Confinamento;

use App\Core\Model;

class Piquete extends Model
{
    public static string $table = "piquete";
    public static ?string $alias = "cp";
    public static array $uppers = ["nome", "codigo"];
    public static array $required = ["nome", "codigo", "id_unidade"];
}
