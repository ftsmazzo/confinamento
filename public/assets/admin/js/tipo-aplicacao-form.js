"use strict";

(function () {
    function initTipoAplicacaoForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-tipo-aplicacao").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initTipoAplicacaoForm = initTipoAplicacaoForm;
    window.registerAjaxModalInitializer(initTipoAplicacaoForm);

    $(document).ready(function () {
        initTipoAplicacaoForm($(document));
    });
})();
