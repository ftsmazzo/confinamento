-- Dois cadastros simples que faltavam no modulo Sanitario:
-- 1. TIPO_APLICACAO: via/forma de administracao do produto (intramuscular,
--    subcutanea, oral, pour-on, topica etc) -- hoje aplicacao_sanitaria
--    nao tinha NENHUM campo para isso.
-- 2. MOTIVO_TRATAMENTO: causa/motivo que levou a um tratamento -- nao
--    confundir com motivo_perda (que e do modulo Manejo, usado em
--    mortalidade/obito, semanticamente diferente).
--
-- Ambos seguem o padrao "cadastro simples em modal" ja usado em
-- Situacoes, Tipos de Entrada/Saida, Motivos de Perda etc: so
-- id + descricao + auditoria, sem campo "ativo".

-- ============================================================
-- 1. TIPO_APLICACAO
-- ============================================================
CREATE TABLE IF NOT EXISTS `tipo_aplicacao` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `descricao` VARCHAR(100) NOT NULL,
    `created_by` INT UNSIGNED NULL DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_by` INT UNSIGNED NULL DEFAULT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_tipo_aplicacao_descricao` (`descricao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tipo_aplicacao` (`descricao`) VALUES
    ('Intramuscular'),
    ('Subcutânea'),
    ('Oral'),
    ('Pour-on'),
    ('Tópica'),
    ('Intravenosa'),
    ('Intranasal');

-- ============================================================
-- 2. MOTIVO_TRATAMENTO
-- ============================================================
CREATE TABLE IF NOT EXISTS `motivo_tratamento` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `descricao` VARCHAR(100) NOT NULL,
    `created_by` INT UNSIGNED NULL DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_by` INT UNSIGNED NULL DEFAULT NULL,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_motivo_tratamento_descricao` (`descricao`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `motivo_tratamento` (`descricao`) VALUES
    ('Vacinação de Rotina'),
    ('Reforço Vacinal'),
    ('Vermifugação'),
    ('Tratamento Clínico'),
    ('Prevenção'),
    ('Suplementação'),
    ('Outro');

-- ============================================================
-- 3. Vincula os dois cadastros a aplicacao_sanitaria (ambos opcionais
--    -- nao quebra registros ja existentes)
-- ============================================================
ALTER TABLE `aplicacao_sanitaria`
    ADD COLUMN `id_tipo_aplicacao` INT UNSIGNED NULL DEFAULT NULL AFTER `id_produto_estoque`,
    ADD COLUMN `id_motivo_tratamento` INT UNSIGNED NULL DEFAULT NULL AFTER `id_tipo_aplicacao`,
    ADD CONSTRAINT `fk_aplicacao_sanitaria_tipo_aplicacao` FOREIGN KEY (`id_tipo_aplicacao`) REFERENCES `tipo_aplicacao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    ADD CONSTRAINT `fk_aplicacao_sanitaria_motivo_tratamento` FOREIGN KEY (`id_motivo_tratamento`) REFERENCES `motivo_tratamento` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- ============================================================
-- PERMISSOES
-- ============================================================
INSERT INTO `usuario_permissao` (`agrupamento`, `grupo`, `permissao`, `descricao`)
SELECT `seed`.`agrupamento`, `seed`.`grupo`, `seed`.`permissao`, `seed`.`descricao`
FROM (
    SELECT 'Sanitário' AS `agrupamento`, 'tipos_aplicacao' AS `grupo`, 'tipo_aplicacao_gerenciar' AS `permissao`, 'Gerenciar' AS `descricao`
    UNION ALL SELECT 'Sanitário', 'tipos_aplicacao', 'tipo_aplicacao_inserir', 'Inserir'
    UNION ALL SELECT 'Sanitário', 'tipos_aplicacao', 'tipo_aplicacao_editar', 'Editar'
    UNION ALL SELECT 'Sanitário', 'tipos_aplicacao', 'tipo_aplicacao_excluir', 'Excluir'

    UNION ALL SELECT 'Sanitário', 'motivos_tratamento', 'motivo_tratamento_gerenciar', 'Gerenciar'
    UNION ALL SELECT 'Sanitário', 'motivos_tratamento', 'motivo_tratamento_inserir', 'Inserir'
    UNION ALL SELECT 'Sanitário', 'motivos_tratamento', 'motivo_tratamento_editar', 'Editar'
    UNION ALL SELECT 'Sanitário', 'motivos_tratamento', 'motivo_tratamento_excluir', 'Excluir'
) AS `seed`
LEFT JOIN `usuario_permissao` `up` ON `up`.`permissao` = `seed`.`permissao`
WHERE `up`.`id` IS NULL;

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
