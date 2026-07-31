# Movimentações de Animais — Explicação e Escopo (5.1)

Este documento explica, em termos de operação real de confinamento, cada um dos 8 eventos de movimentação previstos no escopo do sistema, e como cada um se relaciona com o que já existe hoje (Unidade, Curral, Piquete, Lote, Animal, Pesagem). Serve de referência para as próximas etapas de desenvolvimento — ver [checkpoint-movimentacoes.md](checkpoint-movimentacoes.md) para o estado técnico atual.

Decisão de arquitetura já confirmada: **cada evento vira uma tabela própria** (não um log genérico com JSON), seguindo o padrão do que já foi feito para Pesagem.

---

## 1. Entrada de animais

**O que é:** o registro formal da chegada de um lote de animais ao confinamento. É o evento que "abre" a vida daquele grupo de animais dentro do sistema.

**Dados que carrega:**
- Origem (de qual fornecedor vieram)
- Documentos: nota fiscal, GTA (Guia de Trânsito Animal — documento obrigatório no Brasil para transporte de gado)
- Quantidade de cabeças
- Peso de entrada (total e/ou médio)
- Valor pago (custo de aquisição)
- Curral de destino inicial

**Por que importa:** é a base de todo o custo do lote (quanto se pagou por cabeça) e a referência de peso inicial para calcular ganho de peso depois. Sem uma entrada registrada, tecnicamente os animais "não existem" no sistema.

**Relação com o que já existe:** hoje isso é coberto **parcialmente** pelo cadastro de `Lote` (tabela `lote`) + a tabela satélite `lote_entrada` (quantidade, peso médio, peso total, data de entrada — criada já pensando nisso). **Falta**: vínculo com fornecedor, documento fiscal/GTA, valor de compra. Um evento formal de "Entrada" reaproveitaria essas tabelas e adicionaria os campos financeiros/documentais.

---

## 2. Formação de lote

**O que é:** a decisão de agrupar um conjunto de animais (recém-chegados, ou reorganizados de outros lotes) em uma única unidade de manejo — o **lote**. Animais do mesmo lote normalmente têm origem, fase ou objetivo semelhantes, e são tratados como grupo (mesma dieta, mesmo curral, mesma pesagem agregada).

**Quando acontece:**
- Junto com a entrada (compra de 50 cabeças que já formam um lote novo) — caso mais comum.
- Separado da entrada (juntar sobras de dois lotes pequenos em um lote novo, por exemplo).

**Relação com o que já existe:** já existe como cadastro estático (`Manejo\LoteController`, tabela `lote`). Falta o aspecto de **evento**: registrar formalmente o motivo da formação e, se for uma reorganização, de quais lotes/animais de origem vieram os animais que formam o novo lote.

---

## 3. Alocação em curral

**O que é:** a definição de qual curral (ou piquete) vai hospedar um lote. É o primeiro "endereço físico" do lote dentro da fazenda.

**Relação com o que já existe:** hoje é só um campo (`lote.id_curral` ou `lote.id_piquete`) — representa o estado **atual**, sem histórico. Não sabemos hoje, olhando o sistema, "desde quando" o lote está naquele curral, nem se já esteve em outro antes. Como evento formal, a Alocação seria o **primeiro registro** dessa história (a Transferência, abaixo, seria os registros seguintes).

---

## 4. Transferência entre currais

**O que é:** mudança de local de um lote (ou de parte dele — por exemplo, separar 10 de 50 animais para outro curral) depois que ele já estava alocado em algum lugar.

**Motivos típicos:**
- Liberar espaço para novo lote.
- Separar animais doentes ou com desempenho diferente do restante.
- Reorganizar por faixa de peso (agrupar animais parecidos).

**Dados que carrega:**
- Curral de origem e curral de destino
- Data da transferência
- Motivo
- Quantidade movida (todo o lote ou só uma parte — nesse caso, tecnicamente cria um "sublote" ou exige dividir o lote)

**Por que importa:** rastreabilidade sanitária (saber onde cada grupo de animais esteve) e organização operacional. É o evento que, junto com a Alocação, forma o **histórico completo de localização** de um lote.

**Relação com o que já existe:** não existe ainda nenhum registro histórico de localização — só o campo atual em `lote`. Este é um evento novo, sem base prévia.

---

## 5. Pesagem inicial, intermediária e final — ✅ já implementado

**O que é:** registro do peso de um lote (agregado) ou de um animal individual, em datas específicas, para acompanhar desempenho ao longo do confinamento.

**Os 3 tipos:**
- **Inicial**: peso de entrada, usado como base de comparação.
- **Intermediária**: pesagens ao longo do período de confinamento, para acompanhar evolução.
- **Final**: peso próximo à saída, usado para decidir o ponto de abate/venda.

**Métrica principal: GMD (Ganho Médio Diário)** — quanto peso o lote/animal ganha por dia, calculado automaticamente comparando duas pesagens consecutivas: `(peso_atual - peso_anterior) / dias_entre_pesagens`. É o indicador mais importante de desempenho de confinamento — decide se a dieta está funcionando e quando o lote está pronto para sair.

**Status:** implementado e testado. Ver [checkpoint-movimentacoes.md](checkpoint-movimentacoes.md) para detalhes técnicos (tabela `movimentacao_pesagem`, cálculo de GMD, telas).

---

## 6. Troca de dieta

**O que é:** registro de quando a fórmula alimentar (ração) de um lote muda.

**Motivos típicos:**
- Fase do confinamento (adaptação → crescimento → terminação — cada fase tem uma dieta diferente, com mais ou menos energia).
- Leitura de cocho (o funcionário verifica quanto sobrou de comida no cocho: sobrou muito = reduzir quantidade; sobrou pouco/nada = aumentar).
- Estratégia técnica (decisão do nutricionista/veterinário por outros motivos).

**Dados que carrega:**
- Dieta anterior e nova dieta (provavelmente precisa de um cadastro de "Dietas/Fórmulas" que ainda não existe)
- Data da troca
- Motivo (fase, leitura de cocho, técnico)

**Por que importa:** custo de alimentação (a dieta é o maior custo variável do confinamento) e explica variações de GMD entre pesagens — se o ganho de peso mudou, muitas vezes é porque a dieta mudou.

**Relação com o que já existe:** não existe ainda cadastro de Dietas/Fórmulas nem histórico de troca. Evento novo, precisa de um cadastro de apoio antes (similar a `tipo_entrada`/`tipo_saida`/`motivo_perda`).

---

## 7. Saída / venda / abate

**O que é:** o oposto da Entrada — registra a baixa dos animais por destino comercial (venda para outro produtor, abate em frigorífico, ou outro destino).

**Dados que carrega:**
- Tipo de saída (usa o cadastro `tipo_saida` que já existe: Venda, Abate, Transferência, Descarte, Baixa)
- Quantidade de cabeças
- Peso de saída
- Valor recebido / resultado financeiro
- Comprador/destino (provavelmente vincula com `Cliente`, já que Cliente no sistema são "frigoríficos, compradores finais, parceiros comerciais")

**Por que importa:** é o evento que "fecha" o ciclo do lote. Compara com o custo de Entrada para calcular o resultado financeiro da operação (lucro/prejuízo por lote) e o desempenho zootécnico (peso ganho, dias de confinamento, GMD médio do lote inteiro).

**Relação com o que já existe:** o cadastro de apoio `tipo_saida` já existe (Venda, Abate, Transferência, Descarte, Baixa). Falta o evento em si e o vínculo com Cliente (comprador).

---

## 8. Mortalidade / perda

**O que é:** baixa técnica de animais — não é venda, é perda real (morte por doença/acidente, descarte por lesão grave, etc.).

**Dados que carrega:**
- Causa/motivo (usa o cadastro `motivo_perda` que já existe: Doença, Acidente, Predação, Intoxicação, Outros)
- Responsável pelo registro (quem constatou/registrou)
- Data
- Quantidade (normalmente 1 animal, mas pode ser mais em casos de surto)

**Por que importa:** taxa de mortalidade é um indicador-chave de manejo sanitário — confinamentos bem manejados têm taxa baixa (tipicamente abaixo de 1-2%). Também reduz a quantidade ativa do lote, afetando os cálculos de peso total e resultado financeiro esperado.

**Relação com o que já existe:** o cadastro de apoio `motivo_perda` já existe. Falta o evento em si.

---

## Resumo — o que já existe vs. o que falta

| Evento | Cadastro de apoio | Evento/histórico |
|---|---|---|
| 1. Entrada de animais | Parcial (`lote_entrada`) | Falta (fornecedor, documento, valor) |
| 2. Formação de lote | Existe (`lote`) | Falta (motivo, origem dos animais) |
| 3. Alocação em curral | Existe (campo atual em `lote`) | Falta (histórico "desde quando") |
| 4. Transferência entre currais | — | Falta (evento novo, zero base) |
| 5. Pesagem | — | ✅ **Implementado** (`movimentacao_pesagem`) |
| 6. Troca de dieta | Falta (cadastro de Dietas) | Falta (evento novo) |
| 7. Saída / venda / abate | Existe (`tipo_saida`) | Falta (evento, vínculo com Cliente) |
| 8. Mortalidade / perda | Existe (`motivo_perda`) | Falta (evento novo) |

## Observação sobre dependências entre eventos

Alguns desses eventos têm ordem natural de implementação por dependerem uns dos outros:
- **Entrada** e **Formação de lote** costumam ser o mesmo momento na prática — pode fazer sentido implementar juntos.
- **Alocação em curral** é o primeiro registro do histórico que a **Transferência** também usa — a mesma tabela de histórico de localização provavelmente serve para os dois eventos (um "alocação inicial" é, estruturalmente, uma transferência sem origem).
- **Troca de dieta** depende de um cadastro de Dietas/Fórmulas que ainda não existe — seria um cadastro de apoio novo antes do evento.
- **Saída/venda/abate** se beneficia de já ter Pesagem (peso de saída) e pode vincular com Cliente (comprador).

Nenhuma decisão de prioridade foi tomada ainda — este documento é só a explicação e o mapeamento do escopo. A escolha de qual implementar a seguir fica com o usuário.
