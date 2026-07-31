"use strict";

// Formulario de situacao de fornecedor carregado via modal AJAX.
// O util.js abre o modal e, quando o HTML chega, dispara os inicializadores
// registrados em window.ajaxModalInitializers.
(function () {
    function initFornecedorSituacaoForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-fornecedor-situacao").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initFornecedorSituacaoForm = initFornecedorSituacaoForm;
    window.registerAjaxModalInitializer(initFornecedorSituacaoForm);

    $(document).ready(function () {
        initFornecedorSituacaoForm($(document));
    });
})();
