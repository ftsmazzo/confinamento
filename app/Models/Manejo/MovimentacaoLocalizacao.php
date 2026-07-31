<?php

namespace App\Models\Manejo;

use App\Core\Model;

class MovimentacaoLocalizacao extends Model
{
    public static string $table = "movimentacao_localizacao";
    public static ?string $alias = "ml";
    public static array $required = ["data_movimentacao"];
}
