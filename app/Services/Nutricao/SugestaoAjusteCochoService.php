<?php

namespace App\Services\Nutricao;

/**
 * E07 — Sugestão de variação % no próximo trato a partir do escore de cocho.
 * Valores conservadores alinhados à prática de bunk score 0–4 e ao seed (+3% em traços).
 * É apenas sugestão: não grava programação nem ajuste automaticamente.
 */
class SugestaoAjusteCochoService
{
    /** @var array<int, float> */
    public const PERCENTUAL_POR_ESCORE = [
        0 => 5.0,
        1 => 3.0,
        2 => 0.0,
        3 => -5.0,
        4 => -10.0,
    ];

    /**
     * @return array{
     *   escore: int,
     *   escore_label: string,
     *   percentual: float,
     *   percentual_label: string,
     *   acao: string,
     *   texto: string
     * }|null
     */
    public function sugerir(?int $escore): ?array
    {
        if ($escore === null || !array_key_exists($escore, self::PERCENTUAL_POR_ESCORE)) {
            return null;
        }

        $pct = self::PERCENTUAL_POR_ESCORE[$escore];
        $acao = $this->acao($pct);
        $pctLabel = $this->formatarPercentual($pct);

        return [
            "escore" => $escore,
            "escore_label" => \App\Models\Nutricao\LeituraCocho::escoreLabel($escore),
            "percentual" => $pct,
            "percentual_label" => $pctLabel,
            "acao" => $acao,
            "texto" => "Escore {$escore} ({$this->escoreCurto($escore)}): sugerido {$pctLabel} no próximo trato ({$acao})",
        ];
    }

    public function percentualSugerido(?int $escore): ?float
    {
        $s = $this->sugerir($escore);
        return $s["percentual"] ?? null;
    }

    /** @return list<array{escore:int,label:string,percentual:float,acao:string}> */
    public function tabelaReferencia(): array
    {
        $rows = [];
        foreach (self::PERCENTUAL_POR_ESCORE as $escore => $pct) {
            $rows[] = [
                "escore" => $escore,
                "label" => \App\Models\Nutricao\LeituraCocho::escoreLabel($escore),
                "percentual" => $pct,
                "acao" => $this->acao($pct),
            ];
        }
        return $rows;
    }

    private function acao(float $pct): string
    {
        if ($pct > 0) {
            return "aumentar oferta";
        }
        if ($pct < 0) {
            return "reduzir oferta";
        }
        return "manter";
    }

    private function formatarPercentual(float $pct): string
    {
        if ($pct > 0) {
            return "+" . rtrim(rtrim(number_format($pct, 1, ",", ""), "0"), ",") . "%";
        }
        if ($pct < 0) {
            return rtrim(rtrim(number_format($pct, 1, ",", ""), "0"), ",") . "%";
        }
        return "0%";
    }

    private function escoreCurto(int $escore): string
    {
        return match ($escore) {
            0 => "limpo",
            1 => "traços",
            2 => "leve sobra",
            3 => "sobra moderada",
            4 => "sobra excessiva",
            default => "—",
        };
    }
}
