<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class LeituraCocho extends Model
{
    public static string $table = "leitura_cocho";
    public static ?string $alias = "lc";
    public static array $required = ["id_lote", "data_leitura", "escore"];

    /**
     * Rotulo textual do escore de leitura de cocho (padrao 0-4 da industria).
     */
    public static function escoreLabel(int $escore): string
    {
        return match ($escore) {
            0 => "Limpo",
            1 => "Traços",
            2 => "Leve sobra",
            3 => "Sobra moderada",
            4 => "Sobra excessiva",
            default => "Desconhecido",
        };
    }
}
