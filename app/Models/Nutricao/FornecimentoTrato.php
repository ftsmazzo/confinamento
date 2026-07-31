<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class FornecimentoTrato extends Model
{
    public static string $table = "fornecimento_trato";
    public static ?string $alias = "ft";
    public static array $required = ["id_lote", "data_fornecimento", "quantidade_fornecida"];
}
