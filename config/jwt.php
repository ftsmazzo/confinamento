<?php
return [
    // segredo privado (nunca commitar em git público)
    'secret'     => env('JWT_SECRET', ''),
    'alg'        => env('JWT_ALG', 'HS256'),
    'issuer'     => env('JWT_ISSUER', 'https://seusistema.com'), // identificador do emissor (opcional)
    'audience'   => env('JWT_AUDIENCE', 'https://seusistema.com/api'),
    'expires_in' => env('JWT_EXPIRES_IN', 3600),      // 1 hora
    'refresh_in' => env('JWT_REFRESH_IN', 1209600),   // 14 dias
    'not_before' => env('JWT_NOT_BEFORE', 0),
];
