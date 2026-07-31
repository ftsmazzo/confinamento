<?php

namespace App\Models\Financeiro;

use App\Core\Model;

class ContaReceber extends Model
{
    public static string $table = "conta_receber";
    public static ?string $alias = "cr";
    public static array $uppers = ["descricao", "documento"];
    public static array $required = ["descricao", "valor", "data_vencimento"];

    public function isParcelado(): bool
    {
        return ($this->parcela_total ?? 1) > 1;
    }

    public function parcelaLabel(): string
    {
        $num = (int) ($this->parcela_numero ?? 1);
        $tot = (int) ($this->parcela_total ?? 1);
        return $tot > 1 ? "{$num}/{$tot}" : "";
    }

    public static function statusLabel(string $status): string
    {
        return match ($status) {
            "PENDENTE" => "Pendente",
            "RECEBIDO" => "Recebido",
            "CANCELADO" => "Cancelado",
            default => $status,
        };
    }

    public static function statusBadge(string $status): string
    {
        return match ($status) {
            "PENDENTE" => "bg-warning",
            "RECEBIDO" => "bg-success",
            "CANCELADO" => "bg-secondary",
            default => "bg-secondary",
        };
    }
}
