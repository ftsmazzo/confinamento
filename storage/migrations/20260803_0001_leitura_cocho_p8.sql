-- P8 / E12 — Leitura de cocho: foto, turno, escore opcional + permissão dieta_dar_nota
-- Idempotente: colunas só se faltarem; permissão só se não existir.

-- foto
SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'leitura_cocho'
        AND COLUMN_NAME = 'foto'
    ),
    'SELECT ''leitura_cocho.foto já existe'' AS info',
    'ALTER TABLE `leitura_cocho`
       ADD COLUMN `foto` VARCHAR(255) NULL DEFAULT NULL
         COMMENT ''arquivo em storage/media/leituras-cocho'' AFTER `observacao`'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- turno
SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'leitura_cocho'
        AND COLUMN_NAME = 'turno'
    ),
    'SELECT ''leitura_cocho.turno já existe'' AS info',
    'ALTER TABLE `leitura_cocho`
       ADD COLUMN `turno` VARCHAR(20) NULL DEFAULT NULL
         COMMENT ''MANHA|MEIO|TARDE|NOITE'' AFTER `data_leitura`,
       ADD INDEX `idx_leitura_cocho_data_turno` (`data_leitura`, `turno`)'
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- escore opcional (permite registrar foto/turno sem nota)
SET @sql := (
  SELECT IF(
    EXISTS(
      SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'leitura_cocho'
        AND COLUMN_NAME = 'escore'
        AND IS_NULLABLE = 'YES'
    ),
    'SELECT ''leitura_cocho.escore já é NULL'' AS info',
    'ALTER TABLE `leitura_cocho`
       MODIFY COLUMN `escore` TINYINT UNSIGNED NULL DEFAULT NULL
         COMMENT ''0-4 industria; NULL = sem nota (sem dieta_dar_nota)'''
  )
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- permissão dieta_dar_nota
INSERT INTO `usuario_permissao` (`agrupamento`, `grupo`, `permissao`, `descricao`)
SELECT 'Nutrição', 'leituras_cocho', 'dieta_dar_nota', 'Lançar escore / nota do cocho'
WHERE NOT EXISTS (
  SELECT 1 FROM `usuario_permissao` WHERE `permissao` = 'dieta_dar_nota'
);

-- Concede ao perfil Administrador e ao usuário admin (todas as permissões atuais)
SET @all_permissions := (
    SELECT COALESCE(
        CONCAT('[', GROUP_CONCAT(`id` ORDER BY `id` SEPARATOR ','), ']'),
        '[]'
    )
    FROM `usuario_permissao`
);

UPDATE `usuario_perfil`
SET `permissoes` = CAST(@all_permissions AS CHAR), `updated_at` = NOW()
WHERE `nome` = 'Administrador';

UPDATE `usuario`
SET `permissoes` = @all_permissions
WHERE `login` = 'admin';
