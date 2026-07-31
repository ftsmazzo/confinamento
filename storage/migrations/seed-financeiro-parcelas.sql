-- Seed de contas parceladas para testar visualização agrupada
-- Cria despesas e receitas com 3-6 parcelas cada
SET @admin := (SELECT id FROM usuario WHERE login = 'admin' LIMIT 1);
SET @forn_racao := (SELECT id FROM fornecedor WHERE documento = '12345678000190');
SET @forn_vet := (SELECT id FROM fornecedor WHERE documento = '34567890000170');
SET @cliente := (SELECT id FROM cliente ORDER BY id LIMIT 1);
SET @plano_alim := (SELECT id FROM plano_conta WHERE codigo = '2.1.2');
SET @plano_san := (SELECT id FROM plano_conta WHERE codigo = '2.1.3');
SET @plano_venda := (SELECT id FROM plano_conta WHERE codigo = '1.1.1');
SET @plano_serv := (SELECT id FROM plano_conta WHERE codigo = '1.1.3');

-- ============================================================
-- Contas a Pagar parceladas
-- ============================================================

-- Despesa 1: Ração 6 parcelas
INSERT INTO conta_pagar (id_fornecedor, id_plano_conta, descricao, valor, data_vencimento, documento, status, parcela_numero, parcela_total, parcela_origem_id, created_by)
VALUES
(@forn_racao, @plano_alim, 'Compra de Ração Mensal', 15000.00, '2026-07-15', 'NF-7890', 'PENDENTE', 1, 6, NULL, @admin),
(@forn_racao, @plano_alim, 'Compra de Ração Mensal', 15000.00, '2026-08-15', 'NF-7890', 'PENDENTE', 2, 6, NULL, @admin),
(@forn_racao, @plano_alim, 'Compra de Ração Mensal', 15000.00, '2026-09-15', 'NF-7890', 'PENDENTE', 3, 6, NULL, @admin),
(@forn_racao, @plano_alim, 'Compra de Ração Mensal', 15000.00, '2026-10-15', 'NF-7890', 'PENDENTE', 4, 6, NULL, @admin),
(@forn_racao, @plano_alim, 'Compra de Ração Mensal', 15000.00, '2026-11-15', 'NF-7890', 'PENDENTE', 5, 6, NULL, @admin),
(@forn_racao, @plano_alim, 'Compra de Ração Mensal', 15000.00, '2026-12-15', 'NF-7890', 'PENDENTE', 6, 6, NULL, @admin);

SET @origem1 = (SELECT MIN(id) FROM conta_pagar WHERE documento = 'NF-7890');
UPDATE conta_pagar SET parcela_origem_id = @origem1 WHERE documento = 'NF-7890';

-- Despesa 2: Medicamentos 3 parcelas (uma já paga)
INSERT INTO conta_pagar (id_fornecedor, id_plano_conta, descricao, valor, data_vencimento, data_pagamento, documento, status, parcela_numero, parcela_total, parcela_origem_id, created_by)
VALUES
(@forn_vet, @plano_san, 'Vacinas e Medicamentos Lote 2026', 8500.00, '2026-06-10', '2026-06-08', 'NF-4567', 'PAGO', 1, 3, NULL, @admin),
(@forn_vet, @plano_san, 'Vacinas e Medicamentos Lote 2026', 8500.00, '2026-07-10', NULL, 'NF-4567', 'PENDENTE', 2, 3, NULL, @admin),
(@forn_vet, @plano_san, 'Vacinas e Medicamentos Lote 2026', 8500.00, '2026-08-10', NULL, 'NF-4567', 'PENDENTE', 3, 3, NULL, @admin);

SET @origem2 = (SELECT MIN(id) FROM conta_pagar WHERE documento = 'NF-4567');
UPDATE conta_pagar SET parcela_origem_id = @origem2 WHERE documento = 'NF-4567';

-- ============================================================
-- Contas a Receber parceladas
-- ============================================================

-- Receita 1: Venda de gado 4 parcelas
INSERT INTO conta_receber (id_cliente, id_plano_conta, descricao, valor, data_vencimento, documento, status, parcela_numero, parcela_total, parcela_origem_id, created_by)
VALUES
(@cliente, @plano_venda, 'Venda de Gado Lote 2026-001', 45000.00, '2026-07-20', 'CT-1001', 'PENDENTE', 1, 4, NULL, @admin),
(@cliente, @plano_venda, 'Venda de Gado Lote 2026-001', 45000.00, '2026-08-20', 'CT-1001', 'PENDENTE', 2, 4, NULL, @admin),
(@cliente, @plano_venda, 'Venda de Gado Lote 2026-001', 45000.00, '2026-09-20', 'CT-1001', 'PENDENTE', 3, 4, NULL, @admin),
(@cliente, @plano_venda, 'Venda de Gado Lote 2026-001', 45000.00, '2026-10-20', 'CT-1001', 'PENDENTE', 4, 4, NULL, @admin);

SET @origem3 = (SELECT MIN(id) FROM conta_receber WHERE documento = 'CT-1001');
UPDATE conta_receber SET parcela_origem_id = @origem3 WHERE documento = 'CT-1001';

-- Receita 2: Serviços de consultoria 3 parcelas (2 recebidas)
INSERT INTO conta_receber (id_cliente, id_plano_conta, descricao, valor, data_vencimento, data_recebimento, documento, status, parcela_numero, parcela_total, parcela_origem_id, created_by)
VALUES
(@cliente, @plano_serv, 'Consultoria Técnica Mensal', 3200.00, '2026-06-15', '2026-06-14', 'CT-1002', 'RECEBIDO', 1, 3, NULL, @admin),
(@cliente, @plano_serv, 'Consultoria Técnica Mensal', 3200.00, '2026-07-15', '2026-07-15', 'CT-1002', 'RECEBIDO', 2, 3, NULL, @admin),
(@cliente, @plano_serv, 'Consultoria Técnica Mensal', 3200.00, '2026-08-15', NULL, 'CT-1002', 'PENDENTE', 3, 3, NULL, @admin);

SET @origem4 = (SELECT MIN(id) FROM conta_receber WHERE documento = 'CT-1002');
UPDATE conta_receber SET parcela_origem_id = @origem4 WHERE documento = 'CT-1002';
