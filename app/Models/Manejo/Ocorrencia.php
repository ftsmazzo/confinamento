<?php

namespace App\Models\Manejo;

use App\Core\Model;

class Ocorrencia extends Model
{
    public static string $table = "ocorrencia";
    public static ?string $alias = "o";
    public static array $required = ["data_ocorrencia", "titulo"];
}
