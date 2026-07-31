<?php

namespace App\Models\Estoque;

use App\Core\Model;

class LoteEstoque extends Model
{
    public static string $table = "lote_estoque";
    public static ?string $alias = "le";
    public static array $required = ["id_produto_estoque", "codigo_lote"];
}
