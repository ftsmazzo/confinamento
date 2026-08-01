-- P7 / E04 — Carga inicial catalogo farmacia (~94 produtos) — Conf. Irmaos Bichara
-- Fonte: planilhas/FARMACIA-CURRAIS PRONTO.xlsx · aba Cadastro-Estoque
-- Prefixo BI-P*: idempotente por codigo; nao colide com PROD01 do seed de teste
-- MVP: so cadastro em produto_estoque (+ local farmacia se faltar). Sem entradas/saidas.
-- Pre-requisito: categoria_produto Sanitario; migration tipo_produto (20260711_0001).
--
-- Conferencia:
--   SELECT COUNT(*) FROM produto_estoque WHERE codigo LIKE 'BI-P%';  -- esperar 94
--   SELECT codigo, nome, unidade_medida, fabricante, saldo_atual, tipo_produto
--   FROM produto_estoque WHERE codigo LIKE 'BI-P%' ORDER BY codigo;

SET @admin := (SELECT id FROM usuario WHERE login = 'admin' LIMIT 1);
SET @unidade := (SELECT id FROM unidade WHERE ativo = 1 ORDER BY id LIMIT 1);

SET @cat_sanitario := (SELECT id FROM categoria_produto WHERE descricao = 'Sanitário' LIMIT 1);
SET @cat_sanitario := IFNULL(@cat_sanitario, (SELECT id FROM categoria_produto WHERE descricao LIKE '%Sanit%' LIMIT 1));

-- Local fisico da farmacia (idempotente)
INSERT INTO local_estoque (id_unidade, nome, codigo, tipo, responsavel, ativo, created_by)
SELECT @unidade, 'Farmácia Veterinária Bichara', 'BI-FARM', 'DEPOSITO', NULL, 1, @admin
WHERE @unidade IS NOT NULL AND NOT EXISTS (SELECT 1 FROM local_estoque WHERE codigo = 'BI-FARM');

SET @local_farm := (SELECT id FROM local_estoque WHERE codigo = 'BI-FARM' LIMIT 1);
SET @local_farm := IFNULL(@local_farm, (SELECT id FROM local_estoque WHERE codigo = 'FARM01' LIMIT 1));
SET @local_farm := IFNULL(@local_farm, (SELECT id FROM local_estoque ORDER BY id LIMIT 1));

INSERT INTO local_armazenagem_interno (id_local_estoque, nome, ativo, created_by)
SELECT @local_farm, 'Prateleira Farmácia Bichara', 1, @admin
WHERE @local_farm IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM local_armazenagem_interno WHERE nome = 'Prateleira Farmácia Bichara');

SET @local_interno := (SELECT id FROM local_armazenagem_interno WHERE nome = 'Prateleira Farmácia Bichara' LIMIT 1);
SET @local_interno := IFNULL(@local_interno, (SELECT id FROM local_armazenagem_interno WHERE id_local_estoque = @local_farm ORDER BY id LIMIT 1));

-- ============================================================
-- PRODUTOS BI-P01 .. BI-P94
-- ============================================================

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TULAXX - ANTIMICROBIANO INJETÁVEL', 'OURO FINO', 'BI-P01', '100 ML', 2.00, NULL,
  0, 'CORTE 25 DIAS OUT/26-1 E AGO/27-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P01')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TULAXX - ANTIMICROBIANO INJETÁVEL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'PLACENCAL - OCITOCINA', 'CALBOS SAÚDE ANIMAL', 'BI-P02', '200 ML', 4.00, NULL,
  0, 'DEZ/26-4', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P02')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'PLACENCAL - OCITOCINA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'UMBICURA', 'PECUARISTA D'' OESTE', 'BI-P03', '250ML', 3.00, NULL,
  0, 'PROÍBIDO EM BEZERRO P/ABATE FEV/26-2 JUL/26-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P03')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'UMBICURA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'BOCIODO', 'BRAVET', 'BI-P04', '100 ML', 5.00, NULL,
  0, '0 CARÊNCIA SET/26-1 MAR/27-4', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P04')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'BOCIODO');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'SUPLEMENTO', @local_interno,
  'MONOVIM B1', 'BRAVET', 'BI-P05', '10 ML', 11.00, NULL,
  0, '0 CARÊNCIA SET/26-7 ABR/27-3', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P05')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MONOVIM B1');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'SUPLEMENTO', @local_interno,
  'MONOVIM B12', 'BRAVET', 'BI-P06', '10 ML', 2.00, NULL,
  0, 'DEZ/26-3', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P06')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MONOVIM B12');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'SUPLEMENTO', @local_interno,
  'MONOVIM K', 'BRAVET', 'BI-P07', '10 ML', 0.00, NULL,
  0, 'OUT/27-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P07')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MONOVIM K');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'BORGAL', 'MSD', 'BI-P08', '50 ML', 5.00, NULL,
  0, 'JUN/26-3', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P08')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'BORGAL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'ANESTT LIDOCAÍNA 2% - ANESTESIO LOCAL', 'SYNTEC', 'BI-P09', '50 ML', 6.00, NULL,
  0, 'AGO/27-19', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P09')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'ANESTT LIDOCAÍNA 2% - ANESTESIO LOCAL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'XILAZIN XILAZINA 2% - SEDATIVO', 'SYNTEC', 'BI-P10', '50 ML', 8.00, NULL,
  0, 'ABR/27-1 AGO/27-7', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P10')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'XILAZIN XILAZINA 2% - SEDATIVO');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'COBALZAM', 'LAB', 'BI-P11', '100 ML', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P11')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'COBALZAM');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'MAXICAM', 'OUROFINO', 'BI-P12', '100 ML', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P12')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MAXICAM');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'GANASEG 7%', 'ELANCO', 'BI-P13', '30 ML', 0.00, NULL,
  0, 'CORTE 34 DIAS MAR/26', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P13')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'GANASEG 7%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'MERCEPTOM', 'BRAVET', 'BI-P14', '100 ML', 0.00, NULL,
  0, '0 CARÊNCIA SET/28-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P14')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MERCEPTOM');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TERRA-COTRIL SPLAY', 'ZOETIS', 'BI-P15', '125ML', 2.00, NULL,
  0, '0 CARÊNCIA JAN/27-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P15')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TERRA-COTRIL SPLAY');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'FLUMAX', 'J A SAÚDE ANIMAL -AGO/26-3', 'BI-P16', '100 ML', 3.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P16')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'FLUMAX');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TILMICOVET', 'CEVA', 'BI-P17', '100 ML', 3.00, NULL,
  0, 'CORTE 28 DIAS SET/26-3', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P17')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TILMICOVET');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'OCITOCINA', 'UCB VET DEZ/26-2', 'BI-P18', '100 ML', 2.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P18')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'OCITOCINA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'ESTREPTOMICINA', 'BIOFARM NOV/28 -1', 'BI-P19', '100 ML', 1.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P19')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'ESTREPTOMICINA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MATERIAL_CONSUMO', @local_interno,
  'PRÓ BEZERRO SERINGA', 'J A SAÚDE ANIMAL', 'BI-P20', '5 ML', 22.00, NULL,
  0, 'FEV/26-22', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P20')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'PRÓ BEZERRO SERINGA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'ALIV V', 'AGEVER UNIÃO', 'BI-P21', '50 ML', 0.00, NULL,
  0, 'CORTE 10 DIAS MAI/25-4', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P21')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'ALIV V');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'CATOL + (BUTAFOSFAN/B12/COBALTO)', 'NOXON', 'BI-P22', '250ML', 1.00, NULL,
  0, '0 CARÊNCIA OUT/26-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P22')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'CATOL + (BUTAFOSFAN/B12/COBALTO)');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'IVERMEC 1%', 'MICROSULES', 'BI-P23', '500ML', 0.00, NULL,
  0, 'FEV/27', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P23')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'IVERMEC 1%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'CIDENTAL', 'BIMEDA', 'BI-P24', '250 ML', 0.00, NULL,
  0, 'OUT/26 -7', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P24')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'CIDENTAL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TREOXIN', 'FB', 'BI-P25', '100 ML', 0.00, NULL,
  0, 'FARMABASE', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P25')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TREOXIN');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TREO ACE', 'ZOETIS', 'BI-P26', '500 ML', 0.00, NULL,
  0, 'CORTE 63 DIAS', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P26')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TREO ACE');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'VERRUTRAT - CLOROBUTANOL', 'UCB VET AGO/27- 2', 'BI-P27', '20 ML', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P27')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'VERRUTRAT - CLOROBUTANOL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'AMINOFORT INJETÁVEL', 'VITAFORT', 'BI-P28', '240 ML', 0.00, NULL,
  0, 'JAN/23', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P28')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'AMINOFORT INJETÁVEL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'MOD PLUS', 'AGENER UNIÃO', 'BI-P29', '500 ML', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P29')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MOD PLUS');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'LACTOSILO GOLD', 'LAB', 'BI-P30', '100 G', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P30')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'LACTOSILO GOLD');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'PROVERME - INJETÁVEL', 'J A SAÚDE ANIMAL', 'BI-P31', '500 ML', 0.00, NULL,
  0, 'DEZ/26-30', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P31')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'PROVERME - INJETÁVEL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'NEWMAST - INTRAMAMÁRIO', 'PEARSON', 'BI-P32', '100 ML', 0.00, NULL,
  0, '20 D. DEZ/25-1  AGO/26-1 OUT/26-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P32')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'NEWMAST - INTRAMAMÁRIO');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TYLAN 200 - TILOSINA', 'ELANCO', 'BI-P33', '100 ML', 0.00, NULL,
  0, 'CORTE 21 DIAS SET/26-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P33')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TYLAN 200 - TILOSINA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'OXITRAT LA PLUS', 'VALLÉE', 'BI-P34', '100 ML', 0.00, NULL,
  0, 'CORTE 39 DIAS AGO/26-2 NOV/27-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P34')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'OXITRAT LA PLUS');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'SERRINHA', 'CASA PECUÁRIA', 'BI-P35', 'UNIDADE', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P35')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'SERRINHA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'C B - 30 TA', 'LAB', 'BI-P36', '100 ML', 0.00, NULL,
  0, 'JUL/27', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P36')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'C B - 30 TA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'RIPERCOLL (1 LITRO)', 'ZOETIS', 'BI-P37', '1 LITRO', 0.00, NULL,
  0, 'CORTE 16 DIAS  JAN/25', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P37')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'RIPERCOLL (1 LITRO)');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'CYPERMIL POUR ON OURO', 'OUROFINO', 'BI-P38', '1 LITRO', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P38')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'CYPERMIL POUR ON OURO');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'SUPLEMENTO', @local_interno,
  'GLICOTON B12 - SUPLEMENTO VIT/ENERG', 'J A SAÚDE ANIMAL', 'BI-P39', '500 ML', 0.00, NULL,
  0, 'JUL/26', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P39')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'GLICOTON B12 - SUPLEMENTO VIT/ENERG');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'AGENBENDAZOL 15% - SULFÓXICO ALBEN. (1 LITRO)', 'AGENER UNIÃO', 'BI-P40', '1 LITRO', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P40')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'AGENBENDAZOL 15% - SULFÓXICO ALBEN. (1 LITRO)');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'AGENBENDAZOL 15% - SULFÓXICO ALBEN. (500 ML)', 'AGENER UNIÃO', 'BI-P41', '500 ML', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P41')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'AGENBENDAZOL 15% - SULFÓXICO ALBEN. (500 ML)');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MATERIAL_CONSUMO', @local_interno,
  'SERINGA DESCARTÁVEL - 20ML', 'DESCARPACK', 'BI-P42', 'CAIXA', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P42')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'SERINGA DESCARTÁVEL - 20ML');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MATERIAL_CONSUMO', @local_interno,
  'SERINGA ESTERIL INSULINA', 'LAB', 'BI-P43', 'CAIXA', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P43')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'SERINGA ESTERIL INSULINA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'RICOBEM 13.6090', 'NOXON SAÚDE ANIMAL', 'BI-P44', 'UNIDADE', 0.00, NULL,
  0, 'CORTE 8 DIAS JUL/24', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P44')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'RICOBEM 13.6090');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'ATADURA COMPRESSÃO 12CM X 1,80M', 'CREAMER', 'BI-P45', 'UNIDADE', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P45')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'ATADURA COMPRESSÃO 12CM X 1,80M');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'BIOXAM', 'VALLÉE', 'BI-P46', '500 ML', 0.00, NULL,
  0, '0 CARÊNCIA JUL/26-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P46')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'BIOXAM');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TINTURA IODO', 'PINUS LABORATÓRIO', 'BI-P47', '1 LITRO', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P47')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TINTURA IODO');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'BASTÃO VERMELHO - MARCAÇÃO 57G', 'CASA PECUÁRIA', 'BI-P48', 'UNIDADE', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P48')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'BASTÃO VERMELHO - MARCAÇÃO 57G');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'UNGUENTO VANILPLUS', 'VANSIL', 'BI-P49', '250 G', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P49')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'UNGUENTO VANILPLUS');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'VETFLOR', 'J A SAÚDE ANIMAL', 'BI-P50', '100 ML', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P50')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'VETFLOR');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'IZOOT 312', 'AGENER UNIÃO', 'BI-P51', '50 ML', 0.00, NULL,
  0, 'CORTE 28 DIAS OUT/25', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P51')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'IZOOT 312');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'BOLFO PROPOUR 1%', 'ELANCO', 'BI-P52', '50 ML', 0.00, NULL,
  0, 'MAI/28', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P52')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'BOLFO PROPOUR 1%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'ANABOLIC NOXOM INJETÁVEL', 'NOXON SAÚDE ANIMAL', 'BI-P53', '500 ML', 0.00, NULL,
  0, '0 CARÊNCIA MAR/27-9', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P53')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'ANABOLIC NOXOM INJETÁVEL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'BOVITAM ORAL GEL', 'DISPEC DO BRASIL', 'BI-P54', '40 G', 0.00, NULL,
  0, 'JUN/26-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P54')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'BOVITAM ORAL GEL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'IVOMEC INJETÁVEL - IVERMECTINA 1%', 'BOEHRINGER INGELHEIM', 'BI-P55', '1 LITRO', 0.00, NULL,
  0, 'NOV/28-5', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P55')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'IVOMEC INJETÁVEL - IVERMECTINA 1%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'ALBENDATHOR 10% INJETÁVEL', 'J A SAÚDE ANIMAL', 'BI-P56', '500 ML', 0.00, NULL,
  0, 'ABR/26-8 JUL/26-8', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P56')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'ALBENDATHOR 10% INJETÁVEL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'MECTIMAX GOLD (1 LITRO #57)', 'LAB', 'BI-P57', '1 LITRO', 0.00, NULL,
  0, 'FEV/26-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P57')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MECTIMAX GOLD (1 LITRO #57)');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'RIPERCOLL (250 ML)', 'ZOETIS', 'BI-P58', '250 ML', 0.00, NULL,
  0, 'CORTE 16 DIAS JUL/25', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P58')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'RIPERCOLL (250 ML)');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'RIPERCOLL (30 ML)', 'ZOETIS', 'BI-P59', '30 ML', 0.00, NULL,
  0, 'OUT/27', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P59')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'RIPERCOLL (30 ML)');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'MAX PRATA', 'VANSIL SAÚDE ANIMAL', 'BI-P60', '290 G', 0.00, NULL,
  0, 'JUL/27-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P60')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MAX PRATA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'MECTIMAX GOLD (1 LITRO #61)', 'AGENER UNIÃO', 'BI-P61', '1 LITRO', 0.00, NULL,
  0, 'FEV/26', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P61')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'MECTIMAX GOLD (1 LITRO #61)');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'COLOSSO PULVERIZAÇÃO', 'OURO FINO', 'BI-P62', '1 LITRO', 1.00, NULL,
  0, 'MAR/27', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P62')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'COLOSSO PULVERIZAÇÃO');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'QUATERMON 30%', 'CHEMITEC', 'BI-P63', '1 LITRO', 0.00, NULL,
  0, 'JUL/27-3', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P63')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'QUATERMON 30%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'FORMOPED', 'ZOETIS', 'BI-P64', '400 G', 0.00, NULL,
  0, 'SET/23-1 SET/27-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P64')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'FORMOPED');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'BOVITAM', 'DISPEC DO BRASIL', 'BI-P65', '500 ML', 1.00, NULL,
  0, 'DEZ/25', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P65')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'BOVITAM');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'QUALIFOOD LAT 300', 'CLORAL', 'BI-P66', '5 LITROS', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P66')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'QUALIFOOD LAT 300');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'IVERMAX GOLD - IVERMECTINA 3,5%', 'DISPEC DO BRASIL', 'BI-P67', '1 LITRO', 0.00, NULL,
  0, 'CORTE 125 DIAS JUL/27-5', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P67')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'IVERMAX GOLD - IVERMECTINA 3,5%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'LIXA CIRCULAR - TRATAMENTO PODAL', 'CASA PECUÁRIA', 'BI-P68', 'UNIDADE', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P68')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'LIXA CIRCULAR - TRATAMENTO PODAL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'AEROCID SPRAY', 'AGENER UNIÃO', 'BI-P69', '309,5G', 2.00, NULL,
  0, 'FEV/27-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P69')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'AEROCID SPRAY');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TERRAMICINA EM PÓ SOLÚVEL - 77', 'ZOETIS', 'BI-P70', '100 G', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P70')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TERRAMICINA EM PÓ SOLÚVEL - 77');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'ABAMIC - ABAMECTINA 1%', 'MICROSULES', 'BI-P71', '1 LITRO', 3.00, NULL,
  0, 'JUL/28-3', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P71')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'ABAMIC - ABAMECTINA 1%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TIGUVON SPOTON 15', 'ELANCO', 'BI-P72', '1 LITRO', 1.00, NULL,
  0, 'CORTE 28 DIAS', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P72')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TIGUVON SPOTON 15');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'PARTOMICINA', 'CEVA', 'BI-P73', '7,91G', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P73')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'PARTOMICINA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'PRADOR', 'J A SAÚDE ANIMAL ABR/27-2', 'BI-P74', '100ML', 2.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P74')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'PRADOR');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'E.C.P. CIPIONATO DE ESTRADIOL', 'ZOETIS', 'BI-P75', '10 ML', 1.00, NULL,
  0, '0 CARÊNCIA MAR/28-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P75')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'E.C.P. CIPIONATO DE ESTRADIOL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'DIURAX FLUROSEMIDA', 'AGENER UNIÃO', 'BI-P76', '5 ML', 0.00, NULL,
  0, 'AGO/22', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P76')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'DIURAX FLUROSEMIDA');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'BANDAGEM COESIVA PRETA 1OCMX4,5M', 'CENTRAL VET', 'BI-P77', 'UNIDADE', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P77')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'BANDAGEM COESIVA PRETA 1OCMX4,5M');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'PENCIVET PLUS PPU BENZILPENICILINA G', 'MSD', 'BI-P78', '50 ML', 0.00, NULL,
  0, 'CORTE 28 DIAS', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P78')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'PENCIVET PLUS PPU BENZILPENICILINA G');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'RESFLOR GOLD', 'MSD', 'BI-P79', '100 ML', 0.00, NULL,
  0, 'CORTE 38 DIAS', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P79')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'RESFLOR GOLD');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MATERIAL_CONSUMO', @local_interno,
  'AGULHA HIPODÉRMICA 40mmX1,20mm', 'DESCARPACK', 'BI-P80', '1 CAIXA', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P80')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'AGULHA HIPODÉRMICA 40mmX1,20mm');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MATERIAL_CONSUMO', @local_interno,
  'SERINGA ACRÍLICO - 25ML', 'COPERCANA', 'BI-P81', 'UNIDADE', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P81')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'SERINGA ACRÍLICO - 25ML');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'VITAKÁ SM', 'SM', 'BI-P82', '20 ML', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P82')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'VITAKÁ SM');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'GANAVET PLUS', 'J A SAÚDE ANIMAL', 'BI-P83', '30 ML', 0.00, NULL,
  0, 'JUN/26-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P83')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'GANAVET PLUS');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TERRAMIN 400 PÓ SOLÚVEL', 'DISPEC DO BRASIL', 'BI-P84', '1 KG', 0.00, NULL,
  0, 'MAI/27-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P84')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TERRAMIN 400 PÓ SOLÚVEL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'IVERMIC EQUINOS - IVERMECTINA 1%', 'MICROSULES', 'BI-P85', '12 G', 2.00, NULL,
  0, 'SET/28', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P85')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'IVERMIC EQUINOS - IVERMECTINA 1%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'KINETOMAX', 'ELANCO', 'BI-P86', '100 ML', 2.00, NULL,
  0, 'CORTE 8 DIAS VIA IM - JAN/27-2', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P86')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'KINETOMAX');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TILADEN', 'CEVA', 'BI-P87', '100 ML', 1.00, NULL,
  0, 'CORTE 21 DIAS NOV/26-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P87')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TILADEN');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'DRAXXIN', 'ZOETIS', 'BI-P88', '100 ML', 0.00, NULL,
  0, 'CORTE 18 DIAS ABR/28-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P88')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'DRAXXIN');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MATERIAL_CONSUMO', @local_interno,
  'AGULHA ESTÉRIL - 13mmx0,45mm', 'MEDIX BRASIL', 'BI-P89', 'CAIXA', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P89')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'AGULHA ESTÉRIL - 13mmx0,45mm');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'QUINOTRIL', 'VALLÉ', 'BI-P90', '100 ML', 0.00, NULL,
  0, '28 DIAS', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P90')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'QUINOTRIL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'TERRACAM SRAY', 'AGENER UNIÃO', 'BI-P91', 'PEQUENO', 0.00, NULL,
  0, NULL, 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P91')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'TERRACAM SRAY');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'NAQUASONE INJETÁVEL', 'MSD', 'BI-P92', '10 ML', 0.00, NULL,
  0, 'LEITE 3 DIAS DEZ/26-1', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P92')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'NAQUASONE INJETÁVEL');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'ABANOX - ABAMECTINA 1%', 'NOXON SAÚDE ANIMAL', 'BI-P93', '1 LITRO', 0.00, NULL,
  0, 'CORTE 20 DIAS AGO/27-4', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P93')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'ABANOX - ABAMECTINA 1%');

INSERT INTO produto_estoque (
  id_categoria_produto, tipo_produto, id_local_armazenagem_interno,
  nome, fabricante, codigo, unidade_medida, saldo_atual, estoque_minimo,
  controla_lote, observacao, ativo, created_by
)
SELECT @cat_sanitario, 'MEDICAMENTO', @local_interno,
  'DIUZON', 'CHEMITEC', 'BI-P94', '10 ML', 0.00, NULL,
  0, 'JAN/27-3', 1, @admin
WHERE NOT EXISTS (SELECT 1 FROM produto_estoque WHERE codigo = 'BI-P94')
  AND NOT EXISTS (SELECT 1 FROM produto_estoque WHERE nome = 'DIUZON');

