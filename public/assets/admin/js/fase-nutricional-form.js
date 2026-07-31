"use strict";

(function () {
    function initFaseNutricionalForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-fase-nutricional").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initFaseNutricionalForm = initFaseNutricionalForm;
    window.registerAjaxModalInitializer(initFaseNutricionalForm);

    $(document).ready(function () {
        initFaseNutricionalForm($(document));
    });
})();
