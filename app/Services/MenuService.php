<?php

namespace App\Services;

use App\Core\Auth;
use App\Core\Cache;
use App\Core\Router;
use App\Services\Menu\AdminMenuDefinition;
use App\Services\Menu\ClienteMenuDefinition;
use App\Services\Menu\MenuBuilder;

class MenuService
{
    protected Router $router;
    protected Auth $auth;
    protected ?array $lang;
    protected Cache $cache;

    private array $sceneries = [
        'admin' => AdminMenuDefinition::class,
        'cliente' => ClienteMenuDefinition::class,
    ];

    public function __construct(Router $router, Auth $auth, ?array $lang, Cache $cache)
    {
        $this->router = $router;
        $this->auth = $auth;
        $this->lang = $lang;
        $this->cache = $cache;
    }

    public function generate(int $userId, string $scenery = 'admin'): array
    {
        $guard = $this->auth->getGuard();
        $cacheKey = "menu_{$scenery}_{$guard}_{$userId}";

        return $this->cache->remember($cacheKey, function () use ($scenery) {
            if (!isset($this->sceneries[$scenery])) {
                return [];
            }

            return $this->buildSceneryMenu($scenery);
        });
    }

    private function buildSceneryMenu(string $scenery): array
    {
        $definitionClass = $this->sceneries[$scenery] ?? null;

        if ($definitionClass === null) {
            return [];
        }

        $builder = new MenuBuilder($this->router);
        $definition = $this->makeDefinition($definitionClass);

        return $builder->build($definition->items(), $this->permissions());
    }

    private function makeDefinition(string $definitionClass): object
    {
        if ($definitionClass === AdminMenuDefinition::class) {
            return new $definitionClass($this->router, $this->auth);
        }

        return new $definitionClass();
    }

    private function permissions(): array
    {
        return (array) $this->auth->permissions();
    }
}
