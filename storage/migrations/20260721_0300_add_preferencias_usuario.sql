-- Adiciona colunas específicas para visão das contas financeiras

ALTER TABLE `usuario_preferencia`
    ADD COLUMN `contas_pagar_visao` VARCHAR(10) NOT NULL DEFAULT 'list' COMMENT 'list|grouped' AFTER `tema`,
    ADD COLUMN `contas_receber_visao` VARCHAR(10) NOT NULL DEFAULT 'list' COMMENT 'list|grouped' AFTER `contas_pagar_visao`;
