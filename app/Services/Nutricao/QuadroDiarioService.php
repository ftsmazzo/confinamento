<?php

namespace App\Services\Nutricao;

use App\Core\DB;
use App\Models\Manejo\Lote;
use App\Models\Nutricao\LeituraCocho;

/**
 * Quadro operacional do dia (E02) + custo alimentar R$/cab/dia (E09).
 *
 * Cruza programacao_trato (previsto por turno) com fornecimento_trato (ocorrido).
 * Match do ocorrido: 1) id_programacao_trato → turno; 2) hora → faixa de turno; 3) só no total.
 */
class QuadroDiarioService
{
    /** @var list<string> */
    public const TURNOS = ["MANHA", "MEIO", "TARDE", "NOITE"];

    private CustoFormulaService $custoService;
    private PrevisaoTratoService $previsaoService;
    private SugestaoAjusteCochoService $sugestaoService;

    public function __construct(
        ?CustoFormulaService $custoService = null,
        ?PrevisaoTratoService $previsaoService = null,
        ?SugestaoAjusteCochoService $sugestaoService = null
    ) {
        $this->custoService = $custoService ?? new CustoFormulaService();
        $this->previsaoService = $previsaoService ?? new PrevisaoTratoService();
        $this->sugestaoService = $sugestaoService ?? new SugestaoAjusteCochoService();
    }

    /**
     * @return array{
     *   data: string,
     *   linhas: list<array<string, mixed>>,
     *   totais: array<string, mixed>,
     *   turnos_label: array<string, string>
     * }
     */
    public function montar(string $data, ?string $linha = null, ?int $idCurral = null): array
    {
        $custoKg = $this->custoService->custoPorKg();
        $programacoes = $this->carregarProgramacoes($data, $linha, $idCurral);
        $fornecimentos = $this->carregarFornecimentos($data, $linha, $idCurral);
        $mapaProgTurno = [];
        foreach ($programacoes as $p) {
            $mapaProgTurno[(int) $p->id] = strtoupper((string) ($p->turno ?? ""));
        }

        /** @var array<int, array<string, mixed>> $porLote */
        $porLote = [];

        foreach ($programacoes as $p) {
            $idLote = (int) $p->id_lote;
            $this->ensureLinha($porLote, $idLote, $p);
            $turno = strtoupper((string) ($p->turno ?? ""));
            if (!in_array($turno, self::TURNOS, true)) {
                continue;
            }
            $porLote[$idLote]["previsto"][$turno] += (float) ($p->quantidade_prevista ?? 0);
            if (!empty($p->id_formula_racao)) {
                $porLote[$idLote]["id_formula_racao"] = (int) $p->id_formula_racao;
                $porLote[$idLote]["formula_nome"] = $p->formula_nome ?? $porLote[$idLote]["formula_nome"];
            }
        }

        foreach ($fornecimentos as $f) {
            $idLote = (int) $f->id_lote;
            $this->ensureLinha($porLote, $idLote, $f);
            $qtd = (float) $f->quantidade_fornecida;
            $turno = $this->resolverTurnoOcorrido($f, $mapaProgTurno);
            if ($turno !== null) {
                $porLote[$idLote]["ocorrido"][$turno] += $qtd;
            } else {
                $porLote[$idLote]["ocorrido_sem_turno"] += $qtd;
            }

            $idFormula = !empty($f->id_formula_racao) ? (int) $f->id_formula_racao : (int) ($porLote[$idLote]["id_formula_racao"] ?? 0);
            if ($idFormula > 0) {
                $porLote[$idLote]["custo_total"] += $qtd * ($custoKg[$idFormula] ?? 0.0);
                if (empty($porLote[$idLote]["formula_nome"]) && !empty($f->formula_nome)) {
                    $porLote[$idLote]["formula_nome"] = $f->formula_nome;
                    $porLote[$idLote]["id_formula_racao"] = $idFormula;
                }
            }
        }

        $this->enriquecerLotes($porLote, $data);

        $linhas = array_values($porLote);
        usort($linhas, static function (array $a, array $b): int {
            $cmp = strcmp((string) ($a["linha"] ?? ""), (string) ($b["linha"] ?? ""));
            if ($cmp !== 0) {
                return $cmp;
            }
            return strcmp((string) ($a["curral_nome"] ?? ""), (string) ($b["curral_nome"] ?? ""));
        });

        return [
            "data" => $data,
            "linhas" => $linhas,
            "totais" => $this->totais($linhas),
            "turnos_label" => PrevisaoTratoService::TURNOS_LABEL,
        ];
    }

    /**
     * @param array<int, array<string, mixed>> $porLote
     */
    private function ensureLinha(array &$porLote, int $idLote, object $row): void
    {
        if (isset($porLote[$idLote])) {
            if (empty($porLote[$idLote]["curral_nome"]) && !empty($row->curral_nome)) {
                $porLote[$idLote]["curral_nome"] = $row->curral_nome;
            }
            if (empty($porLote[$idLote]["linha"]) && !empty($row->curral_linha)) {
                $porLote[$idLote]["linha"] = $row->curral_linha;
            }
            if (empty($porLote[$idLote]["id_curral"]) && !empty($row->id_curral)) {
                $porLote[$idLote]["id_curral"] = (int) $row->id_curral;
            }
            return;
        }

        $previsto = [];
        $ocorrido = [];
        foreach (self::TURNOS as $t) {
            $previsto[$t] = 0.0;
            $ocorrido[$t] = 0.0;
        }

        $porLote[$idLote] = [
            "id_lote" => $idLote,
            "lote_nome" => $row->lote_nome ?? "",
            "lote_codigo" => $row->lote_codigo ?? "",
            "giro" => $row->lote_giro ?? null,
            "id_curral" => !empty($row->id_curral) ? (int) $row->id_curral : null,
            "curral_nome" => $row->curral_nome ?? "",
            "linha" => $row->curral_linha ?? "",
            "id_formula_racao" => !empty($row->id_formula_racao) ? (int) $row->id_formula_racao : null,
            "formula_nome" => $row->formula_nome ?? "",
            "cabecas" => null,
            "dias" => null,
            "alerta" => null,
            "previsto" => $previsto,
            "ocorrido" => $ocorrido,
            "ocorrido_sem_turno" => 0.0,
            "custo_total" => 0.0,
            "custo_cab" => null,
            "total_previsto" => 0.0,
            "total_ocorrido" => 0.0,
            "delta" => 0.0,
            "aderencia" => null,
            "cocho_escore" => null,
            "cocho_escore_label" => null,
            "cocho_sugestao_pct" => null,
            "cocho_sugestao_label" => null,
            "cocho_sugestao_texto" => null,
            "id_leitura_cocho" => null,
        ];
    }

    /**
     * @param array<int, array<string, mixed>> $porLote
     */
    private function enriquecerLotes(array &$porLote, string $data): void
    {
        if (empty($porLote)) {
            return;
        }

        $ids = array_keys($porLote);
        $lotes = Lote::leftJoin("lote_entrada as le", "l.id", "=", "le.id_lote")
            ->leftJoin("curral as c", "l.id_curral", "=", "c.id")
            ->select(
                "l.id",
                "l.nome",
                "l.codigo",
                "l.giro",
                "l.id_curral",
                "c.nome as curral_nome",
                "c.linha as curral_linha",
                "le.quantidade",
                "le.data_entrada"
            )
            ->whereIn("l.id", $ids)
            ->get();

        foreach ($lotes as $lote) {
            $id = (int) $lote->id;
            if (!isset($porLote[$id])) {
                continue;
            }

            $porLote[$id]["lote_nome"] = $lote->nome ?? $porLote[$id]["lote_nome"];
            $porLote[$id]["lote_codigo"] = $lote->codigo ?? $porLote[$id]["lote_codigo"];
            $porLote[$id]["giro"] = $lote->giro ?? $porLote[$id]["giro"];
            $porLote[$id]["cabecas"] = $lote->quantidade !== null ? (int) $lote->quantidade : null;

            if (empty($porLote[$id]["curral_nome"]) && !empty($lote->curral_nome)) {
                $porLote[$id]["curral_nome"] = $lote->curral_nome;
            }
            if (empty($porLote[$id]["linha"]) && !empty($lote->curral_linha)) {
                $porLote[$id]["linha"] = $lote->curral_linha;
            }
            if (empty($porLote[$id]["id_curral"]) && !empty($lote->id_curral)) {
                $porLote[$id]["id_curral"] = (int) $lote->id_curral;
            }

            $dias = $this->previsaoService->diasConfinamento(
                !empty($lote->data_entrada) ? (string) $lote->data_entrada : null,
                $data
            );
            $porLote[$id]["dias"] = $dias;
            $porLote[$id]["alerta"] = $this->previsaoService->nivelAlerta($dias);

            $totalP = array_sum($porLote[$id]["previsto"]);
            $totalO = array_sum($porLote[$id]["ocorrido"]) + (float) $porLote[$id]["ocorrido_sem_turno"];
            $porLote[$id]["total_previsto"] = round($totalP, 2);
            $porLote[$id]["total_ocorrido"] = round($totalO, 2);
            $porLote[$id]["delta"] = round($totalO - $totalP, 2);
            $porLote[$id]["aderencia"] = $totalP > 0 ? round(($totalO / $totalP) * 100, 1) : null;

            $cab = $porLote[$id]["cabecas"];
            if ($cab && $cab > 0 && $porLote[$id]["custo_total"] > 0) {
                $porLote[$id]["custo_cab"] = round($porLote[$id]["custo_total"] / $cab, 2);
            } else {
                $porLote[$id]["custo_cab"] = null;
            }

            $porLote[$id]["custo_total"] = round((float) $porLote[$id]["custo_total"], 2);
        }

        $this->aplicarSugestoesCocho($porLote, $data);
    }

    /**
     * Última leitura com nota (escore) até a data do quadro → sugestão %.
     *
     * @param array<int, array<string, mixed>> $porLote
     */
    private function aplicarSugestoesCocho(array &$porLote, string $data): void
    {
        $ids = array_keys($porLote);
        if ($ids === []) {
            return;
        }

        $leituras = LeituraCocho::whereIn("id_lote", $ids)
            ->whereNotNull("escore")
            ->where("data_leitura", "<=", $data)
            ->orderBy("data_leitura", "desc")
            ->orderBy("id", "desc")
            ->get();

        $porLoteLeitura = [];
        foreach ($leituras as $leitura) {
            $idLote = (int) $leitura->id_lote;
            if (!isset($porLoteLeitura[$idLote])) {
                $porLoteLeitura[$idLote] = $leitura;
            }
        }

        foreach ($porLoteLeitura as $idLote => $leitura) {
            if (!isset($porLote[$idLote])) {
                continue;
            }
            $escore = (int) $leitura->escore;
            $sugestao = $this->sugestaoService->sugerir($escore);
            if ($sugestao === null) {
                continue;
            }

            $porLote[$idLote]["cocho_escore"] = $escore;
            $porLote[$idLote]["cocho_escore_label"] = $sugestao["escore_label"];
            $porLote[$idLote]["cocho_sugestao_pct"] = $sugestao["percentual"];
            $porLote[$idLote]["cocho_sugestao_label"] = $sugestao["percentual_label"];
            $porLote[$idLote]["cocho_sugestao_texto"] = $sugestao["texto"];
            $porLote[$idLote]["id_leitura_cocho"] = (int) $leitura->id;
        }
    }

    /**
     * @param list<array<string, mixed>> $linhas
     * @return array<string, mixed>
     */
    private function totais(array $linhas): array
    {
        $previsto = 0.0;
        $ocorrido = 0.0;
        $custo = 0.0;
        $cabecasComCusto = 0;
        $custoCabSoma = 0.0;
        $nCustoCab = 0;

        foreach ($linhas as $l) {
            $previsto += (float) $l["total_previsto"];
            $ocorrido += (float) $l["total_ocorrido"];
            $custo += (float) $l["custo_total"];
            if ($l["custo_cab"] !== null) {
                $custoCabSoma += (float) $l["custo_cab"];
                $nCustoCab++;
            }
            if (!empty($l["cabecas"])) {
                $cabecasComCusto += (int) $l["cabecas"];
            }
        }

        return [
            "previsto" => round($previsto, 2),
            "ocorrido" => round($ocorrido, 2),
            "delta" => round($ocorrido - $previsto, 2),
            "aderencia" => $previsto > 0 ? round(($ocorrido / $previsto) * 100, 1) : null,
            "custo_total" => round($custo, 2),
            "custo_cab_medio" => $nCustoCab > 0 ? round($custoCabSoma / $nCustoCab, 2) : null,
            "lotes" => count($linhas),
            "cabecas" => $cabecasComCusto,
        ];
    }

    private function resolverTurnoOcorrido(object $f, array $mapaProgTurno): ?string
    {
        if (!empty($f->id_programacao_trato)) {
            $turno = $mapaProgTurno[(int) $f->id_programacao_trato] ?? null;
            if ($turno && in_array($turno, self::TURNOS, true)) {
                return $turno;
            }
        }

        if (!empty($f->hora_fornecimento)) {
            return $this->turnoPorHora((string) $f->hora_fornecimento);
        }

        return null;
    }

    private function turnoPorHora(string $hora): string
    {
        $parts = explode(":", $hora);
        $h = (int) ($parts[0] ?? 0);

        if ($h < 10) {
            return "MANHA";
        }
        if ($h < 14) {
            return "MEIO";
        }
        if ($h < 18) {
            return "TARDE";
        }

        return "NOITE";
    }

    /**
     * @return list<object>
     */
    private function carregarProgramacoes(string $data, ?string $linha, ?int $idCurral): array
    {
        $query = DB::table("programacao_trato", "pt")
            ->leftJoin("lote as l", "pt.id_lote", "=", "l.id")
            ->leftJoin("curral as c", "pt.id_curral", "=", "c.id")
            ->leftJoin("formula_racao as fr", "pt.id_formula_racao", "=", "fr.id")
            ->select(
                "pt.id",
                "pt.id_lote",
                "pt.id_curral",
                "pt.id_formula_racao",
                "pt.turno",
                "pt.quantidade_prevista",
                "l.nome as lote_nome",
                "l.codigo as lote_codigo",
                "l.giro as lote_giro",
                "c.nome as curral_nome",
                "c.linha as curral_linha",
                "fr.nome as formula_nome"
            )
            ->where("pt.data_programacao", "=", $data);

        if ($linha !== null && $linha !== "") {
            $query = $query->where("c.linha", "=", $linha);
        }
        if ($idCurral) {
            $query = $query->where("pt.id_curral", "=", $idCurral);
        }

        return $query->get();
    }

    /**
     * @return list<object>
     */
    private function carregarFornecimentos(string $data, ?string $linha, ?int $idCurral): array
    {
        $query = DB::table("fornecimento_trato", "ft")
            ->leftJoin("lote as l", "ft.id_lote", "=", "l.id")
            ->leftJoin("curral as c", "ft.id_curral", "=", "c.id")
            ->leftJoin("formula_racao as fr", "ft.id_formula_racao", "=", "fr.id")
            ->select(
                "ft.id",
                "ft.id_programacao_trato",
                "ft.id_lote",
                "ft.id_curral",
                "ft.id_formula_racao",
                "ft.hora_fornecimento",
                "ft.quantidade_fornecida",
                "l.nome as lote_nome",
                "l.codigo as lote_codigo",
                "l.giro as lote_giro",
                "c.nome as curral_nome",
                "c.linha as curral_linha",
                "fr.nome as formula_nome"
            )
            ->where("ft.data_fornecimento", "=", $data);

        if ($linha !== null && $linha !== "") {
            $query = $query->where("c.linha", "=", $linha);
        }
        if ($idCurral) {
            $query = $query->where("ft.id_curral", "=", $idCurral);
        }

        return $query->get();
    }
}
