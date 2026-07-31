<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class AjusteConsumo extends Model
{
    public static string $table = "ajuste_consumo";
    public static ?string $alias = "ac";
    public static array $uppers = ["motivo"];
    public static array $required = ["id_lote", "data_ajuste"];
}
