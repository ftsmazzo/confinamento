-- Seed de dados de teste do modulo Sanitario (5.4).
-- Datas escolhidas de forma que a carencia ja tenha vencido (nao trava
-- futuros testes de Saida com a data atual).

SET @admin := (SELECT id FROM usuario WHERE login = 'admin' LIMIT 1);
SET @lote1 := (SELECT id FROM lote WHERE codigo = 'L2026001');
SET @lote2 := (SELECT id FROM lote WHERE codigo = 'L2026002');
SET @animal1 := (SELECT id FROM animal WHERE identificacao = 'BR001');
SET @produto_vacina := (SELECT id FROM produto_estoque WHERE codigo = 'PROD01');
SET @produto_vermifugo := (SELECT id FROM produto_estoque WHERE codigo = 'PROD02');
SET @loteestoque_vacina := (SELECT id FROM lote_estoque WHERE codigo_lote = 'LOTE-AFTOSA-2026A');

-- ============================================================
-- 1. PROTOCOLOS SANITARIOS
-- ============================================================
INSERT INTO protocolo_sanitario (id_produto_estoque, nome, descricao, dias_carencia_padrao, ativo, created_by)
VALUES
(@produto_vacina, 'Vacinação Febre Aftosa', 'Protocolo obrigatório semestral contra febre aftosa', 21, 1, @admin),
(@produto_vermifugo, 'Vermifugação de Entrada', 'Aplicado em todos os animais na entrada do confinamento', 14, 1, @admin);

SET @protocolo_aftosa := (SELECT id FROM protocolo_sanitario WHERE nome = 'Vacinação Febre Aftosa');
SET @protocolo_vermifugo := (SELECT id FROM protocolo_sanitario WHERE nome = 'Vermifugação de Entrada');

-- ============================================================
-- 2. APLICACOES SANITARIAS (com baixa de estoque ja refletida)
-- ============================================================
INSERT INTO aplicacao_sanitaria (id_lote, id_protocolo_sanitario, id_produto_estoque, id_lote_estoque, tipo, data_aplicacao, quantidade_animais, quantidade_produto, dias_carencia, data_carencia_fim, veterinario_responsavel, created_by)
VALUES
(@lote1, @protocolo_aftosa, @produto_vacina, @loteestoque_vacina, 'TRATAMENTO_LOTE', '2026-05-02', 50, 50.00, 21, '2026-05-23', 'Ana Paula Souza', @admin);

INSERT INTO aplicacao_sanitaria (id_animal, id_protocolo_sanitario, id_produto_estoque, tipo, data_aplicacao, quantidade_produto, dias_carencia, data_carencia_fim, veterinario_responsavel, created_by)
VALUES
(@animal1, @protocolo_vermifugo, @produto_vermifugo, 'TRATAMENTO_INDIVIDUAL', '2026-05-01', 10.00, 14, '2026-05-15', 'Ana Paula Souza', @admin);

INSERT INTO aplicacao_sanitaria (id_lote, id_produto_estoque, tipo, data_aplicacao, quantidade_produto, veterinario_responsavel, observacao, created_by)
VALUES
(@lote2, @produto_vermifugo, 'TRATAMENTO_LOTE', '2026-06-10', 60, 'Ana Paula Souza', 'Tratamento avulso sem protocolo formal, reforço de vermifugação', @admin);

-- Baixa de estoque correspondente as 3 aplicacoes acima (50+10+60)
UPDATE produto_estoque SET saldo_atual = saldo_atual - 50.00 WHERE id = @produto_vacina;
UPDATE lote_estoque SET quantidade_atual = quantidade_atual - 50.00 WHERE id = @loteestoque_vacina;
UPDATE produto_estoque SET saldo_atual = saldo_atual - 70.00 WHERE id = @produto_vermifugo;

-- ============================================================
-- 3. OCORRENCIAS SANITARIAS
-- ============================================================
INSERT INTO ocorrencia_sanitaria (id_lote, data_ocorrencia, descricao, gravidade, responsavel, created_by)
VALUES
(@lote2, '2026-06-15', 'Foco de bicheira observado em 3 animais do lote', 'MODERADA', 'Ana Paula Souza', @admin);

INSERT INTO ocorrencia_sanitaria (id_animal, data_ocorrencia, descricao, gravidade, responsavel, observacao, created_by)
VALUES
(@animal1, '2026-05-20', 'Claudicação leve na pata traseira, sem sinais de fratura', 'LEVE', 'Ana Paula Souza', 'Em observação, sem necessidade de tratamento imediato', @admin);
SET @admin := (SELECT id FROM usuario WHERE login = 'admin' LIMIT 1);
SET @lote3 := (SELECT id FROM lote WHERE codigo = 'L2026003');
SET @animal6 := (SELECT id FROM animal WHERE identificacao = 'BR006');
SET @protocolo_aftosa := (SELECT id FROM protocolo_sanitario WHERE nome = 'Vacinação Febre Aftosa');
SET @produto_vacina := (SELECT id FROM produto_estoque WHERE codigo = 'PROD01');
SET @loteestoque_vacina := (SELECT id FROM lote_estoque WHERE codigo_lote = 'LOTE-AFTOSA-2026A');

INSERT INTO aplicacao_sanitaria (id_lote, id_protocolo_sanitario, id_produto_estoque, id_lote_estoque, tipo, data_aplicacao, quantidade_animais, quantidade_produto, dias_carencia, data_carencia_fim, veterinario_responsavel, created_by)
VALUES
(@lote3, @protocolo_aftosa, @produto_vacina, @loteestoque_vacina, 'TRATAMENTO_LOTE', '2026-06-02', 40, 40.00, 21, '2026-06-23', 'Ana Paula Souza', @admin);

UPDATE produto_estoque SET saldo_atual = saldo_atual - 40.00 WHERE id = @produto_vacina;
UPDATE lote_estoque SET quantidade_atual = quantidade_atual - 40.00 WHERE id = @loteestoque_vacina;

INSERT INTO ocorrencia_sanitaria (id_animal, data_ocorrencia, descricao, gravidade, responsavel, created_by)
VALUES
(@animal6, '2026-06-20', 'Ferimento superficial em cerca, tratado com curativo local', 'LEVE', 'Ana Paula Souza', @admin);
