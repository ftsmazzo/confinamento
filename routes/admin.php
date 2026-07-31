<?php
$router->namespace("\App\Controllers\Admin")->group(null);

    // rota dinâmica para erros
    $router->get('/erro/{code}', 'ErrorController:index', 'admin.error');

    $router->get("/", "LoginController:index", "admin.login");
    $router->post("/login", "LoginController:login", "admin.logar");
    $router->get("/esqueci-minha-senha", "LoginController:password", "admin.password");
    $router->post("/esqueci-minha-senha", "LoginController:passwordRequest", "admin.password.request");
    $router->get("/redefinir-senha/{token}", "LoginController:passwordReset", "admin.password.reset");
    $router->post("/redefinir-senha", "LoginController:passwordUpdate", "admin.password.update");
    $router->get("/logout", "LoginController:logout", "admin.logout");
    $router->get("/home", "HomeController:index", "admin.home");
    $router->get("/home/grafico-peso", "HomeController:graficoPeso", "admin.home.grafico.peso");
    $router->post("/tema/{tema}", "UsuarioPreferenciaController:theme", "admin.tema");

    // CALENDARIO (programacao de trato, carencias, validades e lembretes)
    $router->get("/calendario", "CalendarioController:index", "admin.calendario.index");
    $router->get("/calendario/eventos", "CalendarioController:eventos", "admin.calendario.eventos");
    $router->get("/calendario/lembretes/novo", "CalendarioController:novoLembrete", "admin.calendario.lembrete.novo");
    $router->post("/calendario/lembretes/insert", "CalendarioController:criarLembrete", "admin.calendario.lembrete.insert");
    $router->get("/calendario/lembretes/editar/{id}", "CalendarioController:editarLembrete", "admin.calendario.lembrete.editar");
    $router->post("/calendario/lembretes/update", "CalendarioController:atualizarLembrete", "admin.calendario.lembrete.update");
    $router->post("/calendario/lembretes/mover", "CalendarioController:moverLembrete", "admin.calendario.lembrete.mover");
    $router->get("/calendario/lembretes/delete/{id}", "CalendarioController:excluirLembrete", "admin.calendario.lembrete.delete");
    $router->post("/calendario/programacao-trato/mover", "CalendarioController:moverProgramacaoTrato", "admin.calendario.programacao.trato.mover");
    $router->post("/calendario/validade-insumo/mover", "CalendarioController:moverValidadeInsumo", "admin.calendario.validade.insumo.mover");
    $router->post("/calendario/preferencia-eventos", "CalendarioController:salvarPreferenciaEventos", "admin.calendario.preferencia.eventos");

    $router->get("/alterar-senha", "UsuarioController:pass", "admin.pass");
    $router->get("/pass/find", "UsuarioController:verifyPass", "admin.pass.find");
    $router->post("/alterar-senha/update", "UsuarioController:updatePass", "admin.pass.update");

    // USUÁRIOS
    $router->get("/usuarios", "UsuarioController:index", "admin.usuario.index");
    $router->get("/usuarios/find", "UsuarioController:checkLogin", "admin.usuario.find");
    $router->get("/usuarios/novo", "UsuarioController:new", "admin.usuario.novo");
    $router->get("/usuarios/editar/{id}", "UsuarioController:edit", "admin.usuario.editar");
    $router->get("/usuarios/historico", "UsuarioController:history", "admin.usuario.historico");
    $router->get("/usuarios/historico/{id}", "UsuarioController:history", "admin.usuario.historicos");
    $router->get("/usuarios/delete/{id}", "UsuarioController:delete", "admin.usuario.deletar");
    $router->post("/usuarios/insert", "UsuarioController:create", "admin.usuario.insert");
    $router->post("/usuarios/update", "UsuarioController:update", "admin.usuario.update");
    $router->get("/usuarios/editar/{id}/delete/foto", "UsuarioController:deletePhoto", "admin.usuario.delete.photo");

    // PERFIS DE ACESSO
    $router->get("/perfis", "UsuarioPerfilController:index", "admin.perfil.index");
    $router->get("/perfis/novo", "UsuarioPerfilController:new", "admin.perfil.novo");
    $router->get("/perfis/editar/{id}", "UsuarioPerfilController:edit", "admin.perfil.editar");
    $router->post("/perfis/insert", "UsuarioPerfilController:create", "admin.perfil.insert");
    $router->post("/perfis/update", "UsuarioPerfilController:update", "admin.perfil.update");
    $router->get("/perfis/delete/{id}", "UsuarioPerfilController:delete", "admin.perfil.delete");
    $router->get("/perfis/{id}/permissoes", "UsuarioPerfilController:permissions", "admin.perfil.permissions");

    // CLIENTES
    $router->get("/clientes", "ClienteController:index", "admin.cliente.index");
    $router->get("/clientes/novo", "ClienteController:new", "admin.cliente.novo");
    $router->get("/clientes/editar/{id}", "ClienteController:edit", "admin.cliente.editar");
    $router->post("/clientes/importar/upload", "ClienteController:importUpload", "admin.cliente.import.upload");
    $router->post("/clientes/find", "ClienteController:find", "admin.cliente.find");
    $router->post("/clientes/quick-insert", "ClienteController:quickCreate", "admin.cliente.quick.insert");
    $router->post("/clientes/insert", "ClienteController:create", "admin.cliente.insert");
    $router->post("/clientes/update", "ClienteController:update", "admin.cliente.update");
    $router->get("/clientes/delete/{id}", "ClienteController:delete", "admin.cliente.deletar");

    // CLIENTES SITUAÇÕES
    $router->get("/clientes/situacoes", "ClienteSituacaoController:index", "admin.cliente.situacao.index");
    $router->get("/clientes/situacoes/novo", "ClienteSituacaoController:new", "admin.cliente.situacao.novo");
    $router->get("/clientes/situacoes/editar/{id}", "ClienteSituacaoController:edit", "admin.cliente.situacao.editar");
    $router->post("/clientes/situacoes/insert", "ClienteSituacaoController:create", "admin.cliente.situacao.insert");
    $router->post("/clientes/situacoes/update", "ClienteSituacaoController:update", "admin.cliente.situacao.update");
    $router->get("/clientes/situacoes/delete/{id}", "ClienteSituacaoController:delete", "admin.cliente.situacao.delete");

    // CONFINAMENTO
    $router->get("/confinamento/unidades", "Confinamento\\UnidadeController:index", "admin.confinamento.unidade.index");
    $router->get("/confinamento/unidades/novo", "Confinamento\\UnidadeController:new", "admin.confinamento.unidade.novo");
    $router->get("/confinamento/unidades/editar/{id}", "Confinamento\\UnidadeController:edit", "admin.confinamento.unidade.editar");
    $router->post("/confinamento/unidades/insert", "Confinamento\\UnidadeController:create", "admin.confinamento.unidade.insert");
    $router->post("/confinamento/unidades/update", "Confinamento\\UnidadeController:update", "admin.confinamento.unidade.update");
    $router->get("/confinamento/unidades/delete/{id}", "Confinamento\\UnidadeController:delete", "admin.confinamento.unidade.delete");

    $router->get("/confinamento/currais", "Confinamento\\CurralController:index", "admin.confinamento.curral.index");
    $router->get("/confinamento/currais/novo", "Confinamento\\CurralController:new", "admin.confinamento.curral.novo");
    $router->get("/confinamento/currais/editar/{id}", "Confinamento\\CurralController:edit", "admin.confinamento.curral.editar");
    $router->post("/confinamento/currais/insert", "Confinamento\\CurralController:create", "admin.confinamento.curral.insert");
    $router->post("/confinamento/currais/update", "Confinamento\\CurralController:update", "admin.confinamento.curral.update");
    $router->get("/confinamento/currais/delete/{id}", "Confinamento\\CurralController:delete", "admin.confinamento.curral.delete");

    $router->get("/confinamento/piquetes", "Confinamento\\PiqueteController:index", "admin.confinamento.piquete.index");
    $router->get("/confinamento/piquetes/novo", "Confinamento\\PiqueteController:new", "admin.confinamento.piquete.novo");
    $router->get("/confinamento/piquetes/editar/{id}", "Confinamento\\PiqueteController:edit", "admin.confinamento.piquete.editar");
    $router->post("/confinamento/piquetes/insert", "Confinamento\\PiqueteController:create", "admin.confinamento.piquete.insert");
    $router->post("/confinamento/piquetes/update", "Confinamento\\PiqueteController:update", "admin.confinamento.piquete.update");
    $router->get("/confinamento/piquetes/delete/{id}", "Confinamento\\PiqueteController:delete", "admin.confinamento.piquete.delete");

    $router->get("/confinamento/locais-estoque", "Confinamento\\LocalEstoqueController:index", "admin.confinamento.local.estoque.index");
    $router->get("/confinamento/locais-estoque/novo", "Confinamento\\LocalEstoqueController:new", "admin.confinamento.local.estoque.novo");
    $router->get("/confinamento/locais-estoque/editar/{id}", "Confinamento\\LocalEstoqueController:edit", "admin.confinamento.local.estoque.editar");
    $router->post("/confinamento/locais-estoque/insert", "Confinamento\\LocalEstoqueController:create", "admin.confinamento.local.estoque.insert");
    $router->post("/confinamento/locais-estoque/update", "Confinamento\\LocalEstoqueController:update", "admin.confinamento.local.estoque.update");
    $router->get("/confinamento/locais-estoque/delete/{id}", "Confinamento\\LocalEstoqueController:delete", "admin.confinamento.local.estoque.delete");

    $router->get("/confinamento/centros-custo", "Confinamento\\CentroCustoController:index", "admin.confinamento.centro.custo.index");
    $router->get("/confinamento/centros-custo/novo", "Confinamento\\CentroCustoController:new", "admin.confinamento.centro.custo.novo");
    $router->get("/confinamento/centros-custo/editar/{id}", "Confinamento\\CentroCustoController:edit", "admin.confinamento.centro.custo.editar");
    $router->post("/confinamento/centros-custo/insert", "Confinamento\\CentroCustoController:create", "admin.confinamento.centro.custo.insert");
    $router->post("/confinamento/centros-custo/update", "Confinamento\\CentroCustoController:update", "admin.confinamento.centro.custo.update");
    $router->get("/confinamento/centros-custo/delete/{id}", "Confinamento\\CentroCustoController:delete", "admin.confinamento.centro.custo.delete");

    // MANEJO - ANIMAIS
    $router->get("/manejo/animais", "Manejo\\AnimalController:index", "admin.manejo.animal.index");
    $router->get("/manejo/animais/novo", "Manejo\\AnimalController:new", "admin.manejo.animal.novo");
    $router->get("/manejo/animais/editar/{id}", "Manejo\\AnimalController:edit", "admin.manejo.animal.editar");
    $router->post("/manejo/animais/insert", "Manejo\\AnimalController:create", "admin.manejo.animal.insert");
    $router->post("/manejo/animais/update", "Manejo\\AnimalController:update", "admin.manejo.animal.update");
    $router->get("/manejo/animais/delete/{id}", "Manejo\\AnimalController:delete", "admin.manejo.animal.delete");

    // MANEJO - SITUACOES DO ANIMAL
    $router->get("/manejo/situacoes-animal", "Manejo\\AnimalSituacaoController:index", "admin.manejo.animal.situacao.index");
    $router->get("/manejo/situacoes-animal/novo", "Manejo\\AnimalSituacaoController:new", "admin.manejo.animal.situacao.novo");
    $router->get("/manejo/situacoes-animal/editar/{id}", "Manejo\\AnimalSituacaoController:edit", "admin.manejo.animal.situacao.editar");
    $router->post("/manejo/situacoes-animal/insert", "Manejo\\AnimalSituacaoController:create", "admin.manejo.animal.situacao.insert");
    $router->post("/manejo/situacoes-animal/update", "Manejo\\AnimalSituacaoController:update", "admin.manejo.animal.situacao.update");
    $router->get("/manejo/situacoes-animal/delete/{id}", "Manejo\\AnimalSituacaoController:delete", "admin.manejo.animal.situacao.delete");

    // MANEJO - LOTES
    $router->get("/manejo/lotes", "Manejo\\LoteController:index", "admin.manejo.lote.index");
    $router->get("/manejo/lotes/novo", "Manejo\\LoteController:new", "admin.manejo.lote.novo");
    $router->get("/manejo/lotes/editar/{id}", "Manejo\\LoteController:edit", "admin.manejo.lote.editar");
    $router->post("/manejo/lotes/insert", "Manejo\\LoteController:create", "admin.manejo.lote.insert");
    $router->post("/manejo/lotes/update", "Manejo\\LoteController:update", "admin.manejo.lote.update");
    $router->get("/manejo/lotes/delete/{id}", "Manejo\\LoteController:delete", "admin.manejo.lote.delete");

    // MANEJO - TIPOS DE ENTRADA
    $router->get("/manejo/tipos-entrada", "Manejo\\TipoEntradaController:index", "admin.manejo.tipo.entrada.index");
    $router->get("/manejo/tipos-entrada/novo", "Manejo\\TipoEntradaController:new", "admin.manejo.tipo.entrada.novo");
    $router->get("/manejo/tipos-entrada/editar/{id}", "Manejo\\TipoEntradaController:edit", "admin.manejo.tipo.entrada.editar");
    $router->post("/manejo/tipos-entrada/insert", "Manejo\\TipoEntradaController:create", "admin.manejo.tipo.entrada.insert");
    $router->post("/manejo/tipos-entrada/update", "Manejo\\TipoEntradaController:update", "admin.manejo.tipo.entrada.update");
    $router->get("/manejo/tipos-entrada/delete/{id}", "Manejo\\TipoEntradaController:delete", "admin.manejo.tipo.entrada.delete");

    // MANEJO - TIPOS DE SAÍDA
    $router->get("/manejo/tipos-saida", "Manejo\\TipoSaidaController:index", "admin.manejo.tipo.saida.index");
    $router->get("/manejo/tipos-saida/novo", "Manejo\\TipoSaidaController:new", "admin.manejo.tipo.saida.novo");
    $router->get("/manejo/tipos-saida/editar/{id}", "Manejo\\TipoSaidaController:edit", "admin.manejo.tipo.saida.editar");
    $router->post("/manejo/tipos-saida/insert", "Manejo\\TipoSaidaController:create", "admin.manejo.tipo.saida.insert");
    $router->post("/manejo/tipos-saida/update", "Manejo\\TipoSaidaController:update", "admin.manejo.tipo.saida.update");
    $router->get("/manejo/tipos-saida/delete/{id}", "Manejo\\TipoSaidaController:delete", "admin.manejo.tipo.saida.delete");

    // MANEJO - MOTIVOS DE PERDA
    $router->get("/manejo/motivos-perda", "Manejo\\MotivoPerdaController:index", "admin.manejo.motivo.perda.index");
    $router->get("/manejo/motivos-perda/novo", "Manejo\\MotivoPerdaController:new", "admin.manejo.motivo.perda.novo");
    $router->get("/manejo/motivos-perda/editar/{id}", "Manejo\\MotivoPerdaController:edit", "admin.manejo.motivo.perda.editar");
    $router->post("/manejo/motivos-perda/insert", "Manejo\\MotivoPerdaController:create", "admin.manejo.motivo.perda.insert");
    $router->post("/manejo/motivos-perda/update", "Manejo\\MotivoPerdaController:update", "admin.manejo.motivo.perda.update");
    $router->get("/manejo/motivos-perda/delete/{id}", "Manejo\\MotivoPerdaController:delete", "admin.manejo.motivo.perda.delete");

    // MANEJO - PESAGENS
    $router->get("/manejo/pesagens", "Manejo\\PesagemController:index", "admin.manejo.pesagem.index");
    $router->get("/manejo/pesagens/novo", "Manejo\\PesagemController:new", "admin.manejo.pesagem.novo");
    $router->get("/manejo/pesagens/editar/{id}", "Manejo\\PesagemController:edit", "admin.manejo.pesagem.editar");
    $router->post("/manejo/pesagens/insert", "Manejo\\PesagemController:create", "admin.manejo.pesagem.insert");
    $router->post("/manejo/pesagens/update", "Manejo\\PesagemController:update", "admin.manejo.pesagem.update");
    $router->get("/manejo/pesagens/delete/{id}", "Manejo\\PesagemController:delete", "admin.manejo.pesagem.delete");

    // MANEJO - ENTRADAS
    $router->get("/manejo/entradas", "Manejo\\EntradaController:index", "admin.manejo.entrada.index");
    $router->get("/manejo/entradas/novo", "Manejo\\EntradaController:new", "admin.manejo.entrada.novo");
    $router->get("/manejo/entradas/editar/{id}", "Manejo\\EntradaController:edit", "admin.manejo.entrada.editar");
    $router->post("/manejo/entradas/insert", "Manejo\\EntradaController:create", "admin.manejo.entrada.insert");
    $router->post("/manejo/entradas/update", "Manejo\\EntradaController:update", "admin.manejo.entrada.update");
    $router->get("/manejo/entradas/delete/{id}", "Manejo\\EntradaController:delete", "admin.manejo.entrada.delete");

    // MANEJO - LOCALIZACOES (alocacao + transferencia)
    $router->get("/manejo/localizacoes", "Manejo\\LocalizacaoController:index", "admin.manejo.localizacao.index");
    $router->get("/manejo/localizacoes/novo", "Manejo\\LocalizacaoController:new", "admin.manejo.localizacao.novo");
    $router->get("/manejo/localizacoes/editar/{id}", "Manejo\\LocalizacaoController:edit", "admin.manejo.localizacao.editar");
    $router->post("/manejo/localizacoes/insert", "Manejo\\LocalizacaoController:create", "admin.manejo.localizacao.insert");
    $router->post("/manejo/localizacoes/update", "Manejo\\LocalizacaoController:update", "admin.manejo.localizacao.update");
    $router->get("/manejo/localizacoes/delete/{id}", "Manejo\\LocalizacaoController:delete", "admin.manejo.localizacao.delete");

    // MANEJO - TROCAS DE DIETA
    $router->get("/manejo/trocas-dieta", "Manejo\\TrocaDietaController:index", "admin.manejo.troca.dieta.index");
    $router->get("/manejo/trocas-dieta/novo", "Manejo\\TrocaDietaController:new", "admin.manejo.troca.dieta.novo");
    $router->get("/manejo/trocas-dieta/editar/{id}", "Manejo\\TrocaDietaController:edit", "admin.manejo.troca.dieta.editar");
    $router->post("/manejo/trocas-dieta/insert", "Manejo\\TrocaDietaController:create", "admin.manejo.troca.dieta.insert");
    $router->post("/manejo/trocas-dieta/update", "Manejo\\TrocaDietaController:update", "admin.manejo.troca.dieta.update");
    $router->get("/manejo/trocas-dieta/delete/{id}", "Manejo\\TrocaDietaController:delete", "admin.manejo.troca.dieta.delete");

    // MANEJO - SAIDAS
    $router->get("/manejo/saidas", "Manejo\\SaidaController:index", "admin.manejo.saida.index");
    $router->get("/manejo/saidas/novo", "Manejo\\SaidaController:new", "admin.manejo.saida.novo");
    $router->get("/manejo/saidas/editar/{id}", "Manejo\\SaidaController:edit", "admin.manejo.saida.editar");
    $router->post("/manejo/saidas/insert", "Manejo\\SaidaController:create", "admin.manejo.saida.insert");
    $router->post("/manejo/saidas/update", "Manejo\\SaidaController:update", "admin.manejo.saida.update");
    $router->get("/manejo/saidas/delete/{id}", "Manejo\\SaidaController:delete", "admin.manejo.saida.delete");

    // MANEJO - MORTALIDADES
    $router->get("/manejo/mortalidades", "Manejo\\MortalidadeController:index", "admin.manejo.mortalidade.index");
    $router->get("/manejo/mortalidades/novo", "Manejo\\MortalidadeController:new", "admin.manejo.mortalidade.novo");
    $router->get("/manejo/mortalidades/editar/{id}", "Manejo\\MortalidadeController:edit", "admin.manejo.mortalidade.editar");
    $router->post("/manejo/mortalidades/insert", "Manejo\\MortalidadeController:create", "admin.manejo.mortalidade.insert");
    $router->post("/manejo/mortalidades/update", "Manejo\\MortalidadeController:update", "admin.manejo.mortalidade.update");
    $router->get("/manejo/mortalidades/delete/{id}", "Manejo\\MortalidadeController:delete", "admin.manejo.mortalidade.delete");

    // MANEJO - OCORRENCIAS (cadastro geral, com anexos de foto/video/audio)
    $router->get("/manejo/ocorrencias", "Manejo\\OcorrenciaController:index", "admin.manejo.ocorrencia.index");
    $router->get("/manejo/ocorrencias/novo", "Manejo\\OcorrenciaController:new", "admin.manejo.ocorrencia.novo");
    $router->get("/manejo/ocorrencias/editar/{id}", "Manejo\\OcorrenciaController:edit", "admin.manejo.ocorrencia.editar");
    $router->post("/manejo/ocorrencias/insert", "Manejo\\OcorrenciaController:create", "admin.manejo.ocorrencia.insert");
    $router->post("/manejo/ocorrencias/update", "Manejo\\OcorrenciaController:update", "admin.manejo.ocorrencia.update");
    $router->get("/manejo/ocorrencias/delete/{id}", "Manejo\\OcorrenciaController:delete", "admin.manejo.ocorrencia.delete");
    $router->get("/manejo/ocorrencias/anexos/delete/{id}", "Manejo\\OcorrenciaController:deleteAnexo", "admin.manejo.ocorrencia.anexo.delete");

    // NUTRICAO - GRUPOS DE INGREDIENTES
    $router->get("/nutricao/grupos-ingrediente", "Nutricao\\GrupoIngredienteController:index", "admin.nutricao.grupo.ingrediente.index");
    $router->get("/nutricao/grupos-ingrediente/novo", "Nutricao\\GrupoIngredienteController:new", "admin.nutricao.grupo.ingrediente.novo");
    $router->get("/nutricao/grupos-ingrediente/editar/{id}", "Nutricao\\GrupoIngredienteController:edit", "admin.nutricao.grupo.ingrediente.editar");
    $router->post("/nutricao/grupos-ingrediente/insert", "Nutricao\\GrupoIngredienteController:create", "admin.nutricao.grupo.ingrediente.insert");
    $router->post("/nutricao/grupos-ingrediente/update", "Nutricao\\GrupoIngredienteController:update", "admin.nutricao.grupo.ingrediente.update");
    $router->get("/nutricao/grupos-ingrediente/delete/{id}", "Nutricao\\GrupoIngredienteController:delete", "admin.nutricao.grupo.ingrediente.delete");

    // NUTRICAO - INGREDIENTES
    $router->get("/nutricao/ingredientes", "Nutricao\\IngredienteController:index", "admin.nutricao.ingrediente.index");
    $router->get("/nutricao/ingredientes/novo", "Nutricao\\IngredienteController:new", "admin.nutricao.ingrediente.novo");
    $router->get("/nutricao/ingredientes/editar/{id}", "Nutricao\\IngredienteController:edit", "admin.nutricao.ingrediente.editar");
    $router->post("/nutricao/ingredientes/insert", "Nutricao\\IngredienteController:create", "admin.nutricao.ingrediente.insert");
    $router->post("/nutricao/ingredientes/update", "Nutricao\\IngredienteController:update", "admin.nutricao.ingrediente.update");
    $router->get("/nutricao/ingredientes/delete/{id}", "Nutricao\\IngredienteController:delete", "admin.nutricao.ingrediente.delete");

    // NUTRICAO - FASES NUTRICIONAIS
    $router->get("/nutricao/fases-nutricionais", "Nutricao\\FaseNutricionalController:index", "admin.nutricao.fase.nutricional.index");
    $router->get("/nutricao/fases-nutricionais/novo", "Nutricao\\FaseNutricionalController:new", "admin.nutricao.fase.nutricional.novo");
    $router->get("/nutricao/fases-nutricionais/editar/{id}", "Nutricao\\FaseNutricionalController:edit", "admin.nutricao.fase.nutricional.editar");
    $router->post("/nutricao/fases-nutricionais/insert", "Nutricao\\FaseNutricionalController:create", "admin.nutricao.fase.nutricional.insert");
    $router->post("/nutricao/fases-nutricionais/update", "Nutricao\\FaseNutricionalController:update", "admin.nutricao.fase.nutricional.update");
    $router->get("/nutricao/fases-nutricionais/delete/{id}", "Nutricao\\FaseNutricionalController:delete", "admin.nutricao.fase.nutricional.delete");

    // NUTRICAO - TIPOS DE DIETA
    $router->get("/nutricao/tipos-dieta", "Nutricao\\TipoDietaController:index", "admin.nutricao.tipo.dieta.index");
    $router->get("/nutricao/tipos-dieta/novo", "Nutricao\\TipoDietaController:new", "admin.nutricao.tipo.dieta.novo");
    $router->get("/nutricao/tipos-dieta/editar/{id}", "Nutricao\\TipoDietaController:edit", "admin.nutricao.tipo.dieta.editar");
    $router->post("/nutricao/tipos-dieta/insert", "Nutricao\\TipoDietaController:create", "admin.nutricao.tipo.dieta.insert");
    $router->post("/nutricao/tipos-dieta/update", "Nutricao\\TipoDietaController:update", "admin.nutricao.tipo.dieta.update");
    $router->get("/nutricao/tipos-dieta/delete/{id}", "Nutricao\\TipoDietaController:delete", "admin.nutricao.tipo.dieta.delete");

    // NUTRICAO - PARAMETROS NUTRICIONAIS
    $router->get("/nutricao/parametros-nutricionais", "Nutricao\\ParametroNutricionalController:index", "admin.nutricao.parametro.nutricional.index");
    $router->get("/nutricao/parametros-nutricionais/novo", "Nutricao\\ParametroNutricionalController:new", "admin.nutricao.parametro.nutricional.novo");
    $router->get("/nutricao/parametros-nutricionais/editar/{id}", "Nutricao\\ParametroNutricionalController:edit", "admin.nutricao.parametro.nutricional.editar");
    $router->post("/nutricao/parametros-nutricionais/insert", "Nutricao\\ParametroNutricionalController:create", "admin.nutricao.parametro.nutricional.insert");
    $router->post("/nutricao/parametros-nutricionais/update", "Nutricao\\ParametroNutricionalController:update", "admin.nutricao.parametro.nutricional.update");
    $router->get("/nutricao/parametros-nutricionais/delete/{id}", "Nutricao\\ParametroNutricionalController:delete", "admin.nutricao.parametro.nutricional.delete");

    // NUTRICAO - FORMULAS DE RACAO
    $router->get("/nutricao/formulas-racao", "Nutricao\\FormulaRacaoController:index", "admin.nutricao.formula.racao.index");
    $router->get("/nutricao/formulas-racao/novo", "Nutricao\\FormulaRacaoController:new", "admin.nutricao.formula.racao.novo");
    $router->get("/nutricao/formulas-racao/editar/{id}", "Nutricao\\FormulaRacaoController:edit", "admin.nutricao.formula.racao.editar");
    $router->post("/nutricao/formulas-racao/insert", "Nutricao\\FormulaRacaoController:create", "admin.nutricao.formula.racao.insert");
    $router->post("/nutricao/formulas-racao/update", "Nutricao\\FormulaRacaoController:update", "admin.nutricao.formula.racao.update");
    $router->get("/nutricao/formulas-racao/delete/{id}", "Nutricao\\FormulaRacaoController:delete", "admin.nutricao.formula.racao.delete");

    // NUTRICAO - CONFECCOES DE RACAO
    $router->get("/nutricao/confeccoes-racao", "Nutricao\\ConfeccaoRacaoController:index", "admin.nutricao.confeccao.racao.index");
    $router->get("/nutricao/confeccoes-racao/novo", "Nutricao\\ConfeccaoRacaoController:new", "admin.nutricao.confeccao.racao.novo");
    $router->get("/nutricao/confeccoes-racao/editar/{id}", "Nutricao\\ConfeccaoRacaoController:edit", "admin.nutricao.confeccao.racao.editar");
    $router->post("/nutricao/confeccoes-racao/insert", "Nutricao\\ConfeccaoRacaoController:create", "admin.nutricao.confeccao.racao.insert");
    $router->post("/nutricao/confeccoes-racao/update", "Nutricao\\ConfeccaoRacaoController:update", "admin.nutricao.confeccao.racao.update");
    $router->get("/nutricao/confeccoes-racao/delete/{id}", "Nutricao\\ConfeccaoRacaoController:delete", "admin.nutricao.confeccao.racao.delete");

    // NUTRICAO - PROGRAMACOES DE TRATO
    $router->get("/nutricao/programacoes-trato", "Nutricao\\ProgramacaoTratoController:index", "admin.nutricao.programacao.trato.index");
    $router->get("/nutricao/programacoes-trato/novo", "Nutricao\\ProgramacaoTratoController:new", "admin.nutricao.programacao.trato.novo");
    $router->get("/nutricao/programacoes-trato/editar/{id}", "Nutricao\\ProgramacaoTratoController:edit", "admin.nutricao.programacao.trato.editar");
    $router->post("/nutricao/programacoes-trato/insert", "Nutricao\\ProgramacaoTratoController:create", "admin.nutricao.programacao.trato.insert");
    $router->post("/nutricao/programacoes-trato/update", "Nutricao\\ProgramacaoTratoController:update", "admin.nutricao.programacao.trato.update");
    $router->get("/nutricao/programacoes-trato/delete/{id}", "Nutricao\\ProgramacaoTratoController:delete", "admin.nutricao.programacao.trato.delete");

    // NUTRICAO - FORNECIMENTOS DE TRATO
    $router->get("/nutricao/fornecimentos-trato", "Nutricao\\FornecimentoTratoController:index", "admin.nutricao.fornecimento.trato.index");
    $router->get("/nutricao/fornecimentos-trato/novo", "Nutricao\\FornecimentoTratoController:new", "admin.nutricao.fornecimento.trato.novo");
    $router->get("/nutricao/fornecimentos-trato/editar/{id}", "Nutricao\\FornecimentoTratoController:edit", "admin.nutricao.fornecimento.trato.editar");
    $router->post("/nutricao/fornecimentos-trato/insert", "Nutricao\\FornecimentoTratoController:create", "admin.nutricao.fornecimento.trato.insert");
    $router->post("/nutricao/fornecimentos-trato/update", "Nutricao\\FornecimentoTratoController:update", "admin.nutricao.fornecimento.trato.update");
    $router->get("/nutricao/fornecimentos-trato/delete/{id}", "Nutricao\\FornecimentoTratoController:delete", "admin.nutricao.fornecimento.trato.delete");

    // NUTRICAO - LEITURAS DE COCHO
    $router->get("/nutricao/leituras-cocho", "Nutricao\\LeituraCochoController:index", "admin.nutricao.leitura.cocho.index");
    $router->get("/nutricao/leituras-cocho/novo", "Nutricao\\LeituraCochoController:new", "admin.nutricao.leitura.cocho.novo");
    $router->get("/nutricao/leituras-cocho/editar/{id}", "Nutricao\\LeituraCochoController:edit", "admin.nutricao.leitura.cocho.editar");
    $router->post("/nutricao/leituras-cocho/insert", "Nutricao\\LeituraCochoController:create", "admin.nutricao.leitura.cocho.insert");
    $router->post("/nutricao/leituras-cocho/update", "Nutricao\\LeituraCochoController:update", "admin.nutricao.leitura.cocho.update");
    $router->get("/nutricao/leituras-cocho/delete/{id}", "Nutricao\\LeituraCochoController:delete", "admin.nutricao.leitura.cocho.delete");

    // NUTRICAO - AJUSTES DE CONSUMO
    $router->get("/nutricao/ajustes-consumo", "Nutricao\\AjusteConsumoController:index", "admin.nutricao.ajuste.consumo.index");
    $router->get("/nutricao/ajustes-consumo/novo", "Nutricao\\AjusteConsumoController:new", "admin.nutricao.ajuste.consumo.novo");
    $router->get("/nutricao/ajustes-consumo/editar/{id}", "Nutricao\\AjusteConsumoController:edit", "admin.nutricao.ajuste.consumo.editar");
    $router->post("/nutricao/ajustes-consumo/insert", "Nutricao\\AjusteConsumoController:create", "admin.nutricao.ajuste.consumo.insert");
    $router->post("/nutricao/ajustes-consumo/update", "Nutricao\\AjusteConsumoController:update", "admin.nutricao.ajuste.consumo.update");
    $router->get("/nutricao/ajustes-consumo/delete/{id}", "Nutricao\\AjusteConsumoController:delete", "admin.nutricao.ajuste.consumo.delete");

    // ESTOQUE - CATEGORIAS DE PRODUTO
    $router->get("/estoque/categorias-produto", "Estoque\\CategoriaProdutoController:index", "admin.estoque.categoria.produto.index");
    $router->get("/estoque/categorias-produto/novo", "Estoque\\CategoriaProdutoController:new", "admin.estoque.categoria.produto.novo");
    $router->get("/estoque/categorias-produto/editar/{id}", "Estoque\\CategoriaProdutoController:edit", "admin.estoque.categoria.produto.editar");
    $router->post("/estoque/categorias-produto/insert", "Estoque\\CategoriaProdutoController:create", "admin.estoque.categoria.produto.insert");
    $router->post("/estoque/categorias-produto/update", "Estoque\\CategoriaProdutoController:update", "admin.estoque.categoria.produto.update");
    $router->get("/estoque/categorias-produto/delete/{id}", "Estoque\\CategoriaProdutoController:delete", "admin.estoque.categoria.produto.delete");

    // ESTOQUE - LOCAIS INTERNOS DE ARMAZENAGEM
    $router->get("/estoque/locais-armazenagem-interno", "Estoque\\LocalArmazenagemInternoController:index", "admin.estoque.local.armazenagem.interno.index");
    $router->get("/estoque/locais-armazenagem-interno/novo", "Estoque\\LocalArmazenagemInternoController:new", "admin.estoque.local.armazenagem.interno.novo");
    $router->get("/estoque/locais-armazenagem-interno/editar/{id}", "Estoque\\LocalArmazenagemInternoController:edit", "admin.estoque.local.armazenagem.interno.editar");
    $router->post("/estoque/locais-armazenagem-interno/insert", "Estoque\\LocalArmazenagemInternoController:create", "admin.estoque.local.armazenagem.interno.insert");
    $router->post("/estoque/locais-armazenagem-interno/update", "Estoque\\LocalArmazenagemInternoController:update", "admin.estoque.local.armazenagem.interno.update");
    $router->get("/estoque/locais-armazenagem-interno/delete/{id}", "Estoque\\LocalArmazenagemInternoController:delete", "admin.estoque.local.armazenagem.interno.delete");

    // ESTOQUE - PRODUTOS
    $router->get("/estoque/produtos", "Estoque\\ProdutoEstoqueController:index", "admin.estoque.produto.index");
    $router->get("/estoque/produtos/novo", "Estoque\\ProdutoEstoqueController:new", "admin.estoque.produto.novo");
    $router->get("/estoque/produtos/editar/{id}", "Estoque\\ProdutoEstoqueController:edit", "admin.estoque.produto.editar");
    $router->post("/estoque/produtos/insert", "Estoque\\ProdutoEstoqueController:create", "admin.estoque.produto.insert");
    $router->post("/estoque/produtos/update", "Estoque\\ProdutoEstoqueController:update", "admin.estoque.produto.update");
    $router->get("/estoque/produtos/delete/{id}", "Estoque\\ProdutoEstoqueController:delete", "admin.estoque.produto.delete");

    // ESTOQUE - LOTES
    $router->get("/estoque/lotes", "Estoque\\LoteEstoqueController:index", "admin.estoque.lote.index");
    $router->get("/estoque/lotes/novo", "Estoque\\LoteEstoqueController:new", "admin.estoque.lote.novo");
    $router->get("/estoque/lotes/editar/{id}", "Estoque\\LoteEstoqueController:edit", "admin.estoque.lote.editar");
    $router->post("/estoque/lotes/insert", "Estoque\\LoteEstoqueController:create", "admin.estoque.lote.insert");
    $router->post("/estoque/lotes/update", "Estoque\\LoteEstoqueController:update", "admin.estoque.lote.update");
    $router->get("/estoque/lotes/delete/{id}", "Estoque\\LoteEstoqueController:delete", "admin.estoque.lote.delete");

    // ESTOQUE - TIPOS DE MOVIMENTACAO
    $router->get("/estoque/tipos-movimentacao", "Estoque\\TipoMovimentacaoEstoqueController:index", "admin.estoque.tipo.movimentacao.index");
    $router->get("/estoque/tipos-movimentacao/novo", "Estoque\\TipoMovimentacaoEstoqueController:new", "admin.estoque.tipo.movimentacao.novo");
    $router->get("/estoque/tipos-movimentacao/editar/{id}", "Estoque\\TipoMovimentacaoEstoqueController:edit", "admin.estoque.tipo.movimentacao.editar");
    $router->post("/estoque/tipos-movimentacao/insert", "Estoque\\TipoMovimentacaoEstoqueController:create", "admin.estoque.tipo.movimentacao.insert");
    $router->post("/estoque/tipos-movimentacao/update", "Estoque\\TipoMovimentacaoEstoqueController:update", "admin.estoque.tipo.movimentacao.update");
    $router->get("/estoque/tipos-movimentacao/delete/{id}", "Estoque\\TipoMovimentacaoEstoqueController:delete", "admin.estoque.tipo.movimentacao.delete");

    // ESTOQUE - MOVIMENTACOES
    $router->get("/estoque/movimentacoes", "Estoque\\MovimentacaoEstoqueController:index", "admin.estoque.movimentacao.index");
    $router->get("/estoque/movimentacoes/novo", "Estoque\\MovimentacaoEstoqueController:new", "admin.estoque.movimentacao.novo");
    $router->get("/estoque/movimentacoes/editar/{id}", "Estoque\\MovimentacaoEstoqueController:edit", "admin.estoque.movimentacao.editar");
    $router->post("/estoque/movimentacoes/insert", "Estoque\\MovimentacaoEstoqueController:create", "admin.estoque.movimentacao.insert");
    $router->post("/estoque/movimentacoes/update", "Estoque\\MovimentacaoEstoqueController:update", "admin.estoque.movimentacao.update");
    $router->get("/estoque/movimentacoes/delete/{id}", "Estoque\\MovimentacaoEstoqueController:delete", "admin.estoque.movimentacao.delete");

    // PESSOAS - FUNCIONARIOS
    $router->get("/pessoas/funcionarios", "Pessoas\\FuncionarioController:index", "admin.pessoas.funcionario.index");
    $router->get("/pessoas/funcionarios/novo", "Pessoas\\FuncionarioController:new", "admin.pessoas.funcionario.novo");
    $router->get("/pessoas/funcionarios/editar/{id}", "Pessoas\\FuncionarioController:edit", "admin.pessoas.funcionario.editar");
    $router->post("/pessoas/funcionarios/insert", "Pessoas\\FuncionarioController:create", "admin.pessoas.funcionario.insert");
    $router->post("/pessoas/funcionarios/update", "Pessoas\\FuncionarioController:update", "admin.pessoas.funcionario.update");
    $router->get("/pessoas/funcionarios/delete/{id}", "Pessoas\\FuncionarioController:delete", "admin.pessoas.funcionario.delete");

    // SANITARIO - PROTOCOLOS
    $router->get("/sanitario/protocolos", "Sanitario\\ProtocoloSanitarioController:index", "admin.sanitario.protocolo.index");
    $router->get("/sanitario/protocolos/novo", "Sanitario\\ProtocoloSanitarioController:new", "admin.sanitario.protocolo.novo");
    $router->get("/sanitario/protocolos/editar/{id}", "Sanitario\\ProtocoloSanitarioController:edit", "admin.sanitario.protocolo.editar");
    $router->post("/sanitario/protocolos/insert", "Sanitario\\ProtocoloSanitarioController:create", "admin.sanitario.protocolo.insert");
    $router->post("/sanitario/protocolos/update", "Sanitario\\ProtocoloSanitarioController:update", "admin.sanitario.protocolo.update");
    $router->get("/sanitario/protocolos/delete/{id}", "Sanitario\\ProtocoloSanitarioController:delete", "admin.sanitario.protocolo.delete");

    // SANITARIO - APLICACOES
    $router->get("/sanitario/aplicacoes", "Sanitario\\AplicacaoSanitariaController:index", "admin.sanitario.aplicacao.index");
    $router->get("/sanitario/aplicacoes/novo", "Sanitario\\AplicacaoSanitariaController:new", "admin.sanitario.aplicacao.novo");
    $router->get("/sanitario/aplicacoes/editar/{id}", "Sanitario\\AplicacaoSanitariaController:edit", "admin.sanitario.aplicacao.editar");
    $router->post("/sanitario/aplicacoes/insert", "Sanitario\\AplicacaoSanitariaController:create", "admin.sanitario.aplicacao.insert");
    $router->post("/sanitario/aplicacoes/update", "Sanitario\\AplicacaoSanitariaController:update", "admin.sanitario.aplicacao.update");
    $router->get("/sanitario/aplicacoes/delete/{id}", "Sanitario\\AplicacaoSanitariaController:delete", "admin.sanitario.aplicacao.delete");

    // SANITARIO - OCORRENCIAS
    $router->get("/sanitario/ocorrencias", "Sanitario\\OcorrenciaSanitariaController:index", "admin.sanitario.ocorrencia.index");
    $router->get("/sanitario/ocorrencias/novo", "Sanitario\\OcorrenciaSanitariaController:new", "admin.sanitario.ocorrencia.novo");
    $router->get("/sanitario/ocorrencias/editar/{id}", "Sanitario\\OcorrenciaSanitariaController:edit", "admin.sanitario.ocorrencia.editar");
    $router->post("/sanitario/ocorrencias/insert", "Sanitario\\OcorrenciaSanitariaController:create", "admin.sanitario.ocorrencia.insert");
    $router->post("/sanitario/ocorrencias/update", "Sanitario\\OcorrenciaSanitariaController:update", "admin.sanitario.ocorrencia.update");
    $router->get("/sanitario/ocorrencias/delete/{id}", "Sanitario\\OcorrenciaSanitariaController:delete", "admin.sanitario.ocorrencia.delete");

    // SANITARIO - TIPOS DE APLICACAO
    $router->get("/sanitario/tipos-aplicacao", "Sanitario\\TipoAplicacaoController:index", "admin.sanitario.tipo.aplicacao.index");
    $router->get("/sanitario/tipos-aplicacao/novo", "Sanitario\\TipoAplicacaoController:new", "admin.sanitario.tipo.aplicacao.novo");
    $router->get("/sanitario/tipos-aplicacao/editar/{id}", "Sanitario\\TipoAplicacaoController:edit", "admin.sanitario.tipo.aplicacao.editar");
    $router->post("/sanitario/tipos-aplicacao/insert", "Sanitario\\TipoAplicacaoController:create", "admin.sanitario.tipo.aplicacao.insert");
    $router->post("/sanitario/tipos-aplicacao/update", "Sanitario\\TipoAplicacaoController:update", "admin.sanitario.tipo.aplicacao.update");
    $router->get("/sanitario/tipos-aplicacao/delete/{id}", "Sanitario\\TipoAplicacaoController:delete", "admin.sanitario.tipo.aplicacao.delete");

    // SANITARIO - MOTIVOS DE TRATAMENTO
    $router->get("/sanitario/motivos-tratamento", "Sanitario\\MotivoTratamentoController:index", "admin.sanitario.motivo.tratamento.index");
    $router->get("/sanitario/motivos-tratamento/novo", "Sanitario\\MotivoTratamentoController:new", "admin.sanitario.motivo.tratamento.novo");
    $router->get("/sanitario/motivos-tratamento/editar/{id}", "Sanitario\\MotivoTratamentoController:edit", "admin.sanitario.motivo.tratamento.editar");
    $router->post("/sanitario/motivos-tratamento/insert", "Sanitario\\MotivoTratamentoController:create", "admin.sanitario.motivo.tratamento.insert");
    $router->post("/sanitario/motivos-tratamento/update", "Sanitario\\MotivoTratamentoController:update", "admin.sanitario.motivo.tratamento.update");
    $router->get("/sanitario/motivos-tratamento/delete/{id}", "Sanitario\\MotivoTratamentoController:delete", "admin.sanitario.motivo.tratamento.delete");

    // RELATORIOS
    $router->get("/relatorios/rentabilidade", "RelatorioController:rentabilidade", "admin.relatorio.rentabilidade");
    $router->get("/relatorios/evolucao-peso", "RelatorioController:evolucaoPeso", "admin.relatorio.evolucao.peso");
    $router->get("/relatorios/mortalidade", "RelatorioController:mortalidade", "admin.relatorio.mortalidade");
    $router->get("/relatorios/consumo-racao", "RelatorioController:consumoRacao", "admin.relatorio.consumo.racao");
    $router->get("/relatorios/eficiencia-trato", "RelatorioController:eficienciaTrato", "admin.relatorio.eficiencia.trato");
    $router->get("/relatorios/eficiencia-alimentar", "RelatorioController:eficienciaAlimentar", "admin.relatorio.eficiencia.alimentar");

    // FINANCEIRO - PLANO DE CONTAS
    $router->get("/financeiro/plano-conta", "Financeiro\\PlanoContaController:index", "admin.financeiro.plano.conta.index");
    $router->get("/financeiro/plano-conta/novo", "Financeiro\\PlanoContaController:new", "admin.financeiro.plano.conta.novo");
    $router->get("/financeiro/plano-conta/editar/{id}", "Financeiro\\PlanoContaController:edit", "admin.financeiro.plano.conta.editar");
    $router->post("/financeiro/plano-conta/insert", "Financeiro\\PlanoContaController:create", "admin.financeiro.plano.conta.insert");
    $router->post("/financeiro/plano-conta/update", "Financeiro\\PlanoContaController:update", "admin.financeiro.plano.conta.update");
    $router->get("/financeiro/plano-conta/delete/{id}", "Financeiro\\PlanoContaController:delete", "admin.financeiro.plano.conta.delete");

    // FINANCEIRO - CONTAS A PAGAR
    $router->get("/financeiro/conta-pagar", "Financeiro\\ContaPagarController:index", "admin.financeiro.conta.pagar.index");
    $router->get("/financeiro/conta-pagar/novo", "Financeiro\\ContaPagarController:new", "admin.financeiro.conta.pagar.novo");
    $router->get("/financeiro/conta-pagar/editar/{id}", "Financeiro\\ContaPagarController:edit", "admin.financeiro.conta.pagar.editar");
    $router->post("/financeiro/conta-pagar/insert", "Financeiro\\ContaPagarController:create", "admin.financeiro.conta.pagar.insert");
    $router->post("/financeiro/conta-pagar/update", "Financeiro\\ContaPagarController:update", "admin.financeiro.conta.pagar.update");
    $router->get("/financeiro/conta-pagar/delete/{id}", "Financeiro\\ContaPagarController:delete", "admin.financeiro.conta.pagar.delete");
    $router->post("/financeiro/conta-pagar/baixar", "Financeiro\\ContaPagarController:baixar", "admin.financeiro.conta.pagar.baixar");

    // FINANCEIRO - CONTAS A RECEBER
    $router->get("/financeiro/conta-receber", "Financeiro\\ContaReceberController:index", "admin.financeiro.conta.receber.index");
    $router->get("/financeiro/conta-receber/novo", "Financeiro\\ContaReceberController:new", "admin.financeiro.conta.receber.novo");
    $router->get("/financeiro/conta-receber/editar/{id}", "Financeiro\\ContaReceberController:edit", "admin.financeiro.conta.receber.editar");
    $router->post("/financeiro/conta-receber/insert", "Financeiro\\ContaReceberController:create", "admin.financeiro.conta.receber.insert");
    $router->post("/financeiro/conta-receber/update", "Financeiro\\ContaReceberController:update", "admin.financeiro.conta.receber.update");
    $router->get("/financeiro/conta-receber/delete/{id}", "Financeiro\\ContaReceberController:delete", "admin.financeiro.conta.receber.delete");
    $router->post("/financeiro/conta-receber/baixar", "Financeiro\\ContaReceberController:baixar", "admin.financeiro.conta.receber.baixar");

    // FINANCEIRO - RELATORIOS
    $router->get("/financeiro/relatorios/extrato", "Financeiro\\RelatorioFinanceiroController:extrato", "admin.financeiro.relatorio.extrato");
    $router->get("/financeiro/relatorios/fluxo-caixa", "Financeiro\\RelatorioFinanceiroController:fluxoCaixa", "admin.financeiro.relatorio.fluxo.caixa");
    $router->get("/financeiro/relatorios/dre", "Financeiro\\RelatorioFinanceiroController:dre", "admin.financeiro.relatorio.dre");

    // FORNECEDORES
    $router->get("/fornecedores", "FornecedorController:index", "admin.fornecedor.index");
    $router->get("/fornecedores/novo", "FornecedorController:new", "admin.fornecedor.novo");
    $router->get("/fornecedores/editar/{id}", "FornecedorController:edit", "admin.fornecedor.editar");
    $router->post("/fornecedores/importar/upload", "FornecedorController:importUpload", "admin.fornecedor.import.upload");
    $router->post("/fornecedores/find", "FornecedorController:find", "admin.fornecedor.find");
    $router->post("/fornecedores/insert", "FornecedorController:create", "admin.fornecedor.insert");
    $router->post("/fornecedores/update", "FornecedorController:update", "admin.fornecedor.update");
    $router->get("/fornecedores/delete/{id}", "FornecedorController:delete", "admin.fornecedor.deletar");

    // FORNECEDORES SITUAÇÕES
    $router->get("/fornecedores/situacoes", "FornecedorSituacaoController:index", "admin.fornecedor.situacao.index");
    $router->get("/fornecedores/situacoes/novo", "FornecedorSituacaoController:new", "admin.fornecedor.situacao.novo");
    $router->get("/fornecedores/situacoes/editar/{id}", "FornecedorSituacaoController:edit", "admin.fornecedor.situacao.editar");
    $router->post("/fornecedores/situacoes/insert", "FornecedorSituacaoController:create", "admin.fornecedor.situacao.insert");
    $router->post("/fornecedores/situacoes/update", "FornecedorSituacaoController:update", "admin.fornecedor.situacao.update");
    $router->get("/fornecedores/situacoes/delete/{id}", "FornecedorSituacaoController:delete", "admin.fornecedor.situacao.delete");

    // FORNECEDORES RAMOS
    $router->get("/fornecedores/ramos", "FornecedorRamoController:index", "admin.fornecedor.ramo.index");
    $router->get("/fornecedores/ramos/novo", "FornecedorRamoController:new", "admin.fornecedor.ramo.novo");
    $router->get("/fornecedores/ramos/editar/{id}", "FornecedorRamoController:edit", "admin.fornecedor.ramo.editar");
    $router->post("/fornecedores/ramos/insert", "FornecedorRamoController:create", "admin.fornecedor.ramo.insert");
    $router->post("/fornecedores/ramos/update", "FornecedorRamoController:update", "admin.fornecedor.ramo.update");
    $router->get("/fornecedores/ramos/delete/{id}", "FornecedorRamoController:delete", "admin.fornecedor.ramo.delete");
