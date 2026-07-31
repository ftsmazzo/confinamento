# Checkpoint — Módulo de Movimentações (2026-07-09)

Continuação de [checkpoint-confinamento-limpeza.md](checkpoint-confinamento-limpeza.md). Aquele documento cobre até a limpeza de escopo (remoção de cartão/cashback/etc.); este cobre o início do módulo de **Movimentações de Animais** (item 5.1 do escopo do usuário).

## Contexto

O usuário descreveu 8 eventos de movimentação:

1. Entrada de animais
2. Formação de lote
3. Alocação em curral
4. Transferência entre currais
5. **Pesagem inicial, intermediária e final** ← implementado nesta rodada
6. Troca de dieta
7. Saída / venda / abate
8. Mortalidade / perda

Decisão de arquitetura (confirmada com o usuário): **uma tabela por tipo de evento**, não uma tabela genérica de log com JSON. Cada evento novo = uma migration + Model + Controller + Views próprios, seguindo o padrão já estabelecido no projeto (ver `Manejo\LoteController` como referência de controller "rico" e `Manejo\TipoEntradaController` como referência de controller simples).

Prioridade escolhida pelo usuário: **Pesagem primeiro**, por ser o evento mais frequente na operação real e já ter base pronta (`lote_entrada` já guardava peso de entrada).

## O que foi implementado: Pesagem

### Tabela `movimentacao_pesagem`
Migration: [storage/migrations/20260709_0032_create_movimentacao_pesagem.sql](../storage/migrations/20260709_0032_create_movimentacao_pesagem.sql)

```
id, id_lote (nullable), id_animal (nullable), tipo (ENUM INICIAL/INTERMEDIARIA/FINAL),
data_pesagem, quantidade (nullable), peso_medio, peso_total (nullable),
observacao, created_by/at, updated_by/at
```

Decisões de desenho:
- **Suporta Lote (agregado) OU Animal individual** — campos `id_lote`/`id_animal` são ambos nullable, mas a aplicação garante que **exatamente um** dos dois está preenchido (nunca os dois, nunca nenhum). Um `CHECK constraint` foi tentado no MySQL mas **não é permitido** quando a coluna já participa de uma FK com `ON DELETE CASCADE` (erro 3823) — a regra é validada só na aplicação, em `PesagemController::validarVinculoEDados()`.
- `tipo` é `ENUM` de 3 valores, escolhido manualmente pelo usuário ao registrar (não é inferido automaticamente pela ordem cronológica).
- **GMD (ganho médio diário) não é persistido** — é calculado em tempo de leitura (`MovimentacaoPesagem::calcularGmd()`), comparando cada pesagem com a anterior do mesmo lote/animal. Isso evita que o GMD fique desatualizado se uma pesagem antiga for corrigida depois.
- FK com `ON DELETE CASCADE` em ambas (`id_lote`, `id_animal`): apagar um lote ou animal apaga o histórico de pesagens dele junto.

### Permissões
`pesagem_gerenciar`, `pesagem_inserir`, `pesagem_editar`, `pesagem_excluir` — agrupamento "Manejo", grupo "pesagens".

### Arquivos criados
- [app/Models/Manejo/MovimentacaoPesagem.php](../app/Models/Manejo/MovimentacaoPesagem.php) — Model + método estático `calcularGmd(pesoAnterior, dataAnterior, pesoAtual, dataAtual): ?float`
- [app/Controllers/Admin/Manejo/PesagemController.php](../app/Controllers/Admin/Manejo/PesagemController.php)
- [app/Views/admin/manejo/pesagem/index.phtml](../app/Views/admin/manejo/pesagem/index.phtml) — listagem com coluna de GMD calculado, badge verde/vermelho conforme sinal
- [app/Views/admin/manejo/pesagem/form.phtml](../app/Views/admin/manejo/pesagem/form.phtml)

### Rotas (`routes/admin.php`, bloco "MANEJO - PESAGENS")
```
GET  /manejo/pesagens                    admin.manejo.pesagem.index   (aceita ?id_lote= ou ?id_animal=)
GET  /manejo/pesagens/novo               admin.manejo.pesagem.novo    (aceita ?id_lote= ou ?id_animal=)
GET  /manejo/pesagens/editar/{id}        admin.manejo.pesagem.editar
POST /manejo/pesagens/insert             admin.manejo.pesagem.insert
POST /manejo/pesagens/update             admin.manejo.pesagem.update
GET  /manejo/pesagens/delete/{id}        admin.manejo.pesagem.delete
```

### Menu
Item "Pesagens" adicionado ao dropdown "Manejo", logo após "Lotes".

### Integração com Lote e Animal
Nas listagens (`manejo/lote/index.phtml` e `manejo/animal/index.phtml`), cada linha agora tem um botão de ação **"Pesagens"** (ícone `uil-weight`) que leva para `admin.manejo.pesagem.index` filtrado por aquele lote/animal específico (`?id_lote=X` ou `?id_animal=X`). Esse botão aparece sempre (não depende de permissão editar/excluir), então a coluna de ações nessas duas telas deixou de ser condicional.

### Fluxo da tela
- `PesagemController::index()` — se vier `id_lote` ou `id_animal` na querystring, filtra e ajusta breadcrumb/contexto. Sem filtro, lista tudo (mais recentes primeiro).
- `PesagemController::new()` — se vier o contexto (`id_lote`/`id_animal`), o formulário mostra um alerta informativo e um campo hidden (não dá pra trocar o vínculo). Sem contexto, mostra dois `<select>` (Lote e Animal) e o usuário escolhe um dos dois.
- O campo "Quantidade Pesada" só aparece no form quando o vínculo é com Lote (não faz sentido para animal individual).

## Bug encontrado e corrigido: `Data::empty()` nunca funciona

Durante o teste, o campo `id_lote` vindo da querystring não chegava na view mesmo estando presente no `$_GET`. Causa raiz, documentada aqui porque **não é óbvia e pode se repetir em código futuro**:

A classe `App\Core\Data` (`app/Core/Data.php`) implementa `__get($name)` para expor os campos do request como propriedades virtuais (`$data->id_lote`), mas **não implementa `__isset($name)`**.

Em PHP, `empty($obj->prop)` e `isset($obj->prop)` **chamam `__isset()`, não `__get()`**, quando a propriedade não é uma propriedade real/pública da classe. Sem `__isset()` definido, o PHP assume que a propriedade não existe e:
- `isset($data->campo)` → sempre `false`
- `empty($data->campo)` → sempre `true`

mesmo que `$data->campo` (acesso direto, que usa `__get()`) retorne um valor perfeitamente válido.

**Prova mínima:**
```php
class Foo {
    private array $data = ["x" => "3"];
    public function __get($name) { return $this->data[$name] ?? null; }
}
$f = new Foo();
var_dump($f->x);           // string(1) "3"  <- __get funciona
var_dump(empty($f->x));    // bool(true)     <- ERRADO, deveria ser false
```

**Regra prática para todo código futuro que usa `App\Core\Data`:** nunca escrever `empty($data->campo)` ou `isset($data->campo)`. Sempre usar `$data->has("campo")` (método real da classe, funciona corretamente) ou comparar o valor direto: `$data->campo !== null && $data->campo !== ""`.

Isso **não afeta** `App\Core\Model` (Cliente, Lote, Curral etc.) — essa classe **tem** `__isset()` implementado corretamente (`app/Core/Model.php:49`), então `empty($cliente->nome)` e similares sempre funcionaram e continuam funcionando normalmente. O bug é exclusivo da classe `Data`, usada para ler `$request->all()` nos métodos de controller.

Vale considerar, numa sessão futura, adicionar `__isset()` à classe `Data` para eliminar essa armadilha de vez (em vez de depender de todo mundo lembrar de usar `->has()`), mas isso é uma mudança no core compartilhado por todos os controllers — não foi feita agora para não arriscar efeito colateral em código existente sem alinhar com o usuário primeiro.

## Testado

Via curl autenticado (mesmo padrão de sessões anteriores: `RECAPTCHA_AUTH=false` temporário, revertido ao final):
- Menu mostra "Pesagens" corretamente.
- Formulário `novo` com `?id_lote=X` mostra o campo hidden corretamente (após o fix do bug acima).
- Duas pesagens consecutivas de um lote de teste (220kg em 01/06, 235kg em 15/06) → GMD calculado e exibido: **1,071 kg/dia**, batendo com o cálculo manual `(235-220)/14`.
- Botão "Pesagens" na listagem de Lotes funciona e filtra corretamente.
- Edição de pesagem carrega os dados certos.
- Validação rejeita corretamente pesagem sem `id_lote` nem `id_animal` (sem inserir no banco).
- Dados de teste removidos ao final; nenhuma tabela de produção foi tocada (confirmado antes de cada `DELETE`).

## Atualização 2026-07-09 (tarde): os 6 eventos restantes foram implementados

Depois da Pesagem, o usuário pediu para implementar **tudo o que faltava** do escopo 5.1. Ele também trouxe o escopo completo do módulo de Nutrição (4.6 + 5.2 — ingredientes, grupos de ingredientes, fórmulas de ração, fases nutricionais, tipos de dieta, parâmetros nutricionais, montagem de fórmula, confecção de ração, baixa de ingredientes, programação/fornecimento de trato, leitura de cocho, ajuste de consumo), mas foi decidido **adiar esse módulo** e fazer primeiro os 6 eventos de 5.1 com uma **Dieta simplificada** (sem composição de ingredientes) — ver seção "Nutrição — adiado" abaixo.

Migration: [storage/migrations/20260709_0033_create_movimentacoes_lote.sql](../storage/migrations/20260709_0033_create_movimentacoes_lote.sql)

### 1. Entrada de animais
- Tabela `movimentacao_entrada` (1:1 com `lote`, como `lote_entrada`): fornecedor, curral de destino, tipo de entrada, documento (NF/GTA/Outro) + número, data, valor total, observação.
- `Manejo\EntradaController` — só permite vincular lotes que **ainda não têm** entrada registrada (`lotesSemEntrada()`), para não duplicar.
- Views: `admin/manejo/entrada/{index,form}.phtml`.

### 2. Localização (Alocação em curral + Transferência entre currais — tabela única)
- Tabela `movimentacao_localizacao`: `id_curral_origem`/`id_piquete_origem` (nulos = alocação inicial), `id_curral_destino`/`id_piquete_destino`, data, quantidade (nulo = lote inteiro), motivo.
- **Efeito colateral importante**: ao criar ou editar um registro, `LocalizacaoController` verifica se é o registro **mais recente** daquele lote e, se for, atualiza `lote.id_curral`/`lote.id_piquete` para espelhar a localização atual — assim o campo em `lote` (usado em listagens/telas de outros módulos) sempre reflete o último registro do histórico, sem precisar fazer join toda vez.
- Views: `admin/manejo/localizacao/{index,form}.phtml`. Testado com sequência real: alocação inicial (curral A) → transferência (A→B) → `lote.id_curral` corretamente atualizado para B.

### 3. Dieta (cadastro simplificado) + Troca de Dieta (evento)
- Tabela `dieta`: nome, fase (texto livre: ADAPTACAO/CRESCIMENTO/TERMINACAO etc.), descrição, ativo. **Sem composição de ingredientes** — isso fica para o módulo de Nutrição completo.
- Tabela `movimentacao_dieta`: lote, dieta, data da troca, motivo, observação.
- `Manejo\DietaController` (cadastro, padrão simples igual `TipoEntradaController`) + `Manejo\TrocaDietaController` (evento, padrão igual Pesagem: filtra por `?id_lote=`).
- Views: `admin/manejo/dieta/{index,form}.phtml` e `admin/manejo/troca-dieta/{index,form}.phtml`.

### 4. Saída / Venda / Abate
- Tabela `movimentacao_saida`: lote, tipo de saída (reaproveita `tipo_saida` já existente), **cliente opcional** (`id_cliente`, nullable — decisão do usuário: "vincula, mas não obrigatório"), data, quantidade, peso total/médio, valor total, resultado (texto livre), observação.
- `Manejo\SaidaController`.
- Views: `admin/manejo/saida/{index,form}.phtml`.

### 5. Mortalidade / Perda
- Tabela `movimentacao_mortalidade`: lote, motivo (reaproveita `motivo_perda` já existente), data, quantidade (default 1), responsável, observação.
- `Manejo\MortalidadeController`.
- Views: `admin/manejo/mortalidade/{index,form}.phtml`.

### Padrão comum aos 5 controllers de evento (Entrada, Localização, Troca de Dieta, Saída, Mortalidade)
Todos seguem o mesmo desenho do `PesagemController`:
- `index(Request $request)` aceita `?id_lote=` opcional — com filtro, mostra breadcrumb contextual ("Voltar ao Lote") e omite a coluna "Lote" da tabela (redundante); sem filtro, lista tudo com a coluna "Lote" visível.
- `new(Request $request)` também aceita `?id_lote=` — com contexto, mostra um `<input type="hidden">` + alerta informativo em vez do `<select>` de lote.
- Todas as validações usam `$data->has("campo")`, nunca `empty($data->campo)` (ver bug documentado abaixo).
- Datas em formato brasileiro no formulário (`input-datebr`), convertidas com `format_date()` antes de persistir.

### Menu reestruturado
O dropdown "Manejo" (que já tinha 6 itens: Animais, Lotes, Pesagens, Tipos de Entrada, Tipos de Saída, Motivos de Perda) foi **dividido em dois dropdowns** sob o mesmo título "Manejo", para não ficar com 12 itens numa lista só:

```
Manejo (título de seção)
  Cadastros (dropdown)
    - Animais
    - Lotes
    - Dietas
    - Tipos de Entrada
    - Tipos de Saída
    - Motivos de Perda
  Movimentações (dropdown)
    - Entradas
    - Localizações
    - Pesagens
    - Trocas de Dieta
    - Saídas
    - Mortalidade / Perda
```

"Pesagens" foi movida de "Cadastros" (onde nunca fez muito sentido) para "Movimentações" (onde pertence conceitualmente).

### Integração com a tela de Lote
Como agora são 5 eventos vinculáveis a um lote específico (Pesagens, Localização, Trocas de Dieta, Saídas, Mortalidade — Entrada é 1:1 então não precisa de listagem, só edição direta), a listagem de Lotes (`admin/manejo/lote/index.phtml`) ganhou um **dropdown de ações** (ícone `uil-exchange`, Bootstrap dropdown) em vez de botões individuais, com um link para cada módulo de movimentação filtrado por aquele lote.

### Permissões
24 novas permissões, grupos `entradas`, `localizacoes`, `dietas`, `trocas_dieta`, `saidas`, `mortalidades` (agrupamento "Manejo", 4 cada: gerenciar/inserir/editar/excluir).

### Testado
Fluxo completo via curl com sessão real (Unidade → 2 Currais → Fornecedor → Cliente → Lote → os 6 eventos):
- Entrada registrada com fornecedor, curral de destino, NF, valor.
- Alocação inicial (sem origem) seguida de transferência (A→B) — `lote.id_curral` corretamente atualizado para o destino mais recente.
- Dieta cadastrada e troca de dieta vinculada ao lote.
- Saída registrada com vínculo a cliente (venda), quantidade, peso, valor.
- Mortalidade registrada com motivo e responsável.
- Todas as 12 telas (6 index + 6 form) carregam sem erro em qualquer combinação de contexto (com/sem `?id_lote=`).
- Dados de teste totalmente removidos ao final; nenhum dado de produção afetado.

## Nutrição — adiado (não implementado)

O usuário trouxe o escopo completo (itens 4.6 e 5.2 do documento dele), reproduzido aqui para não se perder:

**4.6 Cadastros de nutrição e ração:**
- Ingredientes (milho, farelo, silagem, ureia, núcleo, aditivos)
- Grupos de ingredientes (energético, proteico, volumoso, mineral, aditivo)
- Fórmulas de ração (composição da dieta, percentual/quantidade por ingrediente)
- Fases nutricionais (adaptação, crescimento, terminação, dietas especiais)
- Tipos de dieta (total, trato, suplemento, pré-mistura, núcleo, concentrado)
- Parâmetros nutricionais (matéria seca, proteína bruta, fibra, energia, consumo previsto)

**5.2 Movimentações de ração e nutrição:**
- Montagem de fórmula
- Confecção de ração (batida produzida: fórmula, quantidade prevista/real, operador)
- Baixa de ingredientes (consumo automático de estoque)
- Programação de trato (planejamento diário por lote/curral)
- Fornecimento de trato (o que foi realmente entregue)
- Leitura de cocho (sobra/limpeza, ajusta próxima carga)
- Ajuste de consumo (correção técnica baseada em desempenho + leitura de cocho)

Isso é um módulo do tamanho do que acabou de ser feito (ou maior) — envolve estoque com baixa automática, produção (fórmula → batida → consumo), e um ciclo diário de planejamento/execução/leitura. Quando o usuário pedir para seguir com isso, tratar como um novo checkpoint próprio, não como extensão deste.

A tabela `dieta` criada agora (nome, fase, descrição) é deliberadamente compatível com isso: quando o cadastro completo de Fórmulas de Ração existir, a ideia é que `dieta` vire (ou seja substituída por) uma referência à fórmula real, sem precisar remodelar `movimentacao_dieta` — o vínculo já é por `id_dieta`, então trocar o que `dieta` representa por baixo é uma migração de dados, não de estrutura.
