# Checkpoint — Módulo de Nutrição e Ração (2026-07-09)

Continuação de [checkpoint-movimentacoes.md](checkpoint-movimentacoes.md). Aquele documento cobre os 6 eventos "simples" de 5.1 (Entrada, Alocação/Transferência, Pesagem, Troca de Dieta, Saída, Mortalidade). Este cobre o escopo que havia sido **deliberadamente deferido**: item **4.6 (Cadastros de Nutrição)** e **5.2 (Movimentações de Ração)**, implementados juntos porque são fortemente acoplados (a Confecção de Ração debita estoque de Ingredientes; o Trato usa Fórmula de Ração).

## Decisão de arquitetura: fusão Dieta → Fórmula de Ração

O módulo de Troca de Dieta (5.1) já tinha criado uma tabela `dieta` (nome/fase/descrição em texto livre) para satisfazer a FK de `movimentacao_dieta`. Ao especificar 4.6 em detalhe, o usuário definiu que a Fórmula de Ração *é* a dieta (composição percentual de ingredientes), então:

**Fundir: dieta VIRA formula_racao** (decisão explícita do usuário, escolhida entre as opções apresentadas).

A fusão foi seguramente executada porque `dieta` e `movimentacao_dieta` ainda tinham **0 registros** no momento (confirmado antes de escrever a migration):

```sql
RENAME TABLE `dieta` TO `formula_racao`;
ALTER TABLE `formula_racao`
    ADD COLUMN `id_tipo_dieta` INT UNSIGNED NULL,
    ADD COLUMN `id_fase_nutricional` INT UNSIGNED NULL,
    ADD CONSTRAINT fk_formula_racao_tipo_dieta ...,
    ADD CONSTRAINT fk_formula_racao_fase_nutricional ...;
-- movimentacao_dieta.id_dieta renomeada para id_formula_racao (mesma FK física)
```

As permissões antigas (`dieta_gerenciar/inserir/editar/excluir`) foram **renomeadas in-place** (`UPDATE`, mesmos IDs) para `formula_racao_*`, preservando qualquer grant já concedido — não foi delete+insert.

**Bug corrigido nesta rodada:** as rotas (`routes/admin.php`) e o menu (`AdminMenuDefinition.php`) ainda apontavam para um `Manejo\DietaController` que já não existe (tinha sido removido antes, junto com a fusão) e para a permissão `dieta_gerenciar` (já renomeada). Eram 6 rotas mortas + 1 item de menu órfão. Ambos removidos nesta rodada.

## Migrations aplicadas (nesta ordem, na DB local `sistema`)

1. [storage/migrations/20260709_0034_create_nutricao_base.sql](../storage/migrations/20260709_0034_create_nutricao_base.sql) — cadastros de apoio + fusão dieta→formula_racao + `formula_racao_item` (composição percentual) + `formula_racao_parametro`
2. [storage/migrations/20260709_0035_create_confeccao_racao.sql](../storage/migrations/20260709_0035_create_confeccao_racao.sql) — `confeccao_racao` + `confeccao_racao_item` (snapshot de consumo)
3. [storage/migrations/20260709_0036_create_trato_cocho.sql](../storage/migrations/20260709_0036_create_trato_cocho.sql) — `programacao_trato`, `fornecimento_trato`, `leitura_cocho`, `ajuste_consumo`

**Estas migrations ainda não foram aplicadas em produção** — só na base local `sistema`. Aplicar manualmente via `mysql` CLI quando o usuário decidir publicar, na mesma ordem acima.

## Tabelas e cadastros de apoio (4.6)

| Tabela | Campos-chave | Cadastro formal? |
|---|---|---|
| `fase_nutricional` | descricao, ordem (Adaptação=1, Crescimento=2, Terminação=3) | Sim |
| `tipo_dieta` | descricao (Total, Trato, Suplemento, Pré-mistura, Núcleo, Concentrado) | Sim |
| `parametro_nutricional` | nome, unidade_medida (Matéria Seca, Proteína Bruta, Fibra, Energia, Consumo Previsto) | Sim |
| `grupo_ingrediente` | descricao (Energético, Proteico, Volumoso, Mineral, Aditivo) | Sim |
| `ingrediente` | nome, id_grupo_ingrediente, unidade_medida, **estoque_atual**, estoque_minimo | Sim — com controle de estoque |
| `formula_racao` (ex-`dieta`) | nome, id_tipo_dieta, id_fase_nutricional, descricao, `fase` (texto livre legado, mantido) | Sim |
| `formula_racao_item` | id_formula_racao, id_ingrediente, percentual (soma deveria fechar 100%) | — (composição) |
| `formula_racao_parametro` | id_formula_racao, id_parametro_nutricional, valor | Criada, **sem UI ainda** (ver Pendências) |

## Movimentações de Ração (5.2)

| Tabela | Papel | Vínculo opcional |
|---|---|---|
| `confeccao_racao` + `confeccao_racao_item` | Registra uma "batida" de mistura; debita estoque dos ingredientes automaticamente | id_operador → usuario |
| `programacao_trato` | Planejamento diário (o que *deveria* ser fornecido) | id_curral, id_formula_racao |
| `fornecimento_trato` | Execução real do trato | id_programacao_trato (opcional — pode ser lançado direto sem planejamento) |
| `leitura_cocho` | Escore de sobra 0-4 (padrão indústria) | id_fornecimento_trato (opcional) |
| `ajuste_consumo` | Correção formal do consumo previsto | id_leitura_cocho (opcional) |

### Lógica de estoque da Confecção de Ração (a parte mais delicada)

Ao **criar** uma confecção:
1. Busca os itens da fórmula (`formula_racao_item`, percentuais)
2. Para cada item: `quantidade_consumida = quantidade_real * percentual / 100`
3. Grava snapshot em `confeccao_racao_item` (percentual e quantidade **não recalculam depois** — imutáveis, como o GMD de Pesagem)
4. Debita `ingrediente.estoque_atual -= quantidade_consumida`

Ao **excluir** uma confecção: estorna (`estoque_atual += quantidade_consumida` de cada item) antes de apagar.

**Limitação deliberada:** `edit()`/`update()` de Confecção **só permite alterar `observacao`**. Não é possível editar quantidade ou fórmula depois de criada — isso exigiria estornar e reaplicar a baixa, e não foi implementado nesta rodada para evitar um edge case de reconciliação de estoque mal tratado. Se o usuário precisar corrigir uma confecção, o caminho é **excluir (estorna) e recriar**. Isso deve ser comunicado ao usuário como limitação conhecida, não bug.

## Arquivos criados

### Models (`app/Models/Nutricao/`, namespace `App\Models\Nutricao`)
GrupoIngrediente, Ingrediente, FaseNutricional, TipoDieta, ParametroNutricional, FormulaRacao, FormulaRacaoItem, FormulaRacaoParametro, ConfeccaoRacao, ConfeccaoRacaoItem, ProgramacaoTrato, FornecimentoTrato, LeituraCocho (com `escoreLabel()` estático), AjusteConsumo — 14 models.

### Controllers (`app/Controllers/Admin/Nutricao/`)
GrupoIngredienteController, IngredienteController, FaseNutricionalController, TipoDietaController, ParametroNutricionalController, FormulaRacaoController (gerencia composição via `salvarItens()` — apaga e recria todos os itens a cada save), ConfeccaoRacaoController, ProgramacaoTratoController, FornecimentoTratoController, LeituraCochoController, AjusteConsumoController — 11 controllers.

### Views (`app/Views/admin/nutricao/`)
22 arquivos (`index.phtml` + `form.phtml` para os 10 primeiros módulos, mais `visualizar.phtml` em vez de `form.phtml` para Confecção — já que ela não é editável livremente).

O form de **Fórmula de Ração** tem um builder dinâmico de linhas (ingrediente + percentual) via `<template>` + JS inline vanilla (sem dependência de lib externa), com botões adicionar/remover linha.

### Removidos
- `app/Controllers/Admin/Manejo/DietaController.php` (referenciava `App\Models\Manejo\Dieta`, que não existe mais pós-fusão)
- `app/Views/admin/manejo/dieta/` (diretório inteiro)
- `App\Controllers\Admin\Manejo\TrocaDietaController` **atualizado** (não removido) para usar `FormulaRacao`/`id_formula_racao` em vez de `Dieta`/`id_dieta`

### Rotas e Menu
- `routes/admin.php`: bloco "NUTRICAO - ..." com 11 grupos de 6 rotas cada (index/novo/editar/insert/update/delete), inserido entre "MANEJO - MORTALIDADES" e "FORNECEDORES". Removidas as 6 rotas mortas de `Manejo\DietaController`.
- `app/Services/Menu/AdminMenuDefinition.php`: nova seção de título "Nutrição" com dois dropdowns — **"Cadastros"** (Grupos de Ingredientes, Ingredientes, Fases Nutricionais, Tipos de Dieta, Parâmetros Nutricionais, Fórmulas de Ração) e **"Trato e Cocho"** (Confecção de Ração, Programação de Trato, Fornecimento de Trato, Leitura de Cocho, Ajuste de Consumo). Removido o item órfão "Dietas" do dropdown "Cadastros" de Manejo.

### Permissões
44 permissões novas (11 módulos × gerenciar/inserir/editar/excluir), agrupamento "Nutrição" na tabela `usuario_permissao`. Todas concedidas automaticamente ao perfil Administrador e ao usuário `admin` (mesmo padrão de todas as migrations anteriores).

## Testes realizados (curl, `RECAPTCHA_AUTH` temporariamente `false`, depois revertido para `true`)

- Login via `/login`, todas as 11 páginas de índice e "novo" retornam 200 sem erro.
- Fluxo completo: criar Grupo → Ingrediente (x2, com estoque inicial 1000kg e 500kg) → Fórmula (60%/40%) → Confecção de 100kg → **confirmado estoque debitado corretamente (940kg/460kg)**.
- Exclusão da confecção → **confirmado estorno correto (voltou a 1000kg/500kg)**.
- Update de observação da confecção → confirmado persistido.
- Dados de teste removidos ao final; base local `sistema` fica limpa.
- Não havia lotes/currais cadastrados na base local para testar o fluxo completo de Programação/Fornecimento/Leitura/Ajuste fim-a-fim (essas tabelas dependem de `lote`, que está vazia); os formulários e listagens foram confirmados funcionais em modo "sem dados".

## Pendências conhecidas (não bugs, escopo consciente)

1. **`formula_racao_parametro`** — tabela criada na migration, mas **sem Controller/View**. Serviria para registrar valores de parâmetros nutricionais (ex: 65% MS, 2.8 Mcal/kg) por fórmula. Perguntar ao usuário se quer essa tela antes de implementar.
2. **Edição de Confecção de Ração** limitada a `observacao` (ver seção acima) — caminho é excluir/recriar.
3. Fluxo fim-a-fim de Programação → Fornecimento → Leitura → Ajuste não testado com dados reais de lote/curral (testado só estruturalmente, sem erros de código).
4. Campo legado `formula_racao.fase` (texto livre, pré-fusão) continua na tabela por compatibilidade; o campo formal é `id_fase_nutricional`. Pode ser aposentado depois se confirmado que nada mais depende dele.

## Roadmap após este checkpoint

Com 5.1 e 4.6+5.2 completos, o escopo original do usuário (documentado em [checkpoint-confinamento-limpeza.md](checkpoint-confinamento-limpeza.md)) está com os módulos de Movimentação de Animais e Nutrição/Ração implementados. Próximos passos dependem do usuário indicar prioridade — possíveis frentes remanescentes: relatórios/dashboards, GMD agregado por lote, alertas de estoque baixo de ingrediente (o campo `estoque_minimo` já existe e o `IngredienteController::index()` já calcula `estoque_baixo`, mas não há notificação ativa ainda).

---

## Rodada de correções pós-checkpoint (mesma data)

Depois deste checkpoint inicial, o usuário testou o módulo e reportou 3 problemas, todos corrigidos na mesma sessão.

### 1. Permissões do Confinamento com grupo/descrição errados

As permissões de Unidade/Curral/Piquete/LocalEstoque (criadas antes do padrão atual existir) tinham **todas o mesmo `grupo` = `'confinamento'`** em vez de um grupo por tabela, e a `descricao` repetia o nome da tabela ("Editar Currais/Baias" em vez de só "Editar") — inconsistente com Manejo e Nutrição, que já seguiam o padrão correto (um grupo por tabela, descrição só a ação).

Corrigido via [storage/migrations/20260709_0037_fix_permissoes_confinamento.sql](../storage/migrations/20260709_0037_fix_permissoes_confinamento.sql) — só `UPDATE`s de `grupo`/`descricao`, preservando os IDs e grants existentes. Resultado: `unidades`, `currais`, `piquetes`, `locais_estoque` como grupos próprios, descrição reduzida a Gerenciar/Inserir/Editar/Excluir.

**Esta migration também não foi aplicada em produção ainda** — mesma situação das migrations 0034-0036.

### 2. Menu "Movimentações" mostrando só Pesagem

Não era bug de código — o menu (`AdminMenuDefinition.php`) e as permissões no banco já estavam corretos, com as 6 movimentações (Entradas, Localizações, Pesagens, Trocas de Dieta, Saídas, Mortalidade) presentes. A causa raiz: `Auth::permissions()` cacheia a lista de permissões (nomes) **tanto em arquivo quanto na sessão PHP** (`App\Core\Auth::setPermissoes()`). Limpar o cache de arquivo (`storage/cache/`) não invalida a sessão já aberta no navegador do usuário — por isso o menu ficava desatualizado até um novo login.

**Não é necessário nenhum código adicional para isso** — é comportamento esperado de cache de sessão. Documentado aqui para não ser confundido com bug em rodadas futuras: sempre que permissões/menu mudarem, orientar o usuário a fazer logout/login (ou, alternativamente, implementar um mecanismo de invalidação de sessão por permissão-version, não feito nesta rodada).

### 3. Campos de peso/valor sem máscara e datas com input de texto mascarado

O usuário pediu: (a) mascarar campos de peso com `numeric-comma`/`jquery.mask` estilo `data-limit=3`, depois (b) o mesmo para campos de valor (R$), e (c) trocar todos os inputs de data para `<input type="date">` nativo em vez do `input-datebr` (texto com máscara dd/mm/aaaa).

**Peso e Valor** — usado o motor `jquery.mask` já presente em `forms.js` (`public/assets/app/scripts/forms.js`), que já tinha `.input-decimal` (1 casa) e `.input-money` (2 casas, `#.##0,00`). Foi adicionada a classe `.input-peso` (mesmo padrão `#.##0,00`) e aplicada nos 6 campos de peso do sistema (Animal.peso_entrada, Lote/LoteEntrada.peso_medio/peso_total, Pesagem.peso_medio/peso_total, Saída.peso_medio/peso_total). A classe `.input-money`, que já existia, foi aplicada nos 2 campos de valor (Entrada.valor_total, Saída.valor_total).

Como os valores mascarados chegam ao backend em formato brasileiro completo (ex: `1.234,56`, com ponto de milhar), foi usado o helper **`money2float()`** — que já existia em `public/libs/helpers.php` mas não estava sendo usado em nenhum controller — para normalizar (`1.234,56` → `1234.56`) antes de gravar nas colunas `DECIMAL`. Aplicado em: PesagemController, SaidaController, LoteController (via `extractLoteEntradaPayload`), AnimalController, EntradaController.

**Datas** — trocados 17 arquivos de view (`input-datebr` → `<input type="date">`, usando o helper `dateus()` para popular o `value` inicial em formato ISO) e removidas as chamadas `format_date()` correspondentes em 14 controllers, já que o navegador nativo já envia `aaaa-mm-dd` (não precisa mais converter de dd/mm/aaaa). Escopo: todos os módulos de Manejo e Nutrição criados nesta sessão, **mais** Cliente e Fornecedor (campo `nascimento`, pré-existentes — usuário pediu para cobrir todo o sistema). As duas únicas chamadas remanescentes de `format_date()` são em `ClienteController`/`FornecedorController`, dentro de `parseImportDate()` — usada só na importação de planilha Excel, que continua recebendo datas em formato livre e não deve ser alterada.

**Bugs reais encontrados e corrigidos durante esta limpeza** (não introduzidos nesta sessão, pré-existentes):
- `LoteController::extractLoteEntradaPayload()` usava `!empty($data->peso_medio)` num objeto `Data` — sempre `false` por causa do bug já documentado de `Data` não implementar `__isset()`. Trocado para `$data->has()`. Isso significa que **peso de lote nunca era salvo corretamente antes desta correção**.
- `LoteController` (campo `data_formacao`) e `EntradaController`/`SaidaController` (campo `valor_total`) nunca tinham conversão nenhuma aplicada (nem `format_date()` nem `money2float()`) — o texto cru batia direto no banco. Com o `type="date"` isso passou a funcionar por acidente para datas (o browser já manda ISO), mas o `valor_total` só ficou correto de fato depois do `money2float()` ser adicionado.

Testado via curl (fluxo Unidade → Lote → Entrada → Pesagem → Cliente), confirmando: `1.234,50` → `1234.50` gravado certo, datas ISO gravadas certas. Dados de teste removidos ao final.
