<?php

namespace App\Models\Manejo;

use App\Core\Model;

class MotivoPerda extends Model
{
    public static string $table = "motivo_perda";
    public static ?string $alias = "mp";
    public static array $uppers = ["descricao"];
    public static array $required = ["descricao"];
}
