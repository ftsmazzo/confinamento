-- Seed de dados de teste para popular todo o sistema de confinamento.
-- Cobre: Confinamento, Pessoas, Fornecedores, Nutricao (cadastros +
-- movimentacoes), Estoque, Manejo (cadastros + movimentacoes).
-- Todos os registros usam nomes com sufixo "TESTE" quando aplicavel para
-- facilitar limpeza posterior se necessario.

SET @admin := (SELECT id FROM usuario WHERE login = 'admin' LIMIT 1);

-- ============================================================
-- 1. CONFINAMENTO
-- ============================================================
INSERT INTO unidade (nome, codigo, descricao, cidade, estado, responsavel, ativo, created_by)
VALUES
('Fazenda Santa Fe', 'FSF01', 'Unidade principal de confinamento', 'Barretos', 'SP', 'Carlos Mendes', 1, @admin),
('Fazenda Boa Vista', 'FBV02', 'Unidade de recria e engorda', 'Aracatuba', 'SP', 'Roberto Lima', 1, @admin);

SET @unidade1 := (SELECT id FROM unidade WHERE codigo = 'FSF01');
SET @unidade2 := (SELECT id FROM unidade WHERE codigo = 'FBV02');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, ativo, created_by)
VALUES
(@unidade1, 'Curral 01', 'C01', 150, 'CONFINAMENTO', 1, @admin),
(@unidade1, 'Curral 02', 'C02', 150, 'CONFINAMENTO', 1, @admin),
(@unidade1, 'Curral 03', 'C03', 200, 'CONFINAMENTO', 1, @admin),
(@unidade2, 'Curral 04', 'C04', 100, 'CONFINAMENTO', 1, @admin);

SET @curral1 := (SELECT id FROM curral WHERE codigo = 'C01');
SET @curral2 := (SELECT id FROM curral WHERE codigo = 'C02');
SET @curral3 := (SELECT id FROM curral WHERE codigo = 'C03');
SET @curral4 := (SELECT id FROM curral WHERE codigo = 'C04');

INSERT INTO piquete (id_unidade, nome, codigo, capacidade, ativo, created_by)
VALUES
(@unidade2, 'Piquete 01', 'P01', 80, 1, @admin);

SET @piquete1 := (SELECT id FROM piquete WHERE codigo = 'P01');

INSERT INTO local_estoque (id_unidade, nome, codigo, tipo, responsavel, ativo, created_by)
VALUES
(@unidade1, 'Silo de Milho', 'SIL01', 'SILO', 'Carlos Mendes', 1, @admin),
(@unidade1, 'Farmacia Veterinaria', 'FARM01', 'DEPOSITO', 'Ana Paula', 1, @admin);

SET @localestoque1 := (SELECT id FROM local_estoque WHERE codigo = 'SIL01');
SET @localestoque2 := (SELECT id FROM local_estoque WHERE codigo = 'FARM01');

INSERT INTO centro_custo (nome, codigo, descricao, ativo, created_by)
VALUES
('Alimentacao', 'CC01', 'Gastos com racao e nutricao', 1, @admin),
('Sanidade', 'CC02', 'Gastos com medicamentos e veterinario', 1, @admin),
('Mao de Obra', 'CC03', 'Gastos com funcionarios', 1, @admin);

-- ============================================================
-- 2. PESSOAS
-- ============================================================
INSERT INTO funcionario (id_unidade, nome, cargo, setor, telefone, data_admissao, ativo, created_by)
VALUES
(@unidade1, 'Carlos Mendes', 'Gerente de Confinamento', 'ADMINISTRATIVO', '17999990001', '2023-01-10', 1, @admin),
(@unidade1, 'Jose Roberto', 'Vaqueiro', 'OPERACIONAL', '17999990002', '2024-03-15', 1, @admin),
(@unidade1, 'Ana Paula Souza', 'Veterinaria', 'TECNICO', '17999990003', '2023-06-01', 1, @admin);

-- ============================================================
-- 3. FORNECEDORES
-- ============================================================
SET @situacao_ativo := (SELECT id FROM fornecedor_situacao WHERE descricao = 'ATIVO');
SET @ramo_racao := (SELECT id FROM fornecedor_ramo WHERE descricao = 'RAÇÃO E NUTRIÇÃO ANIMAL');
SET @ramo_gado := (SELECT id FROM fornecedor_ramo WHERE descricao = 'COMPRA E VENDA DE GADO');
SET @ramo_vet := (SELECT id FROM fornecedor_ramo WHERE descricao = 'INSUMOS VETERINÁRIOS');

INSERT INTO fornecedor (id_situacao, id_ramo, pessoa, documento, razao, nome, telefone, email, cidade, estado, created_by)
VALUES
(@situacao_ativo, @ramo_racao, 'J', '12345678000190', 'NUTRICAO ANIMAL LTDA', 'Nutricao Animal', '1733001100', 'contato@nutricaoanimal.com.br', 'Barretos', 'SP', @admin),
(@situacao_ativo, @ramo_gado, 'J', '23456789000180', 'PECUARIA SAO JOSE LTDA', 'Pecuaria Sao Jose', '1733001200', 'contato@pecuariasaojose.com.br', 'Colombia', 'SP', @admin),
(@situacao_ativo, @ramo_vet, 'J', '34567890000170', 'VETFARMA DISTRIBUIDORA LTDA', 'Vetfarma', '1733001300', 'vendas@vetfarma.com.br', 'Barretos', 'SP', @admin);

SET @fornecedor_racao := (SELECT id FROM fornecedor WHERE documento = '12345678000190');
SET @fornecedor_gado := (SELECT id FROM fornecedor WHERE documento = '23456789000180');
SET @fornecedor_vet := (SELECT id FROM fornecedor WHERE documento = '34567890000170');

-- ============================================================
-- 4. NUTRICAO - INGREDIENTES E FORMULA
-- ============================================================
SET @grupo_energetico := (SELECT id FROM grupo_ingrediente WHERE descricao = 'ENERGÉTICO');
SET @grupo_proteico := (SELECT id FROM grupo_ingrediente WHERE descricao = 'PROTEICO');
SET @grupo_volumoso := (SELECT id FROM grupo_ingrediente WHERE descricao = 'VOLUMOSO');
SET @grupo_mineral := (SELECT id FROM grupo_ingrediente WHERE descricao = 'MINERAL');

INSERT INTO ingrediente (id_grupo_ingrediente, nome, unidade_medida, estoque_atual, estoque_minimo, ativo, created_by)
VALUES
(@grupo_energetico, 'Milho Moido', 'KG', 5000.00, 1000.00, 1, @admin),
(@grupo_proteico, 'Farelo de Soja', 'KG', 2000.00, 500.00, 1, @admin),
(@grupo_volumoso, 'Silagem de Milho', 'KG', 8000.00, 2000.00, 1, @admin),
(@grupo_mineral, 'Nucleo Mineral', 'KG', 500.00, 100.00, 1, @admin),
(@grupo_energetico, 'Ureia Pecuaria', 'KG', 300.00, 50.00, 1, @admin);

SET @ing_milho := (SELECT id FROM ingrediente WHERE nome = 'Milho Moido');
SET @ing_farelo := (SELECT id FROM ingrediente WHERE nome = 'Farelo de Soja');
SET @ing_silagem := (SELECT id FROM ingrediente WHERE nome = 'Silagem de Milho');
SET @ing_nucleo := (SELECT id FROM ingrediente WHERE nome = 'Nucleo Mineral');
SET @ing_ureia := (SELECT id FROM ingrediente WHERE nome = 'Ureia Pecuaria');

SET @fase_adaptacao := (SELECT id FROM fase_nutricional WHERE descricao = 'ADAPTAÇÃO');
SET @fase_crescimento := (SELECT id FROM fase_nutricional WHERE descricao = 'CRESCIMENTO');
SET @fase_terminacao := (SELECT id FROM fase_nutricional WHERE descricao = 'TERMINAÇÃO');
SET @tipo_dieta_total := (SELECT id FROM tipo_dieta WHERE descricao = 'TOTAL');

INSERT INTO formula_racao (id_tipo_dieta, id_fase_nutricional, nome, descricao, ativo, created_by)
VALUES
(@tipo_dieta_total, @fase_adaptacao, 'Formula Adaptacao', 'Dieta de adaptacao para animais recem-chegados', 1, @admin),
(@tipo_dieta_total, @fase_crescimento, 'Formula Crescimento', 'Dieta de crescimento', 1, @admin),
(@tipo_dieta_total, @fase_terminacao, 'Formula Terminacao', 'Dieta de terminacao para acabamento', 1, @admin);

SET @formula_adaptacao := (SELECT id FROM formula_racao WHERE nome = 'Formula Adaptacao');
SET @formula_crescimento := (SELECT id FROM formula_racao WHERE nome = 'Formula Crescimento');
SET @formula_terminacao := (SELECT id FROM formula_racao WHERE nome = 'Formula Terminacao');

INSERT INTO formula_racao_item (id_formula_racao, id_ingrediente, percentual, created_by) VALUES
(@formula_adaptacao, @ing_silagem, 60.00, @admin),
(@formula_adaptacao, @ing_milho, 25.00, @admin),
(@formula_adaptacao, @ing_farelo, 10.00, @admin),
(@formula_adaptacao, @ing_nucleo, 5.00, @admin),
(@formula_crescimento, @ing_silagem, 40.00, @admin),
(@formula_crescimento, @ing_milho, 40.00, @admin),
(@formula_crescimento, @ing_farelo, 15.00, @admin),
(@formula_crescimento, @ing_nucleo, 5.00, @admin),
(@formula_terminacao, @ing_milho, 60.00, @admin),
(@formula_terminacao, @ing_farelo, 15.00, @admin),
(@formula_terminacao, @ing_silagem, 20.00, @admin),
(@formula_terminacao, @ing_nucleo, 5.00, @admin);

-- ============================================================
-- 5. ESTOQUE (generico, independente de Ingrediente/Nutricao)
-- ============================================================
SET @cat_sanitario := (SELECT id FROM categoria_produto WHERE descricao = 'Sanitário');
SET @cat_combustivel := (SELECT id FROM categoria_produto WHERE descricao = 'Combustível');

INSERT INTO local_armazenagem_interno (id_local_estoque, nome, ativo, created_by)
VALUES
(@localestoque2, 'Prateleira de Vacinas', 1, @admin),
(@localestoque2, 'Geladeira de Medicamentos', 1, @admin);

SET @localinterno_vacinas := (SELECT id FROM local_armazenagem_interno WHERE nome = 'Prateleira de Vacinas');

INSERT INTO produto_estoque (id_categoria_produto, id_local_armazenagem_interno, id_fornecedor_padrao, nome, codigo, unidade_medida, saldo_atual, estoque_minimo, controla_lote, ativo, created_by)
VALUES
(@cat_sanitario, @localinterno_vacinas, @fornecedor_vet, 'Vacina Febre Aftosa', 'PROD01', 'DOSE', 200.00, 50.00, 1, 1, @admin),
(@cat_sanitario, @localinterno_vacinas, @fornecedor_vet, 'Vermifugo Injetavel', 'PROD02', 'ML', 5000.00, 1000.00, 0, 1, @admin),
(@cat_combustivel, NULL, NULL, 'Diesel S10', 'PROD03', 'LT', 1000.00, 200.00, 0, 1, @admin);

SET @produto_vacina := (SELECT id FROM produto_estoque WHERE codigo = 'PROD01');

INSERT INTO lote_estoque (id_produto_estoque, codigo_lote, data_validade, quantidade_atual, created_by)
VALUES
(@produto_vacina, 'LOTE-AFTOSA-2026A', '2027-06-01', 200.00, @admin);

SET @loteestoque_vacina := (SELECT id FROM lote_estoque WHERE codigo_lote = 'LOTE-AFTOSA-2026A');

SET @tipo_mov_entrada := (SELECT id FROM tipo_movimentacao_estoque WHERE descricao = 'Entrada');

INSERT INTO movimentacao_estoque (id_produto_estoque, id_tipo_movimentacao_estoque, id_lote_estoque, id_centro_custo, id_fornecedor, id_operador, data_movimentacao, quantidade, motivo, created_by)
SELECT @produto_vacina, @tipo_mov_entrada, @loteestoque_vacina, id, @fornecedor_vet, @admin, '2026-06-15', 200.00, 'Compra inicial de vacinas', @admin
FROM centro_custo WHERE codigo = 'CC02';

-- ============================================================
-- 6. MANEJO - LOTES E ANIMAIS
-- ============================================================
SET @tipo_entrada_compra := (SELECT id FROM tipo_entrada WHERE descricao = 'COMPRA');

INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, ativo, created_by)
VALUES
(@unidade1, @curral1, 'Lote 2026-001', 'L2026001', '2026-05-01', 'ADAPTACAO', 'ENGORDA', 'ATIVO', 1, @admin),
(@unidade1, @curral2, 'Lote 2026-002', 'L2026002', '2026-05-10', 'CRESCIMENTO', 'ENGORDA', 'ATIVO', 1, @admin),
(@unidade2, @curral4, 'Lote 2026-003', 'L2026003', '2026-06-01', 'TERMINACAO', 'ENGORDA', 'ATIVO', 1, @admin);

SET @lote1 := (SELECT id FROM lote WHERE codigo = 'L2026001');
SET @lote2 := (SELECT id FROM lote WHERE codigo = 'L2026002');
SET @lote3 := (SELECT id FROM lote WHERE codigo = 'L2026003');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by) VALUES
(@lote1, 50, 380.00, 19000.00, '2026-05-01', @admin),
(@lote2, 60, 400.00, 24000.00, '2026-05-10', @admin),
(@lote3, 40, 450.00, 18000.00, '2026-06-01', @admin);

INSERT INTO movimentacao_entrada (id_lote, id_fornecedor, id_curral_destino, id_tipo_entrada, documento, tipo_documento, data_entrada, valor_total, created_by) VALUES
(@lote1, @fornecedor_gado, @curral1, @tipo_entrada_compra, 'NF-1001', 'NF', '2026-05-01', 152000.00, @admin),
(@lote2, @fornecedor_gado, @curral2, @tipo_entrada_compra, 'NF-1002', 'NF', '2026-05-10', 192000.00, @admin),
(@lote3, @fornecedor_gado, @curral4, @tipo_entrada_compra, 'NF-1003', 'NF', '2026-06-01', 162000.00, @admin);

-- Animais individuais (amostra de 5 por lote, nao os 150 completos, para nao inflar demais)
INSERT INTO animal (id_lote, id_fornecedor, id_tipo_entrada, identificacao, tipo_identificacao, sexo, raca, data_nascimento, data_entrada, peso_entrada, status, ativo, created_by)
VALUES
(@lote1, @fornecedor_gado, @tipo_entrada_compra, 'BR001', 'BRINCO', 'M', 'NELORE', '2024-08-01', '2026-05-01', 375.00, 'ATIVO', 1, @admin),
(@lote1, @fornecedor_gado, @tipo_entrada_compra, 'BR002', 'BRINCO', 'M', 'NELORE', '2024-08-05', '2026-05-01', 382.00, 'ATIVO', 1, @admin),
(@lote1, @fornecedor_gado, @tipo_entrada_compra, 'BR003', 'BRINCO', 'M', 'NELORE', '2024-08-10', '2026-05-01', 378.00, 'ATIVO', 1, @admin),
(@lote2, @fornecedor_gado, @tipo_entrada_compra, 'BR004', 'BRINCO', 'M', 'ANGUS', '2024-07-15', '2026-05-10', 405.00, 'ATIVO', 1, @admin),
(@lote2, @fornecedor_gado, @tipo_entrada_compra, 'BR005', 'BRINCO', 'M', 'ANGUS', '2024-07-20', '2026-05-10', 398.00, 'ATIVO', 1, @admin),
(@lote3, @fornecedor_gado, @tipo_entrada_compra, 'BR006', 'BRINCO', 'M', 'NELORE', '2024-06-01', '2026-06-01', 448.00, 'ATIVO', 1, @admin),
(@lote3, @fornecedor_gado, @tipo_entrada_compra, 'BR007', 'BRINCO', 'M', 'NELORE', '2024-06-05', '2026-06-01', 452.00, 'ATIVO', 1, @admin);

-- ============================================================
-- 7. MANEJO - LOCALIZACAO (alocacao inicial + transferencia)
-- ============================================================
INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by) VALUES
(@lote1, NULL, @curral1, '2026-05-01', 50, 'Alocação inicial', @admin),
(@lote2, NULL, @curral2, '2026-05-10', 60, 'Alocação inicial', @admin),
(@lote3, NULL, @curral4, '2026-06-01', 40, 'Alocação inicial', @admin),
(@lote1, @curral1, @curral3, '2026-06-20', 50, 'Transferência por reforma do curral 01', @admin);

-- ============================================================
-- 8. MANEJO - PESAGENS
-- ============================================================
INSERT INTO movimentacao_pesagem (id_lote, tipo, data_pesagem, quantidade, peso_medio, peso_total, created_by) VALUES
(@lote1, 'INICIAL', '2026-05-01', 50, 380.00, 19000.00, @admin),
(@lote1, 'INTERMEDIARIA', '2026-06-01', 50, 420.00, 21000.00, @admin),
(@lote2, 'INICIAL', '2026-05-10', 60, 400.00, 24000.00, @admin),
(@lote2, 'INTERMEDIARIA', '2026-06-10', 60, 445.00, 26700.00, @admin),
(@lote3, 'INICIAL', '2026-06-01', 40, 450.00, 18000.00, @admin);

-- ============================================================
-- 9. MANEJO - TROCA DE DIETA
-- ============================================================
INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by) VALUES
(@lote1, @formula_adaptacao, '2026-05-01', 'Início do confinamento', @admin),
(@lote1, @formula_crescimento, '2026-06-01', 'Fase de crescimento', @admin),
(@lote2, @formula_adaptacao, '2026-05-10', 'Início do confinamento', @admin),
(@lote3, @formula_terminacao, '2026-06-01', 'Lote em fase final', @admin);

-- ============================================================
-- 10. MANEJO - SAIDA E MORTALIDADE
-- ============================================================
SET @tipo_saida_venda := (SELECT id FROM tipo_saida WHERE descricao = 'VENDA');
SET @cliente_frigorifico := (SELECT id FROM cliente ORDER BY id LIMIT 1);
SET @motivo_doenca := (SELECT id FROM motivo_perda WHERE descricao = 'DOENÇA');

INSERT INTO movimentacao_saida (id_lote, id_tipo_saida, id_cliente, data_saida, quantidade, peso_total, peso_medio, valor_total, resultado, created_by)
VALUES
(@lote3, @tipo_saida_venda, @cliente_frigorifico, '2026-07-05', 5, 2450.00, 490.00, 24500.00, 'Venda parcial do lote 3, bom acabamento', @admin);

INSERT INTO movimentacao_mortalidade (id_lote, id_motivo_perda, data_ocorrencia, quantidade, responsavel, observacao, created_by)
VALUES
(@lote2, @motivo_doenca, '2026-06-15', 1, 'Ana Paula Souza', 'Óbito por pneumonia, atendido mas não resistiu', @admin);

-- ============================================================
-- 11. NUTRICAO - CONFECCAO DE RACAO (com baixa de estoque)
-- ============================================================
INSERT INTO confeccao_racao (id_formula_racao, id_operador, data_confeccao, quantidade_prevista, quantidade_real, observacao, created_by)
VALUES
(@formula_crescimento, @admin, '2026-06-05', 1000.00, 980.00, 'Batida da manhã', @admin);

SET @confeccao1 := (SELECT id FROM confeccao_racao WHERE data_confeccao = '2026-06-05');

INSERT INTO confeccao_racao_item (id_confeccao_racao, id_ingrediente, percentual_formula, quantidade_consumida)
SELECT @confeccao1, id_ingrediente, percentual, ROUND(980.00 * percentual / 100, 2)
FROM formula_racao_item WHERE id_formula_racao = @formula_crescimento;

UPDATE ingrediente i
JOIN (
    SELECT id_ingrediente, quantidade_consumida FROM confeccao_racao_item WHERE id_confeccao_racao = @confeccao1
) c ON c.id_ingrediente = i.id
SET i.estoque_atual = i.estoque_atual - c.quantidade_consumida;

-- ============================================================
-- 12. NUTRICAO - PROGRAMACAO E FORNECIMENTO DE TRATO
-- ============================================================
INSERT INTO programacao_trato (id_lote, id_curral, id_formula_racao, data_programacao, turno, quantidade_prevista, created_by)
VALUES
(@lote1, @curral3, @formula_crescimento, '2026-06-06', 'MANHA', 500.00, @admin),
(@lote1, @curral3, @formula_crescimento, '2026-06-06', 'TARDE', 500.00, @admin),
(@lote2, @curral2, @formula_adaptacao, '2026-06-06', 'MANHA', 400.00, @admin);

SET @prog1 := (SELECT id FROM programacao_trato WHERE id_lote = @lote1 AND turno = 'MANHA' LIMIT 1);

INSERT INTO fornecimento_trato (id_programacao_trato, id_lote, id_curral, id_formula_racao, id_operador, data_fornecimento, hora_fornecimento, quantidade_fornecida, created_by)
VALUES
(@prog1, @lote1, @curral3, @formula_crescimento, @admin, '2026-06-06', '07:00:00', 495.00, @admin),
(NULL, @lote2, @curral2, @formula_adaptacao, @admin, '2026-06-06', '07:30:00', 400.00, @admin);

-- ============================================================
-- 13. NUTRICAO - LEITURA DE COCHO E AJUSTE DE CONSUMO
-- ============================================================
INSERT INTO leitura_cocho (id_lote, id_curral, data_leitura, escore, created_by)
VALUES
(@lote1, @curral3, '2026-06-07', 1, @admin),
(@lote2, @curral2, '2026-06-07', 2, @admin);

SET @leitura1 := (SELECT id FROM leitura_cocho WHERE id_lote = @lote1 LIMIT 1);

INSERT INTO ajuste_consumo (id_lote, id_leitura_cocho, data_ajuste, percentual_ajuste, motivo, created_by)
VALUES
(@lote1, @leitura1, '2026-06-08', 3.00, 'Cocho limpo, aumentar oferta em 3%', @admin);

-- Custos unitarios (adicionados apos a migration 20260710_0042)
UPDATE ingrediente SET custo_unitario = 0.85 WHERE nome = 'MILHO MOIDO';
UPDATE ingrediente SET custo_unitario = 2.10 WHERE nome = 'FARELO DE SOJA';
UPDATE ingrediente SET custo_unitario = 0.35 WHERE nome = 'SILAGEM DE MILHO';
UPDATE ingrediente SET custo_unitario = 8.50 WHERE nome = 'NUCLEO MINERAL';
UPDATE ingrediente SET custo_unitario = 3.20 WHERE nome = 'UREIA PECUARIA';
UPDATE produto_estoque SET custo_unitario = 18.50 WHERE nome = 'Vacina Febre Aftosa';
UPDATE produto_estoque SET custo_unitario = 12.00 WHERE nome = 'Vermifugo Injetavel';
UPDATE produto_estoque SET custo_unitario = 6.20 WHERE nome = 'Diesel S10';
