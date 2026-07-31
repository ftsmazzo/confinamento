<?php

namespace App\Models\Manejo;

use App\Core\Model;

class Dieta extends Model
{
    public static string $table = "dieta";
    public static ?string $alias = "d";
    public static array $uppers = ["nome", "fase"];
    public static array $required = ["nome"];
}
