<?php

namespace App\Models\Manejo;

use App\Core\Model;

class MovimentacaoMortalidade extends Model
{
    public static string $table = "movimentacao_mortalidade";
    public static ?string $alias = "mm";
    public static array $uppers = ["responsavel"];
    public static array $required = ["data_ocorrencia", "quantidade"];
}
