<?php

namespace App\Models\Estoque;

use App\Core\Model;

class ProdutoEstoque extends Model
{
    public static string $table = "produto_estoque";
    public static ?string $alias = "pe";
    public static array $required = ["nome", "tipo_produto"];

    /**
     * Tipos que exigem/aceitam os campos extras de princípio ativo,
     * apresentação e fabricante -- e que são listados na tela de
     * Medicamentos e Vacinas (ver ProdutoEstoqueController).
     */
    public const TIPOS_SANITARIOS = ["MEDICAMENTO", "VACINA", "SUPLEMENTO"];

    public static function tipoProdutoLabel(string $tipo): string
    {
        return match ($tipo) {
            "RACAO_INSUMO" => "Ração / Insumo Nutricional",
            "MEDICAMENTO" => "Medicamento",
            "VACINA" => "Vacina",
            "SUPLEMENTO" => "Suplemento",
            "MATERIAL_CONSUMO" => "Material de Consumo",
            "COMBUSTIVEL_LUBRIFICANTE" => "Combustível / Lubrificante",
            default => "Outro",
        };
    }
}
