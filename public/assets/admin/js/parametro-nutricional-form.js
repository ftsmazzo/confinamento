"use strict";

(function () {
    function initParametroNutricionalForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-parametro-nutricional").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("nome,unidade_medida", $root);
    }

    window.initParametroNutricionalForm = initParametroNutricionalForm;
    window.registerAjaxModalInitializer(initParametroNutricionalForm);

    $(document).ready(function () {
        initParametroNutricionalForm($(document));
    });
})();
