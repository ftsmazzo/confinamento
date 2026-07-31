-- P6 / E05 — Carga inicial rebanho/currais (peso médio) — Conf. Irmãos Bichara
-- Fonte: planilha "Acompanhamento" aba Fornecimanto de Trato (snapshot ~21/07/2026)
-- Totais: 14 lotes ocupados · 1067 cabeças · peso médio entrada ~351 kg
--
-- Idempotente por codigo (prefixo BI-): reaplicar não duplica.
-- Prefixo BI- evita colisão com seed-dados-teste (C01/L2026001).
-- Pré-requisito: 20260731_0001_add_linha_giro.sql (colunas linha/giro).
--
-- Como aplicar (segura ou real):
--   mysql -u ... -p ... < storage/migrations/20260731_0003_seed_rebanho_bichara.sql
-- Conferência:
--   SELECT codigo, linha, nome FROM curral WHERE codigo LIKE 'BI-%' ORDER BY codigo;
--   SELECT l.codigo, l.nome, l.giro, l.fase, c.codigo AS curral, le.quantidade, le.peso_medio, le.data_entrada
--   FROM lote l JOIN curral c ON c.id = l.id_curral
--   LEFT JOIN lote_entrada le ON le.id_lote = l.id
--   WHERE l.codigo LIKE 'BI-%' ORDER BY l.codigo;

SET @admin := (SELECT id FROM usuario WHERE login = 'admin' LIMIT 1);

-- Unidade alvo: primeira ativa; se não houver nenhuma, cria BICHARA
SET @unidade := (SELECT id FROM unidade WHERE ativo = 1 ORDER BY id LIMIT 1);

INSERT INTO unidade (nome, codigo, descricao, cidade, estado, responsavel, ativo, created_by)
SELECT 'Conf. Irmãos Bichara', 'BICHARA', 'Unidade principal — carga P6', NULL, NULL, NULL, 1, @admin
WHERE @unidade IS NULL
  AND NOT EXISTS (SELECT 1 FROM unidade WHERE codigo = 'BICHARA');

SET @unidade := IFNULL(@unidade, (SELECT id FROM unidade WHERE codigo = 'BICHARA' LIMIT 1));

-- ============================================================
-- CURRAIS (ocupados + vazios da planilha, incl. 03/15/16 e recepção 17–20)
-- Curral 4 na planilha vem como 4 U / 4 V → dois currais lógicos
-- ============================================================
INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 01', 'BI-C01', 150, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C01');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 02', 'BI-C02', 150, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C02');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 03', 'BI-C03', 150, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C03');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 04 U', 'BI-C04U', 100, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C04U');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 04 V', 'BI-C04V', 100, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C04V');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 05', 'BI-C05', 150, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C05');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 06', 'BI-C06', 150, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C06');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 07', 'BI-C07', 200, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C07');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 08', 'BI-C08', 200, 'CONFINAMENTO', 'A / VELHA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C08');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 09', 'BI-C09', 150, 'CONFINAMENTO', 'B / NOVA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C09');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 10', 'BI-C10', 150, 'CONFINAMENTO', 'B / NOVA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C10');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 11', 'BI-C11', 150, 'CONFINAMENTO', 'B / NOVA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C11');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 12', 'BI-C12', 150, 'CONFINAMENTO', 'B / NOVA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C12');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 13', 'BI-C13', 150, 'CONFINAMENTO', 'B / NOVA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C13');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 14', 'BI-C14', 150, 'CONFINAMENTO', 'B / NOVA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C14');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 15', 'BI-C15', 150, 'CONFINAMENTO', 'B / NOVA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C15');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 16', 'BI-C16', 150, 'CONFINAMENTO', 'B / NOVA', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C16');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 17', 'BI-C17', 100, 'CONFINAMENTO', 'RECEPÇÃO', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C17');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 18', 'BI-C18', 100, 'CONFINAMENTO', 'RECEPÇÃO', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C18');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 19', 'BI-C19', 100, 'CONFINAMENTO', 'RECEPÇÃO', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C19');

INSERT INTO curral (id_unidade, nome, codigo, capacidade, tipo_estrutura, linha, ativo, created_by)
SELECT @unidade, 'Curral 20', 'BI-C20', 100, 'CONFINAMENTO', 'RECEPÇÃO', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM curral WHERE codigo = 'BI-C20');

-- ============================================================
-- LOTES ocupados + lote_entrada (qtd + peso médio) + localização
-- ============================================================

-- Helper: formula por fase (melhor esforço; NULL se não houver)
SET @formula_crescimento := (
  SELECT id FROM formula_racao
  WHERE ativo = 1 AND (UPPER(nome) LIKE '%CRESCIMENTO%' OR id_fase_nutricional = (
    SELECT id FROM fase_nutricional WHERE UPPER(descricao) LIKE '%CRESCIMENTO%' LIMIT 1
  ))
  ORDER BY id LIMIT 1
);
SET @formula_terminacao := (
  SELECT id FROM formula_racao
  WHERE ativo = 1 AND (UPPER(nome) LIKE '%TERMINA%' OR id_fase_nutricional = (
    SELECT id FROM fase_nutricional WHERE UPPER(descricao) LIKE '%TERMINA%' LIMIT 1
  ))
  ORDER BY id LIMIT 1
);

-- Macro por linha de lote (repetida abaixo de forma explícita)

-- BI-L01 / Curral 01
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C01'), 'Lote Curral 01', 'BI-L01', '2026-02-26', 'TERMINACAO', 'ENGORDA', 'ATIVO', '1º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L01');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 37, 351.72, ROUND(37 * 351.72, 2), '2026-02-26', @admin
FROM lote l
WHERE l.codigo = 'BI-L01'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-02-26', 37, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l
WHERE l.codigo = 'BI-L01'
  AND NOT EXISTS (
    SELECT 1 FROM movimentacao_localizacao ml
    WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%'
  );

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-02-26', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l
WHERE l.codigo = 'BI-L01'
  AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM movimentacao_dieta md
    WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%'
  );

-- BI-L02
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C02'), 'Lote Curral 02', 'BI-L02', '2026-05-13', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L02');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 79, 359.00, ROUND(79 * 359.00, 2), '2026-05-13', @admin
FROM lote l WHERE l.codigo = 'BI-L02'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-05-13', 79, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L02'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-05-13', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L02' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L04U
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C04U'), 'Lote Curral 04 U', 'BI-L04U', '2026-06-06', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L04U');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 45, 427.00, ROUND(45 * 427.00, 2), '2026-06-06', @admin
FROM lote l WHERE l.codigo = 'BI-L04U'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-06-06', 45, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L04U'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-06-06', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L04U' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L04V
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C04V'), 'Lote Curral 04 V', 'BI-L04V', '2026-06-06', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L04V');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 35, 340.00, ROUND(35 * 340.00, 2), '2026-06-06', @admin
FROM lote l WHERE l.codigo = 'BI-L04V'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-06-06', 35, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L04V'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-06-06', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L04V' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L05
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C05'), 'Lote Curral 05', 'BI-L05', '2026-04-17', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L05');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 54, 396.70, ROUND(54 * 396.70, 2), '2026-04-17', @admin
FROM lote l WHERE l.codigo = 'BI-L05'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-04-17', 54, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L05'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-04-17', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L05' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L06 (CRESCIMENTO)
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C06'), 'Lote Curral 06', 'BI-L06', '2026-07-17', 'CRESCIMENTO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L06');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 66, 304.00, ROUND(66 * 304.00, 2), '2026-07-17', @admin
FROM lote l WHERE l.codigo = 'BI-L06'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-07-17', 66, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L06'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_crescimento, '2026-07-17', 'Carga inicial P6 — CRESCIMENTO', @admin
FROM lote l WHERE l.codigo = 'BI-L06' AND @formula_crescimento IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L07 (CRESCIMENTO)
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C07'), 'Lote Curral 07', 'BI-L07', '2026-07-16', 'CRESCIMENTO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L07');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 101, 339.00, ROUND(101 * 339.00, 2), '2026-07-16', @admin
FROM lote l WHERE l.codigo = 'BI-L07'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-07-16', 101, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L07'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_crescimento, '2026-07-16', 'Carga inicial P6 — CRESCIMENTO', @admin
FROM lote l WHERE l.codigo = 'BI-L07' AND @formula_crescimento IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L08
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C08'), 'Lote Curral 08', 'BI-L08', '2026-04-16', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L08');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 103, 340.00, ROUND(103 * 340.00, 2), '2026-04-16', @admin
FROM lote l WHERE l.codigo = 'BI-L08'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-04-16', 103, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L08'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-04-16', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L08' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L09
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C09'), 'Lote Curral 09', 'BI-L09', '2026-05-13', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L09');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 97, 336.00, ROUND(97 * 336.00, 2), '2026-05-13', @admin
FROM lote l WHERE l.codigo = 'BI-L09'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-05-13', 97, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L09'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-05-13', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L09' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L10
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C10'), 'Lote Curral 10', 'BI-L10', '2026-04-15', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L10');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 43, 340.00, ROUND(43 * 340.00, 2), '2026-04-15', @admin
FROM lote l WHERE l.codigo = 'BI-L10'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-04-15', 43, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L10'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-04-15', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L10' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L11
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C11'), 'Lote Curral 11', 'BI-L11', '2026-07-16', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L11');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 97, 349.80, ROUND(97 * 349.80, 2), '2026-07-16', @admin
FROM lote l WHERE l.codigo = 'BI-L11'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-07-16', 97, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L11'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-07-16', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L11' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L12
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C12'), 'Lote Curral 12', 'BI-L12', '2026-05-08', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L12');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 102, 340.00, ROUND(102 * 340.00, 2), '2026-05-08', @admin
FROM lote l WHERE l.codigo = 'BI-L12'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-05-08', 102, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L12'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-05-08', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L12' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L13
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C13'), 'Lote Curral 13', 'BI-L13', '2026-07-06', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L13');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 108, 355.80, ROUND(108 * 355.80, 2), '2026-07-06', @admin
FROM lote l WHERE l.codigo = 'BI-L13'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-07-06', 108, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L13'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-07-06', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L13' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');

-- BI-L14
INSERT INTO lote (id_unidade, id_curral, nome, codigo, data_formacao, fase, objetivo, status, giro, ativo, created_by)
SELECT @unidade, (SELECT id FROM curral WHERE codigo = 'BI-C14'), 'Lote Curral 14', 'BI-L14', '2026-05-12', 'TERMINACAO', 'ENGORDA', 'ATIVO', '2º', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM lote WHERE codigo = 'BI-L14');

INSERT INTO lote_entrada (id_lote, quantidade, peso_medio, peso_total, data_entrada, created_by)
SELECT l.id, 100, 340.00, ROUND(100 * 340.00, 2), '2026-05-12', @admin
FROM lote l WHERE l.codigo = 'BI-L14'
  AND NOT EXISTS (SELECT 1 FROM lote_entrada le WHERE le.id_lote = l.id);

INSERT INTO movimentacao_localizacao (id_lote, id_curral_origem, id_curral_destino, data_movimentacao, quantidade, motivo, created_by)
SELECT l.id, NULL, l.id_curral, '2026-05-12', 100, 'Carga inicial P6 (planilha Acompanhamento)', @admin
FROM lote l WHERE l.codigo = 'BI-L14'
  AND NOT EXISTS (SELECT 1 FROM movimentacao_localizacao ml WHERE ml.id_lote = l.id AND ml.motivo LIKE 'Carga inicial P6%');

INSERT INTO movimentacao_dieta (id_lote, id_formula_racao, data_troca, motivo, created_by)
SELECT l.id, @formula_terminacao, '2026-05-12', 'Carga inicial P6 — TERMINAÇÃO', @admin
FROM lote l WHERE l.codigo = 'BI-L14' AND @formula_terminacao IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM movimentacao_dieta md WHERE md.id_lote = l.id AND md.motivo LIKE 'Carga inicial P6%');
