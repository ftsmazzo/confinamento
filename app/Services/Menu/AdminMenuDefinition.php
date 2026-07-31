<?php
namespace App\Services\Menu;

use App\Core\Auth;
use App\Core\Router;

class AdminMenuDefinition extends AbstractMenuDefinition
{
    private Router $router;
    private Auth $auth;

    public function __construct(
        Router $router,
        Auth $auth
    ) {
        $this->router = $router;
        $this->auth = $auth;
    }

    public function items(): array
    {
        $clienteItems = array_values(array_filter([
            $this->link("clientes-clientes", "Clientes", "admin.cliente.index", [
                "permission" => "cliente_gerenciar",
            ]),
            $this->link("clientes-situacoes", "Situações", "admin.cliente.situacao.index", [
                "permission" => "cliente_situacao_gerenciar",
            ]),
        ]));

        $fornecedorItems = array_values(array_filter([
            $this->link("fornecedores-fornecedores", "Fornecedores", "admin.fornecedor.index", [
                "permission" => "fornecedor_gerenciar",
            ]),
            $this->link("fornecedores-situacoes", "Situações", "admin.fornecedor.situacao.index", [
                "permission" => "fornecedor_situacao_gerenciar",
            ]),
            $this->link("fornecedores-ramos", "Ramos", "admin.fornecedor.ramo.index", [
                "permission" => "fornecedor_ramo_gerenciar",
            ]),
        ]));

        $financeiroRelatoriosItems = array_values(array_filter([
            $this->link("relatorios-financeiro-extrato", "Extrato Financeiro", "admin.financeiro.relatorio.extrato", [
                "permission" => "relatorio_financeiro_visualizar",
            ]),
            $this->link("relatorios-financeiro-fluxo-caixa", "Fluxo de Caixa", "admin.financeiro.relatorio.fluxo.caixa", [
                "permission" => "relatorio_financeiro_visualizar",
            ]),
            $this->link("relatorios-financeiro-dre", "DRE Simplificado", "admin.financeiro.relatorio.dre", [
                "permission" => "relatorio_financeiro_visualizar",
            ]),
        ]));

        $confinamentoItems = array_values(array_filter([
            $this->link("confinamento-unidades", "Unidades", "admin.confinamento.unidade.index", [
                "permission" => "confinamento_unidade_gerenciar",
            ]),
            $this->link("confinamento-currais", "Currais", "admin.confinamento.curral.index", [
                "permission" => "confinamento_curral_gerenciar",
            ]),
            $this->link("confinamento-piquetes", "Piquetes", "admin.confinamento.piquete.index", [
                "permission" => "confinamento_piquete_gerenciar",
            ]),
            $this->link("confinamento-centros-custo", "Centros de Custo", "admin.confinamento.centro.custo.index", [
                "permission" => "centro_custo_gerenciar",
            ]),
        ]));

        $manejoCadastrosItems = array_values(array_filter([
            $this->link("manejo-animais", "Animais", "admin.manejo.animal.index", [
                "permission" => "animal_gerenciar",
            ]),
            $this->link("manejo-situacoes-animal", "Situações do Animal", "admin.manejo.animal.situacao.index", [
                "permission" => "animal_situacao_gerenciar",
            ]),
            $this->link("manejo-lotes", "Lotes", "admin.manejo.lote.index", [
                "permission" => "lote_gerenciar",
            ]),
            $this->link("manejo-tipos-entrada", "Tipos de Entrada", "admin.manejo.tipo.entrada.index", [
                "permission" => "tipo_entrada_gerenciar",
            ]),
            $this->link("manejo-tipos-saida", "Tipos de Saída", "admin.manejo.tipo.saida.index", [
                "permission" => "tipo_saida_gerenciar",
            ]),
            $this->link("manejo-motivos-perda", "Motivos de Perda", "admin.manejo.motivo.perda.index", [
                "permission" => "motivo_perda_gerenciar",
            ]),
        ]));

        $movimentacoesItems = array_values(array_filter([
            $this->link("manejo-entradas", "Entradas", "admin.manejo.entrada.index", [
                "permission" => "entrada_gerenciar",
            ]),
            $this->link("manejo-localizacoes", "Localizações", "admin.manejo.localizacao.index", [
                "permission" => "localizacao_gerenciar",
            ]),
            $this->link("manejo-pesagens", "Pesagens", "admin.manejo.pesagem.index", [
                "permission" => "pesagem_gerenciar",
            ]),
            $this->link("manejo-trocas-dieta", "Trocas de Dieta", "admin.manejo.troca.dieta.index", [
                "permission" => "troca_dieta_gerenciar",
            ]),
            $this->link("manejo-saidas", "Saídas", "admin.manejo.saida.index", [
                "permission" => "saida_gerenciar",
            ]),
            $this->link("manejo-mortalidades", "Mortalidade / Perda", "admin.manejo.mortalidade.index", [
                "permission" => "mortalidade_gerenciar",
            ]),
            $this->link("manejo-ocorrencias", "Ocorrências", "admin.manejo.ocorrencia.index", [
                "permission" => "ocorrencia_gerenciar",
            ]),
        ]));

        $nutricaoCadastrosItems = array_values(array_filter([
            $this->link("nutricao-grupos-ingrediente", "Grupos de Ingredientes", "admin.nutricao.grupo.ingrediente.index", [
                "permission" => "grupo_ingrediente_gerenciar",
            ]),
            $this->link("nutricao-ingredientes", "Ingredientes", "admin.nutricao.ingrediente.index", [
                "permission" => "ingrediente_gerenciar",
            ]),
            $this->link("nutricao-fases-nutricionais", "Fases Nutricionais", "admin.nutricao.fase.nutricional.index", [
                "permission" => "fase_nutricional_gerenciar",
            ]),
            $this->link("nutricao-tipos-dieta", "Tipos de Dieta", "admin.nutricao.tipo.dieta.index", [
                "permission" => "tipo_dieta_gerenciar",
            ]),
            $this->link("nutricao-parametros-nutricionais", "Parâmetros Nutricionais", "admin.nutricao.parametro.nutricional.index", [
                "permission" => "parametro_nutricional_gerenciar",
            ]),
            $this->link("nutricao-formulas-racao", "Fórmulas de Ração", "admin.nutricao.formula.racao.index", [
                "permission" => "formula_racao_gerenciar",
            ]),
        ]));

        $nutricaoTratoItems = array_values(array_filter([
            $this->link("nutricao-confeccoes-racao", "Confecção de Ração", "admin.nutricao.confeccao.racao.index", [
                "permission" => "confeccao_racao_gerenciar",
            ]),
            $this->link("nutricao-programacoes-trato", "Programação de Trato", "admin.nutricao.programacao.trato.index", [
                "permission" => "programacao_trato_gerenciar",
            ]),
            $this->link("nutricao-parametros-trato", "Parâmetros do Trato", "admin.nutricao.parametro.trato.editar", [
                "permission" => "programacao_trato_gerenciar",
            ]),
            $this->link("nutricao-fornecimentos-trato", "Fornecimento de Trato", "admin.nutricao.fornecimento.trato.index", [
                "permission" => "fornecimento_trato_gerenciar",
            ]),
            $this->link("nutricao-leituras-cocho", "Leitura de Cocho", "admin.nutricao.leitura.cocho.index", [
                "permission" => "leitura_cocho_gerenciar",
            ]),
            $this->link("nutricao-ajustes-consumo", "Ajuste de Consumo", "admin.nutricao.ajuste.consumo.index", [
                "permission" => "ajuste_consumo_gerenciar",
            ]),
        ]));

        $estoqueItems = array_values(array_filter([
            $this->link("estoque-produtos", "Produtos de Estoque", "admin.estoque.produto.index", [
                "permission" => "produto_estoque_gerenciar",
            ]),
            $this->link("estoque-categorias-produto", "Categorias de Produto", "admin.estoque.categoria.produto.index", [
                "permission" => "categoria_produto_gerenciar",
            ]),
            $this->link("confinamento-locais-estoque", "Locais de Estoque", "admin.confinamento.local.estoque.index", [
                "permission" => "confinamento_local_estoque_gerenciar",
            ]),
            $this->link("estoque-locais-armazenagem-interno", "Locais de Armazenagem", "admin.estoque.local.armazenagem.interno.index", [
                "permission" => "local_armazenagem_interno_gerenciar",
            ]),
            $this->link("estoque-tipos-movimentacao", "Tipos de Movimentação", "admin.estoque.tipo.movimentacao.index", [
                "permission" => "tipo_movimentacao_estoque_gerenciar",
            ]),
            $this->link("estoque-movimentacoes", "Movimentações", "admin.estoque.movimentacao.index", [
                "permission" => "movimentacao_estoque_gerenciar",
            ]),
        ]));

        $pessoasItems = array_values(array_filter([
            $this->link("pessoas-funcionarios", "Funcionários", "admin.pessoas.funcionario.index", [
                "permission" => "funcionario_gerenciar",
            ]),
        ]));

        $sanitarioCadastrosItems = array_values(array_filter([
            $this->link("sanitario-medicamentos-vacinas", "Medicamentos e Vacinas", "admin.estoque.produto.index", [
                "permission" => "produto_estoque_gerenciar",
                "route_params" => ["sanitarios" => 1],
            ]),
            $this->link("sanitario-tipos-aplicacao", "Tipos de Aplicação", "admin.sanitario.tipo.aplicacao.index", [
                "permission" => "tipo_aplicacao_gerenciar",
            ]),
            $this->link("sanitario-motivos-tratamento", "Motivos de Tratamento", "admin.sanitario.motivo.tratamento.index", [
                "permission" => "motivo_tratamento_gerenciar",
            ]),
        ]));

        $sanitarioItems = array_values(array_filter([
            $this->link("sanitario-protocolos", "Protocolos Sanitários", "admin.sanitario.protocolo.index", [
                "permission" => "protocolo_sanitario_gerenciar",
            ]),
            $this->link("sanitario-aplicacoes", "Aplicações Sanitárias", "admin.sanitario.aplicacao.index", [
                "permission" => "aplicacao_sanitaria_gerenciar",
            ]),
            $this->link("sanitario-ocorrencias", "Ocorrências Sanitárias", "admin.sanitario.ocorrencia.index", [
                "permission" => "ocorrencia_sanitaria_gerenciar",
            ]),
        ]));

        $relatorioItems = array_values(array_filter([
            $this->link("relatorios-rentabilidade", "Rentabilidade por Lote", "admin.relatorio.rentabilidade", [
                "permission" => "relatorio_rentabilidade_visualizar",
            ]),
            $this->link("relatorios-evolucao-peso", "Evolução de Peso / GMD", "admin.relatorio.evolucao.peso", [
                "permission" => "relatorio_evolucao_peso_visualizar",
            ]),
            $this->link("relatorios-mortalidade", "Mortalidade / Perdas", "admin.relatorio.mortalidade", [
                "permission" => "relatorio_mortalidade_visualizar",
            ]),
            $this->link("relatorios-consumo-racao", "Consumo de Ração", "admin.relatorio.consumo.racao", [
                "permission" => "relatorio_consumo_racao_visualizar",
            ]),
            $this->link("relatorios-eficiencia-trato", "Eficiência de Trato", "admin.relatorio.eficiencia.trato", [
                "permission" => "relatorio_eficiencia_trato_visualizar",
            ]),
            $this->link("relatorios-eficiencia-alimentar", "Eficiência Alimentar", "admin.relatorio.eficiencia.alimentar", [
                "permission" => "relatorio_eficiencia_alimentar_visualizar",
            ]),
        ]));

        return array_values(array_filter([
            $this->link("painel", "Painel", "admin.home", [
                "icon" => "uil-dashboard",
            ]),
            $this->link("calendario", "Calendário", "admin.calendario.index", [
                "icon" => "uil uil-calendar-alt",
                "permission" => "calendario_visualizar",
            ]),
            !empty($relatorioItems) ? $this->drop("relatorios", "Relatórios", $relatorioItems, [
                "icon" => "uil uil-chart-growth",
            ]) : null,
            $this->title("Pessoas"),
            !empty($clienteItems) ? $this->drop("pessoas-clientes", "Clientes", $clienteItems, [
                "icon" => "uil uil-user-check",
            ]) : null,
            !empty($fornecedorItems) ? $this->drop("pessoas-fornecedores", "Fornecedores", $fornecedorItems, [
                "icon" => "uil uil-truck",
            ]) : null,
            !empty($pessoasItems) ? $this->drop("pessoas-funcionarios", "Pessoas", $pessoasItems, [
                "icon" => "uil uil-user",
            ]) : null,
            $this->title("Financeiro"),
            $this->link("financeiro-contas-pagar", "Contas a Pagar", "admin.financeiro.conta.pagar.index", [
                "icon" => "uil uil-arrow-down-left",
                "permission" => "conta_pagar_gerenciar",
            ]),
            $this->link("financeiro-contas-receber", "Contas a Receber", "admin.financeiro.conta.receber.index", [
                "icon" => "uil uil-arrow-up-right",
                "permission" => "conta_receber_gerenciar",
            ]),
            $this->link("financeiro-plano-contas", "Plano de Contas", "admin.financeiro.plano.conta.index", [
                "icon" => "uil uil-book-open",
                "permission" => "plano_conta_gerenciar",
            ]),
            !empty($financeiroRelatoriosItems) ? $this->drop("financeiro-relatorios", "Relatórios", $financeiroRelatoriosItems, [
                "icon" => "uil uil-chart",
            ]) : null,
            !empty($confinamentoItems) ? $this->title("Confinamento") : null,
            !empty($confinamentoItems) ? $this->drop("confinamento", "Confinamento", $confinamentoItems, [
                "icon" => "fa-solid fa-cow",
            ]) : null,
            (!empty($manejoCadastrosItems) || !empty($movimentacoesItems)) ? $this->title("Manejo") : null,
            !empty($manejoCadastrosItems) ? $this->drop("manejo", "Cadastros", $manejoCadastrosItems, [
                "icon" => "ti ti-list-details",
            ]) : null,
            !empty($movimentacoesItems) ? $this->drop("movimentacoes", "Movimentações", $movimentacoesItems, [
                "icon" => "ti ti-arrows-shuffle",
            ]) : null,
            (!empty($nutricaoCadastrosItems) || !empty($nutricaoTratoItems)) ? $this->title("Nutrição") : null,
            !empty($nutricaoCadastrosItems) ? $this->drop("nutricao-cadastros", "Cadastros", $nutricaoCadastrosItems, [
                "icon" => "uil uil-list-ul",
            ]) : null,
            !empty($nutricaoTratoItems) ? $this->drop("nutricao-trato", "Trato e Cocho", $nutricaoTratoItems, [
                "icon" => "uil uil-restaurant",
            ]) : null,
            (!empty($sanitarioCadastrosItems) || !empty($sanitarioItems)) ? $this->title("Sanitário") : null,
            !empty($sanitarioCadastrosItems) ? $this->drop("sanitario-cadastros", "Cadastros", $sanitarioCadastrosItems, [
                "icon" => "uil uil-list-ul",
            ]) : null,
            !empty($sanitarioItems) ? $this->drop("sanitario", "Sanitário", $sanitarioItems, [
                "icon" => "ti ti-vaccine",
            ]) : null,
            !empty($estoqueItems) ? $this->title("Estoque") : null,
            !empty($estoqueItems) ? $this->drop("estoque", "Estoque", $estoqueItems, [
                "icon" => "uil uil-box",
            ]) : null,
            $this->title("Usuários"),
            $this->drop("usuarios", "Usuários", [
                $this->link("usuarios-usuarios", "Usuários", "admin.usuario.index", [
                    "permission" => "usuario_gerenciar",
                ]),
                $this->link("usuarios-perfis", "Perfis de Acesso", "admin.perfil.index", [
                    "permission" => "usuario_permissoes",
                ]),
            ], [
                "icon" => "uil-user",
            ]),
            $this->link("senha", "Alterar Senha", "admin.pass", [
                "icon" => "uil-lock-alt",
            ]),
            $this->link("logout", "Sair do Sistema", "admin.logout", [
                "icon" => "uil uil-signout",
                "extra" => fn () => 'data-logoff="' . $this->router->route($this->auth->getRouteLogout()) . '"',
            ]),
        ]));
    }
}
