# Checkpoint — Reorganização de Cadastros + Limpeza de Escopo (2026-07-09)

Este checkpoint substitui e atualiza [checkpoint-confinamento-cadastros.md](checkpoint-confinamento-cadastros.md), que ficou desatualizado (os controllers descritos lá na raiz de `Controllers/Admin` foram movidos para subpastas por módulo).

## Contexto

O sistema foi clonado/adaptado de uma base de cartão-fidelidade/cashback (postos, comércio) para virar um sistema de **gestão de confinamento de gado**. O banco já foi promovido para produção e as migrations antigas foram apagadas — **a partir de agora todas as migrations SQL partem do zero**, começando em `storage/migrations/20260708_0027_*`.

## Estado atual do escopo (o que existe e funciona)

### Menu (`app/Services/Menu/AdminMenuDefinition.php`)

```
Painel
Clientes
  - Clientes
  - Situações
Fornecedores
  - Fornecedores
  - Situações
  - Ramos
Confinamento
  - Unidades
  - Currais
  - Piquetes
  - Locais de Estoque
Manejo
  - Animais
  - Lotes
  - Tipos de Entrada
  - Tipos de Saída
  - Motivos de Perda
Usuários
  - Usuários
  - Perfis de Acesso
```

Não existe mais "Cadastros" (Bancos/Bandeiras/Canais de Venda/Índices Financeiros) nem "Empresas" — eram órfãos/quebrados (tabelas inexistentes) e foram removidos.

### Módulo Cliente
- `app/Controllers/Admin/ClienteController.php` + `ClienteSituacaoController.php`
- Campos: PF/PJ, documento (CPF/CNPJ com busca automática), endereço com CEP, situação, importação por planilha.
- **Não tem mais Ramo** (Ramo foi movido para Fornecedor — ver abaixo). Não tem mais "Cartões" (era vínculo com o módulo Cartão, removido).
- Tabelas: `cliente`, `cliente_situacao`.

### Módulo Fornecedor
- `app/Controllers/Admin/FornecedorController.php` + `FornecedorSituacaoController.php` + `FornecedorRamoController.php`
- Espelha o Cliente: PF/PJ, documento, endereço, situação, importação por planilha, **+ Ramo** (campo que Cliente costumava ter).
- Ramos seedados pertinentes ao confinamento: Ração e Nutrição Animal, Insumos Veterinários, Genética e Reprodução, Transporte e Logística, Equipamentos e Máquinas, Combustíveis e Lubrificantes, Construção e Manutenção, Compra e Venda de Gado, Serviços Gerais.
- Tabelas: `fornecedor`, `fornecedor_situacao`, `fornecedor_ramo`.

### Módulo Confinamento (`app/Controllers/Admin/Confinamento/`)
- `UnidadeController`, `CurralController`, `PiqueteController`, `LocalEstoqueController`.
- Currais/Piquetes/LocalEstoque vinculados a Unidade (FK `id_unidade`).
- Tabelas: `unidade`, `curral`, `piquete`, `local_estoque`.
- Sem soft-delete, usa `ativo` (padrão diferente do Cliente/Fornecedor, que usam soft-delete com `trash`).

### Módulo Manejo (`app/Controllers/Admin/Manejo/`)
- `AnimalController` — identificação individual (brinco/RFID), vinculado a Lote, Fornecedor, Tipo de Entrada. **Opcional/complementar** — a maioria das operações não precisa cadastrar animal por animal.
- `LoteController` — unidade principal de manejo. Vinculado a Unidade + Curral/Piquete (opcionais). Tem uma tabela satélite **`lote_entrada`** (1:1, `App\Models\Manejo\LoteEntrada`) com `quantidade`, `peso_medio`, `peso_total`, `data_entrada` — agregados para controlar o lote **sem precisar cadastrar animal individual**. Essa tabela foi desenhada para depois virar a base do registro "Entrada de animais" do módulo de Movimentações (ver Roadmap abaixo), sem precisar migrar dado.
- `TipoEntradaController`, `TipoSaidaController`, `MotivoPerdaController` — cadastros de apoio simples (descrição + ativo).
- Tabelas: `animal`, `lote`, `lote_entrada`, `tipo_entrada`, `tipo_saida`, `motivo_perda`.

### Core (não mexer sem necessidade)
- Autenticação: `LoginController`, `Auth`, sessões.
- Usuários/Permissões: `UsuarioController`, `UsuarioPerfilController`, `UsuarioPreferenciaController`.
- `HomeController` — **foi reescrito** nesta sessão: antes tinha KPIs de recarga/cashback/fidelidade (dashboard de cartão), agora é uma home simples de boas-vindas sem KPIs. Dashboard de confinamento real (animais, lotes ativos, currais ocupados) ainda não foi feito — fica para quando o módulo de Movimentações existir e houver dado de verdade pra mostrar.

## Migrations aplicadas (em ordem, banco `sistema` local)

```
20260708_0027_create_fornecedor_base.sql           — tabelas fornecedor + fornecedor_situacao + permissões
20260708_0028_move_ramo_cliente_to_fornecedor.sql  — dropa cliente.id_ramo + cliente_ramo; cria fornecedor_ramo + seed
20260708_0029_create_zootecnia_base.sql            — tipo_entrada, tipo_saida, motivo_perda, lote, animal + seeds + permissões
20260708_0030_create_lote_entrada.sql              — tabela lote_entrada (agregados de quantidade/peso do lote)
20260709_0031_remove_permissoes_cartao_orfas.sql   — DELETE das 25 permissões órfãs (Cartões/Cashback/Configuações/Movimentações/Relatórios)
```

**Importante**: essas migrations ainda **não foram aplicadas em produção** — só no banco `sistema` local. Quando for a hora, aplicar todas em ordem no banco de produção.

## Limpeza de escopo feita em 2026-07-09

O usuário pediu para remover tudo que não pertence ao confinamento (cartão, cashback, fidelidade, movimentações financeiras, bancos, canais de venda, índices financeiros, empresas — módulos herdados do sistema de cartão-fidelidade original).

### O que foi removido (com backup)
Backup completo em **`_backup_limpeza_2026-07-09/`** na raiz do projeto — cópia de tudo antes de apagar, caso algo tenha sido classificado errado. Não é um repositório git, então esse backup é a única rede de segurança.

- **14 Controllers**: `CartaoController`, `CartaoBandeiraController`, `CartaoConfiguracaoController`, `CashbackRegraController`, `FidelidadeRegraController`, `RelatorioController`, `BancoController`, `CanalVendaController`, `IndiceFinanceiroController`, `EmpresaController`, `EmpresaResponsavelController`, `CronjobController` (Serviços — só tinha rotinas de vencimento de cartão), + 2 duplicados mortos (`UnidadeController.php`/`CurralController.php` soltos na raiz de `Controllers/Admin/`, nunca roteados).
- **11 Models**: `Cartao`, `CartaoBandeira`, `CashbackRegra`, `FidelidadeRegra`, `Movimentacao`, `Banco`, `CanalVenda`, `IndiceFinanceiro`, `IndiceFinanceiroHistorico`, `Empresa`, `EmpresaResponsavel`.
- **6 Enums órfãos**: `CartaoStatusEnum`, `MovimentacaoTipoEnum`, `MovimentacaoSentidoEnum`, `MovimentacaoOrigemEnum`, `CanalVendaTipo`, `PaymentMethod`.
- **Views**: pastas `cartao/`, `banco/`, `canal_venda/`, `cartao_bandeira/`, `indice_financeiro/`, `empresa/` inteiras + `cliente/cartoes.phtml` + 2 arquivos de backup esquecidos em `home/` (`.index.phtml`, `..index.phtml`).
- **Rotas**: bloco comentado morto de ~315 linhas (sistema ainda mais antigo: Grupos, DRE, Vendas, Estabelecimentos, Franqueados, Sindicatos, Intranet etc.) + todos os blocos ativos dos módulos removidos + rota `/cnpj` (`EstabelecimentoController` nem existia mais) + rota `/home/atalho/recarga`.
- **11 assets JS** órfãos (`cartao-form.js`, `banco-form.js`, `cashback-regra-form.js`, `dre-*.js`, `venda-geral.js`, `empresa-form.js` etc.)
- **25 permissões órfãs** no banco (`usuario_permissao`): grupos `Cartões`, `Cashback`, `Configuações`, `Movimentações`, `Relatórios`.

### O que foi refatorado (não apenas apagado)
- **`HomeController` + `home/index.phtml`**: removida toda dependência de `Cartao`/`Movimentacao`/`CartaoService`; virou home simples.
- **`ClienteController`**: removido método `cartoes()` (listava cartões vinculados ao cliente) e stubs mortos (`updateServico`, `historicoServico`, `editEmpresa`, `bloquear` — já eram avisos de "não migrado", sem uso real). Helpers órfãos (`shortValue`, `statusBadge`, `moneyBR`) também removidos. View `cliente/lista.phtml` sem a coluna "Cartões".

### Achados incidentais durante a limpeza (documentados, não necessariamente resolvidos)
- `Empresa`/`EmpresaResponsavel` apontavam para tabelas que **não existiam** no banco — já estavam quebrados antes desta limpeza.
- `Banco`, `CanalVenda`, `IndiceFinanceiro*`, `CartaoBandeira`, `CartaoConfiguracao` — mesma situação, tabelas inexistentes.
- `Configuracao.php` (model) e `ApiClient.php` foram **mantidos** por decisão do usuário ("manter por segurança"), mesmo sem uso ativo identificado.
- `proposta.min.css` em `public/assets/admin/` não é referenciado em nenhuma view — órfão não relacionado a cartão, não removido (fora do escopo pedido).

## Decisões e preferências do usuário (importante para continuidade)

1. **Ramo pertence a Fornecedor, não a Cliente.** Foi removido de Cliente e recriado do zero em Fornecedor com ramos pertinentes ao agronegócio.
2. **Menu "Confinamento" é seção própria**, separada de qualquer "Cadastros" genérico.
3. **Nomes de permissão devem ser curtos** ("Gerenciar", "Editar", "Inserir", "Excluir") — o agrupamento/grupo já dá o contexto na tela de perfis. Não repetir o nome do módulo na descrição (ex.: nunca "Editar Fornecedores", só "Editar").
4. **Lote usa controle agregado (quantidade/peso), não exige animal individual.** Motivo do usuário: "seria difícil controlar isso individualmente" com centenas de cabeças. Animal continua existindo como opção para quem faz rastreio por brinco/RFID.
5. **`lote_entrada` é tabela separada de `lote`** por decisão deliberada — para não colidir com o futuro histórico de pesagens (inicial/intermediária/final) do módulo de Movimentações.
6. **Banco de produção já subiu** — não mexer em dados de produção sem confirmação explícita. Migrations locais ainda não foram replicadas lá.
7. **Projeto não é repositório git** — sem rede de segurança de `git revert`. Por isso o padrão desta sessão foi sempre fazer backup em pasta (`_backup_limpeza_2026-07-09/`) antes de deletar algo em operações grandes.
8. **Teste sempre via navegador/curl real**, nunca só `php -l`. O login usa reCAPTCHA v3 que bloqueia automação — o padrão usado nesta sessão foi: setar `RECAPTCHA_AUTH=false` no `.env` temporariamente, testar via curl com cookies de sessão, e **sempre reverter para `true`** ao final. O cache de menu/permissões por usuário (`storage/cache/menu_admin_usuario_<id>.txt` e `dcf_admin_usuario_permissoes_<id>.txt`) precisa ser apagado manualmente sempre que o menu ou as permissões mudam — não invalida sozinho.
9. **URL do ambiente local**: `https://confinamento.local/` (vhost Laragon, DocumentRoot é a raiz do projeto, não `public/`). Login: `admin` / `@admin`.

## Roadmap confirmado com o usuário (ainda não implementado)

O usuário descreveu o próximo módulo grande como **"Movimentações"** (seção 5.1 do documento de escopo dele), com os seguintes eventos — ele pediu para eu avaliar quais fazem sentido implementar:

- **Entrada de animais**: chegada ao confinamento — origem, documentos, quantidade, peso, valores, curral de destino.
- **Formação de lote**: criação do lote inicial a partir de compra/agrupamento.
- **Alocação em curral**: define curral onde o lote fica.
- **Transferência entre currais**: muda local do lote (ou parte dele), com histórico e motivo.
- **Pesagem inicial, intermediária e final**: acompanhar peso, GMD (ganho médio diário), ponto de saída.
- **Troca de dieta**: mudança de fórmula conforme fase/leitura de cocho/estratégia técnica.
- **Saída/venda/abate**: baixa com quantidade, peso, resultado.
- **Mortalidade/perda**: baixa técnica com causa (usa `motivo_perda`, já cadastrado) e responsável.

Também mencionado e **ainda não criado**: **Centro de Custo** (classificar gastos: alimentação, sanidade, frete, mão de obra, manutenção) — usuário disse "deixar para depois".

O usuário disse: *"por hora somente essa [tabela lote_entrada]... dps vou publicar a parte de cadastros e te aviso para continuar. Vê as movimentações dessa lista que são pertinentes."* — ou seja, a próxima sessão deve **aguardar o aviso do usuário** antes de iniciar o módulo de Movimentações, e quando começar, avaliar/priorizar quais desses 8 eventos implementar primeiro (provavelmente Entrada de Animais + Pesagens, dado que `lote_entrada` já foi desenhada pensando nisso).

## Arquivos-chave para orientação rápida

- Menu: [app/Services/Menu/AdminMenuDefinition.php](app/Services/Menu/AdminMenuDefinition.php)
- Rotas: [routes/admin.php](routes/admin.php), [routes/servicos.php](routes/servicos.php)
- Padrão de Controller CRUD simples: [app/Controllers/Admin/Confinamento/CurralController.php](app/Controllers/Admin/Confinamento/CurralController.php)
- Padrão de Controller CRUD completo (PF/PJ): [app/Controllers/Admin/FornecedorController.php](app/Controllers/Admin/FornecedorController.php)
- Padrão de Lote (com tabela satélite 1:1): [app/Controllers/Admin/Manejo/LoteController.php](app/Controllers/Admin/Manejo/LoteController.php)
- Migrations: [storage/migrations/](storage/migrations/) (a partir de `20260708_0027`)
- Backup da limpeza: `_backup_limpeza_2026-07-09/` (raiz do projeto)

## Próximo passo recomendado

Aguardar o usuário publicar a parte de cadastros em produção e avisar para continuar. Quando retomar: iniciar o módulo de Movimentações, priorizando Entrada de Animais e Pesagens (que já têm a base de dados parcialmente pronta via `lote_entrada`), e confirmar com o usuário o desenho de tabelas antes de criar (padrão desta sessão: sempre perguntar antes de estruturar dados que podem colidir com histórico futuro).
