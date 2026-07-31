<?php

namespace App\Models\Sanitario;

use App\Core\Model;

class ProtocoloSanitario extends Model
{
    public static string $table = "protocolo_sanitario";
    public static ?string $alias = "ps";
    public static array $required = ["nome"];
}
