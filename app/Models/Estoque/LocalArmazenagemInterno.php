<?php

namespace App\Models\Estoque;

use App\Core\Model;

class LocalArmazenagemInterno extends Model
{
    public static string $table = "local_armazenagem_interno";
    public static ?string $alias = "lai";
    public static array $uppers = ["nome"];
    public static array $required = ["id_local_estoque", "nome"];
}
