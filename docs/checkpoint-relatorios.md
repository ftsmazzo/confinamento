# Checkpoint — Módulo de Relatórios (2026-07-10)

Continuação de [checkpoint-sanitario.md](checkpoint-sanitario.md). Implementa 4 relatórios operacionais pedidos pelo usuário, com foco principal em **Rentabilidade por Lote** (valor final + custos vs. valor de venda).

## Pré-requisito descoberto: nenhuma tabela tinha custo unitário

Antes de implementar Rentabilidade, foi identificado que **nenhuma tabela do sistema tinha campo de custo/preço unitário** — nem `ingrediente`, nem `produto_estoque`, nem `formula_racao`. Sem isso, era impossível calcular "quanto custou a ração" ou "quanto custou o sanitário" em R$, só em quantidade física (kg, doses).

**Decisão confirmada com o usuário:** adicionar `custo_unitario` (nullable, `DECIMAL(10,4)`) em `ingrediente` e `produto_estoque`, em vez de fazer o relatório só com quantidades sem valor financeiro.

## Migrations aplicadas (na base local `sistema`)

1. [storage/migrations/20260710_0042_add_custo_unitario.sql](../storage/migrations/20260710_0042_add_custo_unitario.sql) — `ALTER TABLE` adicionando `custo_unitario` em `ingrediente` e `produto_estoque`.
2. [storage/migrations/20260710_0043_create_permissoes_relatorios.sql](../storage/migrations/20260710_0043_create_permissoes_relatorios.sql) — 4 permissões `relatorio_*_visualizar` (só leitura, um único verbo em vez do padrão gerenciar/inserir/editar/excluir).

**Ainda não aplicadas em produção.** Sempre aplicar com `--default-character-set=utf8mb4`.

## Cadastros atualizados

`IngredienteController`/`ProdutoEstoqueController` (e respectivas views) passaram a aceitar `custo_unitario` (campo opcional, mascarado com `.input-money`, convertido com `money2float()`). Sem preenchimento, o campo fica `NULL` e os relatórios tratam como custo 0 (subestimando o total até o usuário cadastrar os preços reais).

## Os 4 relatórios (`app/Controllers/Admin/RelatorioController.php`, sem subnamespace)

### 1. Rentabilidade por Lote (`admin.relatorio.rentabilidade`)

O relatório principal pedido pelo usuário. Por lote:
- **Custo de Entrada**: `movimentacao_entrada.valor_total`
- **Custo de Ração**: soma de `fornecimento_trato.quantidade_fornecida` × custo/kg da fórmula usada. Custo/kg da fórmula é calculado a partir de `formula_racao_item` (percentual × `ingrediente.custo_unitario`, somado entre todos os ingredientes da composição) — não persistido, sempre recalculado a partir do cadastro atual.
- **Custo Sanitário**: soma de `aplicacao_sanitaria.quantidade_produto` × `produto_estoque.custo_unitario`, cobrindo tanto aplicações diretas no lote quanto aplicações em animais individuais pertencentes ao lote.
- **Receita**: soma de `movimentacao_saida.valor_total`
- **Resultado** = Receita − (Entrada + Ração + Sanitário)

Lotes sem nenhuma saída registrada ainda aparecem com badge "Em aberto" mostrando o custo acumulado até agora (não é tratado como prejuízo definitivo, já que a venda pode não ter ocorrido).

Inclui 4 cards de resumo no topo (custo total, receita total, resultado consolidado, nº de lotes) e um atalho por linha para o relatório de Evolução de Peso daquele lote.

### 2. Evolução de Peso / GMD (`admin.relatorio.evolucao.peso`)

Lista as pesagens (`movimentacao_pesagem`) de cada lote em ordem cronológica, com GMD calculado entre pesagens consecutivas usando o mesmo `MovimentacaoPesagem::calcularGmd()` já usado na tela de Pesagens (não duplicou a lógica). Aceita filtro opcional `?id_lote=`.

### 3. Mortalidade / Perdas (`admin.relatorio.mortalidade`)

Por lote: quantidade recebida, total de perdas (`movimentacao_mortalidade`), percentual de perda, valor estimado perdido (`custo médio por cabeça do lote × cabeças perdidas`, onde custo médio = `valor_total` da entrada ÷ quantidade recebida), e o detalhamento de cada ocorrência com data/motivo/quantidade.

### 4. Consumo de Ração por Lote (`admin.relatorio.consumo.racao`)

Agrega `fornecimento_trato` por lote + fórmula, mostrando quantidade total (kg) e custo estimado (mesmo cálculo de custo/kg usado na Rentabilidade). Um lote que trocou de dieta aparece com uma linha por fórmula usada.

## Arquivos criados

- `app/Controllers/Admin/RelatorioController.php` — 4 métodos públicos + 5 helpers privados (`custoFormulaPorKg`, `racaoPorLotePorFormula`, `custoSanitarioPorLote`, `somarPorLote`)
- `app/Views/admin/relatorio/{rentabilidade,evolucao-peso,mortalidade,consumo-racao}.phtml`

## Rotas e Menu

- `routes/admin.php`: bloco "RELATORIOS" com 4 rotas GET (sem CRUD, são só leitura), inserido entre "SANITARIO - OCORRENCIAS" e "FORNECEDORES".
- `app/Services/Menu/AdminMenuDefinition.php`: novo dropdown "Relatórios" logo após "Painel" (topo do menu, para dar destaque), com os 4 itens.

## Testes realizados (curl, `RECAPTCHA_AUTH` temporariamente `false`, depois revertido)

Todos os 4 relatórios testados contra os dados reais já populados no sistema, com os cálculos conferidos manualmente:

- **Rentabilidade**: Lote 2026-001 — custo ração 495kg × R$1,22/kg (fórmula Crescimento) = R$603,90 ✓; custo sanitário R$925 (vacina no lote) + R$120 (vermífugo no animal BR001 do lote) = R$1.045,00 ✓ — **confirmado que o cálculo soma corretamente aplicações diretas no lote E em animais individuais pertencentes a ele**. Lote 2026-003 com venda parcial (5 de 40 cabeças): resultado R$24.500 − R$162.740 = **-R$138.240,00**, exibido corretamente como prejuízo (esperado, já que é uma venda parcial que não cobre o custo do lote inteiro).
- **Evolução de Peso**: GMD do Lote 2026-001 entre 01/05 (380kg) e 01/06 (420kg) = (420-380)/31 dias = **1,290 kg/dia**, batendo com o cálculo manual.
- **Mortalidade**: Lote 2026-002, 1 morte em 60 cabeças = 1,67%, valor estimado R$3.200,00 (R$192.000/60 × 1) ✓.
- **Consumo de Ração**: valores batem exatamente com os mesmos usados no cálculo de Rentabilidade (mesma fonte de dados, `fornecimento_trato`).

## Pendências conhecidas (não bugs, escopo consciente)

1. **Custo de mão de obra e outros centros de custo genéricos não entram no cálculo de Rentabilidade.** O sistema tem `centro_custo` como cadastro, mas nenhuma movimentação genérica de despesa está ligada a ele hoje (só `movimentacao_estoque` tem `id_centro_custo` opcional, raramente usado). Se o usuário quiser incluir mão de obra/manutenção/frete no custo do lote, precisa de uma nova fonte de dados — não foi pedido nesta rodada.
2. **Custo unitário é opcional e não retroativo** — ingredientes/produtos cadastrados antes desta migration ficam com `custo_unitario = NULL` até serem editados manualmente. Os relatórios tratam isso como custo 0, o que pode subestimar o total sem aviso visual explícito na tela (não há um alerta "X ingredientes sem custo cadastrado").
3. **Rentabilidade usa o custo/kg da fórmula ATUAL da composição**, não um snapshot histórico. Se o usuário editar a composição percentual de uma fórmula depois, o custo de rações já fornecidas no passado muda retroativamente no relatório (mesmo comportamento simplificado, aceitável para uma primeira versão, mas diferente do padrão "snapshot imutável" usado em Confecção de Ração).
4. Nenhum dos 4 relatórios tem exportação (PDF/Excel) nem filtro de período — mostra o histórico completo de cada lote.

## Roadmap após este checkpoint

Com Relatórios implementado, o sistema cobre: cadastros (4.1-4.7), movimentações de animais (5.1), movimentações de ração/nutrição (5.2), movimentações sanitárias (5.4), e agora relatórios gerenciais. Se houver um item "5.3" no escopo original do usuário que ainda não foi mencionado, ou se quiser mais relatórios (ex: fluxo de caixa, ranking de fornecedores, ocupação de curral), aguardando indicação.
