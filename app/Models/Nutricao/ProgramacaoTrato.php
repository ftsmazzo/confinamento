<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class ProgramacaoTrato extends Model
{
    public static string $table = "programacao_trato";
    public static ?string $alias = "pt";
    public static array $uppers = ["turno"];
    public static array $required = ["id_lote", "data_programacao"];
}
