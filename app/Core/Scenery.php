<?php
namespace App\Core;

use App\Core\Config;

class Scenery
{
    private string $name;
    private array $config;
    private static ?Scenery $current = null;

    public function __construct(string $name)
    {
        $this->name = $name;
        $this->config = Config::get("app.sceneries.{$name}");
    }

    public function getMenu(int $userId, $router, $auth, $lang)
    {
        $menuService = $this->config['menu_service'];

        return (new $menuService(
            $router,
            $auth,
            $lang,
            new Cache()
        ))->generate($userId, $this->name);
    }

    public function getPreferences($userId)
    {
        $model = $this->config['preference_model'];
        $preferences = $model::find($userId, 'id_user');

        if ($preferences) {
            return $preferences;
        }

        return (object) [
            'id_user' => $userId,
            'tema' => 'light',
        ];
    }

    public function getCase(): string
    {
        return $this->config['case'] ?? 'normal';
    }

    public function getLayout($preferences): array
    {
        $themeIcons = [
            'light' => 'uil uil-moon',
            'dark'  => 'uil uil-sun',
        ];

        $theme = $preferences->tema ?? 'light';

        $layout = $this->config['layout'];
        $layout['theme-icon']   = $themeIcons[$theme] ?? $themeIcons['light'];
        $layout['layout-color'] = $theme;
        $layout['menu'] = $this->config['menu'] ?? ($layout['menu'] ?? 'vertical');
        $layout['content_container'] = $layout['content_container']
            ?? (($layout['menu'] ?? 'vertical') === 'horizontal' ? 'container-extra' : 'container-fluid');
        $layout['sidebar_mobile_usercard'] = $layout['sidebar_mobile_usercard'] ?? true;

        return $layout;
    }
}
