<?php

namespace App\Models\Manejo;

use App\Core\Model;

class MovimentacaoPesagem extends Model
{
    public static string $table = "movimentacao_pesagem";
    public static ?string $alias = "mp";
    public static array $uppers = ["tipo"];
    public static array $required = ["tipo", "data_pesagem", "peso_medio"];

    /**
     * Calcula o GMD (kg/dia) entre duas pesagens consecutivas.
     * Retorna null quando as datas coincidem (intervalo zero) ou faltam pesos.
     */
    public static function calcularGmd(?float $pesoAnterior, ?string $dataAnterior, ?float $pesoAtual, ?string $dataAtual): ?float
    {
        if ($pesoAnterior === null || $pesoAtual === null || !$dataAnterior || !$dataAtual) {
            return null;
        }

        $dias = (strtotime($dataAtual) - strtotime($dataAnterior)) / 86400;

        if ($dias <= 0) {
            return null;
        }

        return round(($pesoAtual - $pesoAnterior) / $dias, 3);
    }
}
