// Contas a Receber - form
(function () {
    var $form = $("#form-financeiro-conta-receber");
    if ($form.length) {
        var up = ($form.data("uppers") || "").split(",").map(function (v) { return v.trim(); });
        if (up.length) {
            $form.find("input, textarea").each(function () {
                var name = $(this).attr("name");
                if (name && up.indexOf(name) !== -1) {
                    $(this).on("blur", function () { this.value = this.value.toUpperCase(); });
                }
            });
        }
    }
})();
