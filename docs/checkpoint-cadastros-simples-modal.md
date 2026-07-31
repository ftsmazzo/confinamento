# Checkpoint — Cadastros Simples em Modal + Situação do Animal (2026-07-10)

Continuação de [checkpoint-relatorios.md](checkpoint-relatorios.md). Ajustes pedidos pelo usuário: simplificar 9 cadastros de 1-2 campos (removendo o campo `ativo`, sem uso real) e trocá-los para o padrão de modal já usado em Situação de Cliente/Fornecedor, mais um novo cadastro formal de Situação do Animal.

## Escopo

**9 cadastros convertidos** para o padrão modal (sem página `/novo` ou `/editar` cheia — o formulário abre num modal Bootstrap injetado via AJAX na própria tela de índice):

1. Tipos de Entrada (`tipo_entrada`)
2. Tipos de Saída (`tipo_saida`)
3. Motivos de Perda (`motivo_perda`)
4. Grupos de Ingredientes (`grupo_ingrediente`)
5. Fases Nutricionais (`fase_nutricional`) — mantém campo `ordem`
6. Tipos de Dieta (`tipo_dieta`)
7. Parâmetros Nutricionais (`parametro_nutricional`) — mantém campo `unidade_medida`
8. Categorias de Produto (`categoria_produto`)
9. Tipos de Movimentação de Estoque (`tipo_movimentacao_estoque`) — mantém campo `natureza` (ENTRADA/SAIDA)

**1 cadastro novo**: Situação do Animal (`animal_situacao`), também no padrão modal, substituindo o campo `animal.status` (texto livre) por uma FK formal `animal.id_situacao`.

## Decisões confirmadas com o usuário

1. **Campo `ativo` removido do banco** (não só da tela) — `DROP COLUMN` nas 9 tabelas. Nenhum controller filtrava dropdowns por `ativo` nesses cadastros, então a remoção não quebrou nada. Se um valor não for mais usado, o caminho é excluir (a exclusão já é bloqueada quando há vínculo, no caso de Situação do Animal).
2. **Nenhum dos 9 cadastros precisa de telas separadas de criar/editar** — todos são "folhas" (não têm tabela pivot nem dependem de outro cadastro), então o padrão modal simples se aplicou sem obstáculo.
3. **Situação do Animal é um cadastro formal**, não só convenção de texto livre — `animal_situacao` com FK em `animal.id_situacao`.

## Padrão modal (replicado de Situação de Cliente/Fornecedor)

Confirmado antes de implementar, via investigação do código existente:

- As rotas `novo`/`editar` **continuam existindo** no backend (GET), mas devolvem apenas o **HTML parcial do formulário** (`form.phtml`, sem `$this->layout(...)`), não uma página completa.
- O front-end abre um modal Bootstrap **fixo, já presente no HTML do `index.phtml`** de cada cadastro, e carrega o conteúdo do form via `$.ajax` GET, usando o motor genérico já existente em `public/assets/app/scripts/util.js` (`openAjaxModal()`, disparado por qualquer elemento com `data-modal-ajax`).
- O **submit continua sendo POST tradicional** (full page reload) — o jQuery Validate só valida client-side; ao passar, chama `form.submit()` nativo. Nenhuma lógica de fetch/AJAX no submit.
- Cada cadastro tem um JS de inicialização mínimo (`{nome}-form.js`) que só aplica `uppers()` no campo certo e se registra em `window.registerAjaxModalInitializer()` — chamado toda vez que o modal carrega conteúdo novo.
- Botão "Salvar" fica no `modal-footer`, fora do `<form>`, ligado via atributo HTML5 `form="form-{nome}"`.

### Arquivos por cadastro (padrão replicado 10x)

- Controller: remove os `$payload["ativo"] = ...` de `create()`/`update()` (payload simplificado)
- `index.phtml`: troca `<a href="...novo">` por `<button data-modal-ajax="..." data-modal-target="#modal-{nome}">`, remove coluna "Ativo" da tabela, adiciona o `<div class="modal fade" id="modal-{nome}">` fixo no fim do arquivo, com `<?php $this->start("endScripts") ?>` carregando o JS do form
- `form.phtml`: vira um partial "cru" (sem `$this->layout()`, sem `<div class="card">` envolvente) — só os campos do formulário
- `public/assets/admin/js/{nome}-form.js`: novo arquivo, ~20 linhas, sempre a mesma estrutura

## Situação do Animal — detalhes

### Migration

[storage/migrations/20260710_0044_simplificar_cadastros_e_situacao_animal.sql](../storage/migrations/20260710_0044_simplificar_cadastros_e_situacao_animal.sql):
1. 9× `ALTER TABLE ... DROP COLUMN ativo`
2. `CREATE TABLE animal_situacao` (id, descricao) + seed com 6 valores: Ativo, Vendido, Abatido, Morto, Em Tratamento, Transferido
3. `ALTER TABLE animal ADD COLUMN id_situacao` + FK para `animal_situacao` (`ON DELETE SET NULL`)
4. **Migração de dados**: casa `animal.status` (texto livre existente) com `animal_situacao.descricao` via `UPPER()`; animais sem correspondência exata caem em "Ativo" por padrão. A coluna antiga `status` foi **mantida** na tabela (não removida) por precaução, mas a aplicação não lê mais dela.
5. 4 novas permissões `animal_situacao_*`

**Ainda não aplicada em produção.** Sempre aplicar com `--default-character-set=utf8mb4`.

### Arquivos criados/alterados

- Novo: `app/Models/Manejo/AnimalSituacao.php`, `app/Controllers/Admin/Manejo/AnimalSituacaoController.php` (com bloqueio de exclusão se houver animal vinculado, igual `ClienteSituacaoController`), `app/Views/admin/manejo/animal-situacao/{index,form}.phtml`, `public/assets/admin/js/animal-situacao-form.js`
- Alterado: `AnimalController.php` (troca `status` texto livre por `id_situacao` — dropdown populado por `AnimalSituacao::orderBy("descricao")->get()`), `app/Views/admin/manejo/animal/form.phtml` (select em vez de input texto) e `index.phtml` (coluna mostra `situacao_descricao` do join)

## Rotas e Menu

- `routes/admin.php`: bloco "MANEJO - SITUACOES DO ANIMAL" com 6 rotas, inserido logo após "MANEJO - ANIMAIS". As rotas dos 9 cadastros existentes **não mudaram** (mesmo path, mesmo nome de rota) — só o comportamento do front-end mudou.
- `app/Services/Menu/AdminMenuDefinition.php`: item "Situações do Animal" adicionado ao dropdown "Cadastros" de Manejo, logo após "Animais".

## Testes realizados (curl, `RECAPTCHA_AUTH` temporariamente `false`, depois revertido)

- Todas as 10 páginas de índice retornam 200 sem erro.
- Confirmado que `/novo` de cada cadastro devolve um **fragmento pequeno de HTML** (8-17 linhas, sem `<!DOCTYPE>`/layout), consistente com o uso em modal.
- Fluxo completo testado em Tipos de Entrada: criar ("Doação") → editar (pré-carregou valor certo, salvou "Doação Editada") → excluir — todos os 3 passos funcionaram.
- Fases Nutricionais: campo `ordem` preservado corretamente ao criar.
- Tipos de Movimentação de Estoque: campo `natureza` preservado corretamente ao criar.
- **Situação do Animal**: criação com uppercase automático confirmado; **bloqueio de exclusão** testado e confirmado — tentativa de excluir "Ativo" (7 animais vinculados) foi rejeitada com a mensagem exata "Existem animais vinculados a esta situação", botão de exclusão aparece desabilitado na listagem quando há vínculo.
- Listagem de Animal exibe a situação corretamente via join (`situacao_descricao`).
- Todas as 8 telas que dependem desses cadastros como dropdown (Animal, Lote, Entrada, Saída, Mortalidade, Fórmula de Ração, Produto de Estoque, Movimentação de Estoque) continuam carregando sem erro.
- Dados de teste removidos ao final.

## Pendências conhecidas (não bugs, escopo consciente)

1. **Coluna `animal.status` (texto livre) não foi removida do banco**, só parou de ser usada pela aplicação — mantida por precaução para não perder histórico. Pode ser removida numa limpeza futura se confirmado que nada mais depende dela.
2. Nenhum dos 9 cadastros simples tem paginação server-side — a listagem carrega tudo de uma vez e o DataTables.js pagina no browser (mesmo padrão já usado em Situação de Cliente/Fornecedor, não é regressão).
