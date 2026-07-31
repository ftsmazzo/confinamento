"use strict";

(function () {
    function initCategoriaProdutoForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-categoria-produto").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initCategoriaProdutoForm = initCategoriaProdutoForm;
    window.registerAjaxModalInitializer(initCategoriaProdutoForm);

    $(document).ready(function () {
        initCategoriaProdutoForm($(document));
    });
})();
