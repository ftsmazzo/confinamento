<?php

namespace App\Models\Nutricao;

use App\Core\Model;
use App\Services\Nutricao\PrevisaoTratoService;

class LeituraCocho extends Model
{
    public static string $table = "leitura_cocho";
    public static ?string $alias = "lc";
    public static array $uppers = ["turno"];
    public static array $required = ["id_lote", "data_leitura"];

    public const MEDIA_PATH = "storage/media/leituras-cocho/";
    public const MEDIA_URL_PATH = "leituras-cocho";

    /** @return array<string, string> */
    public static function turnosLabel(): array
    {
        return PrevisaoTratoService::TURNOS_LABEL;
    }

    public static function turnoLabel(?string $turno): string
    {
        if ($turno === null || $turno === "") {
            return "-";
        }

        return self::turnosLabel()[$turno] ?? $turno;
    }

    /**
     * Rotulo textual do escore de leitura de cocho (padrao 0-4 da industria).
     */
    public static function escoreLabel(?int $escore): string
    {
        if ($escore === null) {
            return "Sem nota";
        }

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
