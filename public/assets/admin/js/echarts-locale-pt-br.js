(function () {
    if (typeof echarts === "undefined") return;

    echarts.registerLocale("PT-BR", {
        time: {
            month: [
                "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
                "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
            ],
            monthAbbr: [
                "Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
                "Jul", "Ago", "Set", "Out", "Nov", "Dez"
            ],
            dayOfWeek: [
                "Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira",
                "Quinta-feira", "Sexta-feira", "Sábado"
            ],
            dayOfWeekAbbr: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
        },
        legend: {
            selector: {
                all: "Todos",
                inverse: "Inverter"
            }
        },
        toolbox: {
            brush: {
                title: {
                    rect: "Seleção retangular",
                    polygon: "Seleção livre",
                    lineX: "Selecionar horizontal",
                    lineY: "Selecionar vertical",
                    keep: "Manter seleção",
                    clear: "Limpar seleção"
                }
            },
            dataView: { title: "Ver dados", lang: ["Dados", "Fechar", "Atualizar"] },
            dataZoom: { title: { zoom: "Zoom", back: "Restaurar zoom" } },
            magicType: { title: { line: "Linha", bar: "Barra", stack: "Empilhado" } },
            restore: { title: "Restaurar" },
            saveAsImage: { title: "Salvar imagem" }
        },
        series: {
            typeNames: {
                pie: "Gráfico de pizza",
                bar: "Gráfico de barras",
                line: "Gráfico de linha",
                scatter: "Gráfico de dispersão"
            }
        },
        aria: {
            general: { withTitle: "Este é um gráfico sobre \"{title}\"", withoutTitle: "Este é um gráfico" }
        }
    });

    window.formatDataBr = function (value) {
        var d = new Date(value);
        var dia = String(d.getDate()).padStart(2, "0");
        var mes = String(d.getMonth() + 1).padStart(2, "0");
        var ano = d.getFullYear();
        var texto = dia + "/" + mes + "/" + ano;

        var temHora = d.getHours() !== 0 || d.getMinutes() !== 0 || d.getSeconds() !== 0;
        if (temHora) {
            var hora = String(d.getHours()).padStart(2, "0");
            var minuto = String(d.getMinutes()).padStart(2, "0");
            texto += " " + hora + ":" + minuto;
        }

        return texto;
    };
})();
