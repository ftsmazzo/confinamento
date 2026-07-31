<?php

namespace App\Models;

use App\Core\Model;

class Fornecedor extends Model
{
    public static string $table = "fornecedor";
    public static ?string $alias = "f";
    protected static array $required = [
        "pessoa",
        "telefone",
        "razao",
        "id_situacao",
    ];
    public static array $uppers = [
        "rg_ie",
        "razao",
        "nome",
        "pessoa",
        "documento",
        "contato",
        "telefone",
        "whatsapp",
        "endereco",
        "numero",
        "complemento",
        "bairro",
        "cidade",
        "estado",
        "pais"
    ];

    public static function applySoftDeleteScope($query)
    {
        return $query->where("f.trash", "=", 0);
    }
}
