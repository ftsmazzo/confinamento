ALTER TABLE `usuario_preferencia`
    ADD COLUMN `calendario_eventos` VARCHAR(255) DEFAULT NULL COMMENT 'Tipos de evento visiveis no calendario (separados por virgula)' AFTER `contas_receber_visao`;
