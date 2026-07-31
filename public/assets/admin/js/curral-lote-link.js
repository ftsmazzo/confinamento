"use strict";

/**
 * E11 — amarra lote ↔ curral nos formulários operacionais.
 * Curral com data-id-lote (único lote ativo) preenche o lote;
 * lote com data-id-curral preenche o curral.
 */
(function () {
    function setSelectValue($select, value) {
        if (!$select.length || value === undefined || value === null || value === "") {
            return;
        }
        const next = String(value);
        if ($select.find('option[value="' + next.replace(/"/g, '\\"') + '"]').length === 0) {
            return;
        }
        if (String($select.val()) === next) {
            return;
        }
        $select.val(next).trigger("change");
    }

    function bindCurralLote($form, curralSelector, loteSelector) {
        const $curral = $form.find(curralSelector).first();
        const $lote = $form.find(loteSelector).filter("select").first();

        if (!$curral.length || !$lote.length || $form.data("curralLoteBound")) {
            return;
        }

        $form.data("curralLoteBound", true);
        let syncing = false;

        function fromCurral() {
            if (syncing) {
                return;
            }
            const idLote = $curral.find("option:selected").attr("data-id-lote");
            if (!idLote) {
                return;
            }
            syncing = true;
            setSelectValue($lote, idLote);
            syncing = false;
        }

        function fromLote() {
            if (syncing) {
                return;
            }
            const idCurral = $lote.find("option:selected").attr("data-id-curral");
            if (!idCurral) {
                return;
            }
            syncing = true;
            setSelectValue($curral, idCurral);
            syncing = false;
        }

        $curral.on("change", fromCurral);
        $lote.on("change", fromLote);

        // Estado inicial: se curral já veio preenchido, puxa lote (e vice-versa).
        if ($curral.val()) {
            fromCurral();
        } else if ($lote.val()) {
            fromLote();
        }
    }

    function initCurralLoteLink($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);

        $root.find("#form-nutricao-leitura-cocho").each(function () {
            bindCurralLote($(this), "#id_curral", "#id_lote");
        });
        $root.find("#form-nutricao-fornecimento-trato").each(function () {
            bindCurralLote($(this), "#id_curral", "#id_lote");
        });
        $root.find("#form-nutricao-programacao-trato").each(function () {
            bindCurralLote($(this), "#id_curral", "#id_lote");
        });
        $root.find("#form-manejo-entrada").each(function () {
            bindCurralLote($(this), "#id_curral_destino", "#id_lote");
        });
    }

    window.initCurralLoteLink = initCurralLoteLink;

    $(document).ready(function () {
        initCurralLoteLink($(document));
    });
})();
