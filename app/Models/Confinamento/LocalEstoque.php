<?php

namespace App\Models\Confinamento;

use App\Core\Model;

class LocalEstoque extends Model
{
    public static string $table = "local_estoque";
    public static ?string $alias = "cle";
    public static array $uppers = ["nome", "codigo"];
    public static array $required = ["nome", "codigo", "id_unidade"];
}
