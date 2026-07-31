<?php

namespace App\Models\Manejo;

use App\Core\Model;

class MovimentacaoSaida extends Model
{
    public static string $table = "movimentacao_saida";
    public static ?string $alias = "ms";
    public static array $required = ["data_saida"];
}
