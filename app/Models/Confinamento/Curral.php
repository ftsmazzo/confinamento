<?php

namespace App\Models\Confinamento;

use App\Core\Model;
use App\Models\Manejo\Lote;

class Curral extends Model
{
    public static string $table = "curral";
    public static ?string $alias = "cc";
    public static array $uppers = ["nome", "codigo", "linha"];
    public static array $required = ["nome", "codigo", "id_unidade"];

    /**
     * Currais com id_lote_ativo quando há exatamente um lote ATIVO no curral
     * (E11: curral puxa lote nas telas operacionais).
     *
     * @return list<object>
     */
    public static function comLoteAtivo(): array
    {
        $currais = self::orderBy("nome")->get();
        $lotes = Lote::where("ativo", "=", 1)
            ->where("status", "=", "ATIVO")
            ->whereNotNull("id_curral")
            ->orderBy("nome")
            ->get();

        $porCurral = [];
        foreach ($lotes as $lote) {
            $cid = (int) $lote->id_curral;
            if ($cid <= 0) {
                continue;
            }
            $porCurral[$cid] ??= [];
            $porCurral[$cid][] = (int) $lote->id;
        }

        foreach ($currais as $curral) {
            $ids = $porCurral[(int) $curral->id] ?? [];
            $curral->id_lote_ativo = count($ids) === 1 ? $ids[0] : null;
        }

        return $currais;
    }
}
