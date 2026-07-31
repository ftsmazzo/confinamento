<?php

namespace App\Models\Sanitario;

use App\Core\Model;

class AplicacaoSanitaria extends Model
{
    public static string $table = "aplicacao_sanitaria";
    public static ?string $alias = "aps";
    public static array $required = ["tipo", "data_aplicacao"];

    public static function tipoLabel(string $tipo): string
    {
        return match ($tipo) {
            "PROTOCOLO" => "Protocolo",
            "TRATAMENTO_INDIVIDUAL" => "Tratamento Individual",
            "TRATAMENTO_LOTE" => "Tratamento em Lote",
            default => "Desconhecido",
        };
    }
}
