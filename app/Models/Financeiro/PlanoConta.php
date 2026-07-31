<?php

namespace App\Models\Financeiro;

use App\Core\Model;

class PlanoConta extends Model
{
    public static string $table = "plano_conta";
    public static ?string $alias = "pc";
    public static array $uppers = ["nome", "codigo"];
    public static array $required = ["codigo", "nome", "tipo"];

    public static function tipoLabel(string $tipo): string
    {
        return match ($tipo) {
            "RECEITA" => "Receita",
            "DESPESA" => "Despesa",
            default => $tipo,
        };
    }
}
