<?php

namespace App\Models\Estoque;

use App\Core\Model;

class TipoMovimentacaoEstoque extends Model
{
    public static string $table = "tipo_movimentacao_estoque";
    public static ?string $alias = "tme";
    public static array $required = ["descricao", "natureza"];
}
