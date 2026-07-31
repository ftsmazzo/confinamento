-- ============================================================
-- Módulo Financeiro — Contas a Pagar / Receber + Plano de Contas
-- ============================================================
-- Decisão de arquitetura:
--   Tabelas separadas para conta_pagar e conta_receber (em vez
--   de uma única tabela lancamento_financeiro com tipo) por
--   clareza de domínio, FKs específicas (fornecedor/cliente) e
--   simplicidade de implementação. O Plano de Contas serve como
--   classificação contábil opcional para ambas.
--
--   Centro de Custo já existe no módulo Confinamento e é
--   reaproveitado aqui como classificação opcional.
-- ============================================================

-- --------------------------------------------------
-- 1. Plano de Contas
-- --------------------------------------------------
CREATE TABLE `plano_conta` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `codigo` VARCHAR(20) NOT NULL COMMENT 'Código de classificação (ex: 1.1.1)',
    `nome` VARCHAR(100) NOT NULL,
    `tipo` ENUM('RECEITA','DESPESA') NOT NULL DEFAULT 'DESPESA' COMMENT 'Natureza da conta',
    `descricao` VARCHAR(255) DEFAULT NULL,
    `ativo` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `updated_by` INT UNSIGNED DEFAULT NULL,
    INDEX `idx_plano_conta_tipo` (`tipo`),
    INDEX `idx_plano_conta_ativo` (`ativo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- 2. Contas a Pagar
-- --------------------------------------------------
CREATE TABLE `conta_pagar` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `id_fornecedor` INT DEFAULT NULL COMMENT 'Fornecedor vinculado (opcional)',
    `id_plano_conta` INT UNSIGNED DEFAULT NULL COMMENT 'Classificação contábil',
    `id_centro_custo` INT UNSIGNED DEFAULT NULL COMMENT 'Centro de custo (opcional)',
    `descricao` VARCHAR(255) NOT NULL COMMENT 'Descrição da conta',
    `valor` DECIMAL(12,2) NOT NULL COMMENT 'Valor nominal',
    `data_vencimento` DATE NOT NULL COMMENT 'Data de vencimento',
    `data_pagamento` DATE DEFAULT NULL COMMENT 'Data em que foi paga',
    `forma_pagamento` VARCHAR(50) DEFAULT NULL COMMENT 'Dinheiro, cartão, boleto, pix, etc',
    `documento` VARCHAR(100) DEFAULT NULL COMMENT 'Número da NF, boleto, contrato',
    `status` ENUM('PENDENTE','PAGO','CANCELADO') NOT NULL DEFAULT 'PENDENTE',
    `observacao` TEXT DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `updated_by` INT UNSIGNED DEFAULT NULL,
    INDEX `idx_conta_pagar_status` (`status`),
    INDEX `idx_conta_pagar_vencimento` (`data_vencimento`),
    INDEX `idx_conta_pagar_fornecedor` (`id_fornecedor`),
    INDEX `idx_conta_pagar_plano_conta` (`id_plano_conta`),
    CONSTRAINT `fk_conta_pagar_fornecedor` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor`(`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_conta_pagar_plano_conta` FOREIGN KEY (`id_plano_conta`) REFERENCES `plano_conta`(`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_conta_pagar_centro_custo` FOREIGN KEY (`id_centro_custo`) REFERENCES `centro_custo`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- 3. Contas a Receber
-- --------------------------------------------------
CREATE TABLE `conta_receber` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `id_cliente` INT DEFAULT NULL COMMENT 'Cliente vinculado (opcional)',
    `id_plano_conta` INT UNSIGNED DEFAULT NULL COMMENT 'Classificação contábil',
    `id_centro_custo` INT UNSIGNED DEFAULT NULL COMMENT 'Centro de custo (opcional)',
    `descricao` VARCHAR(255) NOT NULL COMMENT 'Descrição da conta',
    `valor` DECIMAL(12,2) NOT NULL COMMENT 'Valor nominal',
    `data_vencimento` DATE NOT NULL COMMENT 'Data de vencimento',
    `data_recebimento` DATE DEFAULT NULL COMMENT 'Data em que foi recebida',
    `forma_pagamento` VARCHAR(50) DEFAULT NULL COMMENT 'Dinheiro, cartão, boleto, pix, etc',
    `documento` VARCHAR(100) DEFAULT NULL COMMENT 'Número da NF, contrato, pedido',
    `status` ENUM('PENDENTE','RECEBIDO','CANCELADO') NOT NULL DEFAULT 'PENDENTE',
    `observacao` TEXT DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_by` INT UNSIGNED DEFAULT NULL,
    `updated_by` INT UNSIGNED DEFAULT NULL,
    INDEX `idx_conta_receber_status` (`status`),
    INDEX `idx_conta_receber_vencimento` (`data_vencimento`),
    INDEX `idx_conta_receber_cliente` (`id_cliente`),
    INDEX `idx_conta_receber_plano_conta` (`id_plano_conta`),
    CONSTRAINT `fk_conta_receber_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente`(`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_conta_receber_plano_conta` FOREIGN KEY (`id_plano_conta`) REFERENCES `plano_conta`(`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_conta_receber_centro_custo` FOREIGN KEY (`id_centro_custo`) REFERENCES `centro_custo`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- 4. Seed do Plano de Contas (padrão para confinamento)
-- --------------------------------------------------
INSERT INTO `plano_conta` (`codigo`, `nome`, `tipo`, `descricao`) VALUES
('1.1.1', 'Venda de Gado', 'RECEITA', 'Receita com venda de animais para abate ou reprodução'),
('1.1.2', 'Venda de Produtos', 'RECEITA', 'Receita com venda de produtos, subprodutos e excedentes'),
('1.1.3', 'Serviços Prestados', 'RECEITA', 'Receita com serviços prestados a terceiros'),
('1.1.4', 'Outras Receitas', 'RECEITA', 'Outras receitas operacionais'),
('2.1.1', 'Compra de Gado', 'DESPESA', 'Aquisição de animais para engorda/reprodução'),
('2.1.2', 'Alimentação / Nutrição', 'DESPESA', 'Ração, suplementos, sal mineral e insumos nutricionais'),
('2.1.3', 'Sanitário / Medicamentos', 'DESPESA', 'Vacinas, medicamentos e insumos veterinários'),
('2.1.4', 'Mão de Obra / Funcionários', 'DESPESA', 'Salários, encargos e benefícios da equipe'),
('2.1.5', 'Manutenção / Equipamentos', 'DESPESA', 'Manutenção de currais, cercas, máquinas e equipamentos'),
('2.1.6', 'Frete / Transporte', 'DESPESA', 'Frete de insumos, animais e demais cargas'),
('2.1.7', 'Impostos / Taxas', 'DESPESA', 'Impostos, taxas e contribuições'),
('2.1.8', 'Utilidades / Energia / Água', 'DESPESA', 'Contas de energia elétrica, água e telecomunicações'),
('2.1.9', 'Outras Despesas', 'DESPESA', 'Outras despesas operacionais');

-- --------------------------------------------------
-- 5. Permissões do módulo Financeiro
-- --------------------------------------------------
INSERT INTO `usuario_permissao` (`agrupamento`, `grupo`, `permissao`, `descricao`)
SELECT `seed`.`agrupamento`, `seed`.`grupo`, `seed`.`permissao`, `seed`.`descricao`
FROM (
    -- Plano de Contas
    SELECT 'Financeiro' AS `agrupamento`, 'plano_contas' AS `grupo`, 'plano_conta_gerenciar' AS `permissao`, 'Gerenciar' AS `descricao`
    UNION ALL SELECT 'Financeiro', 'plano_contas', 'plano_conta_inserir', 'Inserir'
    UNION ALL SELECT 'Financeiro', 'plano_contas', 'plano_conta_editar', 'Editar'
    UNION ALL SELECT 'Financeiro', 'plano_contas', 'plano_conta_excluir', 'Excluir'
    -- Contas a Pagar
    UNION ALL SELECT 'Financeiro', 'contas_pagar', 'conta_pagar_gerenciar', 'Gerenciar'
    UNION ALL SELECT 'Financeiro', 'contas_pagar', 'conta_pagar_inserir', 'Inserir'
    UNION ALL SELECT 'Financeiro', 'contas_pagar', 'conta_pagar_editar', 'Editar'
    UNION ALL SELECT 'Financeiro', 'contas_pagar', 'conta_pagar_excluir', 'Excluir'
    -- Contas a Receber
    UNION ALL SELECT 'Financeiro', 'contas_receber', 'conta_receber_gerenciar', 'Gerenciar'
    UNION ALL SELECT 'Financeiro', 'contas_receber', 'conta_receber_inserir', 'Inserir'
    UNION ALL SELECT 'Financeiro', 'contas_receber', 'conta_receber_editar', 'Editar'
    UNION ALL SELECT 'Financeiro', 'contas_receber', 'conta_receber_excluir', 'Excluir'
) AS `seed`
LEFT JOIN `usuario_permissao` `up` ON `up`.`permissao` = `seed`.`permissao`
WHERE `up`.`id` IS NULL;

-- --------------------------------------------------
-- 6. Conceder todas as permissões novas ao Admin
-- ---------------------------------------------------
SET @new_permissions := (
    SELECT COALESCE(
        CONCAT(
            '[',
            GROUP_CONCAT(`id` ORDER BY `id` SEPARATOR ','),
            ']'
        ),
        '[]'
    )
    FROM `usuario_permissao`
    WHERE `permissao` IN (
        'plano_conta_gerenciar','plano_conta_inserir','plano_conta_editar','plano_conta_excluir',
        'conta_pagar_gerenciar','conta_pagar_inserir','conta_pagar_editar','conta_pagar_excluir',
        'conta_receber_gerenciar','conta_receber_inserir','conta_receber_editar','conta_receber_excluir'
    )
);

UPDATE `usuario_perfil`
SET `permissoes` = CAST(
    (
        SELECT COALESCE(
            CONCAT(
                '[',
                GROUP_CONCAT(DISTINCT `id` ORDER BY `id` SEPARATOR ','),
                ']'
            ),
            '[]'
        )
        FROM `usuario_permissao`
    ) AS CHAR),
    `updated_at` = NOW()
WHERE `nome` = 'Administrador';

UPDATE `usuario`
SET `permissoes` = (
    SELECT COALESCE(
        CONCAT(
            '[',
            GROUP_CONCAT(DISTINCT `id` ORDER BY `id` SEPARATOR ','),
            ']'
        ),
        '[]'
    )
    FROM `usuario_permissao`
)
WHERE `login` = 'admin';
