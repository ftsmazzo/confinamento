<?php

namespace App\Models\Estoque;

use App\Core\Model;

class MovimentacaoEstoque extends Model
{
    public static string $table = "movimentacao_estoque";
    public static ?string $alias = "me";
    public static array $required = ["id_produto_estoque", "id_tipo_movimentacao_estoque", "data_movimentacao", "quantidade"];
}
