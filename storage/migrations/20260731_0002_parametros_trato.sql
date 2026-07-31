-- P4 / E01·E10 — Parâmetros do motor de previsão de trato + limiares de alerta
-- Defaults da planilha Bichara: GMD 1,5 · %PV 2,25 · turnos 30/20/20/30 · alerta 100/110
-- Idempotente: só insere a chave se ainda não existir.

INSERT INTO `configuracao` (`chave`, `valor`, `updated_by`, `updated_at`)
SELECT 'trato_gmd', '1.5', NULL, NOW()
WHERE NOT EXISTS (SELECT 1 FROM `configuracao` WHERE `chave` = 'trato_gmd');

INSERT INTO `configuracao` (`chave`, `valor`, `updated_by`, `updated_at`)
SELECT 'trato_pct_peso_vivo', '2.25', NULL, NOW()
WHERE NOT EXISTS (SELECT 1 FROM `configuracao` WHERE `chave` = 'trato_pct_peso_vivo');

INSERT INTO `configuracao` (`chave`, `valor`, `updated_by`, `updated_at`)
SELECT 'trato_turno_1_pct', '30', NULL, NOW()
WHERE NOT EXISTS (SELECT 1 FROM `configuracao` WHERE `chave` = 'trato_turno_1_pct');

INSERT INTO `configuracao` (`chave`, `valor`, `updated_by`, `updated_at`)
SELECT 'trato_turno_2_pct', '20', NULL, NOW()
WHERE NOT EXISTS (SELECT 1 FROM `configuracao` WHERE `chave` = 'trato_turno_2_pct');

INSERT INTO `configuracao` (`chave`, `valor`, `updated_by`, `updated_at`)
SELECT 'trato_turno_3_pct', '20', NULL, NOW()
WHERE NOT EXISTS (SELECT 1 FROM `configuracao` WHERE `chave` = 'trato_turno_3_pct');

INSERT INTO `configuracao` (`chave`, `valor`, `updated_by`, `updated_at`)
SELECT 'trato_turno_4_pct', '30', NULL, NOW()
WHERE NOT EXISTS (SELECT 1 FROM `configuracao` WHERE `chave` = 'trato_turno_4_pct');

INSERT INTO `configuracao` (`chave`, `valor`, `updated_by`, `updated_at`)
SELECT 'trato_alerta_dias', '100', NULL, NOW()
WHERE NOT EXISTS (SELECT 1 FROM `configuracao` WHERE `chave` = 'trato_alerta_dias');

INSERT INTO `configuracao` (`chave`, `valor`, `updated_by`, `updated_at`)
SELECT 'trato_alerta_risco_dias', '110', NULL, NOW()
WHERE NOT EXISTS (SELECT 1 FROM `configuracao` WHERE `chave` = 'trato_alerta_risco_dias');
