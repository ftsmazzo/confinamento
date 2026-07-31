<?php

namespace App\Models\Manejo;

use App\Core\Model;

class Lembrete extends Model
{
    public static string $table = "lembrete";
    public static ?string $alias = "lb";
    public static array $required = ["data_lembrete", "titulo"];
}
