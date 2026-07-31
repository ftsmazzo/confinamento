-- P2 / E06 — Campos Linha (curral) e Giro (lote)
-- Vocabulário operacional da fazenda (ex.: Linha 1/2/A/B/RECEPÇÃO; Giro 1º/2º).
-- Aplicar no Adminer (ou mysql CLI) na versão real DEPOIS do deploy do código deste passo.
-- Idempotente: só adiciona a coluna se ainda não existir.

-- Curral: linha física / agrupamento
SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'curral'
    AND COLUMN_NAME = 'linha'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE `curral`
     ADD COLUMN `linha` VARCHAR(50) NULL DEFAULT NULL
       COMMENT ''Linha operacional (ex: 1, 2, A, B, RECEPÇÃO)''
       AFTER `tipo_estrutura`,
     ADD INDEX `idx_curral_linha` (`linha`)',
  'SELECT ''curral.linha já existe'' AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Lote: giro / ciclo de engorda
SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'lote'
    AND COLUMN_NAME = 'giro'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE `lote`
     ADD COLUMN `giro` VARCHAR(50) NULL DEFAULT NULL
       COMMENT ''Giro/ciclo do lote (ex: 1, 2, 1º, 2º)''
       AFTER `fase`,
     ADD INDEX `idx_lote_giro` (`giro`)',
  'SELECT ''lote.giro já existe'' AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
