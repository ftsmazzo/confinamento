-- ============================================================
-- Adiciona suporte a parcelamento nas contas a pagar/receber
-- ============================================================

ALTER TABLE `conta_pagar`
    ADD COLUMN `parcela_numero` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Número da parcela (1 = primeira)',
    ADD COLUMN `parcela_total` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Total de parcelas',
    ADD INDEX `idx_conta_pagar_parcelas` (`parcela_numero`, `parcela_total`);

ALTER TABLE `conta_receber`
    ADD COLUMN `parcela_numero` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Número da parcela (1 = primeira)',
    ADD COLUMN `parcela_total` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Total de parcelas',
    ADD INDEX `idx_conta_receber_parcelas` (`parcela_numero`, `parcela_total`);
