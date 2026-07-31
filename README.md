# Sistema — Guia de Configuração

## Menu: vertical ou horizontal

Cada área do sistema (`admin`, `cliente`) tem seu próprio modo de menu. Para alternar, edite `config/app.php`:

```php
'sceneries' => [
    'admin' => [
        'menu' => 'horizontal', // 'vertical' ou 'horizontal'
        ...
    ],
    'cliente' => [
        'menu' => 'vertical',
        ...
    ],
],
```

**Vertical** — sidebar fixa à esquerda. Pode ser recolhida pelo usuário (estado salvo no navegador).

**Horizontal** — barra de navegação no topo. Em mobile a sidebar aparece como menu deslizante.

---

## Largura do conteúdo

Controla se o conteúdo ocupa a tela toda ou fica centralizado em um container.

### Padrão global por área

Em `config/app.php`, dentro de cada cenário:

```php
'layout' => [
    'content_container' => 'container-fluid', // padrão
],
```

| Valor | Resultado |
|---|---|
| `container-fluid` | Ocupa toda a largura disponível |
| `container` | Container Bootstrap centralizado e responsivo |
| `container-extra` | Container intermediário (máx. ~1480px em telas grandes) |

### Por página individual

Em qualquer controller, passe a variável na renderização da view:

```php
$this->render('minha-view', [
    'content_container' => 'container',
]);
```

Isso sobrescreve o padrão global apenas naquela página.

---

## Logos

As logos são configuradas por área em `config/app.php`:

```php
'layout' => [
    'logo_login'   => 'logo.svg',    // tela de login
    'logo_sidebar' => 'logo.svg',    // sidebar / header horizontal
    'logo_mobile'  => 'logo.svg',    // versão mobile
    'logo_light'   => 'logo.png',    // tema claro
    'logo_dark'    => 'logo-dark.png', // tema escuro
],
```

Os arquivos devem estar em `storage/layouts/`.

---

## Fuso horário, nome e ambiente

```php
'environment' => env('APP_ENV', 'sandbox'), // local, sandbox, production
'name'        => env('APP_NAME', 'Sistema'),
'timezone'    => env('APP_TIMEZONE', 'America/Sao_Paulo'),
```

Esses valores podem ser definidos no `.env` da raiz do projeto.

---

## Itens do menu

Os itens de cada área ficam nos arquivos:

- Admin → `app/Services/Menu/AdminMenuDefinition.php`
- Cliente → `app/Services/Menu/ClienteMenuDefinition.php`

Cada item pode ter os tipos: `link`, `drop` (com subitens) ou `title` (separador).

No menu **horizontal**, separadores (`title`) aparecem apenas dentro de dropdowns — na barra principal são ocultados automaticamente.

---

> Para detalhes técnicos sobre a implementação do layout, consulte [docs/TECHNICAL.md](docs/TECHNICAL.md).
