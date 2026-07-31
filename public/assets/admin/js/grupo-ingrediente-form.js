"use strict";

(function () {
    function initGrupoIngredienteForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-grupo-ingrediente").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initGrupoIngredienteForm = initGrupoIngredienteForm;
    window.registerAjaxModalInitializer(initGrupoIngredienteForm);

    $(document).ready(function () {
        initGrupoIngredienteForm($(document));
    });
})();
