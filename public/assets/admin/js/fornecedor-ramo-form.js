"use strict";

// Formulario de ramo de fornecedor carregado via modal AJAX.
// O util.js abre o modal e, quando o HTML chega, dispara os inicializadores
// registrados em window.ajaxModalInitializers.
(function () {
    function initFornecedorRamoForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-fornecedor-ramo").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initFornecedorRamoForm = initFornecedorRamoForm;
    window.registerAjaxModalInitializer(initFornecedorRamoForm);

    $(document).ready(function () {
        initFornecedorRamoForm($(document));
    });
})();
