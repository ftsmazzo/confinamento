<?php

namespace App\Models;

use App\Core\Model;

class Configuracao extends Model
{
    public static string $table = "configuracao";
    public static ?string $alias = "c";

    public static function getValue(string $chave, mixed $default = null): mixed
    {
        $row = static::where("c.chave", "=", $chave)->first();
        return $row ? $row->valor : $default;
    }

    public static function setValue(string $chave, mixed $valor, ?int $updatedBy = null): void
    {
        $payload = [
            "valor" => ($valor !== null && $valor !== "") ? (string) $valor : null,
            "updated_by" => $updatedBy,
            "updated_at" => date("Y-m-d H:i:s"),
        ];

        $row = static::where("c.chave", "=", $chave)->first();
        if ($row) {
            static::updateBy((int) $row->id, $payload);
            return;
        }

        static::create([
            "chave" => $chave,
            "valor" => $payload["valor"],
            "updated_by" => $payload["updated_by"],
            "updated_at" => $payload["updated_at"],
        ]);
    }

    public static function allIndexed(): array
    {
        $rows = static::get();
        $result = [];
        foreach ($rows as $row) {
            $result[(string) $row->chave] = $row->valor;
        }
        return $result;
    }
}
