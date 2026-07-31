"use strict";

(function () {
    function initMotivoTratamentoForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-motivo-tratamento").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initMotivoTratamentoForm = initMotivoTratamentoForm;
    window.registerAjaxModalInitializer(initMotivoTratamentoForm);

    $(document).ready(function () {
        initMotivoTratamentoForm($(document));
    });
})();
