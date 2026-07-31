<?php
$router->namespace("\App\Controllers\Servicos");

$router->group("/notificacoes");
    // NOTIFICAÇÕES WEBPUSH
    $router->post("/webpush/subscription-save", "WebpushController:save", "webpush.subscription.save");
    $router->post("/webpush/subscription-delete", "WebpushController:delete", "webpush.subscription.delete");
    $router->get("/webpush/enviar", "WebpushController:send");
