<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Configurações principais do sistema
    |--------------------------------------------------------------------------
    */

    'environment' => env('APP_ENV', 'sandbox'),
    'name'        => env('APP_NAME', 'Sistema'),
    'path'        => env('APP_PATH', ''),
    'timezone'    => env('APP_TIMEZONE', 'America/Sao_Paulo'),
    'path_app'    => 'app',

    /*
    |--------------------------------------------------------------------------
    | Valores globais do sistema
    |--------------------------------------------------------------------------
    */
    'globals' => [
        'multi_language' => false,
        'default_language' => 'pt-BR',
    ],

    /*
    |--------------------------------------------------------------------------
    | Configuração para uso de Python
    |--------------------------------------------------------------------------
    */
    'python' => [
        'command' => PHP_OS_FAMILY === 'Windows' ? 'C:\laragon\bin\python\python-3.13\python.exe' : '/usr/bin/python3',
        'command_py' => PHP_OS_FAMILY === 'Windows' ? 'pip' : '/usr/bin/py3',
    ],

    /*
    |--------------------------------------------------------------------------
    | Fontes e versões externas
    |--------------------------------------------------------------------------
    */
    'icons' => [
        'font_awesome_version' => '6.7.2',
        'font_unicons_version' => '4.2.0',
        'font_tabler_version' => 'latest',
    ],

    /*
    |--------------------------------------------------------------------------
    | Layouts e temas
    |--------------------------------------------------------------------------
    */
    'sceneries' => [

        'admin' => [
            'case'  => 'upper', // upper, normal (upper apenas nos campos selecionados no Model)
            'menu'  => 'vetical', // vertical, horizontal
            'color' => 'light', // clean, light, dark
            'preference_model' => \App\Models\UsuarioPreferencia::class,
            'menu_service'     => \App\Services\MenuService::class,

            'layout' => [
                'content_container'     => 'container-fluid',
                'topbar-logo-height'    => '40',
                'topbar-logo-height-sm' => '20',
                'topbar-logo-route'     => 'admin.home',
                'custom-js'             => 'admin/js/admin.min.js',
                'logo_login'            => 'logo.svg',
                'logo_login_height'     => '150',
                'logo_sidebar'          => 'logo-sidebar-name.svg',
                'logo_sidebar_height'   => '',
                'logo_mobile'           => '',
                'logo_light'            => '',
                'logo_dark'             => '',
                'background_login'      => 'fundo-login.jpg',
            ],
        ],

        'cliente' => [
            'case'  => 'upper', // upper, normal
            'menu'  => 'vertical', // vertical, horizontal
            'theme' => 'vertical',
            'fluid' => true,
            'color' => 'light',
            'preference_model' => \App\Models\UserPreferencia::class,
            'menu_service'     => \App\Services\MenuService::class,

            'layout' => [
                'content_container'     => 'container-fluid',
                'template'              => 'vertical',
                'leftbar-theme'         => 'dark',
                'leftbar-compact-mode'  => 'fixed',
                'rightbar-onstart'      => 'false',
                'topbar-logo-height'    => '48',
                'topbar-logo-height-sm' => '20',
                'topbar-logo-route'     => 'cliente.home',
                'custom-js'             => 'cliente/js/cliente.min.js',
                'logo_login'            => 'logo.png',
                'logo_sidebar'          => 'logo.png',
                'logo_mobile'           => 'logo_small.png',
                'logo_light'            => 'logo.png', // storage/layouts
                'logo_dark'             => 'logo-dark.png', // storage/layouts
            ],
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Segurança e chaves
    |--------------------------------------------------------------------------
    */
    'security' => [
        'encrypt_key' => env('APP_ENCRYPT_KEY', '5d7b4c7d6da7b9dbea6a222cbe06fb14'),
        'cookie_name' => env('APP_COOKIE_NAME', 'lgpd_dcf'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Outras opções gerais
    |--------------------------------------------------------------------------
    */
    'uploads' => [
        'path' => 'storage/media/uploads',
    ],


];
