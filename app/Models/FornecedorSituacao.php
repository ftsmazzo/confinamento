<?php

namespace App\Models;

use App\Core\Model;

class FornecedorSituacao extends Model
{
    public static string $table = "fornecedor_situacao";
    public static ?string $alias = "fs";
    public static array $uppers = ["descricao", "cor"];
}
