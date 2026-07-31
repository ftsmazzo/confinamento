"use strict";

(function () {
    function initAnimalSituacaoForm($scope) {
        const $root = $scope && $scope.length ? $scope : $(document);
        const $form = $root.find("#form-animal-situacao").first();

        if (!$form.length || $form.data("ajaxFormBound")) {
            return;
        }

        $form.data("ajaxFormBound", true);

        uppers("descricao", $root);
    }

    window.initAnimalSituacaoForm = initAnimalSituacaoForm;
    window.registerAjaxModalInitializer(initAnimalSituacaoForm);

    $(document).ready(function () {
        initAnimalSituacaoForm($(document));
    });
})();
