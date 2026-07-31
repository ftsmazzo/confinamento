"use strict";

(function () {
    function initTipoDietaForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-tipo-dieta").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initTipoDietaForm = initTipoDietaForm;
    window.registerAjaxModalInitializer(initTipoDietaForm);

    $(document).ready(function () {
        initTipoDietaForm($(document));
    });
})();
