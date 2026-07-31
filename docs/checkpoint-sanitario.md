# Checkpoint — Módulo Sanitário (2026-07-09)

Continuação de [checkpoint-estoque-pendentes.md](checkpoint-estoque-pendentes.md). Implementa o escopo **5.4 Movimentações sanitárias**: Aplicação de Protocolo, Tratamento Individual, Tratamento em Lote, Registro de Ocorrência, Controle de Carência e Baixa de Medicamento.

## Decisões de arquitetura (confirmadas com o usuário antes de implementar)

1. **Protocolo Sanitário é um cadastro formal**, não texto livre — tabela `protocolo_sanitario` com nome, produto padrão (opcional, `id_produto_estoque`) e `dias_carencia_padrao`.
2. **Aplicação de Protocolo, Tratamento Individual e Tratamento em Lote foram unificados** numa única tabela `aplicacao_sanitaria`, com um campo `tipo` ENUM (`PROTOCOLO`/`TRATAMENTO_INDIVIDUAL`/`TRATAMENTO_LOTE`) para diferenciar — em vez de 3 tabelas quase idênticas. Mesmo padrão de vínculo já usado em `movimentacao_pesagem`: `id_lote` OU `id_animal`, nunca os dois.
3. **Controle de carência bloqueia ativamente** a tela de Saída (não é só alerta visual) — `SaidaController::create()`/`update()` rejeita o registro se houver carência vigente na data da saída.
4. **Baixa de medicamento é automática**, sem tela própria — embutida na criação da Aplicação Sanitária, mesmo padrão já usado em Confecção de Ração e Movimentação de Estoque.

## Migration aplicada (na base local `sistema`)

[storage/migrations/20260709_0041_create_sanitario.sql](../storage/migrations/20260709_0041_create_sanitario.sql) — `protocolo_sanitario`, `aplicacao_sanitaria`, `ocorrencia_sanitaria` + 12 permissões.

**Ainda não aplicada em produção** — mesmo estado das migrations anteriores (0034-0040). **Aplicar sempre com `--default-character-set=utf8mb4`** (ver nota no `storage/migrations/README.md`, adicionada após o bug de encoding da rodada anterior).

## Tabelas

| Tabela | Papel |
|---|---|
| `protocolo_sanitario` | Cadastro: nome, produto padrão opcional, dias de carência padrão |
| `aplicacao_sanitaria` | Unifica os 3 tipos de aplicação. Campos-chave: `id_lote`/`id_animal` (exclusivos), `id_protocolo_sanitario` (opcional), `id_produto_estoque`/`id_lote_estoque`, `tipo`, `quantidade_produto`, `dias_carencia`, **`data_carencia_fim` (calculada)** |
| `ocorrencia_sanitaria` | Eventos livres: `id_lote`/`id_animal` (exclusivos), descrição, `gravidade` ENUM (LEVE/MODERADA/GRAVE), responsável |

### Cálculo de carência

Em `AplicacaoSanitariaController::normalizarPayload()`:
1. Se `dias_carencia` não foi informado manualmente e há um protocolo selecionado, herda `protocolo_sanitario.dias_carencia_padrao`.
2. `data_carencia_fim = data_aplicacao + dias_carencia` (calculada e persistida, não recalculada em runtime — mesma filosofia do GMD em Pesagem: nunca fica desatualizada porque não depende de leitura futura).

### Bloqueio de carência na Saída

`SaidaController::carenciaVigente(int $idLote, string $dataSaida)`: busca em `aplicacao_sanitaria` (com `LEFT JOIN animal`) qualquer registro com `data_carencia_fim >= data_saida` vinculado **diretamente ao lote OU a qualquer animal pertencente a ele** (via `whereRaw("(aps.id_lote = ? OR a.id_lote = ?)", [...])`, já que o query builder do projeto não suporta agrupamento por closure — só `where`/`orWhere` diretos e `whereRaw` com bindings). Se encontrar, rejeita com mensagem informando a data exata de liberação.

### Baixa/estorno de estoque

Mesmo padrão de Confecção de Ração/Movimentação de Estoque: ao criar uma aplicação com produto informado, debita `produto_estoque.saldo_atual` (e `lote_estoque.quantidade_atual` se aplicável) na hora; ao excluir, estorna antes de apagar. Se o produto tem `controla_lote = 1`, exige `id_lote_estoque` — senão rejeita com mensagem clara.

**Mesma limitação deliberada de Confecção de Ração/Movimentação de Estoque:** `edit()`/`update()` de Aplicação Sanitária só permite alterar `observacao`. Para corrigir vínculo/quantidade/produto, o caminho é excluir (estorna) e recriar.

## Arquivos criados

**Models** (`app/Models/Sanitario/`): ProtocoloSanitario, AplicacaoSanitaria (com `tipoLabel()` estático), OcorrenciaSanitaria.

**Controllers** (`app/Controllers/Admin/Sanitario/`): ProtocoloSanitarioController, AplicacaoSanitariaController, OcorrenciaSanitariaController.

**Views** (`app/Views/admin/sanitario/`): 7 arquivos — `index.phtml` + `form.phtml` para Protocolo e Ocorrência, mais `index.phtml` + `form.phtml` + `visualizar.phtml` para Aplicação (não editável livremente, mesma razão de Confecção/Movimentação).

**Modificado**: `app/Controllers/Admin/Manejo/SaidaController.php` — adicionado `carenciaVigente()` e chamadas em `create()`/`update()`.

**Rotas**: bloco "SANITARIO - ..." com 3 grupos de 6 rotas cada, inserido entre "PESSOAS - FUNCIONARIOS" e "FORNECEDORES".

**Menu**: nova seção de título "Sanitário" com dropdown "Sanitário" (Protocolos, Aplicações, Ocorrências), posicionada entre Nutrição (Trato e Cocho) e Estoque.

**Permissões**: 12 novas (3 módulos × gerenciar/inserir/editar/excluir), agrupamento "Sanitário". Concedidas ao perfil Administrador e ao usuário `admin`.

## Testes realizados (curl, `RECAPTCHA_AUTH` temporariamente `false`, depois revertido)

- Todas as 6 páginas (3 índices + 3 "novo") retornam 200 sem erro.
- Fluxo completo: Protocolo "Vacinação Febre Aftosa" (carência padrão 21 dias) → Aplicação em Lote (50 cabeças, produto com controle de lote) → **confirmado carência calculada certa (01/07 + 21 dias = 22/07/2026)** e **estoque debitado corretamente (200→150, produto e lote de estoque)**.
- **Bloqueio de Saída**: tentativa de saída do mesmo lote em data dentro da carência foi **rejeitada** com mensagem exata "Este lote possui aplicação sanitária com carência vigente até 22/07/2026...". Saída um dia após o fim da carência foi aceita normalmente.
- Exclusão da aplicação → **confirmado estorno correto** (voltou a 200/200).
- Validação de vínculo: tentativa de `TRATAMENTO_INDIVIDUAL` com `id_lote` (sem `id_animal`) foi corretamente rejeitada.
- Tratamento individual válido (produto sem controle de lote) → baixa direta confirmada (5000→4990).
- Ocorrência Sanitária criada e listada corretamente, com badge de gravidade.
- Dados de teste de validação removidos ao final; depois populados dados de teste definitivos (2 protocolos, 3 aplicações, 2 ocorrências) com datas de carência já vencidas para não travar testes futuros de Saída na data atual — script salvo em `storage/migrations/seed-dados-teste-sanitario.sql`.

## Pendências conhecidas (não bugs, escopo consciente)

1. **Edição de Aplicação Sanitária** limitada a observação — caminho é excluir/recriar, mesma limitação já documentada para Confecção de Ração e Movimentação de Estoque.
2. O bloqueio de carência na Saída considera **apenas o lote inteiro e seus animais individuais** — não há bloqueio granular por "só os N animais que receberam a aplicação" dentro de uma saída parcial de lote. Se o usuário vender parte do lote, o sistema bloqueia a saída inteira até a carência vencer, mesmo que os animais vendidos especificamente não tenham recebido o produto.
3. Não há automação para popular `quantidade_animais` a partir do total de cabeças do lote — é digitado manualmente na aplicação.

## Roadmap após este checkpoint (2026-07-09)

Com o módulo Sanitário implementado, o escopo 5.1 (Movimentações de Animais), 5.2 (Movimentações de Ração e Nutrição) e 5.4 (Movimentações Sanitárias) estão completos. Não foi mencionado um item 5.3 pelo usuário até o momento — se existir no escopo original, precisa ser levantado numa próxima rodada.

---

# Checkpoint 2 — Cadastros Sanitários + Reorganização (2026-07-11/12)

Continuação direta do checkpoint acima. Escopo: avaliar 7 cadastros sanitários que o usuário listou (Medicamentos, Vacinas, Produtos veterinários, Protocolos sanitários, Tipos de aplicação, Doenças/ocorrências, Motivos de tratamento), decidir o que já existia vs. o que faltava, e organizar o módulo antes de ir pra produção definitiva.

## Decisão de arquitetura: NÃO fragmentar produto_estoque

Usuário perguntou explicitamente se compensava separar Medicamento/Vacina/Produto Veterinário em tabelas próprias. **Recusado** — duplicaria toda a lógica de estoque já existente (baixa automática, lote/validade, custo unitário usado em Rentabilidade, estoque mínimo usado no alerta do Dashboard).

**Solução escolhida** (sugerida pelo próprio usuário): enum interno `tipo_produto` em `produto_estoque`, usado para (a) filtrar/separar telas sem duplicar cadastro, (b) mostrar campos específicos condicionalmente. Nomenclatura pedida "a mais completa e padrão possível" do setor agropecuário/veterinário.

**Valores do enum `tipo_produto`** (7, confirmados com o usuário): `RACAO_INSUMO`, `MEDICAMENTO`, `VACINA`, `SUPLEMENTO`, `MATERIAL_CONSUMO`, `COMBUSTIVEL_LUBRIFICANTE`, `OUTRO`. Default `OUTRO`.

**`ProdutoEstoque::TIPOS_SANITARIOS`** (const no Model) = `["MEDICAMENTO", "VACINA", "SUPLEMENTO"]` — esses 3 tipos liberam os campos extras e alimentam a tela filtrada "Medicamentos e Vacinas".

## O que já existia vs. o que foi criado

Do levantamento dos 7 itens que o usuário listou:
- **Já existia** (checkpoint 1): Protocolos Sanitários, Aplicações Sanitárias (cobre "vacinas"/"medicamentos" como eventos), Ocorrências Sanitárias (cobre "doenças/ocorrências").
- **Resolvido via enum, sem tabela nova**: Medicamentos, Vacinas, Produtos veterinários → viraram `tipo_produto` em `produto_estoque`.
- **Criados do zero** (não existiam): **Tipos de Aplicação** (via/forma de administração — intramuscular, subcutânea, oral, pour-on, tópica, intravenosa, intranasal) e **Motivos de Tratamento** (causa do tratamento — vacinação de rotina, reforço vacinal, vermifugação, tratamento clínico, prevenção, suplementação, outro).

**Atenção**: Motivo de Tratamento é semanticamente diferente de `motivo_perda` (módulo Manejo, usado em mortalidade/óbito) — não reaproveitar, são conceitos distintos mesmo com nomes parecidos.

## Migrations aplicadas (base local `sistema`)

1. [storage/migrations/20260711_0001_add_tipo_produto_e_campos_sanitarios.sql](../storage/migrations/20260711_0001_add_tipo_produto_e_campos_sanitarios.sql) — adiciona `tipo_produto` (enum), `principio_ativo`, `apresentacao`, `fabricante` em `produto_estoque` + índice. Inclui `UPDATE`s de auto-classificação por `LIKE` no nome para os produtos de teste já existentes.
2. [storage/migrations/20260711_0002_create_tipo_aplicacao_motivo_tratamento.sql](../storage/migrations/20260711_0002_create_tipo_aplicacao_motivo_tratamento.sql) — cria `tipo_aplicacao` e `motivo_tratamento` (padrão "cadastro simples": id + descricao UNIQUE + auditoria, sem `ativo`), com 7 seeds cada; adiciona `id_tipo_aplicacao`/`id_motivo_tratamento` (FKs opcionais, `ON DELETE SET NULL`) em `aplicacao_sanitaria`; 8 permissões novas (`tipo_aplicacao_*`, `motivo_tratamento_*`).
3. [storage/migrations/20260712_0001_unificar_grupo_permissoes_relatorios.sql](../storage/migrations/20260712_0001_unificar_grupo_permissoes_relatorios.sql) — não é do Sanitário, é de Relatórios: unifica o `grupo` das 6 permissões `relatorio_*_visualizar` (estavam espalhadas em 5 `grupo`s diferentes, gerando 5 cards na tela de permissões de usuário/perfil) para um único `grupo = 'relatorios'`, e remove o prefixo "Visualizar" das descrições (ficaram redundantes dentro de 1 card só).

**Todas as 3 já aplicadas na base local.** Ainda não aplicadas em produção — aplicar sempre com `mysql -u root sistema --default-character-set=utf8mb4 < arquivo.sql`, na ordem acima.

## Instrução permanente sobre migrations (importante para próximas sessões)

O histórico de migrations anteriores a 2026-07-11 (18 arquivos + README.md) foi **apagado** de `storage/migrations/` a pedido do usuário, porque a base de produção já tinha sido migrada com todo esse histórico — só ficaram os 3 seeds de dados de teste. **Isso foi limpeza pontual, não uma mudança de processo.** A partir de 2026-07-11 em diante, **toda alteração de schema continua exigindo uma nova migration `.sql`** em `storage/migrations/`, para o usuário aplicar manualmente em produção. Nunca pular esse passo.

## Arquivos criados

**Models** (`app/Models/Sanitario/`): `TipoAplicacao`, `MotivoTratamento` — ambos mínimos (`$table`, `$alias`, `$uppers = ["descricao"]`, `$required = ["descricao"]`), seguindo exatamente o molde de `MotivoPerda`.

**Controllers** (`app/Controllers/Admin/Sanitario/`): `TipoAplicacaoController`, `MotivoTratamentoController` — CRUD modal padrão (index/new/create/edit/update/delete), idêntico a `MotivoPerdaController`.

**Views** (`app/Views/admin/sanitario/`): `tipo-aplicacao/{index,form}.phtml`, `motivo-tratamento/{index,form}.phtml` — modal Bootstrap com AJAX GET para carregar o form e POST nativo (full reload) para salvar, replicando `motivo-perda/{index,form}.phtml` + JS companion.

**JS**: `public/assets/admin/js/tipo-aplicacao-form.js`, `motivo-tratamento-form.js` — só registram `uppers("descricao")` via `window.registerAjaxModalInitializer`, mesmo padrão de `motivo-perda-form.js`.

## Arquivos modificados

**`app/Models/Estoque/ProdutoEstoque.php`**: adicionado `tipo_produto` a `$required`; const `TIPOS_SANITARIOS`; método estático `tipoProdutoLabel(string $tipo): string`.

**`app/Controllers/Admin/Estoque/ProdutoEstoqueController.php`**:
- Constructor agora lê `$_GET["sanitarios"]` diretamente (não dá pra usar `Request` injetado, o construtor roda antes — **usar `$_GET` é a solução aceita aqui**, não um workaround a corrigir) para definir `title`/`active_menu`/`page` dinamicamente conforme é a tela "Produtos de Estoque" normal ou a "Medicamentos e Vacinas" filtrada.
- `index()`: aceita `?sanitarios=1`, filtra via `whereIn("pe.tipo_produto", ProdutoEstoque::TIPOS_SANITARIOS)`, calcula `tipo_produto_label` por linha.
- `new()`: aceita `?tipo_produto=` (sugestão vinda de outro fluxo, pré-seleciona no form).
- `create()`/`update()`: validam `tipo_produto` como obrigatório (mensagem "Informe o tipo do produto").
- `normalizarPayload()`: `nullIfEmpty` em `principio_ativo`, `apresentacao`, `fabricante`.

**`app/Views/admin/estoque/produto-estoque/form.phtml`**: select "Tipo do Produto" (7 opções) + seção "Dados Sanitários" (Princípio Ativo, Apresentação, Fabricante) que só aparece via JS quando o tipo selecionado é MEDICAMENTO/VACINA/SUPLEMENTO (toggle em `<script>` no fim do arquivo, `id="secao-dados-sanitarios"`).

**`app/Views/admin/estoque/produto-estoque/index.phtml`**: nova coluna "Tipo" com badge (`tipo_produto_label`).

**`app/Controllers/Admin/Sanitario/AplicacaoSanitariaController.php`**:
- `produtos()` agora filtra por `whereIn("tipo_produto", ProdutoEstoque::TIPOS_SANITARIOS)` — só Medicamento/Vacina/Suplemento aparecem no select de "Produto Usado".
- Novos helpers `tiposAplicacao()`/`motivosTratamento()`, passados pro form.
- `normalizarPayload()`: `nullIfEmpty` em `id_tipo_aplicacao`/`id_motivo_tratamento`.
- `edit()`: carrega `TipoAplicacao`/`MotivoTratamento` por id pra exibir a descrição (não só o id) na tela de visualização.

**`app/Views/admin/sanitario/aplicacao-sanitaria/form.phtml`**: 2 selects novos (Via de Aplicação, Motivo do Tratamento), ambos opcionais, `select2`.

**`app/Views/admin/sanitario/aplicacao-sanitaria/visualizar.phtml`**: 2 campos readonly novos mostrando as descrições.

**`routes/admin.php`**: 12 rotas novas (6 para `tipo-aplicacao`, 6 para `motivo-tratamento`), inseridas antes do bloco RELATORIOS. Nenhuma rota nova para "Medicamentos e Vacinas" — reaproveita `admin.estoque.produto.index` com querystring.

**`app/Services/Menu/AdminMenuDefinition.php`**: seção "Sanitário" **separada em 2 dropdowns** (pedido do usuário: "separe os cadastros do sanitario no sidebar") — `sanitarioCadastrosItems` (Medicamentos e Vacinas, Tipos de Aplicação, Motivos de Tratamento) vira dropdown **"Cadastros"**, e `sanitarioItems` (Protocolos, Aplicações, Ocorrências) continua no dropdown **"Sanitário"**, ambos sob o mesmo `title("Sanitário")`. Mesmo padrão já usado em Manejo (Cadastros/Movimentações) e Nutrição (Cadastros/Trato e Cocho). O link de "Medicamentos e Vacinas" usa `route_params => ["sanitarios" => 1]` (chave suportada nativamente por `MenuBuilder::resolveRoute()` — vira querystring automaticamente pra qualquer param que não bate com um `{placeholder}` da rota).

## Reorganização de permissões de Relatórios (fora do módulo Sanitário, mesma sessão)

Pedido do usuário: "os relatorios... faça todos em um grupo só" — não era sobre o menu (que já agrupava tudo num dropdown), era sobre a **tela de permissões de usuário/perfil**: `UsuarioPermissaoService::grouped()` agrupa por `(agrupamento, grupo)`, e cada `grupo` distinto vira **um card separado** (`div.permission-block`) em `usuario/editar.phtml` e `perfil/editar.phtml`. As 6 permissões `relatorio_*_visualizar` tinham `grupo` diferentes (`rentabilidade`, `evolucao_peso`, `mortalidade`, `consumo_racao`, `relatorios`), gerando 5 cards. Unificado tudo em `grupo = 'relatorios'` → migration 3 acima. Depois removido o prefixo "Visualizar" das descrições (pedido separado do usuário) — só o nome do relatório fica (`"Rentabilidade por Lote"`, `"Consumo de Ração"` etc.).

**Padrão a lembrar**: se o usuário pedir pra "juntar"/"separar" permissões visualmente na tela de perfil, é sempre o campo `grupo` que precisa mudar, nunca `agrupamento` (que só define o título de seção `<h1>`, não o card).

## Tutorial atualizado

Artifact publicado (URL estável, reutilizar em vez de criar novo): `https://claude.ai/code/artifact/28191668-e445-406c-a5ff-423995a89108` — "Manual do Sistema — Confinamento". Fonte de trabalho fica em `C:\Users\DIZ\AppData\Local\Temp\claude\c--laragon-www-confinamento\<session>\scratchpad\tutorial-final.html` (esse path muda a cada sessão nova — **procurar pelo artifact publicado via `Artifact({action:"list"})` em vez de assumir o path**, e reconstruir a partir da URL se o arquivo local não existir mais).

Estrutura do tutorial: 16 seções numeradas (`<h2>`), TOC lateral (`<nav class="toc">` com `<a href="#id">`), cada tela é um `<article class="screen">` com `<h3>` + `<span class="path">` (rota) + opcionalmente `<figure class="shot"><img>` (screenshot em base64) + `<p>` + `<div class="callout tip|warn">`. Pares de tela cabem em `<div class="grid-2">`. Seção nova "12. Cadastros do Sanitário" criada seguindo esse padrão; "13. Sanitário" e "11. Estoque" (Novo Produto) atualizadas com o novo conteúdo; todas as seções seguintes renumeradas.

**Pendência**: os 3 artigos novos (Medicamentos e Vacinas, Tipos de Aplicação, Motivos de Tratamento) **não têm screenshot** — não havia CDP/browser logado disponível nesta sessão. Texto está completo; se o usuário pedir para completar com capturas de tela, isso precisa de uma sessão com Chrome CDP ativo e login manual (não dá pra pegar a senha do admin do banco — bloqueado pelo classificador de segurança).

## Testes realizados

- `php -l` em todos os arquivos PHP/phtml novos e modificados — sem erros de sintaxe.
- HTTP smoke test via curl contra `https://confinamento.local` (domínio real do Laragon, **não** `/admin` — as rotas ficam na raiz, ex. `/sanitario/tipos-aplicacao`, não `/admin/sanitario/...`): todas as rotas novas retornam 302 (redirect de login), igual à rota `home` já existente — confirma que não há 500/fatal error e que as rotas foram registradas corretamente.
- **Não foi feito teste logado via browser** (sem CDP nesta sessão) — validação ficou em nível de rota/sintaxe, não de fluxo funcional completo. Se algo especificamente visual/JS quebrar (ex. o toggle de `secao-dados-sanitarios`), ainda não foi confirmado com os próprios olhos.
- `RECAPTCHA_AUTH=false` no `.env` — **instrução permanente do usuário, não reverter nunca mais** (evita ele ter que desabilitar toda hora pra testar).

## Pendências conhecidas para próxima rodada

1. Screenshots faltando no tutorial para as 3 telas novas (ver seção "Tutorial atualizado" acima).
2. Teste funcional logado via browser real ainda não feito nesta rodada — vale confirmar visualmente o toggle JS do form de Produto e o fluxo completo de Nova Aplicação Sanitária com os 2 selects novos.
3. Migrations 1, 2 e 3 desta rodada (`20260711_0001`, `20260711_0002`, `20260712_0001`) ainda **não aplicadas em produção** — usuário aplica manualmente quando for fazer o deploy.
