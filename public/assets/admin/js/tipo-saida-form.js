"use strict";

(function () {
    function initTipoSaidaForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-tipo-saida").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initTipoSaidaForm = initTipoSaidaForm;
    window.registerAjaxModalInitializer(initTipoSaidaForm);

    $(document).ready(function () {
        initTipoSaidaForm($(document));
    });
})();
