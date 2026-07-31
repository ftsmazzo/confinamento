<?php

namespace App\Models;

use App\Core\Model;

class FornecedorRamo extends Model
{
    public static string $table = "fornecedor_ramo";
    public static ?string $alias = "fr";
    public static array $uppers = ["descricao"];
}
