<?php

namespace App\Models\Sanitario;

use App\Core\Model;

class TipoAplicacao extends Model
{
    public static string $table = "tipo_aplicacao";
    public static ?string $alias = "ta";
    public static array $uppers = ["descricao"];
    public static array $required = ["descricao"];
}
