"use strict";

(function () {
    function initTipoEntradaForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-tipo-entrada").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initTipoEntradaForm = initTipoEntradaForm;
    window.registerAjaxModalInitializer(initTipoEntradaForm);

    $(document).ready(function () {
        initTipoEntradaForm($(document));
    });
})();
