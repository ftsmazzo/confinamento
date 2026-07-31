<?php

namespace App\Models\Confinamento;

use App\Core\Model;

class Curral extends Model
{
    public static string $table = "curral";
    public static ?string $alias = "cc";
    public static array $uppers = ["nome", "codigo", "linha"];
    public static array $required = ["nome", "codigo", "id_unidade"];
}
