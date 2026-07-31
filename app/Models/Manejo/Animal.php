<?php

namespace App\Models\Manejo;

use App\Core\Model;

class Animal extends Model
{
    public static string $table = "animal";
    public static ?string $alias = "a";
    public static array $uppers = ["identificacao", "tipo_identificacao", "sexo", "raca", "status"];
    public static array $required = ["identificacao"];
}
