<?php

namespace App\Models\Nutricao;

use App\Core\Model;

class ConfeccaoRacaoItem extends Model
{
    public static string $table = "confeccao_racao_item";
    public static ?string $alias = "cri";
    public static array $required = ["id_confeccao_racao", "id_ingrediente", "percentual_formula", "quantidade_consumida"];
}
