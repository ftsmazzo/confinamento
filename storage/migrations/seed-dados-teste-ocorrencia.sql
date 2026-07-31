-- Seed de dados de teste para o cadastro geral de Ocorrências.
-- Não é uma migration numerada — script avulso para popular dados de
-- demonstração/teste, reaplicável a qualquer momento.

INSERT INTO `ocorrencia` (`id_lote`, `id_animal`, `data_ocorrencia`, `titulo`, `categoria`, `descricao`, `responsavel`, `created_by`)
VALUES
    (8, NULL, '2026-06-20', 'Cocho danificado no curral', 'Estrutural', 'Cocho de alimentação apresentou rachadura e precisa de reparo antes do próximo trato.', 'João Tratador', 1),
    (NULL, 3, '2026-06-25', 'Claudicação leve observada', 'Sanitário', 'Animal apresentou leve claudicação na pata traseira direita durante inspeção de rotina. Em observação.', 'Dra. Ana Veterinária', 1),
    (9, NULL, '2026-07-01', 'Comportamento agressivo no lote', 'Comportamental', 'Registrado comportamento agressivo entre animais do lote durante o fornecimento de trato da manhã.', 'João Tratador', 1),
    (NULL, NULL, '2026-07-05', 'Manutenção preventiva do trator', 'Administrativo', 'Trator utilizado na distribuição de ração passou por manutenção preventiva programada.', 'Carlos Mecânico', 1);
