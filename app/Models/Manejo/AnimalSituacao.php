<?php

namespace App\Models\Manejo;

use App\Core\Model;

class AnimalSituacao extends Model
{
    public static string $table = "animal_situacao";
    public static ?string $alias = "asi";
    public static array $uppers = ["descricao", "cor"];
    public static array $required = ["descricao"];
}
