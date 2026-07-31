<?php

namespace App\Models\Manejo;

use App\Core\Model;

class Lote extends Model
{
    public static string $table = "lote";
    public static ?string $alias = "l";
    public static array $uppers = ["nome", "codigo", "giro"];
    public static array $required = ["nome", "codigo", "id_unidade"];
}
