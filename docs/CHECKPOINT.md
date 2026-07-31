# CHECKPOINT — Módulo Financeiro + Calendário + Dashboard

## Contexto do Projeto
- Local: `C:\laragon\www\confinamento`
- PHP 7.4.33, MySQL 8.4, Laragon vhost `confinamento.local`
- Login padrão: `admin` / `@admin`
- Rotas financeiras SEM prefixo `/admin` — tudo em root: `confinamento.local/financeiro/...`
- `DB::where()` exige 3 argumentos (coluna, operador, valor)
- `DB::execute()` retorna objetos para SELECT, bool para demais
- `Model::query()` NÃO aceita SQL cru — usar `DB::execute()` para JOINs
- Cache de menu em `storage/cache/menu_admin_usuario_{id}.txt` — limpar manualmente ao alterar `AdminMenuDefinition`

---

## Migrations Executadas

| Arquivo | Descrição |
|---|---|
| `20260721_0045_create_financeiro_base.sql` | plano_conta, conta_pagar, conta_receber, 13 contas padrão, 12 permissões |
| `20260721_0100_add_parcelamento_financeiro.sql` | colunas parcela_numero, parcela_total + índices |
| `20260721_0200_add_parcela_origem_id.sql` | coluna + população de registros existentes agrupando por documento |
| `20260721_0300_add_preferencias_usuario.sql` | colunas `contas_pagar_visao`, `contas_receber_visao` em `usuario_preferencia` |
| `20260721_0400_add_calendario_eventos_preferencia.sql` | coluna `calendario_eventos` (VARCHAR(255)) |
| `20260721_0500_add_calendario_visao_preferencia.sql` | coluna `calendario_visao` (VARCHAR(20), default `dayGridMonth`) |

---

## Models Criados

| Model | Tabela |
|---|---|
| `app/Models/Financeiro/PlanoConta.php` | `plano_conta` |
| `app/Models/Financeiro/ContaPagar.php` | `conta_pagar` |
| `app/Models/Financeiro/ContaReceber.php` | `conta_receber` |
| `app/Models/Admin/UsuarioPreferencia.php` | `usuario_preferencia` (já existia) |

---

## Controllers Implementados / Modificados

### Financeiro
| Controller | Ações |
|---|---|
| `ContaPagarController` | CRUD + `baixar()` (JSON), hash removido, `find()` sem `findByMd5`, parcelas query com fallback por `parcela_origem_id` e `documento` |
| `ContaReceberController` | CRUD + `baixar()` (JSON), mesmas regras do ContaPagar |
| `RelatorioFinanceiroController` | extrato, fluxo de caixa, DRE |

### Dashboard
| Controller | Método |
|---|---|
| `HomeController::financeiroResumo()` | Totais a pagar/receber do mês, variação vs mês anterior, meses em português |

### Calendário
| Arquivo | Mudanças |
|---|---|
| `CalendarioController::index()` | Lê `calendario_eventos` e `calendario_visao` de `usuario_preferencia` |
| `CalendarioController::salvarPreferenciaEventos()` | Endpoint POST que salva `calendario_eventos` e/ou `calendario_visao` |

---

## Views Modificadas

### `admin/home/index.phtml`
- **Financeiro heading**: ícone removido, meses em português
- **Cards**: `border-2`, ícones como marca d'água (90px, 8% opacidade)
- **Variação**: lógica invertida para contas a pagar (subiu=vermelho, caiu=verde), contas a receber e saldo (subiu=verde, caiu=vermelho), zero oculto
- **Subtítulo "Operacional"** entre cards financeiros e cards de movimentação
- **Badge de carências**: "Faltam X dias" / "X dias atrasado(s)"

### `admin/financeiro/conta-pagar/index.phtml` e `conta-receber/index.phtml`
- CSS de botões `.table-action-btn.table-action-success`
- Toggle Lista/Agrupado, avulsos na mesma tabela, modal detalhe, modal baixar
- `event.stopPropagation()` no link editar dentro do grupo

### `admin/financeiro/conta-pagar/form.phtml` e `conta-receber/form.phtml`
- **Seção "Parcelas"** dentro do card do formulário (antes de Salvar/Voltar)
- Busca parcelas por `parcela_origem_id` com fallback por `documento`
- **Botão "Baixar"** (verde) → abre modal com data, faz fetch POST e reload
- **Botão "Editar" removido** (navegação não funcionava dentro do form)
- CSS próprio para `.table-action-btn` e `.table-actions`

### `admin/calendario/index.phtml`
- **Checkboxes na legenda**: cada tipo de evento (trato, carencia, validade, lembrete, conta-pagar, conta-receber)
- Ao marcar/desmarcar → AJAX POST salva em `calendario_eventos` + `calendar.refetchEvents()`
- Ao trocar visão (Mês/Semana) → AJAX POST salva em `calendario_visao`
- `initialView` lido de `calendario_visao` (default `dayGridMonth`)
- Filtro client-side no callback `events` do FullCalendar

---

## Rotas Adicionadas

```
POST /calendario/preferencia-eventos  → CalendarioController:salvarPreferenciaEventos  (admin.calendario.preferencia.eventos)
```

---

## Pendências / Issues Conhecidas

1. **Navegação do botão "Editar" nas parcelas do form**: não funcionava via `window.location.href` com URL hardcoded ou com `$router->route()`. Removido em favor do botão "Baixar". Se precisar editar parcela individual, criar rota separada ou modal de edição inline.

---

## Comandos Úteis

```bash
# Rodar migrations manualmente
Get-Content storage\migrations\20260721_*.sql | mysql -u root sistema

# Limpar cache de menu
Remove-Item storage\cache\menu_admin_*.txt

# Seed de parcelas financeiras (executar apenas uma vez)
Get-Content storage\migrations\seed-financeiro-parcelas.sql | mysql -u root sistema
```
