<?php

namespace App\Models\Pessoas;

use App\Core\Model;

class Funcionario extends Model
{
    public static string $table = "funcionario";
    public static ?string $alias = "func";
    public static array $uppers = ["nome", "cargo", "setor"];
    public static array $required = ["nome"];
}
