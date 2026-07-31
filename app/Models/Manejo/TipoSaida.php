<?php

namespace App\Models\Manejo;

use App\Core\Model;

class TipoSaida extends Model
{
    public static string $table = "tipo_saida";
    public static ?string $alias = "ts";
    public static array $uppers = ["descricao"];
    public static array $required = ["descricao"];
}
