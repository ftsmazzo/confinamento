"use strict";

/**
 * E11 — amarra lote ↔ curral nos formulários operacionais.
 * Estratégia principal: achar o lote cuja option tem data-id-curral = curral escolhido.
 * Fallback: data-id-lote na option do curral (quando há um único lote ativo).
 */
(function () {
    function setSelectValue($select, value) {
        if (!$select.length || value === undefined || value === null || value === "") {
            return;
        }
        const next = String(value);
        if ($select.find('option[value="' + next.replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '"]').length === 0) {
            return;
        }
        if (String($select.val() || "") === next) {
            return;
        }
        $select.val(next).trigger("change");
    }

    function loteIdForCurral($lote, idCurral, $curralOpt) {
        if (!idCurral) {
            return "";
        }
        const matches = [];
        $lote.find("option").each(function () {
            const cid = String($(this).attr("data-id-curral") || "");
            if (cid && cid === String(idCurral) && this.value) {
                matches.push(String(this.value));
            }
        });
        if (matches.length === 1) {
            return matches[0];
        }
        // Fallback: atributo no curral (quando o PHP já resolveu o lote único)
        const fromCurral = $curralOpt && $curralOpt.attr("data-id-lote");
        return fromCurral ? String(fromCurral) : "";
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
            const idCurral = $curral.val();
            const $opt = $curral.find("option:selected");
            const idLote = loteIdForCurral($lote, idCurral, $opt);
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

        // Select2 dispara select2:select; change cobre select nativo
        $curral.on("change select2:select", fromCurral);
        $lote.on("change select2:select", fromLote);

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

    $(function () {
        initCurralLoteLink($(document));
    });
})();
