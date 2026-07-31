"use strict";

(function () {
    function initMotivoPerdaForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-motivo-perda").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initMotivoPerdaForm = initMotivoPerdaForm;
    window.registerAjaxModalInitializer(initMotivoPerdaForm);

    $(document).ready(function () {
        initMotivoPerdaForm($(document));
    });
})();
