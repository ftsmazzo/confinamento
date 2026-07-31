<?php

namespace App\Models\Manejo;

use App\Core\Model;

class MovimentacaoDieta extends Model
{
    public static string $table = "movimentacao_dieta";
    public static ?string $alias = "md";
    public static array $required = ["id_dieta", "data_troca"];
}
