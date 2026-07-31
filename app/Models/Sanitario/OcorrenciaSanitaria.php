<?php

namespace App\Models\Sanitario;

use App\Core\Model;

class OcorrenciaSanitaria extends Model
{
    public static string $table = "ocorrencia_sanitaria";
    public static ?string $alias = "os";
    public static array $required = ["data_ocorrencia", "descricao", "gravidade"];
}
