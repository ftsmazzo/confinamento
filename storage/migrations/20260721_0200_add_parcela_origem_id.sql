-- Adiciona campo parcela_origem_id para agrupar parcelas de uma mesma despesa/receita

ALTER TABLE `conta_pagar`
    ADD COLUMN `parcela_origem_id` INT UNSIGNED DEFAULT NULL AFTER `parcela_total`,
    ADD INDEX `idx_conta_pagar_parcela_origem` (`parcela_origem_id`);

ALTER TABLE `conta_receber`
    ADD COLUMN `parcela_origem_id` INT UNSIGNED DEFAULT NULL AFTER `parcela_total`,
    ADD INDEX `idx_conta_receber_parcela_origem` (`parcela_origem_id`);

-- Popula registros existentes: agrupa por documento ou (descricao + fornecedor) quando parcela_total > 1
UPDATE conta_pagar cp
INNER JOIN (
    SELECT
        COALESCE(documento, CONCAT(descricao, '_', COALESCE(id_fornecedor, 0))) AS `grupo`,
        MIN(id) AS `origem_id`
    FROM conta_pagar
    WHERE parcela_total > 1
    GROUP BY COALESCE(documento, CONCAT(descricao, '_', COALESCE(id_fornecedor, 0)))
) g ON COALESCE(cp.documento, CONCAT(cp.descricao, '_', COALESCE(cp.id_fornecedor, 0))) = g.grupo
SET cp.parcela_origem_id = g.origem_id
WHERE cp.parcela_total > 1;

UPDATE conta_receber cr
INNER JOIN (
    SELECT
        COALESCE(documento, CONCAT(descricao, '_', COALESCE(id_cliente, 0))) AS `grupo`,
        MIN(id) AS `origem_id`
    FROM conta_receber
    WHERE parcela_total > 1
    GROUP BY COALESCE(documento, CONCAT(descricao, '_', COALESCE(id_cliente, 0)))
) g ON COALESCE(cr.documento, CONCAT(cr.descricao, '_', COALESCE(cr.id_cliente, 0))) = g.grupo
SET cr.parcela_origem_id = g.origem_id
WHERE cr.parcela_total > 1;
