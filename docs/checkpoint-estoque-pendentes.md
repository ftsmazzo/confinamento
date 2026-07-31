# Checkpoint — Centro de Custo, Funcionário e Módulo de Estoque (2026-07-09)

Continuação de [checkpoint-nutricao.md](checkpoint-nutricao.md). Depois de auditar o escopo original do usuário (seções 4.1 a 4.7) contra o código real do projeto, foram identificados 3 cadastros pendentes: **Centro de Custo** e **Funcionário** (itens isolados dos grupos 4.1/4.2), e o **módulo de Estoque completo** (grupo 4.7, que não tinha nenhuma implementação). Esta rodada fecha os três.

## Decisões de arquitetura (confirmadas com o usuário antes de implementar)

1. **Ingrediente (Nutrição) e Produto de Estoque continuam separados.** O usuário confirmou explicitamente que não quer unificar — `ingrediente` continua exclusivo das Fórmulas de Ração, e `produto_estoque` é um cadastro novo e independente para itens fora do escopo nutricional (medicamentos, materiais, combustível, uso geral). Nenhuma tabela ou controller de Nutrição foi tocado nesta rodada.
2. **Movimentações de estoque com baixa/estorno automático de saldo**, no mesmo padrão já usado em Confecção de Ração: cada movimentação atualiza `produto_estoque.saldo_atual` na hora (soma se natureza=ENTRADA, subtrai se SAIDA), e excluir a movimentação reverte o efeito antes de apagar.
3. **Locais internos de armazenagem são um cadastro próprio**, vinculado a um `local_estoque` já existente no módulo Confinamento (FK `id_local_estoque`), permitindo subdividir um silo/depósito em prateleiras/baias internas (ex: "Prateleira de Vacinas" dentro da "Farmácia Central").

## Migrations aplicadas (nesta ordem, na base local `sistema`)

1. [storage/migrations/20260709_0038_create_centro_custo.sql](../storage/migrations/20260709_0038_create_centro_custo.sql) — `centro_custo`
2. [storage/migrations/20260709_0039_create_funcionario.sql](../storage/migrations/20260709_0039_create_funcionario.sql) — `funcionario` (com vínculo opcional a `usuario` e `unidade`)
3. [storage/migrations/20260709_0040_create_estoque_base.sql](../storage/migrations/20260709_0040_create_estoque_base.sql) — `categoria_produto`, `local_armazenagem_interno`, `produto_estoque`, `lote_estoque`, `tipo_movimentacao_estoque`, `movimentacao_estoque` + seeds de categorias e tipos padrão

**Estas migrations ainda não foram aplicadas em produção** — só na base local `sistema`, mesmo estado das migrations anteriores (0034-0037).

### Bug de encoding encontrado e corrigido durante a aplicação

Ao aplicar `20260709_0040` via `mysql -u root sistema < arquivo.sql` (sem flag de charset), os `INSERT`s de seed com acentuação (`categoria_produto.descricao` = "Nutrição", "Sanitário" etc.; `tipo_movimentacao_estoque.descricao` = "Saída", "Ajuste (acréscimo)" etc.) foram gravados com **duplo encoding corrompido** (ex: "Sa├¡da" em vez de "Saída"), mesmo o arquivo `.sql` em disco estando em UTF-8 válido (confirmado com `file`). Corrigido via `UPDATE` direto no banco com `--default-character-set=utf8mb4` explícito na conexão. **Adicionada nota de alerta no `storage/migrations/README.md`** para sempre usar essa flag ao aplicar migrations com texto acentuado — inclusive ao aplicar em produção depois.

## Centro de Custo (grupo 4.1)

Cadastro simples: `nome`, `codigo`, `descricao`, `ativo`. Vive dentro do módulo Confinamento (mesmo padrão de Unidade/Curral/Piquete), pois é aí que o usuário espera encontrá-lo no menu. Usado como classificação opcional em Movimentações de Estoque (`id_centro_custo`, nullable).

- Model: [app/Models/Confinamento/CentroCusto.php](../app/Models/Confinamento/CentroCusto.php)
- Controller: [app/Controllers/Admin/Confinamento/CentroCustoController.php](../app/Controllers/Admin/Confinamento/CentroCustoController.php)
- Views: `app/Views/admin/confinamento/centro-custo/{index,form}.phtml`
- Rotas: `admin.confinamento.centro.custo.*`
- Menu: item "Centros de Custo" no dropdown "Confinamento"
- Permissões: `centro_custo_gerenciar/inserir/editar/excluir`

## Funcionário (grupo 4.2)

Distinto de `usuario` (conta de acesso ao sistema) — cobre toda a equipe operacional, técnica, administrativa e de apoio, **incluindo quem não acessa o sistema** (ex: peão de curral). Campos: nome, CPF, cargo, setor (Operacional/Técnico/Administrativo/Apoio), telefone, e-mail, unidade, datas de admissão/demissão, observação, ativo. Tem um vínculo **opcional** com `usuario` (`id_usuario`, nullable) para os casos em que o funcionário também tem login no sistema.

Namespace próprio `App\Models\Pessoas` / `App\Controllers\Admin\Pessoas`, já que não pertence nem a Confinamento nem a Manejo. Nova seção de menu "Pessoas" criada exclusivamente para isso (só um item por enquanto, mas deixa espaço para crescer).

- Model: [app/Models/Pessoas/Funcionario.php](../app/Models/Pessoas/Funcionario.php)
- Controller: [app/Controllers/Admin/Pessoas/FuncionarioController.php](../app/Controllers/Admin/Pessoas/FuncionarioController.php)
- Views: `app/Views/admin/pessoas/funcionario/{index,form}.phtml`
- Rotas: `admin.pessoas.funcionario.*`
- Menu: seção "Pessoas" > "Funcionários"
- Permissões: `funcionario_gerenciar/inserir/editar/excluir`

## Módulo de Estoque (grupo 4.7) — completo

6 tabelas novas, todas independentes do estoque de Ingredientes de Nutrição:

| Tabela | Papel |
|---|---|
| `categoria_produto` | Classificação: Nutrição, Sanitário, Manutenção, Combustível, Uso Geral (seed inicial) |
| `local_armazenagem_interno` | Subdivisão de um `local_estoque` (Confinamento) — ex: "Prateleira de Vacinas" dentro da "Farmácia Central" |
| `produto_estoque` | Item genérico com saldo agregado (`saldo_atual`, `estoque_minimo`), categoria, local interno padrão, fornecedor padrão opcional, e flag `controla_lote` |
| `lote_estoque` | Rastreabilidade por lote de compra/validade — só relevante quando `produto_estoque.controla_lote = 1` |
| `tipo_movimentacao_estoque` | Entrada, Saída, Ajuste (acréscimo/redução), Transferência, Perda, Inventário (acréscimo/redução) — cada um com `natureza` ENTRADA/SAIDA (seed inicial) |
| `movimentacao_estoque` | Histórico + baixa/estorno automático do saldo do produto e, quando aplicável, do lote |

### Lógica de saldo da Movimentação de Estoque

Ao **criar** uma movimentação:
1. Valida que o tipo de movimentação existe e que, se o produto tem `controla_lote = 1`, um `id_lote_estoque` foi informado (senão rejeita com mensagem clara)
2. `MovimentacaoEstoqueController::aplicarSaldo()`: aplica `+quantidade` se `natureza = ENTRADA` ou `-quantidade` se `SAIDA`, tanto em `produto_estoque.saldo_atual` quanto em `lote_estoque.quantidade_atual` (se houver lote)

Ao **excluir**: monta um "tipo invertido" (troca ENTRADA↔SAIDA) e reaplica `aplicarSaldo()` com ele antes de apagar — efetivamente estorna.

**Mesma limitação deliberada da Confecção de Ração:** `edit()`/`update()` de Movimentação só permite alterar `motivo`/`observacao`. Para corrigir quantidade/tipo/produto, o caminho é excluir (estorna) e recriar.

### Campos de contexto opcionais na Movimentação

- `id_local_armazenagem_interno_origem` / `_destino` — usados em Transferências
- `id_centro_custo` — classificação financeira opcional
- `id_fornecedor` — de quem veio, em entradas por compra
- `id_operador` — quem registrou (default: usuário logado)

### Arquivos criados

**Models** (`app/Models/Estoque/`): CategoriaProduto, LocalArmazenagemInterno, ProdutoEstoque, LoteEstoque, TipoMovimentacaoEstoque, MovimentacaoEstoque.

**Controllers** (`app/Controllers/Admin/Estoque/`): CategoriaProdutoController, LocalArmazenagemInternoController, ProdutoEstoqueController, LoteEstoqueController (com filtro contextual `?id_produto=`, mesmo padrão de Pesagem/Programação de Trato), TipoMovimentacaoEstoqueController, MovimentacaoEstoqueController.

**Views** (`app/Views/admin/estoque/`): 11 arquivos — `index.phtml` + `form.phtml` para os 5 primeiros módulos, mais `visualizar.phtml` em vez de `form.phtml` para Movimentação (não editável livremente, mesma razão da Confecção de Ração).

**Rotas**: bloco "ESTOQUE - ..." com 6 grupos de 6 rotas cada, inserido entre "NUTRICAO - AJUSTES DE CONSUMO" e "FORNECEDORES". Bloco "PESSOAS - FUNCIONARIOS" logo em seguida.

**Menu**: nova seção de título "Estoque" com um dropdown "Estoque" (Produtos, Categorias, Locais Internos, Tipos de Movimentação, Movimentações), e nova seção "Pessoas" com dropdown "Pessoas" (Funcionários). Também adicionado "Centros de Custo" ao dropdown existente "Confinamento".

**Permissões**: 32 novas (8 módulos × gerenciar/inserir/editar/excluir: categoria_produto, local_armazenagem_interno, produto_estoque, tipo_movimentacao_estoque, movimentacao_estoque — reaproveitando `produto_estoque_*` para Lote de Estoque também, já que lote é uma extensão do cadastro de produto — mais centro_custo e funcionario). Todas concedidas automaticamente ao perfil Administrador e ao usuário `admin`.

## Testes realizados (curl, `RECAPTCHA_AUTH` temporariamente `false`, depois revertido para `true`)

- Login, todas as 7 páginas de índice e "novo" dos módulos novos retornam 200 sem erro.
- Menu renderiza corretamente com as novas seções "Estoque" e "Pessoas", e o item "Centros de Custo" dentro de "Confinamento".
- Fluxo completo: Centro de Custo → Unidade → Local de Estoque (Confinamento) → Local Interno de Armazenagem → Produto (com `controla_lote=1`) → Lote de Estoque → Movimentação de Entrada (50 un) → **confirmado saldo do produto e do lote atualizados corretamente (50.00 em ambos)**.
- Movimentação de Saída (15 un) → **confirmado saldo correto (35.00)**.
- Exclusão da movimentação de Saída → **confirmado estorno correto (voltou a 50.00 em ambos)**.
- Validação de lote obrigatório: tentativa de movimentação **sem** `id_lote_estoque` num produto com `controla_lote=1` foi corretamente rejeitada (nenhuma linha criada, redirecionado de volta ao formulário).
- Funcionário criado com sucesso, data de admissão em ISO gravada corretamente.
- Dados de teste removidos ao final; base local `sistema` fica limpa.

## Pendências conhecidas (não bugs, escopo consciente)

1. **Edição de Movimentação de Estoque** limitada a motivo/observação — caminho é excluir/recriar, mesma limitação já documentada para Confecção de Ração.
2. Fluxo de **Transferência** (`id_local_armazenagem_interno_origem`/`_destino`) foi implementado na estrutura de dados e no formulário, mas **não testado end-to-end** — a lógica de saldo atual trata transferência como uma saída simples (debita do produto), sem side-effect automático de "criar uma entrada equivalente no destino". Se o usuário precisar que a Transferência efetivamente mova saldo entre dois produtos/locais (em vez de só documentar a intenção), isso precisa de uma iteração futura.
3. **Fornecedor padrão por item** (`produto_estoque.id_fornecedor_padrao`) é só um campo informativo — não há nenhuma automação que sugira esse fornecedor ao registrar uma movimentação de entrada.

## Roadmap após este checkpoint

Com Centro de Custo, Funcionário e o módulo de Estoque implementados, **todos os itens do escopo 4.1 a 4.7 levantado pelo usuário estão cobertos**. Os únicos itens remanescentes de qualquer rodada anterior são as pendências já documentadas (formula_racao_parametro sem UI, edição restrita de Confecção/Movimentação, fluxo de Transferência não testado fim-a-fim). Próximos passos dependem de nova indicação de prioridade do usuário.
