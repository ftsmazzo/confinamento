<?php

namespace App\Models\Manejo;

use App\Core\Model;

class OcorrenciaAnexo extends Model
{
    public static string $table = "ocorrencia_anexo";
    public static ?string $alias = "oa";
    public static array $required = ["id_ocorrencia", "arquivo", "tipo_midia"];

    public static function tipoMidiaPorExtensao(string $extensao): string
    {
        $extensao = strtolower($extensao);

        $imagem = ["jpg", "jpeg", "png", "gif", "bmp", "webp"];
        $video = ["mp4", "mov", "avi", "webm", "mkv"];
        $audio = ["mp3", "wav", "ogg", "m4a", "wma"];

        if (in_array($extensao, $imagem, true)) {
            return "IMAGEM";
        }

        if (in_array($extensao, $video, true)) {
            return "VIDEO";
        }

        if (in_array($extensao, $audio, true)) {
            return "AUDIO";
        }

        return "OUTRO";
    }
}
