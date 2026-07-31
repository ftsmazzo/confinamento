<?php

namespace App\Models\Manejo;

use App\Core\Model;

class MovimentacaoEntrada extends Model
{
    public static string $table = "movimentacao_entrada";
    public static ?string $alias = "me";
    public static array $uppers = ["documento", "tipo_documento"];
    public static array $required = ["data_entrada"];
}
