<?php

namespace App\Models\Manejo;

use App\Core\Model;

class TipoEntrada extends Model
{
    public static string $table = "tipo_entrada";
    public static ?string $alias = "te";
    public static array $uppers = ["descricao"];
    public static array $required = ["descricao"];
}
