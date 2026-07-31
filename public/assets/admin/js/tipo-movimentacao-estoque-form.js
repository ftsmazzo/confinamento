"use strict";

(function () {
    function initTipoMovimentacaoEstoqueForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-tipo-movimentacao-estoque").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initTipoMovimentacaoEstoqueForm = initTipoMovimentacaoEstoqueForm;
    window.registerAjaxModalInitializer(initTipoMovimentacaoEstoqueForm);

    $(document).ready(function () {
        initTipoMovimentacaoEstoqueForm($(document));
    });
})();
