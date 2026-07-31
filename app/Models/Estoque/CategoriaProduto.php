<?php

namespace App\Models\Estoque;

use App\Core\Model;

class CategoriaProduto extends Model
{
    public static string $table = "categoria_produto";
    public static ?string $alias = "cp";
    public static array $required = ["descricao"];
}
