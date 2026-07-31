-- As permissoes de Relatorios estavam com "grupo" diferente entre si
-- (rentabilidade, evolucao_peso, mortalidade, consumo_racao, relatorios),
-- o que faz UsuarioPermissaoService::grouped() renderizar cada uma como
-- um card separado na tela de permissoes de usuario/perfil (ver
-- app/Views/admin/usuario/editar.phtml e perfil/editar.phtml -- cada
-- valor distinto de "grupo" dentro do mesmo "agrupamento" vira um
-- div.permission-block == 1 card).
--
-- Unifica todas em grupo = 'relatorios' para que virem um card unico
-- "Relatorios" no lugar de varios.

UPDATE `usuario_permissao`
SET `grupo` = 'relatorios'
WHERE `agrupamento` = 'Relatórios';

-- Padroniza as descricoes -- antes 4 delas eram so "Visualizar" (sem
-- dizer qual relatorio), o que fica confuso agora que todas estao no
-- mesmo card. O prefixo "Visualizar" foi removido em seguida (todas as
-- permissoes deste grupo sao de visualizacao, entao o prefixo era
-- redundante dentro do card).
UPDATE `usuario_permissao` SET `descricao` = 'Rentabilidade por Lote' WHERE `permissao` = 'relatorio_rentabilidade_visualizar';
UPDATE `usuario_permissao` SET `descricao` = 'Evolução de Peso / GMD' WHERE `permissao` = 'relatorio_evolucao_peso_visualizar';
UPDATE `usuario_permissao` SET `descricao` = 'Mortalidade / Perdas' WHERE `permissao` = 'relatorio_mortalidade_visualizar';
UPDATE `usuario_permissao` SET `descricao` = 'Consumo de Ração' WHERE `permissao` = 'relatorio_consumo_racao_visualizar';
UPDATE `usuario_permissao` SET `descricao` = 'Eficiência de Trato' WHERE `permissao` = 'relatorio_eficiencia_trato_visualizar';
UPDATE `usuario_permissao` SET `descricao` = 'Eficiência Alimentar' WHERE `permissao` = 'relatorio_eficiencia_alimentar_visualizar';
