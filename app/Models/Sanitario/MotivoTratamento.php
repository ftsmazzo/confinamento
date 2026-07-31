<?php

namespace App\Models\Sanitario;

use App\Core\Model;

class MotivoTratamento extends Model
{
    public static string $table = "motivo_tratamento";
    public static ?string $alias = "mt";
    public static array $uppers = ["descricao"];
    public static array $required = ["descricao"];
}
