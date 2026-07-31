<?php

namespace App\Services\Nutricao;

use App\Models\Configuracao;
use App\Models\Manejo\Lote;
use App\Models\Manejo\MovimentacaoDieta;
use App\Models\Nutricao\FormulaRacaoParametro;
use App\Models\Nutricao\ParametroNutricional;
use App\Models\Nutricao\ProgramacaoTrato;

/**
 * Motor de previsão de trato (planilha Bichara / E01).
 *
 * permanência     = dia_ref − data_entrada
 * peso_projetado  = peso_entrada + (GMD × permanência)
 * consumo_MS_cab  = peso_projetado × (%PV / 100)
 * fornecimento_MN = consumo_MS_cab ÷ (%MS_dieta / 100)
 * trato_n         = fornecimento_MN × (%turno / 100) × cabeças
 */
class PrevisaoTratoService
{
    public const TURNO_MANHA = "MANHA";
    public const TURNO_MEIO = "MEIO";
    public const TURNO_TARDE = "TARDE";
    public const TURNO_NOITE = "NOITE";

    /** @var array<string, string> */
    public const TURNOS_LABEL = [
        self::TURNO_MANHA => "Manhã (1º)",
        self::TURNO_MEIO => "Intermediário (2º)",
        self::TURNO_TARDE => "Tarde (3º)",
        self::TURNO_NOITE => "Noite (4º)",
    ];

    public const DEFAULTS = [
        "trato_gmd" => "1.5",
        "trato_pct_peso_vivo" => "2.25",
        "trato_turno_1_pct" => "30",
        "trato_turno_2_pct" => "20",
        "trato_turno_3_pct" => "20",
        "trato_turno_4_pct" => "30",
        "trato_alerta_dias" => "100",
        "trato_alerta_risco_dias" => "110",
    ];

    /**
     * @return array{
     *   gmd: float,
     *   pct_peso_vivo: float,
     *   turnos: array<string, float>,
     *   alerta_dias: int,
     *   alerta_risco_dias: int
     * }
     */
    public function parametros(): array
    {
        $cfg = Configuracao::allIndexed();

        $turnoPcts = [
            self::TURNO_MANHA => (float) ($cfg["trato_turno_1_pct"] ?? self::DEFAULTS["trato_turno_1_pct"]),
            self::TURNO_MEIO => (float) ($cfg["trato_turno_2_pct"] ?? self::DEFAULTS["trato_turno_2_pct"]),
            self::TURNO_TARDE => (float) ($cfg["trato_turno_3_pct"] ?? self::DEFAULTS["trato_turno_3_pct"]),
            self::TURNO_NOITE => (float) ($cfg["trato_turno_4_pct"] ?? self::DEFAULTS["trato_turno_4_pct"]),
        ];

        return [
            "gmd" => (float) ($cfg["trato_gmd"] ?? self::DEFAULTS["trato_gmd"]),
            "pct_peso_vivo" => (float) ($cfg["trato_pct_peso_vivo"] ?? self::DEFAULTS["trato_pct_peso_vivo"]),
            "turnos" => $turnoPcts,
            "alerta_dias" => (int) ($cfg["trato_alerta_dias"] ?? self::DEFAULTS["trato_alerta_dias"]),
            "alerta_risco_dias" => (int) ($cfg["trato_alerta_risco_dias"] ?? self::DEFAULTS["trato_alerta_risco_dias"]),
        ];
    }

    /**
     * @param array<string, float|int|string> $valores chaves = DEFAULTS keys
     */
    public function salvarParametros(array $valores, ?int $userId = null): void
    {
        foreach (array_keys(self::DEFAULTS) as $chave) {
            if (!array_key_exists($chave, $valores)) {
                continue;
            }
            Configuracao::setValue($chave, $valores[$chave], $userId);
        }
    }

    public function diasConfinamento(?string $dataEntrada, ?string $dataRef = null): ?int
    {
        if ($dataEntrada === null || $dataEntrada === "" || $dataEntrada === "0000-00-00") {
            return null;
        }

        $ref = $dataRef ?: date("Y-m-d");
        $entrada = new \DateTimeImmutable(substr($dataEntrada, 0, 10));
        $hoje = new \DateTimeImmutable(substr($ref, 0, 10));

        return (int) $entrada->diff($hoje)->format("%r%a");
    }

    /**
     * @return null|"ok"|"atencao"|"risco"
     */
    public function nivelAlerta(?int $dias): ?string
    {
        if ($dias === null || $dias < 0) {
            return null;
        }

        $params = $this->parametros();
        if ($dias >= $params["alerta_risco_dias"]) {
            return "risco";
        }
        if ($dias >= $params["alerta_dias"]) {
            return "atencao";
        }

        return "ok";
    }

    /**
     * Calcula o previsto diário de um lote (sem gravar).
     *
     * @return array<string, mixed>|null
     */
    public function calcularLote(object $lote, string $dataRef): ?array
    {
        $params = $this->parametros();
        $quantidade = isset($lote->quantidade) ? (int) $lote->quantidade : 0;
        $pesoEntrada = isset($lote->peso_medio) ? (float) $lote->peso_medio : 0.0;
        $dataEntrada = $lote->data_entrada ?? null;

        if ($quantidade <= 0 || $pesoEntrada <= 0 || empty($dataEntrada)) {
            return null;
        }

        $dias = $this->diasConfinamento((string) $dataEntrada, $dataRef);
        if ($dias === null || $dias < 0) {
            return null;
        }

        $idFormula = $this->formulaVigente((int) $lote->id, $dataRef);
        if (!$idFormula) {
            return null;
        }

        $pctMs = $this->materiaSecaFormula($idFormula);
        if ($pctMs === null || $pctMs <= 0) {
            return null;
        }

        $pesoProjetado = $pesoEntrada + ($params["gmd"] * $dias);
        $consumoMsCab = $pesoProjetado * ($params["pct_peso_vivo"] / 100);
        $fornecimentoMnCab = $consumoMsCab / ($pctMs / 100);
        $totalMnDia = $fornecimentoMnCab * $quantidade;

        $porTurno = [];
        foreach ($params["turnos"] as $turno => $pctTurno) {
            $porTurno[$turno] = round($totalMnDia * ($pctTurno / 100), 2);
        }

        return [
            "id_lote" => (int) $lote->id,
            "lote_nome" => $lote->nome ?? "",
            "id_curral" => !empty($lote->id_curral) ? (int) $lote->id_curral : null,
            "id_formula_racao" => $idFormula,
            "data_entrada" => (string) $dataEntrada,
            "dias" => $dias,
            "alerta" => $this->nivelAlerta($dias),
            "quantidade" => $quantidade,
            "peso_entrada" => round($pesoEntrada, 2),
            "peso_projetado" => round($pesoProjetado, 2),
            "pct_ms" => round($pctMs, 3),
            "gmd" => $params["gmd"],
            "pct_peso_vivo" => $params["pct_peso_vivo"],
            "consumo_ms_cab" => round($consumoMsCab, 3),
            "fornecimento_mn_cab" => round($fornecimentoMnCab, 3),
            "total_mn_dia" => round($totalMnDia, 2),
            "turnos" => $porTurno,
        ];
    }

    /**
     * Gera programacao_trato (4 turnos) para a data.
     *
     * @return array{gerados: int, lotes: int, pulados: list<string>, detalhes: list<array>}
     */
    public function gerar(string $dataRef, ?int $idLote, int $userId, bool $substituir = true): array
    {
        $lotes = $this->lotesElegiveis($idLote);
        $gerados = 0;
        $lotesOk = 0;
        $pulados = [];
        $detalhes = [];

        foreach ($lotes as $lote) {
            $calc = $this->calcularLote($lote, $dataRef);

            if ($calc === null) {
                $motivo = $this->motivoPulo($lote, $dataRef);
                $pulados[] = ($lote->nome ?? ("#" . $lote->id)) . ": " . $motivo;
                continue;
            }

            if ($substituir) {
                ProgramacaoTrato::where("id_lote", "=", (int) $lote->id)
                    ->where("data_programacao", "=", $dataRef)
                    ->delete();
            } else {
                $existe = ProgramacaoTrato::where("id_lote", "=", (int) $lote->id)
                    ->where("data_programacao", "=", $dataRef)
                    ->first();
                if ($existe) {
                    $pulados[] = ($lote->nome ?? ("#" . $lote->id)) . ": já possui programação nesta data";
                    continue;
                }
            }

            foreach ($calc["turnos"] as $turno => $qtd) {
                ProgramacaoTrato::create([
                    "id_lote" => $calc["id_lote"],
                    "id_curral" => $calc["id_curral"],
                    "id_formula_racao" => $calc["id_formula_racao"],
                    "data_programacao" => $dataRef,
                    "turno" => $turno,
                    "quantidade_prevista" => $qtd,
                    "observacao" => "Gerado pelo motor (GMD {$calc["gmd"]}, %PV {$calc["pct_peso_vivo"]}, MS {$calc["pct_ms"]}%)",
                    "created_by" => $userId,
                ]);
                $gerados++;
            }

            $lotesOk++;
            $detalhes[] = $calc;
        }

        return [
            "gerados" => $gerados,
            "lotes" => $lotesOk,
            "pulados" => $pulados,
            "detalhes" => $detalhes,
        ];
    }

    /**
     * @return list<object>
     */
    private function lotesElegiveis(?int $idLote): array
    {
        $query = Lote::leftJoin("lote_entrada as le", "l.id", "=", "le.id_lote")
            ->select(
                "l.id",
                "l.nome",
                "l.id_curral",
                "l.ativo",
                "l.status",
                "le.quantidade",
                "le.peso_medio",
                "le.data_entrada"
            )
            ->where("l.ativo", "=", 1);

        if ($idLote) {
            $query = $query->where("l.id", "=", $idLote);
        }

        return $query->orderBy("l.nome")->get();
    }

    private function formulaVigente(int $idLote, string $dataRef): ?int
    {
        $troca = MovimentacaoDieta::where("id_lote", "=", $idLote)
            ->where("data_troca", "<=", $dataRef)
            ->orderBy("data_troca", "desc")
            ->orderBy("id", "desc")
            ->first();

        if ($troca && !empty($troca->id_formula_racao)) {
            return (int) $troca->id_formula_racao;
        }

        // Fallback: última troca mesmo se futura (dados de teste)
        $ultima = MovimentacaoDieta::where("id_lote", "=", $idLote)
            ->orderBy("data_troca", "desc")
            ->orderBy("id", "desc")
            ->first();

        return $ultima && !empty($ultima->id_formula_racao) ? (int) $ultima->id_formula_racao : null;
    }

    private function materiaSecaFormula(int $idFormula): ?float
    {
        $paramMs = ParametroNutricional::where("nome", "=", "MATÉRIA SECA")->first();
        if (!$paramMs) {
            return null;
        }

        $row = FormulaRacaoParametro::where("id_formula_racao", "=", $idFormula)
            ->where("id_parametro_nutricional", "=", $paramMs->id)
            ->first();

        if (!$row) {
            return null;
        }

        return (float) $row->valor;
    }

    private function motivoPulo(object $lote, string $dataRef): string
    {
        if (empty($lote->data_entrada)) {
            return "sem data de entrada";
        }
        if (empty($lote->quantidade) || (int) $lote->quantidade <= 0) {
            return "sem quantidade de animais";
        }
        if (empty($lote->peso_medio) || (float) $lote->peso_medio <= 0) {
            return "sem peso médio de entrada";
        }

        $idFormula = $this->formulaVigente((int) $lote->id, $dataRef);
        if (!$idFormula) {
            return "sem troca de dieta / fórmula vinculada";
        }

        $pctMs = $this->materiaSecaFormula($idFormula);
        if ($pctMs === null || $pctMs <= 0) {
            return "fórmula sem % MS cadastrado";
        }

        return "dados insuficientes para calcular";
    }
}
