-- --------------------------------------------------------
-- Servidor:                     89.117.57.72
-- Versão do servidor:           8.0.35 - Source distribution
-- OS do Servidor:               Linux
-- HeidiSQL Versão:              12.14.0.7169
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Copiando estrutura para tabela confinamento.ajuste_consumo
CREATE TABLE IF NOT EXISTS `ajuste_consumo` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned NOT NULL,
  `id_leitura_cocho` int unsigned DEFAULT NULL COMMENT 'opcional: leitura que motivou o ajuste',
  `data_ajuste` date NOT NULL,
  `percentual_ajuste` decimal(5,2) DEFAULT NULL COMMENT 'ex: +5.00 = aumentar 5%%, -3.00 = reduzir 3%%',
  `quantidade_ajustada` decimal(10,2) DEFAULT NULL COMMENT 'nova quantidade prevista de trato, se informada diretamente',
  `motivo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ajuste_consumo_lote` (`id_lote`,`data_ajuste`),
  KEY `fk_ajuste_consumo_leitura` (`id_leitura_cocho`),
  CONSTRAINT `fk_ajuste_consumo_leitura` FOREIGN KEY (`id_leitura_cocho`) REFERENCES `leitura_cocho` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ajuste_consumo_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.ajuste_consumo: ~0 rows (aproximadamente)
DELETE FROM `ajuste_consumo`;
INSERT INTO `ajuste_consumo` (`id`, `id_lote`, `id_leitura_cocho`, `data_ajuste`, `percentual_ajuste`, `quantidade_ajustada`, `motivo`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 8, 1, '2026-06-08', 3.00, NULL, 'Cocho limpo, aumentar oferta em 3%', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.animal
CREATE TABLE IF NOT EXISTS `animal` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned DEFAULT NULL,
  `id_fornecedor` int DEFAULT NULL,
  `id_tipo_entrada` int unsigned DEFAULT NULL,
  `identificacao` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_identificacao` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sexo` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `raca` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_nascimento` date DEFAULT NULL,
  `data_entrada` date DEFAULT NULL,
  `peso_entrada` decimal(8,2) DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ATIVO',
  `id_situacao` int unsigned DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_animal_identificacao` (`identificacao`),
  KEY `idx_animal_lote` (`id_lote`),
  KEY `idx_animal_fornecedor` (`id_fornecedor`),
  KEY `fk_animal_tipo_entrada` (`id_tipo_entrada`),
  KEY `fk_animal_situacao` (`id_situacao`),
  CONSTRAINT `fk_animal_fornecedor` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_animal_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_animal_situacao` FOREIGN KEY (`id_situacao`) REFERENCES `animal_situacao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_animal_tipo_entrada` FOREIGN KEY (`id_tipo_entrada`) REFERENCES `tipo_entrada` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.animal: ~7 rows (aproximadamente)
DELETE FROM `animal`;
INSERT INTO `animal` (`id`, `id_lote`, `id_fornecedor`, `id_tipo_entrada`, `identificacao`, `tipo_identificacao`, `sexo`, `raca`, `data_nascimento`, `data_entrada`, `peso_entrada`, `status`, `id_situacao`, `observacao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(2, 8, 4, 1, 'BR001', 'BRINCO', 'M', 'NELORE', '2024-08-01', '2026-05-01', 375.00, 'ATIVO', 1, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 09:32:23'),
	(3, 8, 4, 1, 'BR002', 'BRINCO', 'M', 'NELORE', '2024-08-05', '2026-05-01', 382.00, 'ATIVO', 1, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 09:32:23'),
	(4, 8, 4, 1, 'BR003', 'BRINCO', 'M', 'NELORE', '2024-08-10', '2026-05-01', 378.00, 'ATIVO', 1, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 09:32:23'),
	(5, 9, 4, 1, 'BR004', 'BRINCO', 'M', 'ANGUS', '2024-07-15', '2026-05-10', 405.00, 'ATIVO', 1, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 09:32:23'),
	(6, 9, 4, 1, 'BR005', 'BRINCO', 'M', 'ANGUS', '2024-07-20', '2026-05-10', 398.00, 'ATIVO', 1, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 09:32:23'),
	(7, 10, 4, 1, 'BR006', 'BRINCO', 'M', 'NELORE', '2024-06-01', '2026-06-01', 448.00, 'ATIVO', 1, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 09:32:23'),
	(8, 10, 4, 1, 'BR007', 'BRINCO', 'M', 'NELORE', '2024-06-05', '2026-06-01', 452.00, 'ATIVO', 1, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 09:32:23');

-- Copiando estrutura para tabela confinamento.animal_situacao
CREATE TABLE IF NOT EXISTS `animal_situacao` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cor` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_animal_situacao_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.animal_situacao: ~6 rows (aproximadamente)
DELETE FROM `animal_situacao`;
INSERT INTO `animal_situacao` (`id`, `descricao`, `cor`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'Ativo', '#198754', NULL, '2026-07-10 09:32:22', NULL, '2026-07-10 10:15:47'),
	(2, 'Vendido', '#0d6efd', NULL, '2026-07-10 09:32:22', NULL, '2026-07-10 10:15:47'),
	(3, 'Abatido', '#6c757d', NULL, '2026-07-10 09:32:22', NULL, '2026-07-10 10:15:47'),
	(4, 'Morto', '#dc3545', NULL, '2026-07-10 09:32:22', NULL, '2026-07-10 10:15:47'),
	(5, 'Em Tratamento', '#ffc107', NULL, '2026-07-10 09:32:22', NULL, '2026-07-10 10:15:47'),
	(6, 'Transferido', '#0dcaf0', NULL, '2026-07-10 09:32:22', NULL, '2026-07-10 10:15:47');

-- Copiando estrutura para tabela confinamento.aplicacao_sanitaria
CREATE TABLE IF NOT EXISTS `aplicacao_sanitaria` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned DEFAULT NULL COMMENT 'preenchido quando a aplicacao e em lote (nunca junto com id_animal)',
  `id_animal` int unsigned DEFAULT NULL COMMENT 'preenchido quando a aplicacao e individual (nunca junto com id_lote)',
  `id_protocolo_sanitario` int unsigned DEFAULT NULL COMMENT 'opcional: null quando for tratamento avulso sem protocolo formal',
  `id_produto_estoque` int unsigned DEFAULT NULL,
  `id_tipo_aplicacao` int unsigned DEFAULT NULL,
  `id_motivo_tratamento` int unsigned DEFAULT NULL,
  `id_lote_estoque` int unsigned DEFAULT NULL COMMENT 'obrigatorio na aplicacao quando o produto controla lote',
  `tipo` enum('PROTOCOLO','TRATAMENTO_INDIVIDUAL','TRATAMENTO_LOTE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_aplicacao` date NOT NULL,
  `quantidade_animais` int unsigned DEFAULT NULL COMMENT 'numero de cabecas tratadas, relevante em tratamento de lote',
  `quantidade_produto` decimal(12,2) DEFAULT NULL COMMENT 'quantidade do produto consumida nesta aplicacao',
  `dias_carencia` int unsigned DEFAULT NULL COMMENT 'dias de carencia desta aplicacao especifica (herda do protocolo, mas pode ser sobrescrito)',
  `data_carencia_fim` date DEFAULT NULL COMMENT 'calculada: data_aplicacao + dias_carencia. Usada para bloquear Saida',
  `veterinario_responsavel` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_aplicacao_sanitaria_lote` (`id_lote`,`data_carencia_fim`),
  KEY `idx_aplicacao_sanitaria_animal` (`id_animal`,`data_carencia_fim`),
  KEY `fk_aplicacao_sanitaria_protocolo` (`id_protocolo_sanitario`),
  KEY `fk_aplicacao_sanitaria_produto` (`id_produto_estoque`),
  KEY `fk_aplicacao_sanitaria_lote_estoque` (`id_lote_estoque`),
  KEY `fk_aplicacao_sanitaria_tipo_aplicacao` (`id_tipo_aplicacao`),
  KEY `fk_aplicacao_sanitaria_motivo_tratamento` (`id_motivo_tratamento`),
  CONSTRAINT `fk_aplicacao_sanitaria_animal` FOREIGN KEY (`id_animal`) REFERENCES `animal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_aplicacao_sanitaria_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_aplicacao_sanitaria_lote_estoque` FOREIGN KEY (`id_lote_estoque`) REFERENCES `lote_estoque` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_aplicacao_sanitaria_motivo_tratamento` FOREIGN KEY (`id_motivo_tratamento`) REFERENCES `motivo_tratamento` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_aplicacao_sanitaria_produto` FOREIGN KEY (`id_produto_estoque`) REFERENCES `produto_estoque` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_aplicacao_sanitaria_protocolo` FOREIGN KEY (`id_protocolo_sanitario`) REFERENCES `protocolo_sanitario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_aplicacao_sanitaria_tipo_aplicacao` FOREIGN KEY (`id_tipo_aplicacao`) REFERENCES `tipo_aplicacao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.aplicacao_sanitaria: ~5 rows (aproximadamente)
DELETE FROM `aplicacao_sanitaria`;
INSERT INTO `aplicacao_sanitaria` (`id`, `id_lote`, `id_animal`, `id_protocolo_sanitario`, `id_produto_estoque`, `id_tipo_aplicacao`, `id_motivo_tratamento`, `id_lote_estoque`, `tipo`, `data_aplicacao`, `quantidade_animais`, `quantidade_produto`, `dias_carencia`, `data_carencia_fim`, `veterinario_responsavel`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 8, NULL, 2, 3, NULL, NULL, 3, 'TRATAMENTO_LOTE', '2026-05-02', 50, 50.00, 21, '2026-05-23', 'Ana Paula Souza', NULL, 1, '2026-07-09 18:52:49', NULL, '2026-07-09 18:52:49'),
	(4, NULL, 2, 3, 4, NULL, NULL, NULL, 'TRATAMENTO_INDIVIDUAL', '2026-05-01', NULL, 10.00, 14, '2026-05-15', 'Ana Paula Souza', NULL, 1, '2026-07-09 18:52:49', NULL, '2026-07-09 18:52:49'),
	(5, 9, NULL, NULL, 4, NULL, NULL, NULL, 'TRATAMENTO_LOTE', '2026-06-10', NULL, 60.00, NULL, NULL, 'Ana Paula Souza', 'Tratamento avulso sem protocolo formal, reforço de vermifugação', 1, '2026-07-09 18:52:49', NULL, '2026-07-09 18:52:49'),
	(6, 10, NULL, 2, 3, NULL, NULL, 3, 'TRATAMENTO_LOTE', '2026-06-02', 40, 40.00, 21, '2026-06-23', 'Ana Paula Souza', NULL, 1, '2026-07-09 18:57:18', NULL, '2026-07-09 18:57:18'),
	(7, 9, NULL, NULL, 3, NULL, NULL, NULL, 'TRATAMENTO_LOTE', '2026-07-05', 60, 12.00, 21, '2026-07-26', 'Dra. Ana Veterinária', NULL, 1, '2026-07-10 23:05:13', NULL, '2026-07-10 23:05:13');

-- Copiando estrutura para tabela confinamento.auth_sessions
CREATE TABLE IF NOT EXISTS `auth_sessions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `guard` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `user_id` bigint NOT NULL,
  `token_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `extra_data` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `last_activity` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `revoked` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `guard` (`guard`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `token_hash` (`token_hash`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=137 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.auth_sessions: ~128 rows (aproximadamente)
DELETE FROM `auth_sessions`;
INSERT INTO `auth_sessions` (`id`, `guard`, `user_id`, `token_hash`, `ip`, `user_agent`, `extra_data`, `created_at`, `last_activity`, `revoked`) VALUES
	(1, 'usuario', 1, '1c08fb21075a6dab08cff7c72aad2001b5b4015f2583f38c67cc353143320149', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 00:38:27', '2026-04-17 00:41:29', 1),
	(2, 'usuario', 1, '4fe947c1fef5a9d946debff4115adefbcdbb27a0fc3f9c6b1f8463b8a558b460', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 00:41:34', '2026-04-17 00:43:28', 1),
	(3, 'usuario', 1, '3381ada5d70ec544b0a00866ab9a5298d9b69606a1d99598e0290dfa092b4b93', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 00:43:48', '2026-04-17 00:49:17', 1),
	(4, 'usuario', 1, 'ae4398cddfb3754b1b352f7166996885c8221b6e486f00818835d2e08a0d3042', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 00:51:18', '2026-04-17 00:53:22', 1),
	(5, 'usuario', 1, '0a247aec5d3d390591e824c3c4b6979295001fd7c0d213e5f13d50c5cb3f67ec', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 00:53:28', '2026-04-17 00:57:14', 1),
	(6, 'usuario', 1, 'f5869d494a78ec4fd756052b84089e3b2e326cb179b567d84be4c371e4fb4fa6', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 00:57:22', '2026-04-17 00:57:28', 1),
	(7, 'usuario', 1, '324ecab578eab9be74089e210c466cac40a04e1f57b4bd14de4a31a181b18031', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 08:30:18', '2026-04-17 16:55:38', 1),
	(8, 'usuario', 1, 'b8da12a5980bd9c509aa5086f1f5c35d960cd514abf2e3a34fcf958d1d03c76b', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 17:08:58', '2026-04-17 17:09:05', 1),
	(9, 'usuario', 1, '1b7395418b67de2d0cf60e7d820e08f0dd477f48674d62450a32ae64e46c6a1f', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 17:10:51', '2026-04-17 17:11:01', 1),
	(10, 'usuario', 1, '8a877f19a75f2bd3d02b6a21b94fb3c7d6bf654656978f3539a08acae71dce6d', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 18:15:33', '2026-04-17 18:16:07', 1),
	(11, 'usuario', 1, 'b85cc97e2fa8e8447f1b2129331e633940e7e9189d55bdf3b293afbd0fa3fdea', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 19:40:27', '2026-04-17 19:40:32', 1),
	(12, 'usuario', 1, 'c24f1d50fd612ddd5ad761533dc3f760ec7d814b6969d5af337c759b9edb6d25', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 19:40:40', '2026-04-17 19:40:51', 1),
	(13, 'usuario', 1, '186061b2a0f67fdd2c1f6390ff29c2fa7395f9e665c15bf8f41ec776ee06ac42', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 19:41:02', '2026-04-17 19:47:11', 1),
	(14, 'usuario', 1, '5f47dd50a667628f5ff4eb4a17306868bbe293d01f24953846993b885b6e100c', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 23:24:31', '2026-04-17 23:24:39', 1),
	(15, 'usuario', 1, '6a439064d8b9722dfa6faae345feec54c285dd13fc23e4f0c2cbcd8071bc9995', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 23:29:19', '2026-04-17 23:29:28', 1),
	(16, 'usuario', 1, '3e559ad3053ff4cf059777beebe5b25061d7d08f9dfc2802280afb482a107b27', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 23:29:49', '2026-04-17 23:29:57', 1),
	(17, 'usuario', 1, '96f0194aa354a79dc234b572deb3168d39e96c82856a96d27eb3b75d6944ede8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-17 23:30:35', '2026-04-17 23:32:59', 1),
	(18, 'usuario', 1, '6eaea234cb879872194716cf221406d9cffa472796bd5fb74ea90868dc555dd3', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 09:48:01', '2026-04-18 09:51:53', 1),
	(19, 'usuario', 1, '1a45d973fbb202fe4d4049f178f694cb3d9f946960e75191d78ccc3bc452e441', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 09:52:01', '2026-04-18 10:05:18', 1),
	(20, 'usuario', 1, 'b5f36ca0fb2457de92f3d16c2d6e1fdcab026aaeec1f6ba58b6a8e522e6d9e10', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 10:05:27', '2026-04-18 20:58:23', 1),
	(21, 'usuario', 1, '31e5e611af95f675bfcff930197d402f2d149c2b9ece7aa6240ed46492375b5e', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 10:30:26', '2026-04-18 10:38:41', 1),
	(22, 'usuario', 1, '080dd3137efd3f38ead4fbe6a0faf205d7d8d7b2e50e5aad176b9044cf03df8b', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 10:38:47', '2026-04-18 13:56:13', 1),
	(23, 'usuario', 1, '3ff369158f554538234a181fd8159bfd939e0080b3a29cb7b729685c6d4eda9f', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 13:56:49', '2026-04-18 14:37:20', 1),
	(24, 'usuario', 1, '5fd62d093c34713122acdded28e0bdd42afc9e2db67ba9fc8a6e8b3e81b9269f', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 14:37:26', '2026-04-18 15:44:00', 1),
	(25, 'usuario', 1, '3a843f5b7889f5785a46d34daffd01879efe385eee9154953279afe7f22e0314', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 15:44:15', '2026-04-18 18:23:13', 1),
	(26, 'usuario', 1, '9fef1a8822d985ddc94e2e5b7ef68eea8b921710046b2d9734935d5eaac24072', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 18:23:41', '2026-04-18 20:48:27', 1),
	(27, 'usuario', 1, 'e388083f76219470894917536ed0d3620fb3442c1f25db231d70f7e6266dcee6', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 20:48:46', '2026-04-18 20:58:23', 1),
	(28, 'usuario', 1, '60c606880aec759c170f4e3421b0d73e2e0151a068bb673e2a1bef875d7f31b6', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-18 21:00:29', '2026-04-19 17:27:14', 1),
	(29, 'usuario', 1, 'f0384cb2277907f5067daf43e32fe0cfbf689d44be6585a9a215943eda47c89d', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-19 18:20:25', '2026-04-19 18:20:25', 0),
	(30, 'usuario', 1, '581ba313a76f9561fa0781594595d43c7478d00ca5b937d2f1949ef8e4144b83', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-19 19:53:17', '2026-04-19 19:56:20', 1),
	(31, 'usuario', 1, '68ae65fd83f51809413339bb0c8a21652cec806716f13d36746de1d0c5e2b1a7', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36', NULL, '2026-04-19 19:56:30', '2026-04-19 20:16:51', 0),
	(32, 'usuario', 1, '70beb9325db9cd9f0acd4df8f71418b8c6f2e705eddbae7eef70203f8f51092a', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-20 21:33:42', '2026-04-20 21:35:58', 1),
	(33, 'usuario', 1, '03e56d2bc6cd34b898a3df8a92e86b3db6d0d4a672d133192ebdd536370d1033', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36', NULL, '2026-04-20 21:36:08', '2026-04-20 22:00:18', 1),
	(34, 'usuario', 1, '2987eba2160067429b42af6ff3172c63357043da26adc55ba78b12c5bacd7e6d', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-20 22:00:25', '2026-04-20 22:03:32', 1),
	(35, 'usuario', 1, '7aa917ac752bec68a35a43b21b4e8d96f04af6b7d9b3762cdc94cab2f921c21a', '127.0.0.1', 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36', NULL, '2026-04-20 22:03:42', '2026-04-20 22:09:02', 1),
	(36, 'usuario', 1, 'aae4f91e4207cbadab4b9d088571bc944c3e8e92af00070578fc68827965f181', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-20 22:20:45', '2026-04-21 01:14:17', 0),
	(37, 'usuario', 1, 'f654352274793c1bf9940bb09a20191d4721e47edad434e8f7ed1f6793a0c13c', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-21 09:28:53', '2026-04-21 18:16:57', 1),
	(38, 'usuario', 1, '56a8c48a90a697ef5d5762ab4690f80076811c5b6e4f06bdd56a288d626316f6', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-21 18:18:44', '2026-04-21 22:58:30', 1),
	(39, 'usuario', 1, 'f1af1c73447d40aa20d82da5d280f6646d4d780d3f991b7845c22f0559f89a7a', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-21 22:58:40', '2026-04-22 01:24:18', 1),
	(40, 'usuario', 1, 'b284a5bbfd9d6161b78ed7b7ad4989679ae6d240ef619ba1b7630a882844bdb0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-22 09:36:15', '2026-04-22 17:49:02', 0),
	(41, 'usuario', 1, '5a0cbd108a4d213da4f04c57eb3822d1b0912ccef9663dacde4f1ecf26a5c22c', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-23 09:34:40', '2026-04-23 21:35:33', 1),
	(42, 'usuario', 1, 'c914d289f3978bfda104f14867124b0f60186102c8f22e2e3d5883f1619dcb71', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-23 21:36:01', '2026-04-24 08:16:15', 1),
	(43, 'usuario', 1, '1199e3e1177a6751645452f9ab655318d6d40cd02305b14e199e8c591756307a', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-24 08:16:33', '2026-04-24 17:10:37', 0),
	(44, 'usuario', 1, 'a19a000da447def6676fdb9b43a6c3b3b047e5506dadebfbe37b7f7e7be6f77d', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-04-25 08:50:17', '2026-04-26 07:33:38', 1),
	(45, 'usuario', 1, 'a56829ae5c75f4f461098c75a2f539792d2d1a91f615cff5b70ad393cc871bfc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-05-01 15:50:11', '2026-05-01 23:08:40', 1),
	(46, 'usuario', 1, '6118b026b1b8433e8ddc9ee9190daa6fc97989e72dda3271cae1ca9ae57ed9db', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-05-01 23:10:24', '2026-05-01 23:10:45', 1),
	(47, 'usuario', 1, 'cba6a97c0917ed384fe7ff9240b5dd6f739d325729b24383cdbcf65089294ab6', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', NULL, '2026-05-02 00:17:43', '2026-05-02 00:26:00', 1),
	(48, 'usuario', 1, 'a5ff918abec58027f81608a19f06c6344c9e7a1fd632173377de30f392bccbb0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', NULL, '2026-05-22 16:39:01', '2026-05-22 16:39:02', 0),
	(49, 'usuario', 1, '3eabd25c99338f7ad75bd27fcc8a7823a9fd304e5419d2e790722f0eedfee412', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-07-08 15:17:49', '2026-07-08 16:23:06', 1),
	(50, 'usuario', 1, 'bd1b194524a469fcba8ef9c1794e8331f075c074ed1f0d34335ddc9e32b2cce3', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-08 16:02:50', '2026-07-08 16:09:13', 0),
	(51, 'usuario', 1, 'd8d455220e3797568d0ced852e54e10c85331e1df8f7ae7f9e2c9553973b16cc', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-08 16:43:31', '2026-07-08 16:47:14', 0),
	(52, 'usuario', 1, '1565c0b235494530b6f8207c4939b02194c6ec4e32ac6105280ae46641441f45', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-07-08 16:54:45', '2026-07-09 11:51:42', 1),
	(53, 'usuario', 1, '034e4f16abd8545161820f2c3692475529c2d6bc89e33f9dac85fc69102fbc5d', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-08 16:55:53', '2026-07-08 16:58:06', 0),
	(54, 'usuario', 1, 'abdd289bece9995a99e5faedcb8c0c803830e333e695b7e8d856e2442dc09fa0', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-08 17:08:46', '2026-07-08 17:08:46', 0),
	(55, 'usuario', 1, '04c531bac84b81cf3fef9e75c95a804b4dfb7dbc53469d8387f66c11865e0c66', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 09:15:42', '2026-07-09 09:19:54', 0),
	(56, 'usuario', 1, '0653f63702454f7bcfa2ad01d0b2c2bdeebb0c13f241faa96d9801dac74441df', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 09:36:37', '2026-07-09 09:43:55', 0),
	(57, 'usuario', 1, '109db65cdd2a6469dc98e997d41a82b3904fd11ed5f6692321148f37ebd29e13', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-07-09 11:54:50', '2026-07-10 09:11:13', 1),
	(58, 'usuario', 1, '4d942d651d60ec0afdd83f92ba4198fb16c2c1db079e3616a769da6c2cec2274', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 13:52:33', '2026-07-09 13:56:47', 0),
	(59, 'usuario', 1, 'd527a6729fc7318c3b8703b4da9b3a7222688c65c9cf137e6899ae9c96d380b4', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 14:30:18', '2026-07-09 14:34:37', 0),
	(60, 'usuario', 1, '25e37fa062a0e4aa1af2e48853b28ee18853e2d4c5b19582fbf7e3be21d1a75a', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 14:55:45', '2026-07-09 14:57:00', 0),
	(61, 'usuario', 1, '1d23d798080f508230b976e492c388c57b6a4309f6b237ddf11b64278b9efdef', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 15:06:54', '2026-07-09 15:09:01', 0),
	(62, 'usuario', 1, '7840ad74b67c5c5b78a85e830f26b3842002b764501a35bf93dcab00a690ba39', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 16:27:51', '2026-07-09 16:33:40', 0),
	(63, 'usuario', 1, 'd73bd5ca2c110f2d5c2842d563720a4fd6ed254834f4646babd1848a0d934f0e', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 17:28:46', '2026-07-09 17:30:56', 0),
	(64, 'usuario', 1, '77a78087ab82b557b508d009952537c076388eebe7ce5fa24c528e9280a11a78', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-09 18:48:52', '2026-07-09 18:53:09', 0),
	(65, 'usuario', 1, 'bd4474cdfba437496de69e7d62d97a0389b51cda902cc21d735312af59722edb', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 09:05:44', '2026-07-10 09:07:00', 0),
	(66, 'usuario', 1, '36f181c9a8f80503369c41c616f30a36d50784d89fb299d43d6e48a6799febcd', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 09:11:50', '2026-07-10 11:41:00', 1),
	(67, 'usuario', 1, 'b949abd2d3c5add54537e4557ef0b209f32d5ec273036be3c6f701fa076adfb1', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 09:49:59', '2026-07-10 09:53:16', 0),
	(68, 'usuario', 1, '52c12406ab9801b5777cf82598614d110899031460401e91b7d98cb25ba3e280', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 10:10:11', '2026-07-10 10:10:11', 0),
	(69, 'usuario', 1, '0f4637ac13b14dff70494a5bfbb7013ea58c01112a84d73f5971d356fdc38493', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 10:18:30', '2026-07-10 10:18:30', 0),
	(70, 'usuario', 1, '6a83f9554bf4d0b5cbe77d2ceff88d16988fa3947b1277c2670264ef6d6f0f59', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 10:25:53', '2026-07-10 10:29:10', 0),
	(71, 'usuario', 1, '7ee2be9d91a477e0848df21af838eede8381315824b67b7d80fae1385fc6d2ac', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 10:29:12', '2026-07-10 10:33:09', 0),
	(72, 'usuario', 1, 'cd33b7d3a8f538e3b3c1a687d5764b8a2389bf2930f439afdee337ef63515ff1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 10:33:10', '2026-07-10 10:34:11', 0),
	(73, 'usuario', 1, 'c38adb156b9378312224b04b0af4b95d0d0340043a17776ef591e9422b3c9502', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 10:55:31', '2026-07-10 10:55:31', 0),
	(74, 'usuario', 1, '7105020d3a9e68bee0b7f94bf0e38429afa73d2e53f6009443a58a771ddb4d27', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 10:57:04', '2026-07-10 10:57:04', 0),
	(75, 'usuario', 1, 'c291cbd4a9dad2cc355d21c74c3b1fb3d76ee3f107a4ffb5f5d119998a04a18c', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 10:59:28', '2026-07-10 10:59:28', 0),
	(76, 'usuario', 1, '74d1a5791a16893a2eeb9cbb777cc10541803c027fcf3f4d532834091d2881af', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 11:17:48', '2026-07-10 11:17:48', 0),
	(77, 'usuario', 1, '5a1cfa3851f72ac8db59274186ad66a7e5a2001e5b302ef0d64d5bb4f17057ed', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 11:18:32', '2026-07-10 11:18:32', 0),
	(78, 'usuario', 1, '300ce0f9abd2a86009758a6f0233b632677fb6519cb2527960555dfcb36250e2', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 11:18:45', '2026-07-10 11:18:45', 0),
	(79, 'usuario', 1, '2f05f1f139c25bb9e6a0257e7bfce7705d8709f096ecf7d5010c9fdb7bb5b852', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 11:32:20', '2026-07-10 11:32:20', 0),
	(80, 'usuario', 1, '98dd130190699d00c0cd97a148053aa86a4632c81428ca505d9505ab53a4442f', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 11:32:59', '2026-07-10 11:32:59', 0),
	(81, 'usuario', 1, '8cc72cc136dfec3309ad1464e0d777a118271bb97c607b55ca5b99ac5e2945bd', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 11:33:19', '2026-07-10 11:33:19', 0),
	(82, 'usuario', 1, '3768f781b655bf7034bb73981a4b880782b42597d13f5dd79f1f3dee20a8c65b', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 11:33:47', '2026-07-10 11:33:47', 0),
	(83, 'usuario', 1, '8cc6b5aaae8e9efc10b6d1acc0c119f1f8f2ed49cb1f468c8a4fdf9766a780b6', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 11:45:17', '2026-07-10 11:45:17', 0),
	(84, 'usuario', 1, 'c039a4e71c043b1dce0ce30d421d7240dac4e97180a445c9211b386773c4645d', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 12:26:36', '2026-07-10 12:55:23', 1),
	(85, 'usuario', 1, '30af6ed775965665f764d35dea1b557841c1c45ff9e20cb3af13ebb52b2e3ad1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 13:02:31', '2026-07-10 22:43:16', 1),
	(86, 'usuario', 1, 'e9260b0325965e5660b12cbacd444703a707d79086b0972ba33138c1e064414c', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 16:03:46', '2026-07-10 16:05:16', 0),
	(87, 'usuario', 1, '3e976f52faeb3ceb6d4279dbd4e660555fb358a81996c1b8dd4e69b594d65c2d', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 16:04:26', '2026-07-10 16:04:26', 0),
	(88, 'usuario', 1, '3b4fa42951fe223b5563078c3b251d845a8ec69e42d283e4ea9b311b1b40b6b7', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 16:09:30', '2026-07-10 16:09:30', 0),
	(89, 'usuario', 1, 'ebed7251771be3559b8e6c7c86fd34ab7312ffc02888a1b096a4408a9c4d0877', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 16:13:35', '2026-07-10 16:13:35', 0),
	(90, 'usuario', 1, 'e90a842a84a0e588ff1fd7283737159ba36a6e0a812f4cc82033ede46c2d485f', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 16:15:55', '2026-07-10 16:15:55', 0),
	(91, 'usuario', 1, 'c859a70fff9a27ed9b388632cd2910aa8d23e53b86210736ae33cf5087776007', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 16:19:19', '2026-07-10 16:19:19', 0),
	(92, 'usuario', 1, '55f6b0466d84bbf166b66afcf9032810609ae59354b0bdf9d5a27d07860d3f81', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 16:38:27', '2026-07-10 16:40:15', 0),
	(93, 'usuario', 1, '8de7d7df7b2a2907b594a22fff82d8704f8dfc59a2555bbb28d083444ed7f859', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 16:39:35', '2026-07-10 16:40:53', 0),
	(94, 'usuario', 1, '0b6c5114a77a6d688e699c17fc66c076a8530508cc7ab2f9e2225dda5e9e903a', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 17:04:58', '2026-07-10 17:05:59', 0),
	(95, 'usuario', 1, '1a82bcc0a50931dafc7f9a893f96c55baa7b4f2936b46b7e2dd4b8412deeb841', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 17:27:23', '2026-07-10 17:27:23', 0),
	(96, 'usuario', 1, 'f1fc242b7733fc995b66305163a95aadd7739a54aa196dc076ca9285e2307686', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 17:28:20', '2026-07-10 17:42:17', 0),
	(97, 'usuario', 1, 'a3e23b87d85fae72e1067f5b3d5de0c7f060c0f1790049ad99e878ba6963b6b6', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 17:41:57', '2026-07-10 17:41:57', 0),
	(98, 'usuario', 1, '2e43b23dd979fa85bc15fca683724e4643b9dc48e7ea12ee9d4366116ee62f7d', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 17:42:19', '2026-07-10 21:33:33', 0),
	(99, 'usuario', 1, '17f0d77cf148b7f16b82e5fbedfe7008fe1d39ddd5b721f226cec54eeb2230f0', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 21:32:34', '2026-07-10 21:32:34', 0),
	(100, 'usuario', 1, 'cd41a2fbddfa85ed2884e1e109986cff496e8a043115705d3a2333faa77a9cf0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 21:33:40', '2026-07-10 22:37:29', 0),
	(101, 'usuario', 1, '283d9395dc3c5f99ed787db7adbb2580616f7b877dab44e361bc66357d9d06ed', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 22:36:53', '2026-07-10 22:36:53', 0),
	(102, 'usuario', 1, 'f20b3ecfb1e618680f15f97d1123bf814075ea92a022433f566e83849089fdfc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 22:37:36', '2026-07-10 22:46:01', 0),
	(103, 'usuario', 1, 'ec52971ad195c74f7364ff26987beb6312bd673125486398e2b7c3138a3a4fa3', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 22:43:32', '2026-07-10 23:29:08', 1),
	(104, 'usuario', 1, 'a7a6bc1d26e362bcefa57248943980fde7bd872631889ea9115c930925ccb792', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 22:45:38', '2026-07-10 22:45:38', 0),
	(105, 'usuario', 1, '8ed654cbf8316a2d6ed86f8361aa463b8a18bc3412e171b5f5491591f2d87909', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 22:46:04', '2026-07-10 22:57:51', 0),
	(106, 'usuario', 1, 'ce41111c029a2ab4ef9aed753146a6706b0e7be7ebceb37fa678e038b802a7f5', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 22:57:16', '2026-07-10 22:57:16', 0),
	(107, 'usuario', 1, '14fa149ddcefef9a270866673e7b74352fc2867944c9e9b6d085cdddc24940f3', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 22:57:54', '2026-07-10 23:06:18', 0),
	(108, 'usuario', 1, '23b5da9b3e9840536b0304bd8e2462b1d583bf864444f52acccdae830c96955f', '127.0.0.1', 'curl/8.11.0', NULL, '2026-07-10 23:05:53', '2026-07-10 23:05:53', 0),
	(109, 'usuario', 1, 'c2cf1a6abb4f34c14bc94b9c49875e80ccf63ea33ed8fff9cc983d78bde0efb9', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 23:06:20', '2026-07-10 23:06:20', 0),
	(110, 'usuario', 1, '89ee4b4fd8fb5f7ce8bc17043de0559636dcd9d51b440c6383385db4f79cfec6', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-07-10 23:51:34', '2026-07-11 00:20:06', 0),
	(111, 'usuario', 1, '32d84cc8540e1da0e675ec0f63214d046afe6e73f734edfaf9be90513d5acae1', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', NULL, '2026-07-21 17:38:11', '2026-07-21 23:58:16', 1),
	(112, 'usuario', 1, '21d090c9d90313a8b5e08d30f8466b3d4369af73ecd906af60c4a237b5b0fd22', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 19:34:48', '2026-07-21 19:34:48', 0),
	(113, 'usuario', 1, '94f3fafab5e263681110894cfca50810d37007e70ccffd7fed5e865827f8a566', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 19:34:53', '2026-07-21 19:34:53', 0),
	(114, 'usuario', 1, '33ccef110b3fff71a4bddc4d13ff440d31be3acf4a7bc84d0ab4dfcd151c1193', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 19:35:05', '2026-07-21 19:35:05', 0),
	(115, 'usuario', 1, '5173822f651a83087a5e19c864d07feda6a58387342853d97328c343e7c34abd', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 19:35:11', '2026-07-21 19:37:41', 0),
	(116, 'usuario', 1, '67840ac270f73f68f3be92df280f2da18906052eb48e254cef432a63d2e41810', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 19:43:36', '2026-07-21 19:44:41', 0),
	(117, 'usuario', 1, '2d0a444b00a7b998af043dba6e0c6dfc82be963bf0166cc492704ca35ea0ab7e', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 20:53:58', '2026-07-21 20:53:58', 0),
	(118, 'usuario', 1, '81092768556a9a88740f0fdee737d20bb0ab2aa5239499102dc106399453ebc1', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 20:54:46', '2026-07-21 20:54:46', 0),
	(119, 'usuario', 1, 'd10ce2f125ad05000c2526913a1f0387d2342e32c1711d42f35d9e8820c8b472', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 20:57:06', '2026-07-21 20:57:06', 0),
	(120, 'usuario', 1, '2df368f9f5e4b836ff36dbe03ab9ed1b340f89caf9a2326b1db831e6e7f9a63a', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 21:03:34', '2026-07-21 21:04:50', 0),
	(121, 'usuario', 1, '072df8fd9dcb339c9ed854b62f1c7cfbe365e46f61257f6a7cf4845b634c54a2', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 21:27:27', '2026-07-21 21:31:52', 0),
	(122, 'usuario', 1, 'c2224868e51cc0ab7ec9cf58782c28b02b0500954e7ca621857fbe4d72f96b7c', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 21:32:53', '2026-07-21 21:33:59', 0),
	(123, 'usuario', 1, 'aead76e61b340ed2adbdba29d9e9fd97755c852043d4cf1968bf5f149741f3ab', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 21:36:48', '2026-07-21 21:36:48', 0),
	(124, 'usuario', 1, 'edde5e9ce47e738db32a081fce6d0c0b7bcd1558301d8ee3a206773577ebb387', '127.0.0.1', 'curl/8.21.0', NULL, '2026-07-21 21:38:09', '2026-07-21 21:38:09', 0),
	(125, 'usuario', 1, '6691cf37224b47eb8846a57c935134f364981e1fe47d7ea56b002f36c9f0c49b', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36', NULL, '2026-07-21 23:53:48', '2026-07-21 23:53:48', 0),
	(126, 'usuario', 1, 'fbd1a0baff3a7c3c9a29965dcf45fe3557fa2184b27569bf4d94514aa729fd5d', '177.54.206.148', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', NULL, '2026-07-22 00:14:37', '2026-07-22 00:14:37', 0),
	(127, 'usuario', 2, '2907dbd709c1df8f1869121c12f54189cbf7cf9a2918d44988243348cf3e6e90', '45.167.184.241', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15', NULL, '2026-07-26 12:10:26', '2026-07-26 12:13:18', 1),
	(128, 'usuario', 2, '46f74330085dccea2ef0fa01d8c61c94bb9ac61b9367e04885c79d1781134840', '45.167.184.241', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15', NULL, '2026-07-26 14:22:42', '2026-07-26 14:35:57', 1),
	(129, 'usuario', 2, '289946e360e9816621be5f4c4310ae13ed9d8ace7d8945bfb35fc2fcbb8ac3b0', '45.167.184.241', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5.2 Mobile/15E148 Safari/604.1', NULL, '2026-07-26 14:31:06', '2026-07-26 14:35:57', 1),
	(130, 'usuario', 1, '652ee2378a3b7a782eb4c9922c909dee83a5bf286fc0099d881118a7e0897997', '179.222.210.166', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', NULL, '2026-07-27 16:33:01', '2026-07-27 17:39:06', 0),
	(131, 'usuario', 2, '0463b70ea19eb82f5f62903c08a462c6c221869d689b60c661dfc19efcb9089b', '201.33.72.99', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15', NULL, '2026-07-30 10:28:40', '2026-07-30 10:48:02', 1),
	(132, 'usuario', 3, '8d11e6d3b738c55aec9a9683c812a70d877fe149eff632a9fe24fe64c5dff26a', '201.33.72.99', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15', NULL, '2026-07-30 10:50:17', '2026-07-30 10:55:04', 1),
	(133, 'usuario', 4, '051d18fbc419197a428caea8dc9fb310601a187916e9717ec64b81ba4d91f03a', '201.33.72.99', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15', NULL, '2026-07-30 10:55:12', '2026-07-30 14:52:40', 1),
	(134, 'usuario', 1, '79d00de7a452fff5b5028f9de435d63037ed36df6a0ffffa1bb0d3cdd51b8160', '179.222.210.166', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', NULL, '2026-07-30 13:42:13', '2026-07-30 13:56:23', 0),
	(135, 'usuario', 3, 'cbf38e761556d8ffecf7e3cc54b2fc3039db65fc3a56fd9e2b070f06333d4ffb', '200.15.16.226', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36', NULL, '2026-07-30 14:51:31', '2026-07-30 14:56:08', 0),
	(136, 'usuario', 3, 'ff34ea4bde94b10cc25cfa8d0aa029d24bf800f62d284fcb6057e3f906e63b71', '201.33.72.99', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15', NULL, '2026-07-30 14:52:52', '2026-07-30 14:53:50', 1);

-- Copiando estrutura para tabela confinamento.cartao
CREATE TABLE IF NOT EXISTS `cartao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'ATIVO',
  `saldo` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_vendas` int NOT NULL DEFAULT '0',
  `acumulado` int NOT NULL DEFAULT '0' COMMENT 'Vendas acumuladas no ciclo atual de fidelidade (zera após cada bônus)',
  `valor_acumulado` decimal(10,2) NOT NULL DEFAULT '0.00',
  `fidelidade_valor_unico_regra_id` int DEFAULT NULL,
  `total_gasto` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Soma acumulada de todos os valores de venda registrados no cartão',
  `codigo_unico` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `token_nfc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `token_qr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `validade` date DEFAULT NULL,
  `data_emissao` date DEFAULT NULL,
  `data_ativacao` date DEFAULT NULL,
  `data_bloqueio` date DEFAULT NULL,
  `motivo_bloqueio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `trash` tinyint(1) NOT NULL DEFAULT '0',
  `observacoes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` int DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_cartao_codigo_unico` (`codigo_unico`),
  UNIQUE KEY `uk_cartao_token_nfc` (`token_nfc`),
  UNIQUE KEY `uk_cartao_token_qr` (`token_qr`),
  KEY `idx_cartao_cliente` (`id_cliente`) USING BTREE,
  KEY `idx_cartao_status` (`status`) USING BTREE,
  KEY `idx_cartao_trash` (`trash`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.cartao: ~7 rows (aproximadamente)
DELETE FROM `cartao`;
INSERT INTO `cartao` (`id`, `id_cliente`, `status`, `saldo`, `total_vendas`, `acumulado`, `valor_acumulado`, `fidelidade_valor_unico_regra_id`, `total_gasto`, `codigo_unico`, `token_nfc`, `token_qr`, `validade`, `data_emissao`, `data_ativacao`, `data_bloqueio`, `motivo_bloqueio`, `trash`, `observacoes`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted_by`, `deleted_at`) VALUES
	(1, 26, 'ATIVO', 50.00, 1, 1, 105.00, NULL, 105.00, '000001', '042592FC9F6181', NULL, NULL, '2026-04-22', '2026-04-22', NULL, NULL, 0, '', 1, '2026-04-22 14:07:10', 1, '2026-05-02 03:18:41', NULL, NULL),
	(4, NULL, 'ATIVO', 1600.00, 0, 0, 0.00, NULL, 0.00, '000002', '0429B5FA9F6180', NULL, NULL, '2026-04-23', '2026-04-23', NULL, NULL, 0, '', 1, '2026-04-23 19:07:13', 1, '2026-04-24 20:02:47', NULL, NULL),
	(5, 95, 'ATIVO', 455.95, 10, 0, 0.00, 3, 3713.00, '000003', '04E095FC9F6180', NULL, NULL, '2026-04-23', '2026-04-23', NULL, NULL, 0, '', 1, '2026-04-24 01:22:34', 1, '2026-05-01 20:19:37', NULL, NULL),
	(6, NULL, 'ATIVO', 0.00, 0, 0, 0.00, NULL, 0.00, '000005', '0469AEFA9F6180', NULL, NULL, '2026-04-23', '2026-04-23', NULL, NULL, 0, '', 1, '2026-04-24 01:50:24', 1, '2026-04-24 02:11:17', NULL, NULL),
	(7, NULL, 'ATIVO', 0.00, 0, 0, 0.00, NULL, 0.00, '000006', '04A2AAFA9F6180', NULL, NULL, '2026-04-24', '2026-04-24', NULL, NULL, 0, '', 1, '2026-04-24 13:22:57', 1, '2026-04-24 15:20:00', NULL, NULL),
	(8, NULL, 'VENCIDO', 0.00, 0, 0, 0.00, NULL, 0.00, '000004', '9999999999', NULL, '2026-04-24', '2026-04-24', '2026-04-24', NULL, NULL, 0, '', 1, '2026-04-24 17:39:53', 1, '2026-05-01 18:56:43', NULL, NULL),
	(9, NULL, 'ATIVO', 120.00, 0, 0, 0.00, NULL, 0.00, '000099', NULL, NULL, NULL, '2026-05-02', '2026-05-02', NULL, NULL, 0, 'CRIADO AUTOMATICAMENTE PELO ATALHO DE RECARGA DA HOME.', 1, '2026-05-02 03:25:36', NULL, '2026-05-02 03:25:36', NULL, NULL);

-- Copiando estrutura para tabela confinamento.cashback_regra
CREATE TABLE IF NOT EXISTS `cashback_regra` (
  `id` int NOT NULL AUTO_INCREMENT,
  `descricao` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `tipo` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'PERCENTUAL',
  `valor` decimal(10,2) NOT NULL DEFAULT '0.00',
  `valor_minimo_recarga` decimal(10,2) DEFAULT NULL,
  `data_inicio` datetime DEFAULT NULL,
  `data_fim` datetime DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `observacoes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `trash` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` int DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_cashback_regra_ativo` (`ativo`) USING BTREE,
  KEY `idx_cashback_regra_tipo` (`tipo`) USING BTREE,
  KEY `idx_cashback_regra_trash` (`trash`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.cashback_regra: ~8 rows (aproximadamente)
DELETE FROM `cashback_regra`;
INSERT INTO `cashback_regra` (`id`, `descricao`, `tipo`, `valor`, `valor_minimo_recarga`, `data_inicio`, `data_fim`, `ativo`, `observacoes`, `trash`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted_by`, `deleted_at`) VALUES
	(1, 'ACIMA DE R$ 100', 'PERCENTUAL', 5.00, 100.00, '2026-04-17 11:02:00', NULL, 1, '', 0, 1, '2026-04-22 14:44:10', 1, '2026-04-24 17:41:28', NULL, NULL),
	(2, 'ACIMA DE R$ 200', 'PERCENTUAL', 8.00, 200.00, '2026-04-01 11:02:00', '2026-04-30 11:02:00', 0, '', 0, 1, '2026-04-22 15:42:43', 1, '2026-04-24 14:02:26', NULL, NULL),
	(3, 'ACIMA DE R$ 400', 'PERCENTUAL', 10.00, 400.00, NULL, NULL, 0, '', 0, 1, '2026-04-22 15:49:54', 1, '2026-04-23 22:20:33', NULL, NULL),
	(4, 'ACIMA DE R$ 1000', 'PERCENTUAL', 7.00, 1000.00, NULL, '2026-04-25 11:02:00', 0, '', 0, 1, '2026-04-23 21:44:36', 1, '2026-04-24 14:02:13', NULL, NULL),
	(5, 'TSTE', 'FIXO', 10.00, 200.00, NULL, NULL, 1, '', 1, 1, '2026-04-23 21:46:26', NULL, '2026-04-23 22:20:11', 1, '2026-04-23 22:20:11'),
	(6, 'TEDSD', 'PERCENTUAL', 7.00, NULL, '2026-04-01 18:48:00', '2026-04-22 18:48:00', 1, '', 1, 1, '2026-04-23 21:48:50', 1, '2026-04-24 02:20:42', 1, '2026-04-24 02:20:42'),
	(7, 'TESTE', 'PERCENTUAL', 10.00, 200.00, '2026-04-23 19:18:00', NULL, 1, '', 1, 1, '2026-04-23 22:18:17', 1, '2026-04-23 22:20:44', 1, '2026-04-23 22:20:44'),
	(8, 'ACIMA DE R$ 600', 'PERCENTUAL', 12.00, 600.00, NULL, NULL, 1, '', 0, 1, '2026-05-01 22:12:07', 1, '2026-05-01 22:12:29', NULL, NULL);

-- Copiando estrutura para tabela confinamento.categoria_produto
CREATE TABLE IF NOT EXISTS `categoria_produto` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ex: Nutricao, Sanitario, Manutencao, Combustivel, Uso Geral',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categoria_produto_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.categoria_produto: ~5 rows (aproximadamente)
DELETE FROM `categoria_produto`;
INSERT INTO `categoria_produto` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'Nutrição', NULL, '2026-07-09 16:13:15', NULL, '2026-07-09 16:32:07'),
	(2, 'Sanitário', NULL, '2026-07-09 16:13:15', NULL, '2026-07-09 16:32:07'),
	(3, 'Manutenção', NULL, '2026-07-09 16:13:15', NULL, '2026-07-09 16:32:07'),
	(4, 'Combustível', NULL, '2026-07-09 16:13:15', NULL, '2026-07-09 16:32:07'),
	(5, 'Uso Geral', NULL, '2026-07-09 16:13:15', NULL, '2026-07-09 16:13:15');

-- Copiando estrutura para tabela confinamento.centro_custo
CREATE TABLE IF NOT EXISTS `centro_custo` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_centro_custo_codigo` (`codigo`),
  KEY `idx_centro_custo_nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.centro_custo: ~3 rows (aproximadamente)
DELETE FROM `centro_custo`;
INSERT INTO `centro_custo` (`id`, `nome`, `codigo`, `descricao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(5, 'Alimentacao', 'CC01', 'Gastos com racao e nutricao', 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(6, 'Sanidade', 'CC02', 'Gastos com medicamentos e veterinario', 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(7, 'Mao de Obra', 'CC03', 'Gastos com funcionarios', 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58');

-- Copiando estrutura para tabela confinamento.cliente
CREATE TABLE IF NOT EXISTS `cliente` (
  `id` int NOT NULL AUTO_INCREMENT,
  `razao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `nome` varchar(255) DEFAULT NULL,
  `pessoa` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `documento` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `rg_ie` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `nascimento` date DEFAULT NULL,
  `contato` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `telefone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `whatsapp` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `site` varchar(255) DEFAULT NULL,
  `cep` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `endereco` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `numero` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `complemento` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `bairro` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cidade` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `estado` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `pais` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `observacoes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `id_situacao` int DEFAULT NULL,
  `trash` tinyint DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT (now()),
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela confinamento.cliente: ~20 rows (aproximadamente)
DELETE FROM `cliente`;
INSERT INTO `cliente` (`id`, `razao`, `nome`, `pessoa`, `documento`, `rg_ie`, `nascimento`, `contato`, `telefone`, `whatsapp`, `email`, `site`, `cep`, `endereco`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, `pais`, `observacoes`, `id_situacao`, `trash`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted_by`, `deleted_at`) VALUES
	(25, 'DIZ SOLUCOES WEB LTDA', 'AGENCIA DIZ.', 'J', '42733455000166', NULL, '2021-07-15', 'DEGO', '17997033832', '17997033832', 'diegoaferraz@gmail.com', NULL, '15807270', 'RUA BELA FLOR', '807', NULL, 'PARQUE GLÓRIA IV', 'CATANDUVA', 'SP', 'BRASIL', NULL, 1, 0, 1, '2026-04-21 15:42:27', 1, NULL, NULL, NULL),
	(26, 'DIEGO AUGUSTO FERRAZ', 'DIEGO', 'F', '35276311862', '40653190-0', '1986-10-15', 'DIEGO', '17997033832', '17997033832', 'diegoaferraz@gmail.com', NULL, '15807270', 'RUA BELA FLOR', '385', NULL, 'PARQUE GLÓRIA IV', 'CATANDUVA', 'SP', 'BRASIL', NULL, 1, 0, 1, '2026-04-21 17:00:14', NULL, NULL, NULL, NULL),
	(61, 'MARIA DA SILVA', '', 'F', '', '', '1986-10-15', '', '', '', '', '', '', '', '', '', '', '', '', 'BRASIL', '', 1, 0, 1, '2026-04-21 18:12:39', NULL, NULL, NULL, NULL),
	(62, 'JOSEFA DE SOUZA', '', 'F', '', '', NULL, '', '', '', '', '', '', '', '', '', '', '', '', 'BRASIL', '', 1, 0, 1, '2026-04-21 18:12:39', NULL, NULL, NULL, NULL),
	(63, 'LAILA OLIVERIRA', '', 'F', '', '', NULL, '', '', '', '', '', '', '', '', '', '', '', '', 'BRASIL', '', 1, 0, 1, '2026-04-21 18:12:39', NULL, NULL, NULL, NULL),
	(85, 'RAZAO 1', 'NOME 1', 'F', '', 'RG 1', '2001-01-01', 'CONTATO 1', '17999999999', '17888888888', 'teste1@teste1.com', 'site1.com.br', '15809111', 'RUA 1', '1', 'COMP 1', 'BAIRRO 1', 'CIDADE 1', '', 'PAIS 1', 'obs1', 9, 0, 1, '2026-04-21 18:55:57', NULL, NULL, NULL, NULL),
	(86, 'RAZAO 2', 'NOME 2', 'F', '', 'RG 2', '2001-01-02', 'CONTATO 2', '17999999999', '17888888888', 'teste1@teste1.com', 'site2.com.br', '15809112', 'RUA 2', '2', 'COMP 2', 'BAIRRO 2', 'CIDADE 2', '', 'PAIS 2', 'obs2', 9, 0, 1, '2026-04-21 18:55:57', NULL, NULL, NULL, NULL),
	(87, 'RAZAO 3', 'NOME 3', 'F', '', 'RG 3', '2001-01-03', 'CONTATO 3', '17999999999', '17888888888', 'teste1@teste1.com', 'site3.com.br', '15809113', 'RUA 3', '3', 'COMP 3', 'BAIRRO 3', 'CIDADE 3', '', 'PAIS 3', 'obs3', 9, 0, 1, '2026-04-21 18:55:57', NULL, NULL, NULL, NULL),
	(88, 'RAZAO 4', 'NOME 4', 'F', '', 'RG 4', '2001-01-04', 'CONTATO 4', '17999999999', '17888888888', 'teste1@teste1.com', 'site4.com.br', '15809114', 'RUA 4', '4', 'COMP 4', 'BAIRRO 4', 'CIDADE 4', '', 'PAIS 4', 'obs4', 9, 0, 1, '2026-04-21 18:55:57', NULL, NULL, NULL, NULL),
	(89, 'RAZAO 5', 'NOME 5', 'F', '', 'RG 5', '2001-01-05', 'CONTATO 5', '17999999999', '17888888888', 'teste1@teste1.com', 'site5.com.br', '15809115', 'RUA 5', '5', 'COMP 5', 'BAIRRO 5', 'CIDADE 5', '', 'PAIS 5', 'obs5', 10, 0, 1, '2026-04-21 18:55:57', NULL, NULL, NULL, NULL),
	(90, 'RAZAO 1', 'NOME 1', 'F', '', 'RG 1', '2001-01-01', 'CONTATO 1', '17999999999', '17888888888', 'teste1@teste1.com', 'site1.com.br', '15809111', 'RUA 1', '1', 'COMP 1', 'BAIRRO 1', 'CIDADE 1', '', 'PAIS 1', 'obs1', 9, 0, 1, '2026-04-21 18:56:21', NULL, NULL, NULL, NULL),
	(91, 'RAZAO 2', 'NOME 2', 'F', '', 'RG 2', '2001-01-02', 'CONTATO 2', '17999999999', '17888888888', 'teste1@teste1.com', 'site2.com.br', '15809112', 'RUA 2', '2', 'COMP 2', 'BAIRRO 2', 'CIDADE 2', '', 'PAIS 2', 'obs2', 9, 0, 1, '2026-04-21 18:56:21', NULL, NULL, NULL, NULL),
	(92, 'RAZAO 3', 'NOME 3', 'F', '', 'RG 3', '2001-01-03', 'CONTATO 3', '17999999999', '17888888888', 'teste1@teste1.com', 'site3.com.br', '15809113', 'RUA 3', '3', 'COMP 3', 'BAIRRO 3', 'CIDADE 3', '', 'PAIS 3', 'obs3', 9, 0, 1, '2026-04-21 18:56:21', NULL, NULL, NULL, NULL),
	(93, 'RAZAO 4', 'NOME 4', 'F', '', 'RG 4', '2001-01-04', 'CONTATO 4', '17999999999', '17888888888', 'teste1@teste1.com', 'site4.com.br', '15809114', 'RUA 4', '4', 'COMP 4', 'BAIRRO 4', 'CIDADE 4', '', 'PAIS 4', 'obs4', 9, 0, 1, '2026-04-21 18:56:21', NULL, NULL, NULL, NULL),
	(94, 'RAZAO 5', 'NOME 5', 'F', '', 'RG 5', '2001-01-05', 'CONTATO 5', '17999999999', '17888888888', 'teste1@teste1.com', 'site5.com.br', '15809115', 'RUA 5', '5', 'COMP 5', 'BAIRRO 5', 'CIDADE 5', '', 'PAIS 5', 'obs5', 10, 0, 1, '2026-04-21 18:56:21', NULL, NULL, NULL, NULL),
	(95, 'DIEGO', NULL, 'F', NULL, NULL, NULL, NULL, '17997033832', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, '2026-04-22 12:42:20', NULL, NULL, NULL, NULL),
	(96, 'DIEGO FERRAZ', NULL, 'F', NULL, NULL, NULL, NULL, '17997033832', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, '2026-04-22 12:49:48', NULL, NULL, NULL, NULL),
	(97, 'DIEGO FERRAZ', NULL, 'F', NULL, NULL, NULL, NULL, '17997033832', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, '2026-04-22 12:54:06', NULL, NULL, NULL, NULL),
	(98, 'TESTE', NULL, 'F', NULL, NULL, NULL, NULL, '17997033832', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, '2026-04-22 12:57:25', NULL, NULL, NULL, NULL),
	(99, 'TESTE2', NULL, 'F', NULL, NULL, NULL, NULL, '17997033832', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1, '2026-04-22 12:58:37', NULL, NULL, NULL, NULL);

-- Copiando estrutura para tabela confinamento.cliente_situacao
CREATE TABLE IF NOT EXISTS `cliente_situacao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `descricao` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cor` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `ativo` tinyint DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT (now()),
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela confinamento.cliente_situacao: ~5 rows (aproximadamente)
DELETE FROM `cliente_situacao`;
INSERT INTO `cliente_situacao` (`id`, `descricao`, `cor`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'ATIVO', '#1FA365', 1, NULL, '2026-04-21 03:50:47', 1, '2026-04-21 04:10:20'),
	(2, 'INATIVO', '#E64757', 0, NULL, '2026-04-21 03:50:47', 1, '2026-04-21 04:10:11'),
	(9, 'PENDENTE', '#2AC5E5', 1, 1, '2026-04-21 18:53:19', 1, '2026-04-22 19:40:32'),
	(10, 'BLOQUEADO', '#FF0000', 0, 1, '2026-04-21 18:55:57', 1, '2026-04-23 21:38:02'),
	(11, 'FALECIDO', '#2B3546', 0, 1, '2026-04-23 21:37:30', 1, '2026-04-23 21:37:41');

-- Copiando estrutura para tabela confinamento.confeccao_racao
CREATE TABLE IF NOT EXISTS `confeccao_racao` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_formula_racao` int unsigned NOT NULL,
  `id_operador` int DEFAULT NULL COMMENT 'usuario que executou a confeccao',
  `data_confeccao` date NOT NULL,
  `quantidade_prevista` decimal(10,2) DEFAULT NULL COMMENT 'kg previstos para a batida',
  `quantidade_real` decimal(10,2) NOT NULL COMMENT 'kg realmente produzidos, usado para calcular a baixa de ingredientes',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_confeccao_racao_formula` (`id_formula_racao`,`data_confeccao`),
  KEY `fk_confeccao_racao_operador` (`id_operador`),
  CONSTRAINT `fk_confeccao_racao_formula` FOREIGN KEY (`id_formula_racao`) REFERENCES `formula_racao` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_confeccao_racao_operador` FOREIGN KEY (`id_operador`) REFERENCES `usuario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.confeccao_racao: ~0 rows (aproximadamente)
DELETE FROM `confeccao_racao`;
INSERT INTO `confeccao_racao` (`id`, `id_formula_racao`, `id_operador`, `data_confeccao`, `quantidade_prevista`, `quantidade_real`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 4, 1, '2026-06-05', 1000.00, 980.00, 'Batida da manhã', 1, '2026-07-09 17:27:59', 2, '2026-07-26 14:28:31');

-- Copiando estrutura para tabela confinamento.confeccao_racao_item
CREATE TABLE IF NOT EXISTS `confeccao_racao_item` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_confeccao_racao` int unsigned NOT NULL,
  `id_ingrediente` int unsigned NOT NULL,
  `percentual_formula` decimal(5,2) NOT NULL COMMENT 'snapshot do percentual da formula no momento da confeccao',
  `quantidade_consumida` decimal(10,2) NOT NULL COMMENT 'kg baixados do estoque deste ingrediente',
  PRIMARY KEY (`id`),
  KEY `idx_confeccao_racao_item_ingrediente` (`id_ingrediente`),
  KEY `fk_confeccao_racao_item_confeccao` (`id_confeccao_racao`),
  CONSTRAINT `fk_confeccao_racao_item_confeccao` FOREIGN KEY (`id_confeccao_racao`) REFERENCES `confeccao_racao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_confeccao_racao_item_ingrediente` FOREIGN KEY (`id_ingrediente`) REFERENCES `ingrediente` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.confeccao_racao_item: ~4 rows (aproximadamente)
DELETE FROM `confeccao_racao_item`;
INSERT INTO `confeccao_racao_item` (`id`, `id_confeccao_racao`, `id_ingrediente`, `percentual_formula`, `quantidade_consumida`) VALUES
	(5, 3, 3, 40.00, 392.00),
	(6, 3, 4, 15.00, 147.00),
	(7, 3, 5, 40.00, 392.00),
	(8, 3, 6, 5.00, 49.00);

-- Copiando estrutura para tabela confinamento.configuracao
CREATE TABLE IF NOT EXISTS `configuracao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `chave` varchar(50) DEFAULT NULL,
  `valor` text,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT (now()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `chave` (`chave`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.configuracao: ~5 rows (aproximadamente)
DELETE FROM `configuracao`;
INSERT INTO `configuracao` (`id`, `chave`, `valor`, `updated_by`, `updated_at`) VALUES
	(1, 'cartao_cliente_obrigatorio', '0', 1, '2026-05-02 01:24:41'),
	(2, 'recarga_expira_dias', '60', 1, '2026-05-02 01:24:41'),
	(3, 'cashback_expira_dias', '30', 1, '2026-05-02 01:24:41'),
	(4, 'fidelidade_expira_dias', '30', 1, '2026-05-02 01:24:41'),
	(5, 'recarga_minima', NULL, 1, '2026-05-02 01:24:41');

-- Copiando estrutura para tabela confinamento.conta_pagar
CREATE TABLE IF NOT EXISTS `conta_pagar` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_fornecedor` int DEFAULT NULL COMMENT 'Fornecedor vinculado (opcional)',
  `id_plano_conta` int unsigned DEFAULT NULL COMMENT 'Classifica????o cont??bil',
  `id_centro_custo` int unsigned DEFAULT NULL COMMENT 'Centro de custo (opcional)',
  `descricao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Descri????o da conta',
  `valor` decimal(12,2) NOT NULL COMMENT 'Valor nominal',
  `data_vencimento` date NOT NULL COMMENT 'Data de vencimento',
  `data_pagamento` date DEFAULT NULL COMMENT 'Data em que foi paga',
  `forma_pagamento` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Dinheiro, cart??o, boleto, pix, etc',
  `documento` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'N??mero da NF, boleto, contrato',
  `status` enum('PENDENTE','PAGO','CANCELADO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDENTE',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  `parcela_numero` int unsigned NOT NULL DEFAULT '1' COMMENT 'N├║mero da parcela (1 = primeira)',
  `parcela_total` int unsigned NOT NULL DEFAULT '1' COMMENT 'Total de parcelas',
  `parcela_origem_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_conta_pagar_status` (`status`),
  KEY `idx_conta_pagar_vencimento` (`data_vencimento`),
  KEY `idx_conta_pagar_fornecedor` (`id_fornecedor`),
  KEY `idx_conta_pagar_plano_conta` (`id_plano_conta`),
  KEY `fk_conta_pagar_centro_custo` (`id_centro_custo`),
  KEY `idx_conta_pagar_parcelas` (`parcela_numero`,`parcela_total`),
  KEY `idx_conta_pagar_parcela_origem` (`parcela_origem_id`),
  CONSTRAINT `fk_conta_pagar_centro_custo` FOREIGN KEY (`id_centro_custo`) REFERENCES `centro_custo` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_conta_pagar_fornecedor` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_conta_pagar_plano_conta` FOREIGN KEY (`id_plano_conta`) REFERENCES `plano_conta` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.conta_pagar: ~32 rows (aproximadamente)
DELETE FROM `conta_pagar`;
INSERT INTO `conta_pagar` (`id`, `id_fornecedor`, `id_plano_conta`, `id_centro_custo`, `descricao`, `valor`, `data_vencimento`, `data_pagamento`, `forma_pagamento`, `documento`, `status`, `observacao`, `created_at`, `updated_at`, `created_by`, `updated_by`, `parcela_numero`, `parcela_total`, `parcela_origem_id`) VALUES
	(1, 3, 7, 6, 'Compra de medicamentos', 1250.00, '2025-08-15', '2025-08-14', 'Pix', 'NF-001', 'PAGO', NULL, '2025-08-10 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(2, 3, 6, 5, 'Ração terminação lote 10', 8750.00, '2025-09-20', '2025-09-19', 'Boleto', 'NF-002', 'PAGO', NULL, '2025-09-12 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(3, 3, 10, NULL, 'Frete transporte', 3200.00, '2025-10-25', '2025-10-24', 'Dinheiro', 'CTRC-001', 'PAGO', NULL, '2025-10-14 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(4, NULL, 12, NULL, 'Energia elétrica - out', 1890.50, '2025-11-05', '2025-11-04', 'Pix', '', 'PAGO', NULL, '2025-10-20 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(5, NULL, 8, 7, 'Salário funcionários - out', 15400.00, '2025-11-01', '2025-10-31', 'Boleto', '', 'PAGO', NULL, '2025-10-22 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(6, 3, 9, NULL, 'Manutenção cercas', 980.00, '2025-12-10', '2025-12-09', 'Pix', '', 'PAGO', NULL, '2025-11-25 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(7, 3, 6, 5, 'Suplemento mineral', 2100.00, '2026-01-15', '2026-01-14', 'Boleto', 'NF-003', 'PAGO', NULL, '2026-01-05 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(8, NULL, 11, NULL, 'Imposto ITR', 3650.00, '2026-02-20', '2026-02-19', 'Boleto', 'DARF-001', 'PAGO', NULL, '2026-02-01 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(9, 3, 5, NULL, 'Aquisição 30 cabeças', 72000.00, '2026-03-05', '2026-03-04', 'Boleto', 'NF-004', 'PAGO', NULL, '2026-02-20 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(10, NULL, 12, NULL, 'Energia elétrica - mar', 2100.00, '2026-04-05', '2026-04-04', 'Pix', '', 'PAGO', NULL, '2026-03-20 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(11, NULL, 8, 7, 'Salário funcionários - mar', 15400.00, '2026-04-01', '2026-03-31', 'Boleto', '', 'PAGO', NULL, '2026-03-22 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(12, 3, 6, 5, 'Ração terminação lote 12', 9200.00, '2026-05-10', '2026-05-09', 'Boleto', 'NF-005', 'PAGO', NULL, '2026-05-01 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(13, 3, 7, 6, 'Medicamentos - maio', 1800.00, '2026-06-01', '2026-05-31', 'Boleto', 'NF-006', 'PAGO', NULL, '2026-05-15 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(14, 3, 10, NULL, 'Frete - junho', 2800.00, '2026-06-25', '2026-06-24', 'Pix', 'CTRC-002', 'PAGO', NULL, '2026-06-10 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(15, NULL, 12, NULL, 'Água - junho', 520.00, '2026-07-05', '2026-07-04', 'Pix', '', 'PAGO', NULL, '2026-06-20 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(16, 3, 13, NULL, 'Consultoria nutricional', 2500.00, '2026-07-25', '2026-07-24', 'Pix', 'CT-001', 'PAGO', NULL, '2026-07-10 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(17, 3, 6, 5, 'Ração terminação lote 14', 9800.00, '2026-08-15', NULL, 'Boleto', 'NF-007', 'PENDENTE', NULL, '2026-08-01 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(18, NULL, 8, 7, 'Salário funcionários - jul', 15400.00, '2026-08-01', NULL, 'Boleto', '', 'PENDENTE', NULL, '2026-07-22 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(19, 3, 9, NULL, 'Manutenção equipamentos', 1500.00, '2026-08-20', NULL, 'Pix', '', 'PENDENTE', NULL, '2026-08-05 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(20, NULL, 12, NULL, 'Energia elétrica - jul', 1950.00, '2026-08-05', NULL, 'Pix', '', 'PENDENTE', NULL, '2026-07-20 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(21, NULL, 11, NULL, 'Imposto Funrural', 4200.00, '2026-09-15', NULL, 'Boleto', 'DARF-002', 'PENDENTE', NULL, '2026-08-20 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(22, 3, 5, NULL, 'Aquisição 25 cabeças', 62500.00, '2026-09-01', NULL, 'Boleto', 'NF-008', 'PENDENTE', NULL, '2026-08-15 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(23, 3, 6, 5, 'Suplemento mineral - set', 2300.00, '2026-09-25', NULL, 'Pix', 'NF-009', 'PENDENTE', NULL, '2026-09-10 00:00:00', '2026-07-21 21:03:05', NULL, NULL, 1, 1, NULL),
	(24, 3, 6, NULL, 'Compra de Ração Mensal', 15000.00, '2026-07-15', NULL, NULL, 'NF-7890', 'PENDENTE', NULL, '2026-07-21 22:12:40', '2026-07-21 22:28:34', 1, NULL, 1, 6, 24),
	(25, 3, 6, NULL, 'Compra de Ração Mensal', 15000.00, '2026-08-15', NULL, NULL, 'NF-7890', 'PENDENTE', NULL, '2026-07-21 22:12:40', '2026-07-21 22:28:34', 1, NULL, 2, 6, 24),
	(26, 3, 6, NULL, 'Compra de Ração Mensal', 15000.00, '2026-09-15', NULL, NULL, 'NF-7890', 'PENDENTE', NULL, '2026-07-21 22:12:40', '2026-07-21 22:28:34', 1, NULL, 3, 6, 24),
	(27, 3, 6, NULL, 'Compra de Ração Mensal', 15000.00, '2026-10-15', NULL, NULL, 'NF-7890', 'PENDENTE', NULL, '2026-07-21 22:12:40', '2026-07-21 22:28:34', 1, NULL, 4, 6, 24),
	(28, 3, 6, NULL, 'Compra de Ração Mensal', 15000.00, '2026-11-15', NULL, NULL, 'NF-7890', 'PENDENTE', NULL, '2026-07-21 22:12:40', '2026-07-21 22:28:34', 1, NULL, 5, 6, 24),
	(29, 3, 6, NULL, 'Compra de Ração Mensal', 15000.00, '2026-12-15', NULL, NULL, 'NF-7890', 'PENDENTE', NULL, '2026-07-21 22:12:40', '2026-07-21 22:28:34', 1, NULL, 6, 6, 24),
	(30, 5, 7, NULL, 'Vacinas e Medicamentos Lote 2026', 8500.00, '2026-06-10', '2026-06-08', NULL, 'NF-4567', 'PAGO', NULL, '2026-07-21 22:12:40', '2026-07-21 22:12:40', 1, NULL, 1, 3, 30),
	(31, 5, 7, NULL, 'Vacinas e Medicamentos Lote 2026', 8500.00, '2026-07-10', NULL, NULL, 'NF-4567', 'PENDENTE', NULL, '2026-07-21 22:12:40', '2026-07-21 22:12:40', 1, NULL, 2, 3, 30),
	(32, 5, 7, NULL, 'Vacinas e Medicamentos Lote 2026', 8500.00, '2026-08-10', NULL, NULL, 'NF-4567', 'PENDENTE', NULL, '2026-07-21 22:12:40', '2026-07-21 22:12:40', 1, NULL, 3, 3, 30);

-- Copiando estrutura para tabela confinamento.conta_receber
CREATE TABLE IF NOT EXISTS `conta_receber` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_cliente` int DEFAULT NULL COMMENT 'Cliente vinculado (opcional)',
  `id_plano_conta` int unsigned DEFAULT NULL COMMENT 'Classifica????o cont??bil',
  `id_centro_custo` int unsigned DEFAULT NULL COMMENT 'Centro de custo (opcional)',
  `descricao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Descri????o da conta',
  `valor` decimal(12,2) NOT NULL COMMENT 'Valor nominal',
  `data_vencimento` date NOT NULL COMMENT 'Data de vencimento',
  `data_recebimento` date DEFAULT NULL COMMENT 'Data em que foi recebida',
  `forma_pagamento` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Dinheiro, cart??o, boleto, pix, etc',
  `documento` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'N??mero da NF, contrato, pedido',
  `status` enum('PENDENTE','RECEBIDO','CANCELADO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDENTE',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  `parcela_numero` int unsigned NOT NULL DEFAULT '1' COMMENT 'N├║mero da parcela (1 = primeira)',
  `parcela_total` int unsigned NOT NULL DEFAULT '1' COMMENT 'Total de parcelas',
  `parcela_origem_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_conta_receber_status` (`status`),
  KEY `idx_conta_receber_vencimento` (`data_vencimento`),
  KEY `idx_conta_receber_cliente` (`id_cliente`),
  KEY `idx_conta_receber_plano_conta` (`id_plano_conta`),
  KEY `fk_conta_receber_centro_custo` (`id_centro_custo`),
  KEY `idx_conta_receber_parcelas` (`parcela_numero`,`parcela_total`),
  KEY `idx_conta_receber_parcela_origem` (`parcela_origem_id`),
  CONSTRAINT `fk_conta_receber_centro_custo` FOREIGN KEY (`id_centro_custo`) REFERENCES `centro_custo` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_conta_receber_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_conta_receber_plano_conta` FOREIGN KEY (`id_plano_conta`) REFERENCES `plano_conta` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.conta_receber: ~22 rows (aproximadamente)
DELETE FROM `conta_receber`;
INSERT INTO `conta_receber` (`id`, `id_cliente`, `id_plano_conta`, `id_centro_custo`, `descricao`, `valor`, `data_vencimento`, `data_recebimento`, `forma_pagamento`, `documento`, `status`, `observacao`, `created_at`, `updated_at`, `created_by`, `updated_by`, `parcela_numero`, `parcela_total`, `parcela_origem_id`) VALUES
	(1, 25, 1, NULL, 'Venda 15 bois lote 8', 67500.00, '2025-08-10', '2025-08-08', 'Pix', 'NF-100', 'RECEBIDO', NULL, '2025-07-25 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(2, 25, 1, NULL, 'Venda 10 vacas descarte', 28000.00, '2025-09-15', '2025-09-13', 'Boleto', 'NF-101', 'RECEBIDO', NULL, '2025-09-01 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(3, 25, 3, NULL, 'Serviço confinamento', 8500.00, '2025-10-25', '2025-10-24', 'Pix', 'CT-050', 'RECEBIDO', NULL, '2025-10-10 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(4, 25, 1, NULL, 'Venda 20 bois lote 9', 94000.00, '2025-11-20', '2025-11-18', 'Boleto', 'NF-102', 'RECEBIDO', NULL, '2025-11-05 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(5, 25, 1, NULL, 'Venda bezerros desmama', 14400.00, '2025-12-20', '2025-12-19', 'Pix', 'NF-103', 'RECEBIDO', NULL, '2025-12-05 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(6, 25, 1, NULL, 'Venda 18 bois lote 10', 84600.00, '2026-01-25', '2026-01-24', 'Boleto', 'NF-104', 'RECEBIDO', NULL, '2026-01-10 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(7, 25, 4, NULL, 'Aluguel pastagem verão', 6000.00, '2026-02-10', '2026-02-09', 'Pix', 'CT-052', 'RECEBIDO', NULL, '2026-01-25 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(8, 25, 1, NULL, 'Venda 22 bois lote 11', 103400.00, '2026-03-15', '2026-03-13', 'Boleto', 'NF-105', 'RECEBIDO', NULL, '2026-03-01 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(9, 25, 3, NULL, 'Serviço inseminação', 3200.00, '2026-04-30', '2026-04-29', 'Pix', 'CT-053', 'RECEBIDO', NULL, '2026-04-15 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(10, 25, 1, NULL, 'Venda 25 bois lote 12', 117500.00, '2026-05-20', '2026-05-19', 'Boleto', 'NF-106', 'RECEBIDO', NULL, '2026-05-05 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(11, 25, 1, NULL, 'Venda 12 bois lote 13', 56400.00, '2026-06-15', '2026-06-14', 'Pix', 'NF-107', 'RECEBIDO', NULL, '2026-06-01 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(12, 25, 4, NULL, 'Aluguel pastagem inverno', 6000.00, '2026-07-10', '2026-07-09', 'Pix', 'CT-054', 'RECEBIDO', NULL, '2026-06-25 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(13, 25, 1, NULL, 'Venda 20 bois lote 14', 94000.00, '2026-08-15', NULL, 'Boleto', 'NF-108', 'PENDENTE', NULL, '2026-08-01 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(14, 25, 3, NULL, 'Serviço confinamento - set', 9000.00, '2026-09-10', NULL, 'Pix', 'CT-055', 'PENDENTE', NULL, '2026-08-20 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(15, 25, 1, NULL, 'Venda 15 bois lote 15', 70500.00, '2026-10-05', NULL, 'Boleto', 'NF-109', 'PENDENTE', NULL, '2026-09-15 00:00:00', '2026-07-21 21:03:06', NULL, NULL, 1, 1, NULL),
	(16, 25, 1, NULL, 'Venda de Gado Lote 2026-001', 45000.00, '2026-07-20', NULL, NULL, 'CT-1001', 'PENDENTE', NULL, '2026-07-21 22:12:41', '2026-07-21 22:12:41', 1, NULL, 1, 4, 16),
	(17, 25, 1, NULL, 'Venda de Gado Lote 2026-001', 45000.00, '2026-08-20', NULL, NULL, 'CT-1001', 'PENDENTE', NULL, '2026-07-21 22:12:41', '2026-07-21 22:12:41', 1, NULL, 2, 4, 16),
	(18, 25, 1, NULL, 'Venda de Gado Lote 2026-001', 45000.00, '2026-09-20', NULL, NULL, 'CT-1001', 'PENDENTE', NULL, '2026-07-21 22:12:41', '2026-07-21 22:12:41', 1, NULL, 3, 4, 16),
	(19, 25, 1, NULL, 'Venda de Gado Lote 2026-001', 45000.00, '2026-10-20', NULL, NULL, 'CT-1001', 'PENDENTE', NULL, '2026-07-21 22:12:41', '2026-07-21 22:12:41', 1, NULL, 4, 4, 16),
	(20, 25, 3, NULL, 'Consultoria Técnica Mensal', 3200.00, '2026-06-15', '2026-06-14', NULL, 'CT-1002', 'RECEBIDO', NULL, '2026-07-21 22:12:41', '2026-07-21 22:28:34', 1, NULL, 1, 3, 20),
	(21, 25, 3, NULL, 'Consultoria Técnica Mensal', 3200.00, '2026-07-15', '2026-07-15', NULL, 'CT-1002', 'RECEBIDO', NULL, '2026-07-21 22:12:41', '2026-07-21 22:28:34', 1, NULL, 2, 3, 20),
	(22, 25, 3, NULL, 'Consultoria Técnica Mensal', 3200.00, '2026-08-15', NULL, NULL, 'CT-1002', 'PENDENTE', NULL, '2026-07-21 22:12:41', '2026-07-21 22:28:34', 1, NULL, 3, 3, 20);

-- Copiando estrutura para tabela confinamento.curral
CREATE TABLE IF NOT EXISTS `curral` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_unidade` int unsigned NOT NULL,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacidade` int unsigned DEFAULT NULL,
  `tipo_estrutura` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ATIVO',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_curral_codigo` (`codigo`),
  KEY `idx_curral_nome` (`nome`),
  KEY `fk_curral_unidade` (`id_unidade`),
  CONSTRAINT `fk_curral_unidade` FOREIGN KEY (`id_unidade`) REFERENCES `unidade` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.curral: ~4 rows (aproximadamente)
DELETE FROM `curral`;
INSERT INTO `curral` (`id`, `id_unidade`, `nome`, `codigo`, `capacidade`, `tipo_estrutura`, `status`, `observacao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(8, 14, 'Curral 01', 'C01', 150, 'CONFINAMENTO', 'ATIVO', NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(9, 14, 'Curral 02', 'C02', 150, 'CONFINAMENTO', 'ATIVO', NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(10, 14, 'Curral 03', 'C03', 200, 'CONFINAMENTO', 'ATIVO', NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(11, 15, 'Curral 04', 'C04', 100, 'CONFINAMENTO', 'ATIVO', NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58');

-- Copiando estrutura para tabela confinamento.fase_nutricional
CREATE TABLE IF NOT EXISTS `fase_nutricional` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordem` int unsigned NOT NULL DEFAULT '0' COMMENT 'sequencia natural: adaptacao=1, crescimento=2, terminacao=3...',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fase_nutricional_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.fase_nutricional: ~3 rows (aproximadamente)
DELETE FROM `fase_nutricional`;
INSERT INTO `fase_nutricional` (`id`, `descricao`, `ordem`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'ADAPTAÇÃO', 1, NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31'),
	(2, 'CRESCIMENTO', 2, NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31'),
	(3, 'TERMINAÇÃO', 3, NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31');

-- Copiando estrutura para tabela confinamento.fidelidade_regra
CREATE TABLE IF NOT EXISTS `fidelidade_regra` (
  `id` int NOT NULL AUTO_INCREMENT,
  `descricao` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `quantidade_vendas` int DEFAULT NULL,
  `valor_minimo_venda` decimal(10,2) DEFAULT NULL,
  `valor_acumulado_minimo` decimal(10,2) DEFAULT NULL,
  `tipo_valor_acumulado` varchar(20) NOT NULL DEFAULT 'CICLICO',
  `valor_saldo` decimal(10,2) NOT NULL DEFAULT '0.00',
  `data_inicio` datetime DEFAULT NULL,
  `data_fim` datetime DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `observacoes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `trash` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` int DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_fidelidade_regra_ativo` (`ativo`) USING BTREE,
  KEY `idx_fidelidade_regra_qtd_vendas` (`quantidade_vendas`) USING BTREE,
  KEY `idx_fidelidade_regra_trash` (`trash`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.fidelidade_regra: ~3 rows (aproximadamente)
DELETE FROM `fidelidade_regra`;
INSERT INTO `fidelidade_regra` (`id`, `descricao`, `quantidade_vendas`, `valor_minimo_venda`, `valor_acumulado_minimo`, `tipo_valor_acumulado`, `valor_saldo`, `data_inicio`, `data_fim`, `ativo`, `observacoes`, `trash`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted_by`, `deleted_at`) VALUES
	(1, 'FIDELIDADE A CADA 10 ALMOÇOS', 5, NULL, NULL, 'CICLICO', 90.00, NULL, NULL, 1, '', 1, 1, '2026-04-22 15:31:21', 1, '2026-04-23 19:09:00', 1, '2026-04-23 19:09:00'),
	(2, 'A CADA 10 ALMOÇOS', 10, NULL, NULL, 'CICLICO', 90.00, '2026-04-01 19:23:00', '2026-04-29 19:23:00', 1, '', 1, 1, '2026-04-23 20:48:18', 1, '2026-04-24 13:32:32', 1, '2026-04-24 13:32:32'),
	(3, 'TESTE', 3, 90.00, 270.00, 'CICLICO', 90.00, '2026-04-01 11:09:00', '2026-05-02 11:09:00', 1, '', 0, 1, '2026-04-24 14:09:40', 1, '2026-05-01 19:26:46', NULL, NULL);

-- Copiando estrutura para tabela confinamento.formula_racao
CREATE TABLE IF NOT EXISTS `formula_racao` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_tipo_dieta` int unsigned DEFAULT NULL,
  `id_fase_nutricional` int unsigned DEFAULT NULL,
  `fase` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ex: ADAPTACAO, CRESCIMENTO, TERMINACAO',
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dieta_nome` (`nome`),
  KEY `fk_formula_racao_tipo_dieta` (`id_tipo_dieta`),
  KEY `fk_formula_racao_fase_nutricional` (`id_fase_nutricional`),
  CONSTRAINT `fk_formula_racao_fase_nutricional` FOREIGN KEY (`id_fase_nutricional`) REFERENCES `fase_nutricional` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_formula_racao_tipo_dieta` FOREIGN KEY (`id_tipo_dieta`) REFERENCES `tipo_dieta` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.formula_racao: ~3 rows (aproximadamente)
DELETE FROM `formula_racao`;
INSERT INTO `formula_racao` (`id`, `nome`, `id_tipo_dieta`, `id_fase_nutricional`, `fase`, `descricao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 'Formula Adaptacao', 1, 1, NULL, 'Dieta de adaptacao para animais recem-chegados', 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(4, 'Formula Crescimento', 1, 2, NULL, 'Dieta de crescimento', 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(5, 'Formula Terminacao', 1, 3, NULL, 'Dieta de terminacao para acabamento', 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58');

-- Copiando estrutura para tabela confinamento.formula_racao_item
CREATE TABLE IF NOT EXISTS `formula_racao_item` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_formula_racao` int unsigned NOT NULL,
  `id_ingrediente` int unsigned NOT NULL,
  `percentual` decimal(5,2) NOT NULL COMMENT 'percentual do ingrediente na formula (soma dos itens deveria fechar em 100)',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_formula_racao_item` (`id_formula_racao`,`id_ingrediente`),
  KEY `idx_formula_racao_item_ingrediente` (`id_ingrediente`),
  CONSTRAINT `fk_formula_racao_item_formula` FOREIGN KEY (`id_formula_racao`) REFERENCES `formula_racao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_formula_racao_item_ingrediente` FOREIGN KEY (`id_ingrediente`) REFERENCES `ingrediente` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.formula_racao_item: ~12 rows (aproximadamente)
DELETE FROM `formula_racao_item`;
INSERT INTO `formula_racao_item` (`id`, `id_formula_racao`, `id_ingrediente`, `percentual`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 3, 5, 60.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(4, 3, 3, 25.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(5, 3, 4, 10.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(6, 3, 6, 5.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(7, 4, 5, 40.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(8, 4, 3, 40.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(9, 4, 4, 15.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(10, 4, 6, 5.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(11, 5, 3, 60.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(12, 5, 4, 15.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(13, 5, 5, 20.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(14, 5, 6, 5.00, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.formula_racao_parametro
CREATE TABLE IF NOT EXISTS `formula_racao_parametro` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_formula_racao` int unsigned NOT NULL,
  `id_parametro_nutricional` int unsigned NOT NULL,
  `valor` decimal(10,3) NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_formula_racao_parametro` (`id_formula_racao`,`id_parametro_nutricional`),
  KEY `fk_formula_racao_parametro_parametro` (`id_parametro_nutricional`),
  CONSTRAINT `fk_formula_racao_parametro_formula` FOREIGN KEY (`id_formula_racao`) REFERENCES `formula_racao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_formula_racao_parametro_parametro` FOREIGN KEY (`id_parametro_nutricional`) REFERENCES `parametro_nutricional` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.formula_racao_parametro: ~0 rows (aproximadamente)
DELETE FROM `formula_racao_parametro`;

-- Copiando estrutura para tabela confinamento.fornecedor
CREATE TABLE IF NOT EXISTS `fornecedor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_situacao` int DEFAULT NULL,
  `id_ramo` int DEFAULT NULL,
  `pessoa` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'J',
  `documento` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `rg_ie` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `razao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `nome` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `nascimento` date DEFAULT NULL,
  `contato` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `telefone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `whatsapp` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `site` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cep` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `endereco` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `numero` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `complemento` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `bairro` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cidade` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `estado` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `pais` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'Brasil',
  `observacoes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `trash` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` int DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_fornecedor_situacao` (`id_situacao`) USING BTREE,
  KEY `idx_fornecedor_documento` (`documento`) USING BTREE,
  KEY `idx_fornecedor_trash` (`trash`) USING BTREE,
  KEY `idx_fornecedor_ramo` (`id_ramo`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.fornecedor: ~3 rows (aproximadamente)
DELETE FROM `fornecedor`;
INSERT INTO `fornecedor` (`id`, `id_situacao`, `id_ramo`, `pessoa`, `documento`, `rg_ie`, `razao`, `nome`, `nascimento`, `contato`, `telefone`, `whatsapp`, `email`, `site`, `cep`, `endereco`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, `pais`, `observacoes`, `trash`, `created_by`, `created_at`, `updated_by`, `updated_at`, `deleted_by`, `deleted_at`) VALUES
	(3, 1, 1, 'J', '12345678000190', NULL, 'NUTRICAO ANIMAL LTDA', 'Nutricao Animal', NULL, NULL, '1733001100', NULL, 'contato@nutricaoanimal.com.br', NULL, NULL, NULL, NULL, NULL, NULL, 'Barretos', 'SP', 'Brasil', NULL, 0, 1, '2026-07-09 20:27:58', NULL, NULL, NULL, NULL),
	(4, 1, 8, 'J', '23456789000180', NULL, 'PECUARIA SAO JOSE LTDA', 'Pecuaria Sao Jose', NULL, NULL, '1733001200', NULL, 'contato@pecuariasaojose.com.br', NULL, NULL, NULL, NULL, NULL, NULL, 'Colombia', 'SP', 'Brasil', NULL, 0, 1, '2026-07-09 20:27:58', NULL, NULL, NULL, NULL),
	(5, 1, 2, 'J', '34567890000170', NULL, 'VETFARMA DISTRIBUIDORA LTDA', 'Vetfarma', NULL, NULL, '1733001300', NULL, 'vendas@vetfarma.com.br', NULL, NULL, NULL, NULL, NULL, NULL, 'Barretos', 'SP', 'Brasil', NULL, 0, 1, '2026-07-09 20:27:58', NULL, NULL, NULL, NULL);

-- Copiando estrutura para tabela confinamento.fornecedor_ramo
CREATE TABLE IF NOT EXISTS `fornecedor_ramo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.fornecedor_ramo: ~9 rows (aproximadamente)
DELETE FROM `fornecedor_ramo`;
INSERT INTO `fornecedor_ramo` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'RAÇÃO E NUTRIÇÃO ANIMAL', NULL, '2026-07-08 19:40:10', NULL, NULL),
	(2, 'INSUMOS VETERINÁRIOS', NULL, '2026-07-08 19:40:10', NULL, NULL),
	(3, 'GENÉTICA E REPRODUÇÃO', NULL, '2026-07-08 19:40:10', NULL, NULL),
	(4, 'TRANSPORTE E LOGÍSTICA', NULL, '2026-07-08 19:40:10', NULL, NULL),
	(5, 'EQUIPAMENTOS E MÁQUINAS', NULL, '2026-07-08 19:40:10', NULL, NULL),
	(6, 'COMBUSTÍVEIS E LUBRIFICANTES', NULL, '2026-07-08 19:40:10', NULL, NULL),
	(7, 'CONSTRUÇÃO E MANUTENÇÃO', NULL, '2026-07-08 19:40:10', NULL, NULL),
	(8, 'COMPRA E VENDA DE GADO', NULL, '2026-07-08 19:40:10', NULL, NULL),
	(9, 'SERVIÇOS GERAIS', NULL, '2026-07-08 19:40:10', NULL, NULL);

-- Copiando estrutura para tabela confinamento.fornecedor_situacao
CREATE TABLE IF NOT EXISTS `fornecedor_situacao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `cor` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '#0d6efd',
  `ativo` tinyint(1) DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.fornecedor_situacao: ~2 rows (aproximadamente)
DELETE FROM `fornecedor_situacao`;
INSERT INTO `fornecedor_situacao` (`id`, `descricao`, `cor`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'ATIVO', '#198754', 1, NULL, '2026-07-08 18:40:12', NULL, NULL),
	(2, 'INATIVO', '#dc3545', 1, NULL, '2026-07-08 18:40:12', NULL, NULL);

-- Copiando estrutura para tabela confinamento.fornecimento_trato
CREATE TABLE IF NOT EXISTS `fornecimento_trato` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_programacao_trato` int unsigned DEFAULT NULL COMMENT 'opcional: vincula ao planejamento quando existir',
  `id_lote` int unsigned NOT NULL,
  `id_curral` int unsigned DEFAULT NULL,
  `id_formula_racao` int unsigned DEFAULT NULL,
  `id_operador` int DEFAULT NULL,
  `data_fornecimento` date NOT NULL,
  `hora_fornecimento` time DEFAULT NULL,
  `quantidade_fornecida` decimal(10,2) NOT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fornecimento_trato_lote` (`id_lote`,`data_fornecimento`),
  KEY `fk_fornecimento_trato_programacao` (`id_programacao_trato`),
  KEY `fk_fornecimento_trato_curral` (`id_curral`),
  KEY `fk_fornecimento_trato_formula` (`id_formula_racao`),
  KEY `fk_fornecimento_trato_operador` (`id_operador`),
  CONSTRAINT `fk_fornecimento_trato_curral` FOREIGN KEY (`id_curral`) REFERENCES `curral` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_fornecimento_trato_formula` FOREIGN KEY (`id_formula_racao`) REFERENCES `formula_racao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_fornecimento_trato_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_fornecimento_trato_operador` FOREIGN KEY (`id_operador`) REFERENCES `usuario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_fornecimento_trato_programacao` FOREIGN KEY (`id_programacao_trato`) REFERENCES `programacao_trato` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.fornecimento_trato: ~2 rows (aproximadamente)
DELETE FROM `fornecimento_trato`;
INSERT INTO `fornecimento_trato` (`id`, `id_programacao_trato`, `id_lote`, `id_curral`, `id_formula_racao`, `id_operador`, `data_fornecimento`, `hora_fornecimento`, `quantidade_fornecida`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 1, 8, 10, 4, 1, '2026-06-06', '07:00:00', 495.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(2, NULL, 9, 9, 3, 1, '2026-06-06', '07:30:00', 400.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.funcionario
CREATE TABLE IF NOT EXISTS `funcionario` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int DEFAULT NULL COMMENT 'opcional: vincula a uma conta de acesso ao sistema',
  `id_unidade` int unsigned DEFAULT NULL,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cpf` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cargo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `setor` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ex: operacional, tecnico, administrativo, apoio',
  `telefone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_admissao` date DEFAULT NULL,
  `data_demissao` date DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_funcionario_cpf` (`cpf`),
  KEY `idx_funcionario_nome` (`nome`),
  KEY `idx_funcionario_unidade` (`id_unidade`),
  KEY `fk_funcionario_usuario` (`id_usuario`),
  CONSTRAINT `fk_funcionario_unidade` FOREIGN KEY (`id_unidade`) REFERENCES `unidade` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_funcionario_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.funcionario: ~3 rows (aproximadamente)
DELETE FROM `funcionario`;
INSERT INTO `funcionario` (`id`, `id_usuario`, `id_unidade`, `nome`, `cpf`, `cargo`, `setor`, `telefone`, `email`, `data_admissao`, `data_demissao`, `observacao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(5, NULL, 14, 'Carlos Mendes', NULL, 'Gerente de Confinamento', 'ADMINISTRATIVO', '17999990001', NULL, '2023-01-10', NULL, NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(6, NULL, 14, 'Jose Roberto', NULL, 'Vaqueiro', 'OPERACIONAL', '17999990002', NULL, '2024-03-15', NULL, NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(7, NULL, 14, 'Ana Paula Souza', NULL, 'Veterinaria', 'TECNICO', '17999990003', NULL, '2023-06-01', NULL, NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58');

-- Copiando estrutura para tabela confinamento.grupo_ingrediente
CREATE TABLE IF NOT EXISTS `grupo_ingrediente` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ex: Energetico, Proteico, Volumoso, Mineral, Aditivo',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_grupo_ingrediente_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.grupo_ingrediente: ~5 rows (aproximadamente)
DELETE FROM `grupo_ingrediente`;
INSERT INTO `grupo_ingrediente` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'ENERGÉTICO', NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31'),
	(2, 'PROTEICO', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32'),
	(3, 'VOLUMOSO', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32'),
	(4, 'MINERAL', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32'),
	(5, 'ADITIVO', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32');

-- Copiando estrutura para tabela confinamento.ingrediente
CREATE TABLE IF NOT EXISTS `ingrediente` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_grupo_ingrediente` int unsigned DEFAULT NULL,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ex: Milho, Farelo de Soja, Silagem, Ureia, Nucleo',
  `unidade_medida` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'KG',
  `custo_unitario` decimal(10,4) DEFAULT NULL COMMENT 'custo por unidade de medida (ex: R$/KG), opcional, usado em relatorios de rentabilidade',
  `estoque_atual` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'saldo atual em estoque, baixado automaticamente pela Confeccao de Racao',
  `estoque_minimo` decimal(12,2) DEFAULT NULL COMMENT 'usado para alertas futuros de estoque baixo',
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ingrediente_nome` (`nome`),
  KEY `idx_ingrediente_grupo` (`id_grupo_ingrediente`),
  CONSTRAINT `fk_ingrediente_grupo` FOREIGN KEY (`id_grupo_ingrediente`) REFERENCES `grupo_ingrediente` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.ingrediente: ~5 rows (aproximadamente)
DELETE FROM `ingrediente`;
INSERT INTO `ingrediente` (`id`, `id_grupo_ingrediente`, `nome`, `unidade_medida`, `custo_unitario`, `estoque_atual`, `estoque_minimo`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 1, 'Milho Moido', 'KG', 0.8500, 4608.00, 1000.00, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-10 08:57:17'),
	(4, 2, 'Farelo de Soja', 'KG', 2.1000, 1853.00, 500.00, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-10 08:57:17'),
	(5, 3, 'Silagem de Milho', 'KG', 0.3500, 7608.00, 2000.00, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-10 08:57:17'),
	(6, 4, 'Nucleo Mineral', 'KG', 8.5000, 451.00, 100.00, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-10 08:57:17'),
	(7, 1, 'Ureia Pecuaria', 'KG', 3.2000, 300.00, 50.00, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-10 08:57:17');

-- Copiando estrutura para tabela confinamento.leitura_cocho
CREATE TABLE IF NOT EXISTS `leitura_cocho` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_fornecimento_trato` int unsigned DEFAULT NULL COMMENT 'opcional: vincula ao fornecimento que gerou esta leitura',
  `id_lote` int unsigned NOT NULL,
  `id_curral` int unsigned DEFAULT NULL,
  `data_leitura` date NOT NULL,
  `escore` tinyint unsigned NOT NULL COMMENT '0=limpo, 1=tracos, 2=leve sobra, 3=sobra moderada, 4=sobra excessiva',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_leitura_cocho_lote` (`id_lote`,`data_leitura`),
  KEY `fk_leitura_cocho_fornecimento` (`id_fornecimento_trato`),
  KEY `fk_leitura_cocho_curral` (`id_curral`),
  CONSTRAINT `fk_leitura_cocho_curral` FOREIGN KEY (`id_curral`) REFERENCES `curral` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_leitura_cocho_fornecimento` FOREIGN KEY (`id_fornecimento_trato`) REFERENCES `fornecimento_trato` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_leitura_cocho_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.leitura_cocho: ~4 rows (aproximadamente)
DELETE FROM `leitura_cocho`;
INSERT INTO `leitura_cocho` (`id`, `id_fornecimento_trato`, `id_lote`, `id_curral`, `data_leitura`, `escore`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, NULL, 8, 10, '2026-06-07', 1, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(2, NULL, 9, 9, '2026-06-07', 2, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(3, NULL, 8, 8, '2026-07-26', 4, 'teste', 2, '2026-07-26 14:32:06', NULL, '2026-07-26 14:32:06'),
	(4, NULL, 8, 10, '2026-07-26', 2, NULL, 2, '2026-07-26 14:32:32', NULL, '2026-07-26 14:32:32');

-- Copiando estrutura para tabela confinamento.lembrete
CREATE TABLE IF NOT EXISTS `lembrete` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned DEFAULT NULL COMMENT 'vinculo opcional (nunca junto com id_animal)',
  `id_animal` int unsigned DEFAULT NULL COMMENT 'vinculo opcional (nunca junto com id_lote)',
  `data_lembrete` date NOT NULL,
  `titulo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `concluido` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lembrete_data` (`data_lembrete`),
  KEY `idx_lembrete_lote` (`id_lote`),
  KEY `idx_lembrete_animal` (`id_animal`),
  CONSTRAINT `fk_lembrete_animal` FOREIGN KEY (`id_animal`) REFERENCES `animal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lembrete_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.lembrete: ~2 rows (aproximadamente)
DELETE FROM `lembrete`;
INSERT INTO `lembrete` (`id`, `id_lote`, `id_animal`, `data_lembrete`, `titulo`, `descricao`, `concluido`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 8, NULL, '2026-07-09', 'Revacinação programada', 'Aplicar segunda dose da vacina de febre aftosa no lote.', 0, 1, '2026-07-10 17:27:00', 1, '2026-07-10 22:43:49'),
	(2, NULL, NULL, '2026-07-20', 'Verificar estoque de sal mineral', 'Conferir se o estoque de sal mineral está suficiente para o mês.', 0, 1, '2026-07-10 17:27:00', NULL, '2026-07-10 17:27:00');

-- Copiando estrutura para tabela confinamento.local_armazenagem_interno
CREATE TABLE IF NOT EXISTS `local_armazenagem_interno` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_local_estoque` int unsigned NOT NULL,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ex: Baia do Milho, Prateleira A, Geladeira de Vacinas',
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_local_armazenagem_interno_local` (`id_local_estoque`),
  CONSTRAINT `fk_local_armazenagem_interno_local` FOREIGN KEY (`id_local_estoque`) REFERENCES `local_estoque` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.local_armazenagem_interno: ~2 rows (aproximadamente)
DELETE FROM `local_armazenagem_interno`;
INSERT INTO `local_armazenagem_interno` (`id`, `id_local_estoque`, `nome`, `descricao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 7, 'Prateleira de Vacinas', NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(4, 7, 'Geladeira de Medicamentos', NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.local_estoque
CREATE TABLE IF NOT EXISTS `local_estoque` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_unidade` int unsigned NOT NULL,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `capacidade` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `responsavel` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_local_estoque_codigo` (`codigo`),
  KEY `idx_local_estoque_nome` (`nome`),
  KEY `fk_local_estoque_unidade` (`id_unidade`),
  CONSTRAINT `fk_local_estoque_unidade` FOREIGN KEY (`id_unidade`) REFERENCES `unidade` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.local_estoque: ~2 rows (aproximadamente)
DELETE FROM `local_estoque`;
INSERT INTO `local_estoque` (`id`, `id_unidade`, `nome`, `codigo`, `tipo`, `capacidade`, `responsavel`, `observacao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(6, 14, 'Silo de Milho', 'SIL01', 'SILO', NULL, 'Carlos Mendes', NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(7, 14, 'Farmacia Veterinaria', 'FARM01', 'DEPOSITO', NULL, 'Ana Paula', NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58');

-- Copiando estrutura para tabela confinamento.lote
CREATE TABLE IF NOT EXISTS `lote` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_unidade` int unsigned NOT NULL,
  `id_curral` int unsigned DEFAULT NULL,
  `id_piquete` int unsigned DEFAULT NULL,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_formacao` date DEFAULT NULL,
  `fase` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `objetivo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ATIVO',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_lote_codigo` (`codigo`),
  KEY `idx_lote_nome` (`nome`),
  KEY `fk_lote_unidade` (`id_unidade`),
  KEY `fk_lote_curral` (`id_curral`),
  KEY `fk_lote_piquete` (`id_piquete`),
  CONSTRAINT `fk_lote_curral` FOREIGN KEY (`id_curral`) REFERENCES `curral` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_lote_piquete` FOREIGN KEY (`id_piquete`) REFERENCES `piquete` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_lote_unidade` FOREIGN KEY (`id_unidade`) REFERENCES `unidade` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.lote: ~3 rows (aproximadamente)
DELETE FROM `lote`;
INSERT INTO `lote` (`id`, `id_unidade`, `id_curral`, `id_piquete`, `nome`, `codigo`, `data_formacao`, `fase`, `objetivo`, `status`, `observacao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(8, 14, 8, NULL, 'Lote 2026-001', 'L2026001', '2026-05-01', 'ADAPTACAO', 'ENGORDA', 'ATIVO', NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(9, 14, 9, NULL, 'Lote 2026-002', 'L2026002', '2026-05-10', 'CRESCIMENTO', 'ENGORDA', 'ATIVO', NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(10, 15, 11, NULL, 'Lote 2026-003', 'L2026003', '2026-06-01', 'TERMINACAO', 'ENGORDA', 'ATIVO', NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.lote_entrada
CREATE TABLE IF NOT EXISTS `lote_entrada` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned NOT NULL,
  `quantidade` int unsigned DEFAULT NULL,
  `peso_medio` decimal(8,2) DEFAULT NULL,
  `peso_total` decimal(10,2) DEFAULT NULL,
  `data_entrada` date DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_lote_entrada_lote` (`id_lote`),
  CONSTRAINT `fk_lote_entrada_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.lote_entrada: ~3 rows (aproximadamente)
DELETE FROM `lote_entrada`;
INSERT INTO `lote_entrada` (`id`, `id_lote`, `quantidade`, `peso_medio`, `peso_total`, `data_entrada`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(5, 8, 50, 380.00, 19000.00, '2026-05-01', 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(6, 9, 60, 400.00, 24000.00, '2026-05-10', 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(7, 10, 40, 450.00, 18000.00, '2026-06-01', 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.lote_estoque
CREATE TABLE IF NOT EXISTS `lote_estoque` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_produto_estoque` int unsigned NOT NULL,
  `codigo_lote` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'codigo do lote de compra/fabricacao',
  `data_validade` date DEFAULT NULL,
  `quantidade_atual` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'saldo atual deste lote especifico',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_lote_estoque_produto_codigo` (`id_produto_estoque`,`codigo_lote`),
  KEY `idx_lote_estoque_validade` (`data_validade`),
  CONSTRAINT `fk_lote_estoque_produto` FOREIGN KEY (`id_produto_estoque`) REFERENCES `produto_estoque` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.lote_estoque: ~2 rows (aproximadamente)
DELETE FROM `lote_estoque`;
INSERT INTO `lote_estoque` (`id`, `id_produto_estoque`, `codigo_lote`, `data_validade`, `quantidade_atual`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 3, 'LOTE-AFTOSA-2026A', '2027-06-01', 110.00, NULL, 1, '2026-07-09 17:27:59', 1, '2026-07-10 22:39:41'),
	(4, 4, 'LOTE-VERMIFUGO-2026B', '2026-07-18', 8.50, NULL, 1, '2026-07-10 23:05:23', NULL, '2026-07-10 23:05:23');

-- Copiando estrutura para tabela confinamento.motivo_perda
CREATE TABLE IF NOT EXISTS `motivo_perda` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_motivo_perda_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.motivo_perda: ~5 rows (aproximadamente)
DELETE FROM `motivo_perda`;
INSERT INTO `motivo_perda` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'DOENÇA', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(2, 'ACIDENTE', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(3, 'PREDAÇÃO', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(4, 'INTOXICAÇÃO', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(5, 'OUTROS', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16');

-- Copiando estrutura para tabela confinamento.motivo_tratamento
CREATE TABLE IF NOT EXISTS `motivo_tratamento` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_motivo_tratamento_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.motivo_tratamento: ~7 rows (aproximadamente)
DELETE FROM `motivo_tratamento`;
INSERT INTO `motivo_tratamento` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'Vacinação de Rotina', NULL, '2026-07-10 23:56:58', NULL, '2026-07-10 23:56:58'),
	(2, 'Reforço Vacinal', NULL, '2026-07-10 23:56:58', NULL, '2026-07-10 23:56:58'),
	(3, 'Vermifugação', NULL, '2026-07-10 23:56:58', NULL, '2026-07-10 23:56:58'),
	(4, 'Tratamento Clínico', NULL, '2026-07-10 23:56:58', NULL, '2026-07-10 23:56:58'),
	(5, 'Prevenção', NULL, '2026-07-10 23:56:58', NULL, '2026-07-10 23:56:58'),
	(6, 'Suplementação', NULL, '2026-07-10 23:56:58', NULL, '2026-07-10 23:56:58'),
	(7, 'Outro', NULL, '2026-07-10 23:56:58', NULL, '2026-07-10 23:56:58');

-- Copiando estrutura para tabela confinamento.movimentacao
CREATE TABLE IF NOT EXISTS `movimentacao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_cartao` int NOT NULL,
  `id_cliente` int DEFAULT NULL COMMENT 'Snapshot do cliente vinculado ao cartão no momento da transação',
  `tipo` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sentido` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `saldo_anterior` decimal(10,2) NOT NULL,
  `saldo_posterior` decimal(10,2) NOT NULL,
  `origem` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `id_operador` int DEFAULT NULL,
  `referencia_tipo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `id_referencia` int DEFAULT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `expira_em` date DEFAULT NULL,
  `saldo_disponivel` decimal(10,2) DEFAULT NULL,
  `forma_pagamento` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_movimentacao_cartao` (`id_cartao`) USING BTREE,
  KEY `idx_movimentacao_tipo` (`tipo`) USING BTREE,
  KEY `idx_movimentacao_sentido` (`sentido`) USING BTREE,
  KEY `idx_movimentacao_origem` (`origem`) USING BTREE,
  KEY `idx_movimentacao_created_at` (`created_at`) USING BTREE,
  KEY `idx_movimentacao_operador` (`id_operador`) USING BTREE,
  KEY `idx_movimentacao_forma_pagamento` (`forma_pagamento`),
  KEY `idx_movimentacao_cliente` (`id_cliente`) USING BTREE,
  KEY `idx_movimentacao_expira_em` (`expira_em`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.movimentacao: ~43 rows (aproximadamente)
DELETE FROM `movimentacao`;
INSERT INTO `movimentacao` (`id`, `id_cartao`, `id_cliente`, `tipo`, `sentido`, `valor`, `saldo_anterior`, `saldo_posterior`, `origem`, `id_operador`, `referencia_tipo`, `id_referencia`, `descricao`, `expira_em`, `saldo_disponivel`, `forma_pagamento`, `created_at`, `created_by`) VALUES
	(1, 5, NULL, 'DEBITO', 'DEBITO', 540.00, 0.00, 0.00, 'admin', 1, 'venda', NULL, 'Gasto #1', NULL, NULL, NULL, '2026-04-24 18:32:49', 1),
	(2, 5, NULL, 'CASHBACK', 'CREDITO', 27.00, 0.00, 27.00, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #1 (R$ 540,00)', NULL, NULL, NULL, '2026-04-24 18:32:50', 1),
	(3, 5, NULL, 'FIDELIDADE', 'CREDITO', 90.00, 27.00, 117.00, 'sistema', NULL, 'movimentacao', 1, 'Bônus de Fidelidade do Gasto #1', NULL, NULL, NULL, '2026-04-24 18:32:51', 1),
	(4, 5, NULL, 'DEBITO', 'DEBITO', 540.00, 117.00, 117.00, 'admin', 1, 'venda', NULL, 'Gasto #4', NULL, NULL, NULL, '2026-04-24 18:44:31', 1),
	(5, 5, NULL, 'CASHBACK', 'CREDITO', 27.00, 117.00, 144.00, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #4 (R$ 540,00)', NULL, NULL, NULL, '2026-04-24 18:44:32', 1),
	(6, 5, NULL, 'FIDELIDADE', 'CREDITO', 90.00, 144.00, 234.00, 'sistema', NULL, 'movimentacao', 4, 'Bônus de Fidelidade do Gasto #4', NULL, NULL, NULL, '2026-04-24 18:44:33', 1),
	(7, 5, NULL, 'DEBITO', 'DEBITO', 114.00, 234.00, 234.00, 'admin', 1, 'venda', NULL, 'Gasto #7', NULL, NULL, NULL, '2026-04-24 18:45:25', 1),
	(8, 5, NULL, 'CASHBACK', 'CREDITO', 5.70, 234.00, 239.70, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #7 (R$ 114,00)', NULL, NULL, NULL, '2026-04-24 18:45:26', 1),
	(9, 5, NULL, 'DEBITO', 'DEBITO', 115.00, 239.70, 124.70, 'admin', 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-24 18:45:59', 1),
	(10, 5, 95, 'DEBITO', 'DEBITO', 124.70, 124.70, 0.00, 'admin', 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-24 18:46:58', 1),
	(11, 4, NULL, 'RECARGA', 'CREDITO', 100.00, 0.00, 100.00, 'admin', 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-24 20:02:43', 1),
	(12, 4, NULL, 'RECARGA', 'CREDITO', 1500.00, 100.00, 1600.00, 'admin', 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-24 20:02:47', 1),
	(13, 5, 95, 'DEBITO', 'DEBITO', 540.00, 0.00, 0.00, 'admin', 1, 'venda', NULL, 'Gasto #13', NULL, NULL, NULL, '2026-05-01 19:26:28', 1),
	(14, 5, 95, 'CASHBACK', 'CREDITO', 27.00, 0.00, 27.00, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #13 (R$ 540,00)', NULL, NULL, NULL, '2026-05-01 19:26:29', 1),
	(15, 5, 95, 'FIDELIDADE', 'CREDITO', 90.00, 27.00, 117.00, 'sistema', NULL, 'movimentacao', 13, 'BÃƒÂ´nus de Fidelidade do Gasto #13', NULL, NULL, NULL, '2026-05-01 19:26:30', 1),
	(16, 5, 95, 'DEBITO', 'DEBITO', 560.00, 117.00, 117.00, 'admin', 1, 'venda', NULL, 'Gasto #16', NULL, NULL, NULL, '2026-05-01 19:26:54', 1),
	(17, 5, 95, 'CASHBACK', 'CREDITO', 28.00, 117.00, 145.00, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #16 (R$ 560,00)', NULL, NULL, NULL, '2026-05-01 19:26:55', 1),
	(18, 5, 95, 'FIDELIDADE', 'CREDITO', 90.00, 145.00, 235.00, 'sistema', NULL, 'movimentacao', 16, 'BÃƒÂ´nus de Fidelidade do Gasto #16', NULL, NULL, NULL, '2026-05-01 19:26:56', 1),
	(19, 5, 95, 'DEBITO', 'DEBITO', 600.00, 235.00, 235.00, 'admin', 1, 'venda', NULL, 'Gasto #19 no valor de R$ 0,00 registrado', NULL, NULL, NULL, '2026-05-01 19:51:41', 1),
	(20, 5, 95, 'CASHBACK', 'CREDITO', 30.00, 235.00, 265.00, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #19 (R$ 600,00)', NULL, NULL, NULL, '2026-05-01 19:51:42', 1),
	(21, 5, 95, 'FIDELIDADE', 'CREDITO', 90.00, 265.00, 355.00, 'sistema', NULL, 'movimentacao', 19, 'Bonus de Fidelidade do Gasto #19', NULL, NULL, NULL, '2026-05-01 19:51:43', 1),
	(22, 5, 95, 'FIDELIDADE', 'CREDITO', 90.00, 355.00, 445.00, 'sistema', NULL, 'movimentacao', 19, 'Bonus de Fidelidade do Gasto #19', NULL, NULL, NULL, '2026-05-01 19:51:43', 1),
	(23, 5, 95, 'DEBITO', 'DEBITO', 265.00, 445.00, 445.00, 'admin', 1, 'venda', NULL, 'Gasto #23 no valor de R$ 265,00 registrado', NULL, NULL, NULL, '2026-05-01 19:55:37', 1),
	(24, 5, 95, 'CASHBACK', 'CREDITO', 13.25, 445.00, 458.25, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #23 (R$ 265,00)', NULL, NULL, NULL, '2026-05-01 19:55:38', 1),
	(25, 5, 95, 'DEBITO', 'DEBITO', 120.00, 458.25, 338.25, 'admin', 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-01 19:56:51', 1),
	(26, 5, 95, 'DEBITO', 'DEBITO', 250.00, 338.25, 338.25, 'admin', 1, 'venda', NULL, 'Gasto #26 no valor de R$ 250,00 registrado', NULL, NULL, NULL, '2026-05-01 19:57:11', 1),
	(27, 5, 95, 'CASHBACK', 'CREDITO', 12.50, 338.25, 350.75, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #26 (R$ 250,00)', NULL, NULL, NULL, '2026-05-01 19:57:12', 1),
	(28, 5, 95, 'FIDELIDADE', 'CREDITO', 90.00, 350.75, 440.75, 'sistema', NULL, 'movimentacao', 26, 'Bonus de Fidelidade do Gasto #26', NULL, NULL, NULL, '2026-05-01 19:57:13', 1),
	(29, 5, 95, 'DEBITO', 'DEBITO', 154.00, 440.75, 440.75, 'admin', 1, 'venda', NULL, 'Gasto #29 no valor de R$ 154,00 registrado', NULL, NULL, NULL, '2026-05-01 19:58:43', 1),
	(30, 5, 95, 'CASHBACK', 'CREDITO', 7.70, 440.75, 448.45, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #29 (R$ 154,00)', NULL, NULL, NULL, '2026-05-01 19:58:44', 1),
	(31, 5, 95, 'DEBITO', 'DEBITO', 150.00, 448.45, 448.45, 'admin', 1, 'venda', NULL, 'Gasto #31 no valor de R$ 150,00 registrado', NULL, NULL, NULL, '2026-05-01 20:03:49', 1),
	(32, 5, 95, 'CASHBACK', 'CREDITO', 7.50, 448.45, 455.95, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #31 (R$ 150,00)', NULL, NULL, NULL, '2026-05-01 20:03:50', 1),
	(33, 5, 95, 'FIDELIDADE', 'CREDITO', 90.00, 455.95, 545.95, 'sistema', NULL, 'movimentacao', 31, 'Bônus de Fidelidade do Gasto #31', NULL, NULL, NULL, '2026-05-01 20:03:51', 1),
	(34, 5, 95, 'ESTORNO', 'DEBITO', 90.00, 545.95, 455.95, 'admin', 1, 'movimentacao', 33, 'Não vai ganhar não', NULL, NULL, NULL, '2026-05-01 20:19:37', 1),
	(35, 1, 26, 'RECARGA', 'CREDITO', 150.00, 0.00, 150.00, 'admin', 1, NULL, NULL, NULL, '2026-04-30', 0.00, 'dinheiro', '2026-05-02 01:24:03', 1),
	(36, 1, 26, 'RECARGA', 'CREDITO', 180.00, 150.00, 330.00, 'admin', 1, NULL, NULL, NULL, '2026-06-30', 0.00, NULL, '2026-05-02 01:24:54', 1),
	(37, 1, 26, 'DEBITO', 'DEBITO', 200.00, 330.00, 130.00, 'admin', 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-02 01:25:16', 1),
	(38, 1, 26, 'EXPIRACAO', 'DEBITO', 130.00, 130.00, 0.00, 'sistema', NULL, 'movimentacao', 35, 'Credito expirado', NULL, NULL, NULL, '2026-05-02 01:28:43', NULL),
	(39, 1, 26, 'DEBITO', 'DEBITO', 105.00, 0.00, 0.00, 'admin', 1, 'venda', NULL, 'Gasto #39 no valor de R$ 105,00 registrado', NULL, NULL, NULL, '2026-05-02 01:53:36', 1),
	(40, 1, 26, 'CASHBACK', 'CREDITO', 5.25, 0.00, 5.25, 'sistema', 1, 'cashback_regra', 1, 'Cashback do Gasto #39 (R$ 105,00)', '2026-04-30', 0.00, NULL, '2026-05-02 01:53:37', 1),
	(41, 1, 26, 'EXPIRACAO', 'DEBITO', 5.25, 5.25, 0.00, 'sistema', NULL, 'movimentacao', 40, 'Credito expirado', NULL, NULL, NULL, '2026-05-02 01:54:09', NULL),
	(42, 1, 26, 'RECARGA', 'CREDITO', 50.00, 0.00, 50.00, 'admin', 1, NULL, NULL, NULL, '2026-07-01', 50.00, NULL, '2026-05-02 03:18:41', 1),
	(43, 9, NULL, 'RECARGA', 'CREDITO', 120.00, 0.00, 120.00, 'admin', 1, NULL, NULL, NULL, '2026-07-01', 120.00, NULL, '2026-05-02 03:25:36', 1);

-- Copiando estrutura para tabela confinamento.movimentacao_dieta
CREATE TABLE IF NOT EXISTS `movimentacao_dieta` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned NOT NULL,
  `id_formula_racao` int unsigned NOT NULL,
  `data_troca` date NOT NULL,
  `motivo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ex: mudanca de fase, leitura de cocho, estrategia tecnica',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_movimentacao_dieta_lote` (`id_lote`,`data_troca`),
  KEY `fk_movimentacao_dieta_formula` (`id_formula_racao`),
  CONSTRAINT `fk_movimentacao_dieta_formula` FOREIGN KEY (`id_formula_racao`) REFERENCES `formula_racao` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_dieta_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.movimentacao_dieta: ~4 rows (aproximadamente)
DELETE FROM `movimentacao_dieta`;
INSERT INTO `movimentacao_dieta` (`id`, `id_lote`, `id_formula_racao`, `data_troca`, `motivo`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(2, 8, 3, '2026-05-01', 'Início do confinamento', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(3, 8, 4, '2026-06-01', 'Fase de crescimento', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(4, 9, 3, '2026-05-10', 'Início do confinamento', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(5, 10, 5, '2026-06-01', 'Lote em fase final', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.movimentacao_entrada
CREATE TABLE IF NOT EXISTS `movimentacao_entrada` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned NOT NULL,
  `id_fornecedor` int DEFAULT NULL,
  `id_curral_destino` int unsigned DEFAULT NULL,
  `id_tipo_entrada` int unsigned DEFAULT NULL,
  `documento` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'numero da nota fiscal ou GTA',
  `tipo_documento` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'NF, GTA, OUTRO',
  `data_entrada` date NOT NULL,
  `valor_total` decimal(12,2) DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_movimentacao_entrada_lote` (`id_lote`),
  KEY `idx_movimentacao_entrada_fornecedor` (`id_fornecedor`),
  KEY `fk_movimentacao_entrada_curral` (`id_curral_destino`),
  KEY `fk_movimentacao_entrada_tipo` (`id_tipo_entrada`),
  CONSTRAINT `fk_movimentacao_entrada_curral` FOREIGN KEY (`id_curral_destino`) REFERENCES `curral` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_entrada_fornecedor` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_entrada_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_entrada_tipo` FOREIGN KEY (`id_tipo_entrada`) REFERENCES `tipo_entrada` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.movimentacao_entrada: ~3 rows (aproximadamente)
DELETE FROM `movimentacao_entrada`;
INSERT INTO `movimentacao_entrada` (`id`, `id_lote`, `id_fornecedor`, `id_curral_destino`, `id_tipo_entrada`, `documento`, `tipo_documento`, `data_entrada`, `valor_total`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 8, 4, 8, 1, 'NF-1001', 'NF', '2026-05-01', 152000.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(4, 9, 4, 9, 1, 'NF-1002', 'NF', '2026-05-10', 192000.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(5, 10, 4, 11, 1, 'NF-1003', 'NF', '2026-06-01', 162000.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.movimentacao_estoque
CREATE TABLE IF NOT EXISTS `movimentacao_estoque` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_produto_estoque` int unsigned NOT NULL,
  `id_tipo_movimentacao_estoque` int unsigned NOT NULL,
  `id_lote_estoque` int unsigned DEFAULT NULL COMMENT 'opcional: obrigatorio na aplicacao quando produto.controla_lote = 1',
  `id_local_armazenagem_interno_origem` int unsigned DEFAULT NULL COMMENT 'usado em transferencias',
  `id_local_armazenagem_interno_destino` int unsigned DEFAULT NULL COMMENT 'usado em transferencias',
  `id_centro_custo` int unsigned DEFAULT NULL,
  `id_fornecedor` int DEFAULT NULL COMMENT 'opcional: de quem veio, em entradas por compra',
  `id_operador` int DEFAULT NULL,
  `data_movimentacao` date NOT NULL,
  `quantidade` decimal(12,2) NOT NULL,
  `motivo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_movimentacao_estoque_produto` (`id_produto_estoque`,`data_movimentacao`),
  KEY `idx_movimentacao_estoque_lote` (`id_lote_estoque`),
  KEY `fk_movimentacao_estoque_tipo` (`id_tipo_movimentacao_estoque`),
  KEY `fk_movimentacao_estoque_local_origem` (`id_local_armazenagem_interno_origem`),
  KEY `fk_movimentacao_estoque_local_destino` (`id_local_armazenagem_interno_destino`),
  KEY `fk_movimentacao_estoque_centro_custo` (`id_centro_custo`),
  KEY `fk_movimentacao_estoque_fornecedor` (`id_fornecedor`),
  KEY `fk_movimentacao_estoque_operador` (`id_operador`),
  CONSTRAINT `fk_movimentacao_estoque_centro_custo` FOREIGN KEY (`id_centro_custo`) REFERENCES `centro_custo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_fornecedor` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_local_destino` FOREIGN KEY (`id_local_armazenagem_interno_destino`) REFERENCES `local_armazenagem_interno` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_local_origem` FOREIGN KEY (`id_local_armazenagem_interno_origem`) REFERENCES `local_armazenagem_interno` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_lote` FOREIGN KEY (`id_lote_estoque`) REFERENCES `lote_estoque` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_operador` FOREIGN KEY (`id_operador`) REFERENCES `usuario` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_produto` FOREIGN KEY (`id_produto_estoque`) REFERENCES `produto_estoque` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_estoque_tipo` FOREIGN KEY (`id_tipo_movimentacao_estoque`) REFERENCES `tipo_movimentacao_estoque` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.movimentacao_estoque: ~0 rows (aproximadamente)
DELETE FROM `movimentacao_estoque`;
INSERT INTO `movimentacao_estoque` (`id`, `id_produto_estoque`, `id_tipo_movimentacao_estoque`, `id_lote_estoque`, `id_local_armazenagem_interno_origem`, `id_local_armazenagem_interno_destino`, `id_centro_custo`, `id_fornecedor`, `id_operador`, `data_movimentacao`, `quantidade`, `motivo`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(4, 3, 1, 3, NULL, NULL, 6, 5, 1, '2026-06-15', 200.00, 'Compra inicial de vacinas', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.movimentacao_localizacao
CREATE TABLE IF NOT EXISTS `movimentacao_localizacao` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned NOT NULL,
  `id_curral_origem` int unsigned DEFAULT NULL,
  `id_piquete_origem` int unsigned DEFAULT NULL,
  `id_curral_destino` int unsigned DEFAULT NULL,
  `id_piquete_destino` int unsigned DEFAULT NULL,
  `data_movimentacao` date NOT NULL,
  `quantidade` int unsigned DEFAULT NULL COMMENT 'numero de cabecas movidas; nulo = lote inteiro',
  `motivo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_movimentacao_localizacao_lote` (`id_lote`,`data_movimentacao`),
  KEY `fk_movimentacao_localizacao_curral_origem` (`id_curral_origem`),
  KEY `fk_movimentacao_localizacao_piquete_origem` (`id_piquete_origem`),
  KEY `fk_movimentacao_localizacao_curral_destino` (`id_curral_destino`),
  KEY `fk_movimentacao_localizacao_piquete_destino` (`id_piquete_destino`),
  CONSTRAINT `fk_movimentacao_localizacao_curral_destino` FOREIGN KEY (`id_curral_destino`) REFERENCES `curral` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_localizacao_curral_origem` FOREIGN KEY (`id_curral_origem`) REFERENCES `curral` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_localizacao_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_localizacao_piquete_destino` FOREIGN KEY (`id_piquete_destino`) REFERENCES `piquete` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_localizacao_piquete_origem` FOREIGN KEY (`id_piquete_origem`) REFERENCES `piquete` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.movimentacao_localizacao: ~4 rows (aproximadamente)
DELETE FROM `movimentacao_localizacao`;
INSERT INTO `movimentacao_localizacao` (`id`, `id_lote`, `id_curral_origem`, `id_piquete_origem`, `id_curral_destino`, `id_piquete_destino`, `data_movimentacao`, `quantidade`, `motivo`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 8, NULL, NULL, 8, NULL, '2026-05-01', 50, 'Alocação inicial', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(4, 9, NULL, NULL, 9, NULL, '2026-05-10', 60, 'Alocação inicial', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(5, 10, NULL, NULL, 11, NULL, '2026-06-01', 40, 'Alocação inicial', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(6, 8, 8, NULL, 10, NULL, '2026-06-20', 50, 'Transferência por reforma do curral 01', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.movimentacao_mortalidade
CREATE TABLE IF NOT EXISTS `movimentacao_mortalidade` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned NOT NULL,
  `id_motivo_perda` int unsigned DEFAULT NULL,
  `data_ocorrencia` date NOT NULL,
  `quantidade` int unsigned NOT NULL DEFAULT '1',
  `responsavel` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_movimentacao_mortalidade_lote` (`id_lote`,`data_ocorrencia`),
  KEY `fk_movimentacao_mortalidade_motivo` (`id_motivo_perda`),
  CONSTRAINT `fk_movimentacao_mortalidade_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_mortalidade_motivo` FOREIGN KEY (`id_motivo_perda`) REFERENCES `motivo_perda` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.movimentacao_mortalidade: ~0 rows (aproximadamente)
DELETE FROM `movimentacao_mortalidade`;
INSERT INTO `movimentacao_mortalidade` (`id`, `id_lote`, `id_motivo_perda`, `data_ocorrencia`, `quantidade`, `responsavel`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(2, 9, 1, '2026-06-15', 1, 'Ana Paula Souza', 'Óbito por pneumonia, atendido mas não resistiu', 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.movimentacao_pesagem
CREATE TABLE IF NOT EXISTS `movimentacao_pesagem` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned DEFAULT NULL,
  `id_animal` int unsigned DEFAULT NULL,
  `tipo` enum('INICIAL','INTERMEDIARIA','FINAL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'INTERMEDIARIA',
  `data_pesagem` date NOT NULL,
  `quantidade` int unsigned DEFAULT NULL COMMENT 'numero de cabecas pesadas, quando id_lote (agregado); nulo para pesagem de animal individual',
  `peso_medio` decimal(8,2) DEFAULT NULL COMMENT 'peso medio por cabeca (lote) ou peso do animal (individual)',
  `peso_total` decimal(10,2) DEFAULT NULL COMMENT 'peso total do lote pesado; nulo para pesagem individual',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_movimentacao_pesagem_lote` (`id_lote`,`data_pesagem`),
  KEY `idx_movimentacao_pesagem_animal` (`id_animal`,`data_pesagem`),
  CONSTRAINT `fk_movimentacao_pesagem_animal` FOREIGN KEY (`id_animal`) REFERENCES `animal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_pesagem_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.movimentacao_pesagem: ~5 rows (aproximadamente)
DELETE FROM `movimentacao_pesagem`;
INSERT INTO `movimentacao_pesagem` (`id`, `id_lote`, `id_animal`, `tipo`, `data_pesagem`, `quantidade`, `peso_medio`, `peso_total`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(5, 8, NULL, 'INICIAL', '2026-05-01', 50, 380.00, 19000.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(6, 8, NULL, 'INTERMEDIARIA', '2026-06-01', 50, 420.00, 21000.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(7, 9, NULL, 'INICIAL', '2026-05-10', 60, 400.00, 24000.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(8, 9, NULL, 'INTERMEDIARIA', '2026-06-10', 60, 445.00, 26700.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(9, 10, NULL, 'INICIAL', '2026-06-01', 40, 450.00, 18000.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.movimentacao_saida
CREATE TABLE IF NOT EXISTS `movimentacao_saida` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned NOT NULL,
  `id_tipo_saida` int unsigned DEFAULT NULL,
  `id_cliente` int DEFAULT NULL,
  `data_saida` date NOT NULL,
  `quantidade` int unsigned DEFAULT NULL,
  `peso_total` decimal(10,2) DEFAULT NULL,
  `peso_medio` decimal(8,2) DEFAULT NULL,
  `valor_total` decimal(12,2) DEFAULT NULL,
  `resultado` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'observacao livre sobre o resultado (lucro/prejuizo, motivo, etc.)',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_movimentacao_saida_lote` (`id_lote`,`data_saida`),
  KEY `idx_movimentacao_saida_cliente` (`id_cliente`),
  KEY `fk_movimentacao_saida_tipo` (`id_tipo_saida`),
  CONSTRAINT `fk_movimentacao_saida_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_saida_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_movimentacao_saida_tipo` FOREIGN KEY (`id_tipo_saida`) REFERENCES `tipo_saida` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.movimentacao_saida: ~0 rows (aproximadamente)
DELETE FROM `movimentacao_saida`;
INSERT INTO `movimentacao_saida` (`id`, `id_lote`, `id_tipo_saida`, `id_cliente`, `data_saida`, `quantidade`, `peso_total`, `peso_medio`, `valor_total`, `resultado`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(2, 10, 1, 25, '2026-07-05', 5, 2450.00, 490.00, 24500.00, 'Venda parcial do lote 3, bom acabamento', NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59');

-- Copiando estrutura para tabela confinamento.ocorrencia
CREATE TABLE IF NOT EXISTS `ocorrencia` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned DEFAULT NULL COMMENT 'preenchido quando a ocorrencia e em lote (nunca junto com id_animal)',
  `id_animal` int unsigned DEFAULT NULL COMMENT 'preenchido quando a ocorrencia e individual (nunca junto com id_lote)',
  `data_ocorrencia` date NOT NULL,
  `titulo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `categoria` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'classificacao livre, ex: Sanitário, Estrutural, Comportamental, Administrativo',
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `responsavel` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ocorrencia_lote` (`id_lote`,`data_ocorrencia`),
  KEY `idx_ocorrencia_animal` (`id_animal`,`data_ocorrencia`),
  CONSTRAINT `fk_ocorrencia_animal` FOREIGN KEY (`id_animal`) REFERENCES `animal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ocorrencia_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.ocorrencia: ~4 rows (aproximadamente)
DELETE FROM `ocorrencia`;
INSERT INTO `ocorrencia` (`id`, `id_lote`, `id_animal`, `data_ocorrencia`, `titulo`, `categoria`, `descricao`, `responsavel`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(2, 8, NULL, '2026-06-20', 'Cocho danificado no curral', 'Estrutural', 'Cocho de alimentação apresentou rachadura e precisa de reparo antes do próximo trato.', 'João Tratador', 1, '2026-07-10 17:02:44', NULL, '2026-07-10 17:02:44'),
	(3, NULL, 3, '2026-06-25', 'Claudicação leve observada', 'Sanitário', 'Animal apresentou leve claudicação na pata traseira direita durante inspeção de rotina. Em observação.', 'Dra. Ana Veterinária', 1, '2026-07-10 17:02:44', NULL, '2026-07-10 17:02:44'),
	(4, 9, NULL, '2026-07-01', 'Comportamento agressivo no lote', 'Comportamental', 'Registrado comportamento agressivo entre animais do lote durante o fornecimento de trato da manhã.', 'João Tratador', 1, '2026-07-10 17:02:44', NULL, '2026-07-10 17:02:44'),
	(5, NULL, NULL, '2026-07-05', 'Manutenção preventiva do trator', 'Administrativo', 'Trator utilizado na distribuição de ração passou por manutenção preventiva programada.', 'Carlos Mecânico', 1, '2026-07-10 17:02:44', NULL, '2026-07-10 17:02:44');

-- Copiando estrutura para tabela confinamento.ocorrencia_anexo
CREATE TABLE IF NOT EXISTS `ocorrencia_anexo` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_ocorrencia` int unsigned NOT NULL,
  `arquivo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'nome do arquivo salvo em storage/media/ocorrencias/',
  `nome_original` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo_midia` enum('IMAGEM','VIDEO','AUDIO','OUTRO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OUTRO',
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tamanho` int unsigned DEFAULT NULL COMMENT 'bytes',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ocorrencia_anexo_ocorrencia` (`id_ocorrencia`),
  CONSTRAINT `fk_ocorrencia_anexo_ocorrencia` FOREIGN KEY (`id_ocorrencia`) REFERENCES `ocorrencia` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.ocorrencia_anexo: ~3 rows (aproximadamente)
DELETE FROM `ocorrencia_anexo`;
INSERT INTO `ocorrencia_anexo` (`id`, `id_ocorrencia`, `arquivo`, `nome_original`, `tipo_midia`, `mime_type`, `tamanho`, `created_by`, `created_at`) VALUES
	(3, 2, 'seed_cocho.png', 'cocho-rachado.png', 'IMAGEM', 'image/png', 68, 1, '2026-07-10 17:03:12'),
	(4, 3, 'seed_claudicacao_1.png', 'pata-direita.png', 'IMAGEM', 'image/png', 68, 1, '2026-07-10 17:03:12'),
	(5, 3, 'seed_claudicacao_2.png', 'pata-direita-2.png', 'IMAGEM', 'image/png', 68, 1, '2026-07-10 17:03:12');

-- Copiando estrutura para tabela confinamento.ocorrencia_sanitaria
CREATE TABLE IF NOT EXISTS `ocorrencia_sanitaria` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned DEFAULT NULL COMMENT 'preenchido quando a ocorrencia e em lote (nunca junto com id_animal)',
  `id_animal` int unsigned DEFAULT NULL COMMENT 'preenchido quando a ocorrencia e individual (nunca junto com id_lote)',
  `data_ocorrencia` date NOT NULL,
  `descricao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gravidade` enum('LEVE','MODERADA','GRAVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LEVE',
  `responsavel` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ocorrencia_sanitaria_lote` (`id_lote`,`data_ocorrencia`),
  KEY `idx_ocorrencia_sanitaria_animal` (`id_animal`,`data_ocorrencia`),
  CONSTRAINT `fk_ocorrencia_sanitaria_animal` FOREIGN KEY (`id_animal`) REFERENCES `animal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ocorrencia_sanitaria_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.ocorrencia_sanitaria: ~3 rows (aproximadamente)
DELETE FROM `ocorrencia_sanitaria`;
INSERT INTO `ocorrencia_sanitaria` (`id`, `id_lote`, `id_animal`, `data_ocorrencia`, `descricao`, `gravidade`, `responsavel`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(2, 9, NULL, '2026-06-15', 'Foco de bicheira observado em 3 animais do lote', 'MODERADA', 'Ana Paula Souza', NULL, 1, '2026-07-09 18:52:50', NULL, '2026-07-09 18:52:50'),
	(3, NULL, 2, '2026-05-20', 'Claudicação leve na pata traseira, sem sinais de fratura', 'LEVE', 'Ana Paula Souza', 'Em observação, sem necessidade de tratamento imediato', 1, '2026-07-09 18:52:50', NULL, '2026-07-09 18:52:50'),
	(4, NULL, 7, '2026-06-20', 'Ferimento superficial em cerca, tratado com curativo local', 'LEVE', 'Ana Paula Souza', NULL, 1, '2026-07-09 18:57:18', NULL, '2026-07-09 18:57:18');

-- Copiando estrutura para tabela confinamento.parametro_nutricional
CREATE TABLE IF NOT EXISTS `parametro_nutricional` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ex: Materia Seca, Proteina Bruta, Fibra, Energia, Consumo Previsto',
  `unidade_medida` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ex: %, Mcal/kg, kg/dia',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_parametro_nutricional_nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.parametro_nutricional: ~5 rows (aproximadamente)
DELETE FROM `parametro_nutricional`;
INSERT INTO `parametro_nutricional` (`id`, `nome`, `unidade_medida`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'MATÉRIA SECA', '%', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32'),
	(2, 'PROTEÍNA BRUTA', '%', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32'),
	(3, 'FIBRA', '%', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32'),
	(4, 'ENERGIA', 'Mcal/kg', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32'),
	(5, 'CONSUMO PREVISTO', 'kg/dia', NULL, '2026-07-09 14:04:32', NULL, '2026-07-09 14:04:32');

-- Copiando estrutura para tabela confinamento.password_reset_tokens
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `guard` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `user_id` int NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `token_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `requested_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uniq_password_reset_token_hash` (`token_hash`) USING BTREE,
  KEY `idx_password_reset_guard_user` (`guard`,`user_id`) USING BTREE,
  KEY `idx_password_reset_email` (`email`) USING BTREE,
  KEY `idx_password_reset_expires_at` (`expires_at`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.password_reset_tokens: ~0 rows (aproximadamente)
DELETE FROM `password_reset_tokens`;
INSERT INTO `password_reset_tokens` (`id`, `guard`, `user_id`, `email`, `token_hash`, `requested_ip`, `expires_at`, `used_at`, `created_at`) VALUES
	(1, 'usuario', 1, 'diego@agenciadiz.com', '4f3e60a06979003821b17da0431e13f7fa45452d91af3ade74eb4c731586929e', '127.0.0.1', '2026-04-17 19:14:02', '2026-04-17 18:15:14', '2026-04-17 18:14:02');

-- Copiando estrutura para tabela confinamento.piquete
CREATE TABLE IF NOT EXISTS `piquete` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_unidade` int unsigned NOT NULL,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacidade` int unsigned DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ATIVO',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_piquete_codigo` (`codigo`),
  KEY `idx_piquete_nome` (`nome`),
  KEY `fk_piquete_unidade` (`id_unidade`),
  CONSTRAINT `fk_piquete_unidade` FOREIGN KEY (`id_unidade`) REFERENCES `unidade` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.piquete: ~0 rows (aproximadamente)
DELETE FROM `piquete`;
INSERT INTO `piquete` (`id`, `id_unidade`, `nome`, `codigo`, `capacidade`, `status`, `observacao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 15, 'Piquete 01', 'P01', 80, 'ATIVO', NULL, 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58');

-- Copiando estrutura para tabela confinamento.plano_conta
CREATE TABLE IF NOT EXISTS `plano_conta` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'C??digo de classifica????o (ex: 1.1.1)',
  `nome` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo` enum('RECEITA','DESPESA') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DESPESA' COMMENT 'Natureza da conta',
  `descricao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int unsigned DEFAULT NULL,
  `updated_by` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_plano_conta_tipo` (`tipo`),
  KEY `idx_plano_conta_ativo` (`ativo`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.plano_conta: ~13 rows (aproximadamente)
DELETE FROM `plano_conta`;
INSERT INTO `plano_conta` (`id`, `codigo`, `nome`, `tipo`, `descricao`, `ativo`, `created_at`, `updated_at`, `created_by`, `updated_by`) VALUES
	(1, '1.1.1', 'Venda de Gado', 'RECEITA', 'Receita com venda de animais para abate ou reprodu????o', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:35', NULL, NULL),
	(2, '1.1.2', 'Venda de Produtos', 'RECEITA', 'Receita com venda de produtos, subprodutos e excedentes', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:35', NULL, NULL),
	(3, '1.1.3', 'Serviços Prestados', 'RECEITA', 'Receita com servi??os prestados a terceiros', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:54', NULL, NULL),
	(4, '1.1.4', 'Outras Receitas', 'RECEITA', 'Outras receitas operacionais', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:35', NULL, NULL),
	(5, '2.1.1', 'Compra de Gado', 'DESPESA', 'Aquisi????o de animais para engorda/reprodu????o', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:35', NULL, NULL),
	(6, '2.1.2', 'Alimentação / Nutrição', 'DESPESA', 'Ra????o, suplementos, sal mineral e insumos nutricionais', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:54', NULL, NULL),
	(7, '2.1.3', 'Sanitário / Medicamentos', 'DESPESA', 'Vacinas, medicamentos e insumos veterin??rios', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:54', NULL, NULL),
	(8, '2.1.4', 'Mão de Obra / Funcionários', 'DESPESA', 'Sal??rios, encargos e benef??cios da equipe', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:54', NULL, NULL),
	(9, '2.1.5', 'Manutenção / Equipamentos', 'DESPESA', 'Manuten????o de currais, cercas, m??quinas e equipamentos', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:54', NULL, NULL),
	(10, '2.1.6', 'Frete / Transporte', 'DESPESA', 'Frete de insumos, animais e demais cargas', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:35', NULL, NULL),
	(11, '2.1.7', 'Impostos / Taxas', 'DESPESA', 'Impostos, taxas e contribui????es', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:35', NULL, NULL),
	(12, '2.1.8', 'Utilidades / Energia / Água', 'DESPESA', 'Contas de energia el??trica, ??gua e telecomunica????es', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:54', NULL, NULL),
	(13, '2.1.9', 'Outras Despesas', 'DESPESA', 'Outras despesas operacionais', 1, '2026-07-21 19:33:35', '2026-07-21 19:33:35', NULL, NULL),
	(14, '1', 'RECEITAS', 'RECEITA', NULL, 1, '2026-07-26 14:33:45', '2026-07-26 14:33:45', 2, NULL);

-- Copiando estrutura para tabela confinamento.produto_estoque
CREATE TABLE IF NOT EXISTS `produto_estoque` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_categoria_produto` int unsigned DEFAULT NULL,
  `tipo_produto` enum('RACAO_INSUMO','MEDICAMENTO','VACINA','SUPLEMENTO','MATERIAL_CONSUMO','COMBUSTIVEL_LUBRIFICANTE','OUTRO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OUTRO' COMMENT 'classificacao interna fixa, independente da categoria_produto (texto livre)',
  `id_local_armazenagem_interno` int unsigned DEFAULT NULL COMMENT 'local interno padrao onde o item costuma ficar',
  `id_fornecedor_padrao` int DEFAULT NULL COMMENT 'fornecedor preferencial deste item, opcional',
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `principio_ativo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'relevante para MEDICAMENTO/VACINA/SUPLEMENTO',
  `apresentacao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ex: injetavel, comprimido, po, liquido oral',
  `fabricante` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'fabricante/laboratorio, relevante para MEDICAMENTO/VACINA',
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unidade_medida` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UN',
  `custo_unitario` decimal(10,4) DEFAULT NULL COMMENT 'custo por unidade de medida, opcional, usado em relatorios de rentabilidade',
  `saldo_atual` decimal(12,2) NOT NULL DEFAULT '0.00' COMMENT 'saldo agregado, atualizado pelas movimentacoes de estoque',
  `estoque_minimo` decimal(12,2) DEFAULT NULL COMMENT 'usado para alertas de estoque baixo',
  `controla_lote` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'se 1, movimentacoes deste produto devem informar lote_estoque',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_produto_estoque_nome` (`nome`),
  KEY `idx_produto_estoque_categoria` (`id_categoria_produto`),
  KEY `idx_produto_estoque_local_interno` (`id_local_armazenagem_interno`),
  KEY `idx_produto_estoque_fornecedor` (`id_fornecedor_padrao`),
  KEY `idx_produto_estoque_tipo` (`tipo_produto`),
  CONSTRAINT `fk_produto_estoque_categoria` FOREIGN KEY (`id_categoria_produto`) REFERENCES `categoria_produto` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_produto_estoque_fornecedor` FOREIGN KEY (`id_fornecedor_padrao`) REFERENCES `fornecedor` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_produto_estoque_local_interno` FOREIGN KEY (`id_local_armazenagem_interno`) REFERENCES `local_armazenagem_interno` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.produto_estoque: ~3 rows (aproximadamente)
DELETE FROM `produto_estoque`;
INSERT INTO `produto_estoque` (`id`, `id_categoria_produto`, `tipo_produto`, `id_local_armazenagem_interno`, `id_fornecedor_padrao`, `nome`, `principio_ativo`, `apresentacao`, `fabricante`, `codigo`, `unidade_medida`, `custo_unitario`, `saldo_atual`, `estoque_minimo`, `controla_lote`, `observacao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(3, 2, 'VACINA', 3, 5, 'Vacina Febre Aftosa', NULL, NULL, NULL, 'PROD01', 'DOSE', 18.5000, 110.00, 50.00, 1, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 23:56:44'),
	(4, 2, 'MEDICAMENTO', 3, 5, 'Vermifugo Injetavel', NULL, NULL, NULL, 'PROD02', 'ML', 12.0000, 4930.00, 1000.00, 0, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 23:56:44'),
	(5, 4, 'COMBUSTIVEL_LUBRIFICANTE', NULL, NULL, 'Diesel S10', NULL, NULL, NULL, 'PROD03', 'LT', 6.2000, 1000.00, 200.00, 0, NULL, 1, 1, '2026-07-09 17:27:59', NULL, '2026-07-10 23:56:44');

-- Copiando estrutura para tabela confinamento.programacao_trato
CREATE TABLE IF NOT EXISTS `programacao_trato` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_lote` int unsigned NOT NULL,
  `id_curral` int unsigned DEFAULT NULL,
  `id_formula_racao` int unsigned DEFAULT NULL,
  `data_programacao` date NOT NULL,
  `turno` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ex: MANHA, TARDE, NOITE',
  `quantidade_prevista` decimal(10,2) DEFAULT NULL COMMENT 'kg previstos para este trato',
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_programacao_trato_lote` (`id_lote`,`data_programacao`),
  KEY `fk_programacao_trato_curral` (`id_curral`),
  KEY `fk_programacao_trato_formula` (`id_formula_racao`),
  CONSTRAINT `fk_programacao_trato_curral` FOREIGN KEY (`id_curral`) REFERENCES `curral` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_programacao_trato_formula` FOREIGN KEY (`id_formula_racao`) REFERENCES `formula_racao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_programacao_trato_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.programacao_trato: ~4 rows (aproximadamente)
DELETE FROM `programacao_trato`;
INSERT INTO `programacao_trato` (`id`, `id_lote`, `id_curral`, `id_formula_racao`, `data_programacao`, `turno`, `quantidade_prevista`, `observacao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 8, 10, 4, '2026-06-06', 'MANHA', 500.00, NULL, 1, '2026-07-09 17:27:59', 1, '2026-07-10 22:38:00'),
	(2, 8, 10, 4, '2026-06-06', 'TARDE', 500.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(3, 9, 9, 3, '2026-06-06', 'MANHA', 400.00, NULL, 1, '2026-07-09 17:27:59', NULL, '2026-07-09 17:27:59'),
	(4, 10, NULL, NULL, '2026-07-14', 'MANHA', 350.00, NULL, 1, '2026-07-10 23:05:13', NULL, '2026-07-10 23:05:13');

-- Copiando estrutura para tabela confinamento.protocolo_sanitario
CREATE TABLE IF NOT EXISTS `protocolo_sanitario` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `id_produto_estoque` int unsigned DEFAULT NULL COMMENT 'produto padrao usado neste protocolo, opcional',
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ex: Vacinacao Febre Aftosa, Vermifugacao de Entrada',
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `dias_carencia_padrao` int unsigned DEFAULT NULL COMMENT 'dias de carencia padrao apos aplicacao, pode ser sobrescrito na aplicacao',
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_protocolo_sanitario_nome` (`nome`),
  KEY `idx_protocolo_sanitario_produto` (`id_produto_estoque`),
  CONSTRAINT `fk_protocolo_sanitario_produto` FOREIGN KEY (`id_produto_estoque`) REFERENCES `produto_estoque` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.protocolo_sanitario: ~2 rows (aproximadamente)
DELETE FROM `protocolo_sanitario`;
INSERT INTO `protocolo_sanitario` (`id`, `id_produto_estoque`, `nome`, `descricao`, `dias_carencia_padrao`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(2, 3, 'Vacinação Febre Aftosa', 'Protocolo obrigatório semestral contra febre aftosa', 21, 1, 1, '2026-07-09 18:52:49', NULL, '2026-07-09 18:52:49'),
	(3, 4, 'Vermifugação de Entrada', 'Aplicado em todos os animais na entrada do confinamento', 14, 1, 1, '2026-07-09 18:52:49', NULL, '2026-07-09 18:52:49');

-- Copiando estrutura para tabela confinamento.tipo_aplicacao
CREATE TABLE IF NOT EXISTS `tipo_aplicacao` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tipo_aplicacao_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.tipo_aplicacao: ~7 rows (aproximadamente)
DELETE FROM `tipo_aplicacao`;
INSERT INTO `tipo_aplicacao` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'Intramuscular', NULL, '2026-07-10 23:56:57', NULL, '2026-07-10 23:56:57'),
	(2, 'Subcutânea', NULL, '2026-07-10 23:56:57', NULL, '2026-07-10 23:56:57'),
	(3, 'Oral', NULL, '2026-07-10 23:56:57', NULL, '2026-07-10 23:56:57'),
	(4, 'Pour-on', NULL, '2026-07-10 23:56:57', NULL, '2026-07-10 23:56:57'),
	(5, 'Tópica', NULL, '2026-07-10 23:56:57', NULL, '2026-07-10 23:56:57'),
	(6, 'Intravenosa', NULL, '2026-07-10 23:56:57', NULL, '2026-07-10 23:56:57'),
	(7, 'Intranasal', NULL, '2026-07-10 23:56:57', NULL, '2026-07-10 23:56:57');

-- Copiando estrutura para tabela confinamento.tipo_dieta
CREATE TABLE IF NOT EXISTS `tipo_dieta` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ex: Total, Trato, Suplemento, Pre-mistura, Nucleo, Concentrado',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tipo_dieta_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.tipo_dieta: ~6 rows (aproximadamente)
DELETE FROM `tipo_dieta`;
INSERT INTO `tipo_dieta` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'TOTAL', NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31'),
	(2, 'TRATO', NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31'),
	(3, 'SUPLEMENTO', NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31'),
	(4, 'PRÉ-MISTURA', NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31'),
	(5, 'NÚCLEO', NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31'),
	(6, 'CONCENTRADO', NULL, '2026-07-09 14:04:31', NULL, '2026-07-09 14:04:31');

-- Copiando estrutura para tabela confinamento.tipo_entrada
CREATE TABLE IF NOT EXISTS `tipo_entrada` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tipo_entrada_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.tipo_entrada: ~4 rows (aproximadamente)
DELETE FROM `tipo_entrada`;
INSERT INTO `tipo_entrada` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'COMPRA', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(2, 'PARCERIA', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(3, 'TRANSFERÊNCIA INTERNA', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(4, 'DEVOLUÇÃO', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16');

-- Copiando estrutura para tabela confinamento.tipo_movimentacao_estoque
CREATE TABLE IF NOT EXISTS `tipo_movimentacao_estoque` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ex: Entrada, Saida, Ajuste, Transferencia, Perda, Inventario',
  `natureza` enum('ENTRADA','SAIDA') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'define se soma ou subtrai do saldo',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tipo_movimentacao_estoque_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.tipo_movimentacao_estoque: ~8 rows (aproximadamente)
DELETE FROM `tipo_movimentacao_estoque`;
INSERT INTO `tipo_movimentacao_estoque` (`id`, `descricao`, `natureza`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'Entrada', 'ENTRADA', NULL, '2026-07-09 16:31:48', NULL, '2026-07-09 16:31:48'),
	(2, 'Saída', 'SAIDA', NULL, '2026-07-09 16:31:48', NULL, '2026-07-09 16:31:48'),
	(3, 'Ajuste (acréscimo)', 'ENTRADA', NULL, '2026-07-09 16:31:48', NULL, '2026-07-09 16:31:48'),
	(4, 'Ajuste (redução)', 'SAIDA', NULL, '2026-07-09 16:31:48', NULL, '2026-07-09 16:31:48'),
	(5, 'Transferência', 'SAIDA', NULL, '2026-07-09 16:31:48', NULL, '2026-07-09 16:31:48'),
	(6, 'Perda', 'SAIDA', NULL, '2026-07-09 16:31:48', NULL, '2026-07-09 16:31:48'),
	(7, 'Inventário (acréscimo)', 'ENTRADA', NULL, '2026-07-09 16:31:48', NULL, '2026-07-09 16:31:48'),
	(8, 'Inventário (redução)', 'SAIDA', NULL, '2026-07-09 16:31:48', NULL, '2026-07-09 16:31:48');

-- Copiando estrutura para tabela confinamento.tipo_saida
CREATE TABLE IF NOT EXISTS `tipo_saida` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tipo_saida_descricao` (`descricao`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.tipo_saida: ~5 rows (aproximadamente)
DELETE FROM `tipo_saida`;
INSERT INTO `tipo_saida` (`id`, `descricao`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'VENDA', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(2, 'ABATE', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(3, 'TRANSFERÊNCIA', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(4, 'DESCARTE', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16'),
	(5, 'BAIXA', NULL, '2026-07-08 16:49:16', NULL, '2026-07-08 16:49:16');

-- Copiando estrutura para tabela confinamento.unidade
CREATE TABLE IF NOT EXISTS `unidade` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `codigo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cidade` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `responsavel` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int unsigned DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_unidade_codigo` (`codigo`),
  KEY `idx_unidade_nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela confinamento.unidade: ~2 rows (aproximadamente)
DELETE FROM `unidade`;
INSERT INTO `unidade` (`id`, `nome`, `codigo`, `descricao`, `cidade`, `estado`, `responsavel`, `ativo`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(14, 'Fazenda Santa Fe', 'FSF01', 'Unidade principal de confinamento', 'Barretos', 'SP', 'Carlos Mendes', 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58'),
	(15, 'Fazenda Boa Vista', 'FBV02', 'Unidade de recria e engorda', 'Aracatuba', 'SP', 'Roberto Lima', 1, 1, '2026-07-09 17:27:58', NULL, '2026-07-09 17:27:58');

-- Copiando estrutura para tabela confinamento.usuario
CREATE TABLE IF NOT EXISTS `usuario` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `cargo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `foto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cor` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '#000000',
  `whatsapp` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `login` varchar(50) NOT NULL DEFAULT '',
  `senha` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `id_perfil` int DEFAULT NULL,
  `permissoes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `online` int DEFAULT '0',
  `current_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `session_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_usuario_id_perfil` (`id_perfil`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.usuario: ~3 rows (aproximadamente)
DELETE FROM `usuario`;
INSERT INTO `usuario` (`id`, `nome`, `cargo`, `foto`, `cor`, `whatsapp`, `email`, `login`, `senha`, `token`, `status`, `id_perfil`, `permissoes`, `online`, `current_ip`, `session_token`, `last_login`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'DIEGO FERRAZ', 'PROGRAMADOR', 'amado-batista.jpg', '#000000', NULL, 'diego@agenciadiz.com', 'admin', '$2y$10$qjr1/B1GDsBu8DsFF/4ZreRejlV75ajvf/7sG5H8bg9V11.rAU4ai', '8797d2fb1b7a1d05316dc0ec5081580b83fb993a1ee162d11b90694b37916ef9', 1, 1, '[309,312,313,310,311,13,14,11,12,17,18,15,16,232,233,230,231,74,75,72,73,82,83,80,81,78,79,76,77,70,71,68,69,246,247,244,245,250,251,248,249,262,263,260,261,254,255,252,253,258,259,256,257,330,331,328,329,334,335,332,333,326,327,324,325,339,86,87,84,85,21,22,19,20,90,91,88,89,101,102,99,100,139,140,137,138,143,144,141,142,105,106,103,104,159,160,157,158,117,118,115,116,303,304,301,302,132,133,130,131,155,156,153,154,299,300,297,298,109,110,107,108,113,114,111,112,151,152,149,150,213,214,211,212,194,195,192,193,171,172,169,170,147,148,145,146,205,206,203,204,167,168,165,166,163,164,161,162,209,210,207,208,179,180,177,178,201,202,199,200,175,176,173,174,239,240,237,238,293,315,308,291,292,290,281,282,279,280,322,323,320,321,285,286,283,284,277,278,275,276,318,319,316,317,9,10,7,8,3,4,1,6,2,5]', 0, NULL, NULL, NULL, NULL, '2026-04-17 03:15:30', NULL, '2026-07-30 17:48:56'),
	(3, 'MAURA BICHARA', 'DIRETORA', 'maura.png', '#000000', NULL, 'maurabichara@gmail.com', 'maurabichara@gmail.com', '$2y$10$Zp0gG0mMGyeR3WBV247ygutDgw7N3gWEUVBCwhGIqMMh.D.f1y1Ym', 'aea3c10cadca8bf76bf0308afb354d8f4cb755482be7d377748d6b359ddd7663', 1, 1, '[309,312,313,310,311,13,14,11,12,17,18,15,16,232,233,230,231,74,75,72,73,82,83,80,81,78,79,76,77,70,71,68,69,246,247,244,245,250,251,248,249,262,263,260,261,254,255,252,253,258,259,256,257,330,331,328,329,334,335,332,333,326,327,324,325,339,86,87,84,85,21,22,19,20,90,91,88,89,101,102,99,100,139,140,137,138,143,144,141,142,105,106,103,104,159,160,157,158,117,118,115,116,303,304,301,302,132,133,130,131,155,156,153,154,299,300,297,298,109,110,107,108,113,114,111,112,151,152,149,150,213,214,211,212,194,195,192,193,171,172,169,170,147,148,145,146,205,206,203,204,167,168,165,166,163,164,161,162,209,210,207,208,179,180,177,178,201,202,199,200,175,176,173,174,239,240,237,238,293,315,308,291,292,290,281,282,279,280,322,323,320,321,285,286,283,284,277,278,275,276,318,319,316,317,9,10,7,8,3,4,1,6,2,5]', 0, NULL, NULL, NULL, 2, '2026-07-30 13:47:04', NULL, '2026-07-30 17:52:25'),
	(4, 'JEAN', 'SUPORTE', NULL, '#000000', NULL, 'capriojean@gmail.com', 'capriojean@gmail.com', '$2y$10$GXmBj.EMxywAYV6QVyBNfe379tN0MRdZBBzF2rRoxxYxEzMqZjdDe', 'f2c94ec10d34a7c872c953a6c0eb3ec1298cab9f7b3576e496c51415fc04759a', 1, 1, '[309,312,313,310,311,13,14,11,12,17,18,15,16,232,233,230,231,74,75,72,73,82,83,80,81,78,79,76,77,70,71,68,69,246,247,244,245,250,251,248,249,262,263,260,261,254,255,252,253,258,259,256,257,330,331,328,329,334,335,332,333,326,327,324,325,339,86,87,84,85,21,22,19,20,90,91,88,89,101,102,99,100,139,140,137,138,143,144,141,142,105,106,103,104,159,160,157,158,117,118,115,116,303,304,301,302,132,133,130,131,155,156,153,154,299,300,297,298,109,110,107,108,113,114,111,112,151,152,149,150,213,214,211,212,194,195,192,193,171,172,169,170,147,148,145,146,205,206,203,204,167,168,165,166,163,164,161,162,209,210,207,208,179,180,177,178,201,202,199,200,175,176,173,174,239,240,237,238,293,315,308,291,292,290,281,282,279,280,322,323,320,321,285,286,283,284,277,278,275,276,318,319,316,317,9,10,7,8,3,4,1,6,2,5]', 0, NULL, NULL, NULL, 3, '2026-07-30 13:54:40', NULL, '2026-07-30 16:50:39');

-- Copiando estrutura para tabela confinamento.usuario_historico
CREATE TABLE IF NOT EXISTS `usuario_historico` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int DEFAULT NULL,
  `login` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `data` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `local` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `acao` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `status` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `motivo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `sistema` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=369 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.usuario_historico: ~338 rows (aproximadamente)
DELETE FROM `usuario_historico`;
INSERT INTO `usuario_historico` (`id`, `id_usuario`, `login`, `data`, `ip`, `local`, `acao`, `status`, `motivo`, `sistema`) VALUES
	(1, 1, 'admin', '2026-04-17 03:38:27', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(2, 1, 'admin', '2026-04-17 03:38:27', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(3, 1, 'admin', '2026-04-17 03:41:29', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(4, 1, 'admin', '2026-04-17 03:41:34', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(5, 1, 'admin', '2026-04-17 03:41:34', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(6, 1, 'admin', '2026-04-17 03:43:28', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(7, 1, 'admin', '2026-04-17 03:43:48', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(8, 1, 'admin', '2026-04-17 03:43:48', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(9, 1, 'admin', '2026-04-17 03:49:17', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(10, 1, 'admin', '2026-04-17 03:51:18', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(11, 1, 'admin', '2026-04-17 03:51:18', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(12, 1, 'admin', '2026-04-17 03:53:22', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(13, 1, 'admin', '2026-04-17 03:53:28', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(14, 1, 'admin', '2026-04-17 03:53:28', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(15, 1, 'admin', '2026-04-17 03:57:14', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(16, 1, 'admin', '2026-04-17 03:57:22', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(17, 1, 'admin', '2026-04-17 03:57:22', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(18, 1, 'admin', '2026-04-17 03:57:28', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(19, 1, 'admin', '2026-04-17 11:30:18', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(20, 1, 'admin', '2026-04-17 11:30:18', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(21, NULL, NULL, '2026-04-17 19:55:38', NULL, 'sistema', 'session_revoked', 'info', 'absolute_timeout', NULL),
	(22, NULL, 'diego', '2026-04-17 20:08:52', '127.0.0.1', 'sistema', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(23, 1, 'admin', '2026-04-17 20:08:58', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(24, 1, 'admin', '2026-04-17 20:08:58', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(25, 1, 'admin', '2026-04-17 20:09:05', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(26, NULL, 'dsdsd', '2026-04-17 20:10:21', '127.0.0.1', 'sistema', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(27, 1, 'admin', '2026-04-17 20:10:51', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(28, 1, 'admin', '2026-04-17 20:10:51', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(29, 1, 'admin', '2026-04-17 20:11:01', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(30, 1, 'admin', '2026-04-17 21:15:14', '127.0.0.1', 'sistema', 'password_reset', 'success', 'Senha redefinida por recuperacao', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(31, 1, 'admin', '2026-04-17 21:15:25', '127.0.0.1', 'sistema', 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(32, 1, 'admin', '2026-04-17 21:15:33', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(33, 1, 'admin', '2026-04-17 21:15:33', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(34, 1, 'admin', '2026-04-17 21:16:07', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(35, 1, 'admin', '2026-04-17 22:40:27', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(36, 1, 'admin', '2026-04-17 22:40:27', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(37, 1, 'admin', '2026-04-17 22:40:32', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(38, 1, 'admin', '2026-04-17 22:40:40', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(39, 1, 'admin', '2026-04-17 22:40:40', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(40, 1, 'admin', '2026-04-17 22:40:51', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(41, 1, 'admin', '2026-04-17 22:41:02', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(42, 1, 'admin', '2026-04-17 22:41:02', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(43, 1, 'admin', '2026-04-17 22:47:11', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(44, 1, 'admin', '2026-04-18 02:24:31', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(45, 1, 'admin', '2026-04-18 02:24:32', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(46, 1, 'admin', '2026-04-18 02:24:39', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(47, 1, 'admin', '2026-04-18 02:29:19', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(48, 1, 'admin', '2026-04-18 02:29:19', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(49, 1, 'admin', '2026-04-18 02:29:28', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(50, 1, 'admin', '2026-04-18 02:29:49', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(51, 1, 'admin', '2026-04-18 02:29:49', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(52, 1, 'admin', '2026-04-18 02:29:57', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(53, 1, 'admin', '2026-04-18 02:30:35', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(54, 1, 'admin', '2026-04-18 02:30:35', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(55, 1, 'admin', '2026-04-18 02:32:59', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(56, 1, 'admin', '2026-04-18 12:48:01', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(57, 1, 'admin', '2026-04-18 12:48:01', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(58, 1, 'admin', '2026-04-18 12:51:53', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(59, 1, 'admin', '2026-04-18 12:52:01', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(60, 1, 'admin', '2026-04-18 12:52:01', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(61, 1, 'admin', '2026-04-18 13:05:18', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(62, 1, 'admin', '2026-04-18 13:05:27', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(63, 1, 'admin', '2026-04-18 13:05:27', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(64, NULL, 'admin', '2026-04-18 13:29:54', '127.0.0.1', 'sistema', 'login', 'error', 'reCAPTCHA invalido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(65, 1, 'admin', '2026-04-18 13:30:26', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(66, NULL, 'admin', '2026-04-18 13:38:32', '127.0.0.1', 'sistema', 'login', 'error', 'reCAPTCHA invalido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(67, 1, 'admin', '2026-04-18 13:38:40', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(68, 1, 'admin', '2026-04-18 13:38:47', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(69, 1, 'admin', '2026-04-18 13:38:47', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(70, NULL, NULL, '2026-04-18 16:56:13', NULL, 'sistema', 'session_revoked', 'info', 'idle_timeout', NULL),
	(71, 1, 'admin', '2026-04-18 16:56:49', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(72, 1, 'admin', '2026-04-18 16:56:49', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(73, NULL, NULL, '2026-04-18 17:37:20', NULL, 'sistema', 'session_revoked', 'info', 'idle_timeout', NULL),
	(74, 1, 'admin', '2026-04-18 17:37:26', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(75, 1, 'admin', '2026-04-18 17:37:26', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(76, 1, 'admin', '2026-04-18 18:44:00', '127.0.0.1', 'sistema', 'logout', 'success', 'Encerramento de sessão', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(77, 1, 'admin', '2026-04-18 18:44:10', '127.0.0.1', 'sistema', 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(78, 1, 'admin', '2026-04-18 18:44:15', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(79, 1, 'admin', '2026-04-18 18:44:15', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(80, NULL, NULL, '2026-04-18 21:23:13', NULL, 'sistema', 'session_revoked', 'info', 'idle_timeout', NULL),
	(81, NULL, 'admin', '2026-04-18 21:23:35', '127.0.0.1', 'sistema', 'login', 'error', 'reCAPTCHA invalido', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(82, 1, 'admin', '2026-04-18 21:23:41', '127.0.0.1', 'sistema', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(83, 1, 'admin', '2026-04-18 21:23:41', '127.0.0.1', 'sistema', 'login', 'success', 'Acesso autorizado', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(84, NULL, NULL, '2026-04-18 23:48:27', NULL, NULL, 'session_revoked', 'info', 'idle_timeout', NULL),
	(85, NULL, 'admin', '2026-04-18 23:48:34', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(86, NULL, 'admin', '2026-04-18 23:48:40', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(87, 1, 'admin', '2026-04-18 23:48:46', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(88, 1, 'admin', '2026-04-18 23:48:46', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(89, 1, NULL, '2026-04-18 23:58:23', '127.0.0.1', NULL, 'session_revoked', 'success', 'password_changed', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(90, NULL, 'admin', '2026-04-18 23:58:33', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(91, NULL, 'admin', '2026-04-18 23:59:03', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(92, 1, 'admin', '2026-04-19 00:00:29', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(93, 1, 'admin', '2026-04-19 00:00:29', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(94, NULL, NULL, '2026-04-19 20:27:14', NULL, NULL, 'session_revoked', 'info', 'absolute_timeout', NULL),
	(95, NULL, NULL, '2026-04-19 21:18:50', '127.0.0.1', NULL, 'login', 'error', 'Login vazio', 'Painel Admin'),
	(96, 1, 'admin', '2026-04-19 21:20:19', '127.0.0.1', NULL, 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(97, 1, 'admin', '2026-04-19 21:20:25', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(98, 1, 'admin', '2026-04-19 21:20:26', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(99, 1, 'admin', '2026-04-19 22:53:02', '127.0.0.1', NULL, 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(100, NULL, 'admin', '2026-04-19 22:53:06', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(101, 1, 'admin', '2026-04-19 22:53:11', '127.0.0.1', NULL, 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(102, 1, 'admin', '2026-04-19 22:53:17', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(103, 1, 'admin', '2026-04-19 22:53:18', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(104, NULL, NULL, '2026-04-19 22:56:20', NULL, NULL, 'session_revoked', 'info', 'ua_mismatch', NULL),
	(105, 1, 'admin', '2026-04-19 22:56:30', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36'),
	(106, 1, 'admin', '2026-04-19 22:56:30', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(107, 1, 'admin', '2026-04-21 00:33:42', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(108, 1, 'admin', '2026-04-21 00:33:43', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(109, NULL, NULL, '2026-04-21 00:35:58', NULL, NULL, 'session_revoked', 'info', 'ua_mismatch', NULL),
	(110, 1, 'admin', '2026-04-21 00:36:08', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36'),
	(111, 1, 'admin', '2026-04-21 00:36:08', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(112, NULL, NULL, '2026-04-21 01:00:18', NULL, NULL, 'session_revoked', 'info', 'ua_mismatch', NULL),
	(113, 1, 'admin', '2026-04-21 01:00:25', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(114, 1, 'admin', '2026-04-21 01:00:26', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(115, NULL, NULL, '2026-04-21 01:03:32', NULL, NULL, 'session_revoked', 'info', 'ua_mismatch', NULL),
	(116, 1, 'admin', '2026-04-21 01:03:42', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36'),
	(117, 1, 'admin', '2026-04-21 01:03:42', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(118, NULL, NULL, '2026-04-21 01:09:02', NULL, NULL, 'session_revoked', 'info', 'ua_mismatch', NULL),
	(119, 1, 'admin', '2026-04-21 01:20:45', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(120, 1, 'admin', '2026-04-21 01:20:45', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(121, NULL, 'admin', '2026-04-21 12:28:45', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(122, 1, 'admin', '2026-04-21 12:28:53', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(123, 1, 'admin', '2026-04-21 12:28:54', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(124, 1, 'admin', '2026-04-21 21:16:57', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(125, NULL, 'admin', '2026-04-21 21:18:35', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(126, 1, 'admin', '2026-04-21 21:18:44', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(127, 1, 'admin', '2026-04-21 21:18:44', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(128, NULL, NULL, '2026-04-22 01:58:30', NULL, NULL, 'session_revoked', 'info', 'idle_timeout', NULL),
	(129, 1, 'admin', '2026-04-22 01:58:40', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(130, 1, 'admin', '2026-04-22 01:58:41', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(131, 1, 'admin', '2026-04-22 04:24:18', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(132, 1, 'admin', '2026-04-22 12:36:15', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(133, 1, 'admin', '2026-04-22 12:36:16', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(134, 1, 'admin', '2026-04-23 12:34:40', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(135, 1, 'admin', '2026-04-23 12:34:41', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(136, NULL, NULL, '2026-04-24 00:35:33', NULL, NULL, 'session_revoked', 'info', 'absolute_timeout', NULL),
	(137, NULL, 'admin', '2026-04-24 00:35:44', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(138, NULL, 'admin', '2026-04-24 00:35:50', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(139, 1, 'admin', '2026-04-24 00:36:01', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(140, 1, 'admin', '2026-04-24 00:36:02', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(141, NULL, NULL, '2026-04-24 11:16:15', NULL, NULL, 'session_revoked', 'info', 'idle_timeout', NULL),
	(142, 1, 'admin', '2026-04-24 11:16:33', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(143, 1, 'admin', '2026-04-24 11:16:34', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(144, 1, 'admin', '2026-04-24 21:42:13', '127.0.0.1', NULL, 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(145, 1, 'admin', '2026-04-25 11:50:17', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(146, 1, 'admin', '2026-04-25 11:50:17', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(147, NULL, NULL, '2026-04-26 10:33:38', NULL, NULL, 'session_revoked', 'info', 'absolute_timeout', NULL),
	(148, 1, 'admin', '2026-05-01 18:50:11', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(149, 1, 'admin', '2026-05-01 18:50:11', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(150, 1, 'admin', '2026-05-02 02:08:40', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(151, 1, 'admin', '2026-05-02 02:10:24', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(152, 1, 'admin', '2026-05-02 02:10:25', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(153, 1, 'admin', '2026-05-02 02:10:45', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(154, NULL, 'admi', '2026-05-02 03:17:37', '127.0.0.1', NULL, 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(155, 1, 'admin', '2026-05-02 03:17:43', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36'),
	(156, 1, 'admin', '2026-05-02 03:17:43', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(157, 1, 'admin', '2026-05-02 03:26:00', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(158, 2, 'diego', '2026-05-22 17:31:01', '127.0.0.1', NULL, 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36'),
	(159, 2, 'diego', '2026-05-22 17:31:11', '127.0.0.1', NULL, 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36'),
	(160, NULL, 'admin', '2026-05-22 19:36:43', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(161, NULL, 'admin', '2026-05-22 19:38:26', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(162, 1, 'admin', '2026-05-22 19:39:01', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36'),
	(163, 1, 'admin', '2026-05-22 19:39:02', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(164, 2, 'diego', '2026-07-08 18:13:24', '127.0.0.1', NULL, 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(165, 1, 'admin', '2026-07-08 18:17:49', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(166, 1, 'admin', '2026-07-08 18:17:49', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(167, NULL, 'admin', '2026-07-08 18:56:14', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(168, NULL, 'admin', '2026-07-08 18:57:34', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(169, NULL, 'admin', '2026-07-08 18:57:45', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(170, 1, 'admin', '2026-07-08 19:02:50', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(171, 1, 'admin', '2026-07-08 19:02:50', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(172, 1, 'admin', '2026-07-08 19:23:06', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(173, 1, 'admin', '2026-07-08 19:43:31', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(174, 1, 'admin', '2026-07-08 19:43:31', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(175, 1, 'admin', '2026-07-08 19:54:45', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(176, 1, 'admin', '2026-07-08 19:54:46', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(177, 1, 'admin', '2026-07-08 19:55:53', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(178, 1, 'admin', '2026-07-08 19:55:53', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(179, 1, 'admin', '2026-07-08 20:08:46', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(180, 1, 'admin', '2026-07-08 20:08:46', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(181, 1, 'admin', '2026-07-09 12:15:41', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(182, 1, 'admin', '2026-07-09 12:15:42', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(183, 1, 'admin', '2026-07-09 12:36:37', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(184, 1, 'admin', '2026-07-09 12:36:37', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(185, NULL, NULL, '2026-07-09 14:51:42', NULL, NULL, 'session_revoked', 'info', 'absolute_timeout', NULL),
	(186, 1, 'admin', '2026-07-09 14:54:50', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(187, 1, 'admin', '2026-07-09 14:54:50', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(188, 1, 'admin', '2026-07-09 16:52:32', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(189, 1, 'admin', '2026-07-09 16:52:34', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(190, 1, 'admin', '2026-07-09 17:30:18', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(191, 1, 'admin', '2026-07-09 17:30:18', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(192, 1, 'admin', '2026-07-09 17:55:45', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(193, 1, 'admin', '2026-07-09 17:55:45', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(194, 1, 'admin', '2026-07-09 18:06:54', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(195, 1, 'admin', '2026-07-09 18:06:54', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(196, 1, 'admin', '2026-07-09 19:27:51', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(197, 1, 'admin', '2026-07-09 19:27:51', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(198, 1, 'admin', '2026-07-09 20:28:46', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(199, 1, 'admin', '2026-07-09 20:28:46', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(200, 1, 'admin', '2026-07-09 21:48:52', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(201, 1, 'admin', '2026-07-09 21:48:52', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(202, 1, 'admin', '2026-07-10 12:05:44', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(203, 1, 'admin', '2026-07-10 12:05:45', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(204, NULL, NULL, '2026-07-10 12:11:13', NULL, NULL, 'session_revoked', 'info', 'absolute_timeout', NULL),
	(205, NULL, 'diego', '2026-07-10 12:11:44', '127.0.0.1', NULL, 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(206, 1, 'admin', '2026-07-10 12:11:50', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(207, 1, 'admin', '2026-07-10 12:11:50', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(208, 1, 'admin', '2026-07-10 12:49:59', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(209, 1, 'admin', '2026-07-10 12:49:59', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(210, 1, 'admin', '2026-07-10 13:10:11', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(211, 1, 'admin', '2026-07-10 13:10:11', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(212, 1, 'admin', '2026-07-10 13:18:30', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(213, 1, 'admin', '2026-07-10 13:18:30', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(214, 1, 'admin', '2026-07-10 13:25:53', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(215, 1, 'admin', '2026-07-10 13:25:53', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(216, 1, 'admin', '2026-07-10 13:29:12', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(217, 1, 'admin', '2026-07-10 13:29:12', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(218, 1, 'admin', '2026-07-10 13:33:10', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(219, 1, 'admin', '2026-07-10 13:33:10', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(220, NULL, 'admin', '2026-07-10 13:54:34', '127.0.0.1', NULL, 'login', 'error', 'reCAPTCHA invalido', 'Painel Admin'),
	(221, 1, 'admin', '2026-07-10 13:55:31', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(222, 1, 'admin', '2026-07-10 13:55:31', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(223, 1, 'admin', '2026-07-10 13:57:04', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(224, 1, 'admin', '2026-07-10 13:57:04', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(225, 1, 'admin', '2026-07-10 13:59:28', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(226, 1, 'admin', '2026-07-10 13:59:28', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(227, 1, 'admin', '2026-07-10 14:17:48', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(228, 1, 'admin', '2026-07-10 14:17:49', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(229, 1, 'admin', '2026-07-10 14:18:32', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(230, 1, 'admin', '2026-07-10 14:18:32', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(231, 1, 'admin', '2026-07-10 14:18:45', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(232, 1, 'admin', '2026-07-10 14:18:45', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(233, 1, 'admin', '2026-07-10 14:32:20', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(234, 1, 'admin', '2026-07-10 14:32:20', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(235, 1, 'admin', '2026-07-10 14:32:59', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(236, 1, 'admin', '2026-07-10 14:32:59', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(237, 1, 'admin', '2026-07-10 14:33:19', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(238, 1, 'admin', '2026-07-10 14:33:19', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(239, 1, 'admin', '2026-07-10 14:33:47', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(240, 1, 'admin', '2026-07-10 14:33:47', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(241, 1, 'admin', '2026-07-10 14:41:00', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(242, 1, 'admin', '2026-07-10 14:45:17', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(243, 1, 'admin', '2026-07-10 14:45:17', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(244, 1, 'admin', '2026-07-10 15:26:36', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(245, 1, 'admin', '2026-07-10 15:26:36', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(246, 1, 'admin', '2026-07-10 15:55:23', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(247, 1, 'admin', '2026-07-10 16:02:31', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(248, 1, 'admin', '2026-07-10 16:02:31', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(249, 1, 'admin', '2026-07-10 19:03:46', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(250, 1, 'admin', '2026-07-10 19:03:46', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(251, 1, 'admin', '2026-07-10 19:04:26', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(252, 1, 'admin', '2026-07-10 19:04:26', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(253, 1, 'admin', '2026-07-10 19:09:30', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(254, 1, 'admin', '2026-07-10 19:09:30', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(255, 1, 'admin', '2026-07-10 19:13:35', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(256, 1, 'admin', '2026-07-10 19:13:35', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(257, 1, 'admin', '2026-07-10 19:15:55', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(258, 1, 'admin', '2026-07-10 19:15:55', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(259, 1, 'admin', '2026-07-10 19:19:19', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(260, 1, 'admin', '2026-07-10 19:19:19', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(261, 1, 'admin', '2026-07-10 19:38:27', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(262, 1, 'admin', '2026-07-10 19:38:27', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(263, 1, 'admin', '2026-07-10 19:39:35', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(264, 1, 'admin', '2026-07-10 19:39:35', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(265, 1, 'admin', '2026-07-10 20:04:58', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(266, 1, 'admin', '2026-07-10 20:04:58', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(267, 1, 'admin', '2026-07-10 20:27:23', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(268, 1, 'admin', '2026-07-10 20:27:23', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(269, 1, 'admin', '2026-07-10 20:28:20', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(270, 1, 'admin', '2026-07-10 20:28:21', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(271, 1, 'admin', '2026-07-10 20:41:57', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(272, 1, 'admin', '2026-07-10 20:41:57', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(273, 1, 'admin', '2026-07-10 20:42:19', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(274, 1, 'admin', '2026-07-10 20:42:19', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(275, 1, 'admin', '2026-07-11 00:32:34', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(276, 1, 'admin', '2026-07-11 00:32:35', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(277, 1, 'admin', '2026-07-11 00:33:39', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(278, 1, 'admin', '2026-07-11 00:33:40', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(279, 1, 'admin', '2026-07-11 01:36:53', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(280, 1, 'admin', '2026-07-11 01:36:53', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(281, 1, 'admin', '2026-07-11 01:37:36', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(282, 1, 'admin', '2026-07-11 01:37:36', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(283, NULL, NULL, '2026-07-11 01:43:16', NULL, NULL, 'session_revoked', 'info', 'idle_timeout', NULL),
	(284, 1, 'admin', '2026-07-11 01:43:32', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(285, 1, 'admin', '2026-07-11 01:43:32', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(286, 1, 'admin', '2026-07-11 01:45:38', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(287, 1, 'admin', '2026-07-11 01:45:38', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(288, 1, 'admin', '2026-07-11 01:46:04', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(289, 1, 'admin', '2026-07-11 01:46:04', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(290, 1, 'admin', '2026-07-11 01:57:16', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(291, 1, 'admin', '2026-07-11 01:57:16', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(292, 1, 'admin', '2026-07-11 01:57:54', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(293, 1, 'admin', '2026-07-11 01:57:54', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(294, 1, 'admin', '2026-07-11 02:05:53', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.11.0'),
	(295, 1, 'admin', '2026-07-11 02:05:53', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(296, 1, 'admin', '2026-07-11 02:06:20', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/149.0.0.0 Safari/537.36'),
	(297, 1, 'admin', '2026-07-11 02:06:20', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(298, 1, 'admin', '2026-07-11 02:29:08', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(299, 1, 'admin', '2026-07-11 02:51:34', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'),
	(300, 1, 'admin', '2026-07-11 02:51:34', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(301, 1, 'admin', '2026-07-21 20:38:11', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
	(302, 1, 'admin', '2026-07-21 20:38:11', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(303, NULL, NULL, '2026-07-21 22:34:08', '127.0.0.1', NULL, 'login', 'error', 'Login vazio', 'Painel Admin'),
	(304, 1, 'admin', '2026-07-21 22:34:48', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(305, 1, 'admin', '2026-07-21 22:34:48', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(306, 1, 'admin', '2026-07-21 22:34:53', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(307, 1, 'admin', '2026-07-21 22:34:53', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(308, 1, 'admin', '2026-07-21 22:35:05', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(309, 1, 'admin', '2026-07-21 22:35:05', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(310, 1, 'admin', '2026-07-21 22:35:11', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(311, 1, 'admin', '2026-07-21 22:35:12', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(312, 1, 'admin', '2026-07-21 22:43:36', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(313, 1, 'admin', '2026-07-21 22:43:37', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(314, 1, 'admin', '2026-07-21 23:53:58', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(315, 1, 'admin', '2026-07-21 23:54:00', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(316, 1, 'admin', '2026-07-21 23:54:46', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(317, 1, 'admin', '2026-07-21 23:54:46', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(318, 1, 'admin', '2026-07-21 23:57:06', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(319, 1, 'admin', '2026-07-21 23:57:06', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(320, 1, 'admin', '2026-07-22 00:03:34', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(321, 1, 'admin', '2026-07-22 00:03:34', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(322, 1, 'admin', '2026-07-22 00:27:26', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(323, 1, 'admin', '2026-07-22 00:27:27', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(324, 1, 'admin', '2026-07-22 00:32:53', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(325, 1, 'admin', '2026-07-22 00:32:53', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(326, 1, 'admin', '2026-07-22 00:36:48', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(327, 1, 'admin', '2026-07-22 00:36:48', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(328, 1, 'admin', '2026-07-22 00:38:09', '127.0.0.1', NULL, 'login', 'success', NULL, 'curl/8.21.0'),
	(329, 1, 'admin', '2026-07-22 00:38:10', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(330, 1, 'admin', '2026-07-22 02:53:48', '127.0.0.1', NULL, 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36'),
	(331, 1, 'admin', '2026-07-22 02:53:48', '127.0.0.1', NULL, 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(332, 1, 'admin', '2026-07-22 02:58:16', '127.0.0.1', NULL, 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(333, 1, 'admin', '2026-07-22 03:14:37', '177.54.206.148', 'Catanduva São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
	(334, 1, 'admin', '2026-07-22 03:14:37', '177.54.206.148', 'Catanduva São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(335, 2, 'jean', '2026-07-26 15:10:26', '45.167.184.241', 'Novo Horizonte São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15'),
	(336, 2, 'jean', '2026-07-26 15:10:26', '45.167.184.241', 'Novo Horizonte São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(337, 2, 'jean', '2026-07-26 15:13:18', '45.167.184.241', 'Novo Horizonte São Paulo Brasil', 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(338, 2, 'jean', '2026-07-26 17:22:42', '45.167.184.241', 'Novo Horizonte São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15'),
	(339, 2, 'jean', '2026-07-26 17:22:42', '45.167.184.241', 'Novo Horizonte São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(340, 2, 'jean', '2026-07-26 17:31:06', '45.167.184.241', 'Novo Horizonte São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5.2 Mobile/15E148 Safari/604.1'),
	(341, 2, 'jean', '2026-07-26 17:31:08', '45.167.184.241', 'Novo Horizonte São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(342, 2, NULL, '2026-07-26 17:35:57', '45.167.184.241', NULL, 'session_revoked', 'success', 'password_changed', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15'),
	(343, 1, 'admin', '2026-07-27 19:33:01', '179.222.210.166', 'Sao Jose do Rio Preto São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
	(344, 1, 'admin', '2026-07-27 19:33:01', '179.222.210.166', 'Sao Jose do Rio Preto São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(345, NULL, 'maura', '2026-07-29 15:22:22', '45.4.32.241', 'Ribeirão Preto São Paulo Brasil', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36'),
	(346, NULL, 'maura', '2026-07-29 15:22:36', '45.4.32.241', 'Ribeirão Preto São Paulo Brasil', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36'),
	(347, NULL, 'maura', '2026-07-29 15:23:04', '45.4.32.241', 'Ribeirão Preto São Paulo Brasil', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36'),
	(348, NULL, 'maura', '2026-07-29 15:24:19', '45.4.32.241', 'Ribeirão Preto São Paulo Brasil', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36'),
	(349, 2, 'jean', '2026-07-29 15:25:13', '45.4.32.241', 'Ribeirão Preto São Paulo Brasil', 'login', 'error', 'Senha incorreta', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36'),
	(350, NULL, 'maura', '2026-07-29 15:31:09', '45.4.32.241', 'Ribeirão Preto São Paulo Brasil', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36'),
	(351, NULL, 'maura', '2026-07-29 16:18:45', '45.4.32.241', 'Ribeirão Preto São Paulo Brasil', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
	(352, NULL, 'maura', '2026-07-30 13:28:28', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'error', 'Usuário inexistente', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15'),
	(353, 2, 'jean', '2026-07-30 13:28:40', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15'),
	(354, 2, 'jean', '2026-07-30 13:28:40', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(355, 2, 'jean', '2026-07-30 13:48:02', '201.33.72.99', 'Barretos São Paulo Brasil', 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(356, 3, 'maurabichara@gmail.com', '2026-07-30 13:50:17', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15'),
	(357, 3, 'maurabichara@gmail.com', '2026-07-30 13:50:17', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(358, 3, 'maurabichara@gmail.com', '2026-07-30 13:55:04', '201.33.72.99', 'Barretos São Paulo Brasil', 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(359, 4, 'capriojean@gmail.com', '2026-07-30 13:55:12', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15'),
	(360, 4, 'capriojean@gmail.com', '2026-07-30 13:55:13', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(361, 1, 'admin', '2026-07-30 16:42:13', '179.222.210.166', 'Sao Jose do Rio Preto São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
	(362, 1, 'admin', '2026-07-30 16:42:13', '179.222.210.166', 'Sao Jose do Rio Preto São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(363, 3, 'maurabichara@gmail.com', '2026-07-30 17:51:31', '200.15.16.226', 'São Paulo São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36'),
	(364, 3, 'maurabichara@gmail.com', '2026-07-30 17:51:32', '200.15.16.226', 'São Paulo São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(365, 4, 'capriojean@gmail.com', '2026-07-30 17:52:40', '201.33.72.99', 'Barretos São Paulo Brasil', 'logout', 'success', 'Encerramento de sessão', 'Painel Admin'),
	(366, 3, 'maurabichara@gmail.com', '2026-07-30 17:52:52', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'success', NULL, 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3 Safari/605.1.15'),
	(367, 3, 'maurabichara@gmail.com', '2026-07-30 17:52:52', '201.33.72.99', 'Barretos São Paulo Brasil', 'login', 'success', 'Acesso autorizado', 'Painel Admin'),
	(368, 3, 'maurabichara@gmail.com', '2026-07-30 17:53:50', '201.33.72.99', 'Barretos São Paulo Brasil', 'logout', 'success', 'Encerramento de sessão', 'Painel Admin');

-- Copiando estrutura para tabela confinamento.usuario_perfil
CREATE TABLE IF NOT EXISTS `usuario_perfil` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `descricao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `permissoes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.usuario_perfil: ~0 rows (aproximadamente)
DELETE FROM `usuario_perfil`;
INSERT INTO `usuario_perfil` (`id`, `nome`, `descricao`, `permissoes`, `created_by`, `created_at`, `updated_by`, `updated_at`) VALUES
	(1, 'Administrador', 'Perfil base do sistema com todas as permissoes cadastradas.', '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,130,131,132,133,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,192,193,194,195,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,230,231,232,233,237,238,239,240,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,275,276,277,278,279,280,281,282,283,284,285,286,290,291,292,293,297,298,299,300,301,302,303,304,308,309,310,311,312,313,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,339]', NULL, '2026-04-18 18:35:30', 1, '2026-07-21 22:43:18');

-- Copiando estrutura para tabela confinamento.usuario_permissao
CREATE TABLE IF NOT EXISTS `usuario_permissao` (
  `id` int NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `permissao` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `grupo` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `agrupamento` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=340 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela confinamento.usuario_permissao: ~214 rows (aproximadamente)
DELETE FROM `usuario_permissao`;
INSERT INTO `usuario_permissao` (`id`, `descricao`, `permissao`, `grupo`, `agrupamento`) VALUES
	(1, 'Gerenciar', 'usuario_gerenciar', 'usuários', 'Usuários'),
	(2, 'Inserir', 'usuario_inserir', 'usuários', 'Usuários'),
	(3, 'Editar', 'usuario_editar', 'usuários', 'Usuários'),
	(4, 'Excluir', 'usuario_excluir', 'usuários', 'Usuários'),
	(5, 'Permissões', 'usuario_permissoes', 'usuários', 'Usuários'),
	(6, 'Histórico', 'usuario_historico', 'usuários', 'Usuários'),
	(7, 'Gerenciar', 'usuario_perfil_gerenciar', 'perfis', 'Usuários'),
	(8, 'Inserir', 'usuario_perfil_inserir', 'perfis', 'Usuários'),
	(9, 'Editar', 'usuario_perfil_editar', 'perfis', 'Usuários'),
	(10, 'Excluir', 'usuario_perfil_excluir', 'perfis', 'Usuários'),
	(11, 'Gerenciar', 'cliente_gerenciar', 'clientes', 'Clientes'),
	(12, 'Inserir', 'cliente_inserir', 'clientes', 'Clientes'),
	(13, 'Editar', 'cliente_editar', 'clientes', 'Clientes'),
	(14, 'Excluir', 'cliente_excluir', 'clientes', 'Clientes'),
	(15, 'Gerenciar', 'cliente_situacao_gerenciar', 'situações', 'Clientes'),
	(16, 'Inserir', 'cliente_situacao_inserir', 'situações', 'Clientes'),
	(17, 'Editar', 'cliente_situacao_editar', 'situações', 'Clientes'),
	(18, 'Excluir', 'cliente_situacao_excluir', 'situações', 'Clientes'),
	(19, 'Gerenciar', 'fornecedor_ramo_gerenciar', 'ramos', 'Fornecedores'),
	(20, 'Inserir', 'fornecedor_ramo_inserir', 'ramos', 'Fornecedores'),
	(21, 'Editar', 'fornecedor_ramo_editar', 'ramos', 'Fornecedores'),
	(22, 'Excluir', 'fornecedor_ramo_excluir', 'ramos', 'Fornecedores'),
	(68, 'Gerenciar', 'confinamento_unidade_gerenciar', 'unidades', 'Confinamento'),
	(69, 'Inserir', 'confinamento_unidade_inserir', 'unidades', 'Confinamento'),
	(70, 'Editar', 'confinamento_unidade_editar', 'unidades', 'Confinamento'),
	(71, 'Excluir', 'confinamento_unidade_excluir', 'unidades', 'Confinamento'),
	(72, 'Gerenciar', 'confinamento_curral_gerenciar', 'currais', 'Confinamento'),
	(73, 'Inserir', 'confinamento_curral_inserir', 'currais', 'Confinamento'),
	(74, 'Editar', 'confinamento_curral_editar', 'currais', 'Confinamento'),
	(75, 'Excluir', 'confinamento_curral_excluir', 'currais', 'Confinamento'),
	(76, 'Gerenciar', 'confinamento_piquete_gerenciar', 'piquetes', 'Confinamento'),
	(77, 'Inserir', 'confinamento_piquete_inserir', 'piquetes', 'Confinamento'),
	(78, 'Editar', 'confinamento_piquete_editar', 'piquetes', 'Confinamento'),
	(79, 'Excluir', 'confinamento_piquete_excluir', 'piquetes', 'Confinamento'),
	(80, 'Gerenciar', 'confinamento_local_estoque_gerenciar', 'locais_estoque', 'Confinamento'),
	(81, 'Inserir', 'confinamento_local_estoque_inserir', 'locais_estoque', 'Confinamento'),
	(82, 'Editar', 'confinamento_local_estoque_editar', 'locais_estoque', 'Confinamento'),
	(83, 'Excluir', 'confinamento_local_estoque_excluir', 'locais_estoque', 'Confinamento'),
	(84, 'Gerenciar', 'fornecedor_gerenciar', 'fornecedores', 'Fornecedores'),
	(85, 'Inserir', 'fornecedor_inserir', 'fornecedores', 'Fornecedores'),
	(86, 'Editar', 'fornecedor_editar', 'fornecedores', 'Fornecedores'),
	(87, 'Excluir', 'fornecedor_excluir', 'fornecedores', 'Fornecedores'),
	(88, 'Gerenciar', 'fornecedor_situacao_gerenciar', 'situações', 'Fornecedores'),
	(89, 'Inserir', 'fornecedor_situacao_inserir', 'situações', 'Fornecedores'),
	(90, 'Editar', 'fornecedor_situacao_editar', 'situações', 'Fornecedores'),
	(91, 'Excluir', 'fornecedor_situacao_excluir', 'situações', 'Fornecedores'),
	(99, 'Gerenciar', 'animal_gerenciar', 'animais', 'Manejo'),
	(100, 'Inserir', 'animal_inserir', 'animais', 'Manejo'),
	(101, 'Editar', 'animal_editar', 'animais', 'Manejo'),
	(102, 'Excluir', 'animal_excluir', 'animais', 'Manejo'),
	(103, 'Gerenciar', 'lote_gerenciar', 'lotes', 'Manejo'),
	(104, 'Inserir', 'lote_inserir', 'lotes', 'Manejo'),
	(105, 'Editar', 'lote_editar', 'lotes', 'Manejo'),
	(106, 'Excluir', 'lote_excluir', 'lotes', 'Manejo'),
	(107, 'Gerenciar', 'tipo_entrada_gerenciar', 'tipos_entrada', 'Manejo'),
	(108, 'Inserir', 'tipo_entrada_inserir', 'tipos_entrada', 'Manejo'),
	(109, 'Editar', 'tipo_entrada_editar', 'tipos_entrada', 'Manejo'),
	(110, 'Excluir', 'tipo_entrada_excluir', 'tipos_entrada', 'Manejo'),
	(111, 'Gerenciar', 'tipo_saida_gerenciar', 'tipos_saida', 'Manejo'),
	(112, 'Inserir', 'tipo_saida_inserir', 'tipos_saida', 'Manejo'),
	(113, 'Editar', 'tipo_saida_editar', 'tipos_saida', 'Manejo'),
	(114, 'Excluir', 'tipo_saida_excluir', 'tipos_saida', 'Manejo'),
	(115, 'Gerenciar', 'motivo_perda_gerenciar', 'motivos_perda', 'Manejo'),
	(116, 'Inserir', 'motivo_perda_inserir', 'motivos_perda', 'Manejo'),
	(117, 'Editar', 'motivo_perda_editar', 'motivos_perda', 'Manejo'),
	(118, 'Excluir', 'motivo_perda_excluir', 'motivos_perda', 'Manejo'),
	(130, 'Gerenciar', 'pesagem_gerenciar', 'pesagens', 'Manejo'),
	(131, 'Inserir', 'pesagem_inserir', 'pesagens', 'Manejo'),
	(132, 'Editar', 'pesagem_editar', 'pesagens', 'Manejo'),
	(133, 'Excluir', 'pesagem_excluir', 'pesagens', 'Manejo'),
	(137, 'Gerenciar', 'entrada_gerenciar', 'entradas', 'Manejo'),
	(138, 'Inserir', 'entrada_inserir', 'entradas', 'Manejo'),
	(139, 'Editar', 'entrada_editar', 'entradas', 'Manejo'),
	(140, 'Excluir', 'entrada_excluir', 'entradas', 'Manejo'),
	(141, 'Gerenciar', 'localizacao_gerenciar', 'localizacoes', 'Manejo'),
	(142, 'Inserir', 'localizacao_inserir', 'localizacoes', 'Manejo'),
	(143, 'Editar', 'localizacao_editar', 'localizacoes', 'Manejo'),
	(144, 'Excluir', 'localizacao_excluir', 'localizacoes', 'Manejo'),
	(145, 'Gerenciar', 'formula_racao_gerenciar', 'formulas_racao', 'Nutrição'),
	(146, 'Inserir', 'formula_racao_inserir', 'formulas_racao', 'Nutrição'),
	(147, 'Editar', 'formula_racao_editar', 'formulas_racao', 'Nutrição'),
	(148, 'Excluir', 'formula_racao_excluir', 'formulas_racao', 'Nutrição'),
	(149, 'Gerenciar', 'troca_dieta_gerenciar', 'trocas_dieta', 'Manejo'),
	(150, 'Inserir', 'troca_dieta_inserir', 'trocas_dieta', 'Manejo'),
	(151, 'Editar', 'troca_dieta_editar', 'trocas_dieta', 'Manejo'),
	(152, 'Excluir', 'troca_dieta_excluir', 'trocas_dieta', 'Manejo'),
	(153, 'Gerenciar', 'saida_gerenciar', 'saidas', 'Manejo'),
	(154, 'Inserir', 'saida_inserir', 'saidas', 'Manejo'),
	(155, 'Editar', 'saida_editar', 'saidas', 'Manejo'),
	(156, 'Excluir', 'saida_excluir', 'saidas', 'Manejo'),
	(157, 'Gerenciar', 'mortalidade_gerenciar', 'mortalidades', 'Manejo'),
	(158, 'Inserir', 'mortalidade_inserir', 'mortalidades', 'Manejo'),
	(159, 'Editar', 'mortalidade_editar', 'mortalidades', 'Manejo'),
	(160, 'Excluir', 'mortalidade_excluir', 'mortalidades', 'Manejo'),
	(161, 'Gerenciar', 'ingrediente_gerenciar', 'ingredientes', 'Nutrição'),
	(162, 'Inserir', 'ingrediente_inserir', 'ingredientes', 'Nutrição'),
	(163, 'Editar', 'ingrediente_editar', 'ingredientes', 'Nutrição'),
	(164, 'Excluir', 'ingrediente_excluir', 'ingredientes', 'Nutrição'),
	(165, 'Gerenciar', 'grupo_ingrediente_gerenciar', 'grupos_ingrediente', 'Nutrição'),
	(166, 'Inserir', 'grupo_ingrediente_inserir', 'grupos_ingrediente', 'Nutrição'),
	(167, 'Editar', 'grupo_ingrediente_editar', 'grupos_ingrediente', 'Nutrição'),
	(168, 'Excluir', 'grupo_ingrediente_excluir', 'grupos_ingrediente', 'Nutrição'),
	(169, 'Gerenciar', 'fase_nutricional_gerenciar', 'fases_nutricionais', 'Nutrição'),
	(170, 'Inserir', 'fase_nutricional_inserir', 'fases_nutricionais', 'Nutrição'),
	(171, 'Editar', 'fase_nutricional_editar', 'fases_nutricionais', 'Nutrição'),
	(172, 'Excluir', 'fase_nutricional_excluir', 'fases_nutricionais', 'Nutrição'),
	(173, 'Gerenciar', 'tipo_dieta_gerenciar', 'tipos_dieta', 'Nutrição'),
	(174, 'Inserir', 'tipo_dieta_inserir', 'tipos_dieta', 'Nutrição'),
	(175, 'Editar', 'tipo_dieta_editar', 'tipos_dieta', 'Nutrição'),
	(176, 'Excluir', 'tipo_dieta_excluir', 'tipos_dieta', 'Nutrição'),
	(177, 'Gerenciar', 'parametro_nutricional_gerenciar', 'parametros_nutricionais', 'Nutrição'),
	(178, 'Inserir', 'parametro_nutricional_inserir', 'parametros_nutricionais', 'Nutrição'),
	(179, 'Editar', 'parametro_nutricional_editar', 'parametros_nutricionais', 'Nutrição'),
	(180, 'Excluir', 'parametro_nutricional_excluir', 'parametros_nutricionais', 'Nutrição'),
	(192, 'Gerenciar', 'confeccao_racao_gerenciar', 'confeccoes_racao', 'Nutrição'),
	(193, 'Inserir', 'confeccao_racao_inserir', 'confeccoes_racao', 'Nutrição'),
	(194, 'Editar', 'confeccao_racao_editar', 'confeccoes_racao', 'Nutrição'),
	(195, 'Excluir', 'confeccao_racao_excluir', 'confeccoes_racao', 'Nutrição'),
	(199, 'Gerenciar', 'programacao_trato_gerenciar', 'programacoes_trato', 'Nutrição'),
	(200, 'Inserir', 'programacao_trato_inserir', 'programacoes_trato', 'Nutrição'),
	(201, 'Editar', 'programacao_trato_editar', 'programacoes_trato', 'Nutrição'),
	(202, 'Excluir', 'programacao_trato_excluir', 'programacoes_trato', 'Nutrição'),
	(203, 'Gerenciar', 'fornecimento_trato_gerenciar', 'fornecimentos_trato', 'Nutrição'),
	(204, 'Inserir', 'fornecimento_trato_inserir', 'fornecimentos_trato', 'Nutrição'),
	(205, 'Editar', 'fornecimento_trato_editar', 'fornecimentos_trato', 'Nutrição'),
	(206, 'Excluir', 'fornecimento_trato_excluir', 'fornecimentos_trato', 'Nutrição'),
	(207, 'Gerenciar', 'leitura_cocho_gerenciar', 'leituras_cocho', 'Nutrição'),
	(208, 'Inserir', 'leitura_cocho_inserir', 'leituras_cocho', 'Nutrição'),
	(209, 'Editar', 'leitura_cocho_editar', 'leituras_cocho', 'Nutrição'),
	(210, 'Excluir', 'leitura_cocho_excluir', 'leituras_cocho', 'Nutrição'),
	(211, 'Gerenciar', 'ajuste_consumo_gerenciar', 'ajustes_consumo', 'Nutrição'),
	(212, 'Inserir', 'ajuste_consumo_inserir', 'ajustes_consumo', 'Nutrição'),
	(213, 'Editar', 'ajuste_consumo_editar', 'ajustes_consumo', 'Nutrição'),
	(214, 'Excluir', 'ajuste_consumo_excluir', 'ajustes_consumo', 'Nutrição'),
	(230, 'Gerenciar', 'centro_custo_gerenciar', 'centros_custo', 'Confinamento'),
	(231, 'Inserir', 'centro_custo_inserir', 'centros_custo', 'Confinamento'),
	(232, 'Editar', 'centro_custo_editar', 'centros_custo', 'Confinamento'),
	(233, 'Excluir', 'centro_custo_excluir', 'centros_custo', 'Confinamento'),
	(237, 'Gerenciar', 'funcionario_gerenciar', 'funcionarios', 'Pessoas'),
	(238, 'Inserir', 'funcionario_inserir', 'funcionarios', 'Pessoas'),
	(239, 'Editar', 'funcionario_editar', 'funcionarios', 'Pessoas'),
	(240, 'Excluir', 'funcionario_excluir', 'funcionarios', 'Pessoas'),
	(244, 'Gerenciar', 'categoria_produto_gerenciar', 'categorias_produto', 'Estoque'),
	(245, 'Inserir', 'categoria_produto_inserir', 'categorias_produto', 'Estoque'),
	(246, 'Editar', 'categoria_produto_editar', 'categorias_produto', 'Estoque'),
	(247, 'Excluir', 'categoria_produto_excluir', 'categorias_produto', 'Estoque'),
	(248, 'Gerenciar', 'local_armazenagem_interno_gerenciar', 'locais_armazenagem_interno', 'Estoque'),
	(249, 'Inserir', 'local_armazenagem_interno_inserir', 'locais_armazenagem_interno', 'Estoque'),
	(250, 'Editar', 'local_armazenagem_interno_editar', 'locais_armazenagem_interno', 'Estoque'),
	(251, 'Excluir', 'local_armazenagem_interno_excluir', 'locais_armazenagem_interno', 'Estoque'),
	(252, 'Gerenciar', 'produto_estoque_gerenciar', 'produtos_estoque', 'Estoque'),
	(253, 'Inserir', 'produto_estoque_inserir', 'produtos_estoque', 'Estoque'),
	(254, 'Editar', 'produto_estoque_editar', 'produtos_estoque', 'Estoque'),
	(255, 'Excluir', 'produto_estoque_excluir', 'produtos_estoque', 'Estoque'),
	(256, 'Gerenciar', 'tipo_movimentacao_estoque_gerenciar', 'tipos_movimentacao_estoque', 'Estoque'),
	(257, 'Inserir', 'tipo_movimentacao_estoque_inserir', 'tipos_movimentacao_estoque', 'Estoque'),
	(258, 'Editar', 'tipo_movimentacao_estoque_editar', 'tipos_movimentacao_estoque', 'Estoque'),
	(259, 'Excluir', 'tipo_movimentacao_estoque_excluir', 'tipos_movimentacao_estoque', 'Estoque'),
	(260, 'Gerenciar', 'movimentacao_estoque_gerenciar', 'movimentacoes_estoque', 'Estoque'),
	(261, 'Inserir', 'movimentacao_estoque_inserir', 'movimentacoes_estoque', 'Estoque'),
	(262, 'Editar', 'movimentacao_estoque_editar', 'movimentacoes_estoque', 'Estoque'),
	(263, 'Excluir', 'movimentacao_estoque_excluir', 'movimentacoes_estoque', 'Estoque'),
	(275, 'Gerenciar', 'protocolo_sanitario_gerenciar', 'protocolos_sanitarios', 'Sanitário'),
	(276, 'Inserir', 'protocolo_sanitario_inserir', 'protocolos_sanitarios', 'Sanitário'),
	(277, 'Editar', 'protocolo_sanitario_editar', 'protocolos_sanitarios', 'Sanitário'),
	(278, 'Excluir', 'protocolo_sanitario_excluir', 'protocolos_sanitarios', 'Sanitário'),
	(279, 'Gerenciar', 'aplicacao_sanitaria_gerenciar', 'aplicacoes_sanitarias', 'Sanitário'),
	(280, 'Inserir', 'aplicacao_sanitaria_inserir', 'aplicacoes_sanitarias', 'Sanitário'),
	(281, 'Editar', 'aplicacao_sanitaria_editar', 'aplicacoes_sanitarias', 'Sanitário'),
	(282, 'Excluir', 'aplicacao_sanitaria_excluir', 'aplicacoes_sanitarias', 'Sanitário'),
	(283, 'Gerenciar', 'ocorrencia_sanitaria_gerenciar', 'ocorrencias_sanitarias', 'Sanitário'),
	(284, 'Inserir', 'ocorrencia_sanitaria_inserir', 'ocorrencias_sanitarias', 'Sanitário'),
	(285, 'Editar', 'ocorrencia_sanitaria_editar', 'ocorrencias_sanitarias', 'Sanitário'),
	(286, 'Excluir', 'ocorrencia_sanitaria_excluir', 'ocorrencias_sanitarias', 'Sanitário'),
	(290, 'Rentabilidade por Lote', 'relatorio_rentabilidade_visualizar', 'relatorios', 'Relatórios'),
	(291, 'Evolução de Peso / GMD', 'relatorio_evolucao_peso_visualizar', 'relatorios', 'Relatórios'),
	(292, 'Mortalidade / Perdas', 'relatorio_mortalidade_visualizar', 'relatorios', 'Relatórios'),
	(293, 'Consumo de Ração', 'relatorio_consumo_racao_visualizar', 'relatorios', 'Relatórios'),
	(297, 'Gerenciar', 'animal_situacao_gerenciar', 'situacoes_animal', 'Manejo'),
	(298, 'Inserir', 'animal_situacao_inserir', 'situacoes_animal', 'Manejo'),
	(299, 'Editar', 'animal_situacao_editar', 'situacoes_animal', 'Manejo'),
	(300, 'Excluir', 'animal_situacao_excluir', 'situacoes_animal', 'Manejo'),
	(301, 'Gerenciar', 'ocorrencia_gerenciar', 'ocorrencias', 'Manejo'),
	(302, 'Inserir', 'ocorrencia_inserir', 'ocorrencias', 'Manejo'),
	(303, 'Editar', 'ocorrencia_editar', 'ocorrencias', 'Manejo'),
	(304, 'Excluir', 'ocorrencia_excluir', 'ocorrencias', 'Manejo'),
	(308, 'Eficiência de Trato', 'relatorio_eficiencia_trato_visualizar', 'relatorios', 'Relatórios'),
	(309, 'Visualizar', 'calendario_visualizar', 'calendario', 'Calendário'),
	(310, 'Gerenciar', 'lembrete_gerenciar', 'lembretes', 'Calendário'),
	(311, 'Inserir', 'lembrete_inserir', 'lembretes', 'Calendário'),
	(312, 'Editar', 'lembrete_editar', 'lembretes', 'Calendário'),
	(313, 'Excluir', 'lembrete_excluir', 'lembretes', 'Calendário'),
	(315, 'Eficiência Alimentar', 'relatorio_eficiencia_alimentar_visualizar', 'relatorios', 'Relatórios'),
	(316, 'Gerenciar', 'tipo_aplicacao_gerenciar', 'tipos_aplicacao', 'Sanitário'),
	(317, 'Inserir', 'tipo_aplicacao_inserir', 'tipos_aplicacao', 'Sanitário'),
	(318, 'Editar', 'tipo_aplicacao_editar', 'tipos_aplicacao', 'Sanitário'),
	(319, 'Excluir', 'tipo_aplicacao_excluir', 'tipos_aplicacao', 'Sanitário'),
	(320, 'Gerenciar', 'motivo_tratamento_gerenciar', 'motivos_tratamento', 'Sanitário'),
	(321, 'Inserir', 'motivo_tratamento_inserir', 'motivos_tratamento', 'Sanitário'),
	(322, 'Editar', 'motivo_tratamento_editar', 'motivos_tratamento', 'Sanitário'),
	(323, 'Excluir', 'motivo_tratamento_excluir', 'motivos_tratamento', 'Sanitário'),
	(324, 'Gerenciar', 'plano_conta_gerenciar', 'plano_contas', 'Financeiro'),
	(325, 'Inserir', 'plano_conta_inserir', 'plano_contas', 'Financeiro'),
	(326, 'Editar', 'plano_conta_editar', 'plano_contas', 'Financeiro'),
	(327, 'Excluir', 'plano_conta_excluir', 'plano_contas', 'Financeiro'),
	(328, 'Gerenciar', 'conta_pagar_gerenciar', 'contas_pagar', 'Financeiro'),
	(329, 'Inserir', 'conta_pagar_inserir', 'contas_pagar', 'Financeiro'),
	(330, 'Editar', 'conta_pagar_editar', 'contas_pagar', 'Financeiro'),
	(331, 'Excluir', 'conta_pagar_excluir', 'contas_pagar', 'Financeiro'),
	(332, 'Gerenciar', 'conta_receber_gerenciar', 'contas_receber', 'Financeiro'),
	(333, 'Inserir', 'conta_receber_inserir', 'contas_receber', 'Financeiro'),
	(334, 'Editar', 'conta_receber_editar', 'contas_receber', 'Financeiro'),
	(335, 'Excluir', 'conta_receber_excluir', 'contas_receber', 'Financeiro'),
	(339, 'Visualizar Relatórios Financeiros', 'relatorio_financeiro_visualizar', 'relatorios_financeiros', 'Financeiro');

-- Copiando estrutura para tabela confinamento.usuario_preferencia
CREATE TABLE IF NOT EXISTS `usuario_preferencia` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_user` int DEFAULT NULL,
  `tema` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'light',
  `contas_pagar_visao` varchar(10) NOT NULL DEFAULT 'list' COMMENT 'list|grouped',
  `contas_receber_visao` varchar(10) NOT NULL DEFAULT 'list' COMMENT 'list|grouped',
  `calendario_eventos` varchar(255) DEFAULT NULL COMMENT 'Tipos de evento visiveis no calendario (separados por virgula)',
  `calendario_visao` varchar(20) DEFAULT 'dayGridMonth' COMMENT 'dayGridMonth|dayGridWeek',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `id_user` (`id_user`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela confinamento.usuario_preferencia: ~4 rows (aproximadamente)
DELETE FROM `usuario_preferencia`;
INSERT INTO `usuario_preferencia` (`id`, `id_user`, `tema`, `contas_pagar_visao`, `contas_receber_visao`, `calendario_eventos`, `calendario_visao`) VALUES
	(1, 1, 'light', 'grouped', 'grouped', 'trato,carencia,validade,lembrete,conta-pagar,conta-receber', 'dayGridMonth'),
	(2, 2, 'light', 'list', 'list', NULL, 'dayGridMonth'),
	(3, 3, 'light', 'list', 'list', NULL, 'dayGridMonth'),
	(4, 4, 'light', 'list', 'list', NULL, 'dayGridMonth');

-- Copiando estrutura para tabela confinamento.webpush_subscriptions
CREATE TABLE IF NOT EXISTS `webpush_subscriptions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `endpoint` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `p256dh` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `auth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copiando dados para a tabela confinamento.webpush_subscriptions: ~1 rows (aproximadamente)
DELETE FROM `webpush_subscriptions`;
INSERT INTO `webpush_subscriptions` (`id`, `user_token`, `endpoint`, `p256dh`, `auth`, `created_at`, `updated_at`) VALUES
	(2, '8797d2fb1b7a1d05316dc0ec5081580b83fb993a1ee162d11b90694b37916ef9', 'https://fcm.googleapis.com/fcm/send/enU1D5In4EE:APA91bFf8pzjQfob8pfZ864VOMP4j_lSlptUowmaDV9KGFUSzZPq2ctDY22xUR3SBlf6v2BOyKjzinebvgzUZwQhnVe4dlK4Gr3zLFIVBszKHng_bL_3S5zNh2jrNOwtt0mr3FnZphMi', 'BD2F7QH1iZjUIizmFtj3waW8p6zG+0cRKjg0WYugvju+9IOvMMARwK5aIeobXFJH4d56ihwhnFQwwe3jKrlbKWo=', '5hy/N9kvji2+bjwA1iTuiA==', '2026-04-21 01:59:16', NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
