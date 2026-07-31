-- Classifica produto_estoque por TIPO (enum fixo interno), em vez de
-- depender só da categoria_produto (texto livre). Isso permite:
-- 1. Filtrar/separar telas por tipo (ex: "Medicamentos e Vacinas")
-- 2. Mostrar campos extras (principio ativo, apresentacao, fabricante)
-- somente quando pertinente (MEDICAMENTO/VACINA/SUPLEMENTO)
-- 3. Restringir os selects de produto em Aplicacao Sanitaria para
-- mostrar so produtos de uso sanitario, nao diesel/racao.
--
-- Decisao de arquitetura (confirmada com o usuario): NAO criar tabelas
-- separadas para Medicamento/Vacina/Produto Veterinario -- isso
-- duplicaria toda a logica de estoque (baixa automatica, lote,
-- validade, custo, estoque minimo) que ja existe em produto_estoque.
-- Um enum interno resolve a necessidade de classificar/filtrar sem
-- fragmentar o cadastro de estoque.

ALTER TABLE `produto_estoque`
    ADD COLUMN `tipo_produto` ENUM(
        'RACAO_INSUMO',
        'MEDICAMENTO',
        'VACINA',
        'SUPLEMENTO',
        'MATERIAL_CONSUMO',
        'COMBUSTIVEL_LUBRIFICANTE',
        'OUTRO'
    ) NOT NULL DEFAULT 'OUTRO' COMMENT 'classificacao interna fixa, independente da categoria_produto (texto livre)' AFTER `id_categoria_produto`,
    ADD COLUMN `principio_ativo` VARCHAR(150) NULL DEFAULT NULL COMMENT 'relevante para MEDICAMENTO/VACINA/SUPLEMENTO' AFTER `nome`,
    ADD COLUMN `apresentacao` VARCHAR(100) NULL DEFAULT NULL COMMENT 'ex: injetavel, comprimido, po, liquido oral' AFTER `principio_ativo`,
    ADD COLUMN `fabricante` VARCHAR(150) NULL DEFAULT NULL COMMENT 'fabricante/laboratorio, relevante para MEDICAMENTO/VACINA' AFTER `apresentacao`,
    ADD INDEX `idx_produto_estoque_tipo` (`tipo_produto`);

-- Classifica os 3 produtos sanitarios de teste ja existentes (se
-- houver) para refletir o novo enum -- ajuste manual pontual, nao
-- afeta produtos que nao sejam claramente sanitarios.
UPDATE `produto_estoque`
SET `tipo_produto` = 'VACINA'
WHERE `nome` LIKE '%vacina%' AND `tipo_produto` = 'OUTRO';

UPDATE `produto_estoque`
SET `tipo_produto` = 'MEDICAMENTO'
WHERE (`nome` LIKE '%vermifug%' OR `nome` LIKE '%antibiotic%' OR `nome` LIKE '%anti-inflamat%')
    AND `tipo_produto` = 'OUTRO';

UPDATE `produto_estoque`
SET `tipo_produto` = 'COMBUSTIVEL_LUBRIFICANTE'
WHERE (`nome` LIKE '%diesel%' OR `nome` LIKE '%oleo%' OR `nome` LIKE '%lubrific%')
    AND `tipo_produto` = 'OUTRO';
