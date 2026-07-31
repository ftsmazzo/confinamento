(function ( $ ) {

    $.fn.dizuploader = function( options ) {

        // Opções Padrão
        var settings = $.extend({
            extensions : this.data("extensions") ? this.data("extensions").split(/[\s,]+/).map(ext => ext.toLowerCase()) : ["*"],
            dropBody   : false, // Confirma se os arquivos serão soltos no "body"
            caption    : "Arraste e solte os arquivos. Ou clique para carregar", // Mensagem da caixa de upload
        }, options);

        // Atributos do elemento
        var id = this.attr("id");;
        var name = this.attr("name");
        var multiple = this.attr("multiple");
        var required = this.attr("required");
        var form = this.closest("form");

        // Montar caixa com elementos
        var wrap = '<div class="dizuploader">'+
            '<input type="file" '+(id?'id="'+id+'"':'')+' '+(name?'name="'+name+'"':'')+' '+(multiple?'multiple':'')+' '+(required?'required':'')+'>'+
            '<label for="dizuploader__files" class="open">'+
                '<i class="fas fa-cloud-upload-alt fa-2x"></i>'+
                '<span>Clique aqui para escolher os arquivos</span>'+
                '<small class="dizuploader__count"></small>'+
                '<div><button type="button" class="dizuploader__clearfiles"><i class="fa fa-times"></i> Remover arquivos</button></div>'+
            '</label>'+
            '<div class="dizuploader__list"></div>'+
        '</div>';

        // Input file (Id se torna obrigatório)
        var idEl = this.attr("id");

        // Remover input e colocar caixa no lugar
        this.parent().prepend(wrap);
        this.remove();

        // variaveis fixas
        var inputEl = $("#" + idEl);
        var boxEl   = inputEl.parent();

        var countEl = boxEl.find(".dizuploader__count");
        var listEl  = boxEl.find(".dizuploader__list");
        var clearEl = boxEl.find(".dizuploader__clearfiles");
        var labelEl = boxEl.find("label[for=dizuploader__files]");

        var hoverClass = "dizuploader__dragover";

        var invalid = 0;
        var totalFiles = 0;

        // Verificar se navegador suporte "Arraste e Solte"
        var isDraggable = function() {
            var div = document.createElement('div');
            var isDrag = (('draggable' in div) || ('ondragstart' in div && 'ondrop' in div)) && 'FormData' in window && 'FileReader' in window;
            return isDrag && multiple;
        }();

        if (isDraggable) {

            // Box fake
            var uploaderEl = boxEl;
            // Elemento onde soltará os arquivos
            var target = settings.dropBody ? $("body") : uploaderEl;

            // Adicionar eventos
            target.on("drag dragstart dragend dragover dragenter dragleave drop", function (e) {
                e.preventDefault();
                e.stopPropagation();
            })

            // Adicionar a classe ao sobrepor
            target.on("dragover dragenter", function(e)  {
                uploaderEl.addClass(hoverClass);
            });

            // Remover a classe ao sair, terminar o arraste ou soltar
            target.on("dragleave dragend drop", function(e) {
                uploaderEl.removeClass(hoverClass)
            });

            // Evento a soltar os arquivos
            target.on('drop', function(e) {

                if (e.originalEvent.dataTransfer && e.originalEvent.dataTransfer.files.length) {

                    droppedFiles = e.originalEvent.dataTransfer.files;

                    // Setar arquivos para o input
                    inputEl.files = droppedFiles

                    // Mostra arquivos selecionados em uma lista
                    showFiles(droppedFiles);
                }
            });

            uploaderEl.find("span").html(settings.caption);
        }

        // Abrir Caixa de dialogo do input pelo label
        labelEl.not("button").click(function(e) {

            var t = e.target.type;

            if (t!="button") {

                // Disparar Evento Click no Input
                inputEl.click();

                // Ao clicar no botão de arquivo
                inputEl.on("change", function(e) {

                    // Pegando arquivos escolhidos
                    changedFiles = e.target.files;

                    // countFiles(changedFiles.length?changedFiles.length:0, null);
                    showFiles(changedFiles);
                });
            }

        });


        // Limpar Arquivos
        clearEl.on("click", function(e) {
            countFiles(0);
        });

        // Validar o Formulário com jQuery Validate
        var btn_submit = form.find("button[type=submit]");
        btn_submit.click(function (e) {

            e.preventDefault();

            if (form.valid()) {

                max_files = inputEl.data("max");

                if (invalid>0) {

                    msg_error = invalid+" "+(invalid>1?"arquivos":"arquivo")+" com a extensão inválida.  Extensões permitidas: "+settings.extensions.join(", ");
                    inputEl.parent().append("<label class=\"dizuploader__error__files has-error\">"+msg_error+"</label>");

                } else if (max_files>0 && totalFiles>max_files) {

                    msg_error = "Você pode enviar apenas "+max_files+' arquivos.';
                    inputEl.parent().append("<label class=\"dizuploader__error__files has-error\">"+msg_error+"</label>");

                } else {

                    $("label.dizuploader__error__files").remove();

                    // Submeter Formulário
                    loadingButton(btn_submit);
                    form.submit();
                }

            }
        });


        // Mostrar arquivos na lista
        function showFiles(files) {

            // Zerando número de arquivos inválidos
            invalid = 0;
            total = 0;

            // Limpar arquivos da lista
            clearList();

            // Remover Mensagem do Validate
            $(".dizuploader__error__files ").html("").remove();

            // Percorre todos os arquivos
            for (var i = 0; i < files.length; i++) {

                // Pegar extensão do arquivo
                ext = getExtension(files[i].name);

                // Verificar se extensão é permitida
                if (settings.extensions.includes('*') || settings.extensions.includes(ext)) {
                    // Mostrar arquivo na lista
                    showLine(i, files[i], ext);
                    total += files[i].size;
                } else {
                    invalid++;
                    showLineError(files[i], ext);
                }
            }

            countFiles(files.length, total);
        }

        function getExtension(path) {
            var basename = path.split(/[\\/]/).pop(),
                pos = basename.lastIndexOf(".");

            if (basename === "" || pos < 1) return "";

            return basename.slice(pos + 1).toLowerCase(); // Garantir que a extensão esteja em minúsculas
        }

        function showLine(index, file, ext) {

            var images = ["jpg", "jpeg", "bmp", "gif", "png", "apng", "jfif", "svg"];

            var deleteButton = '<button type="button" class="dizuploader__delete" data-index="'+ index +'"><i class="uil uil-times"></i></button>';

            if (images.includes(ext)) {

                // listEl.prepend("<div class=\"line border-top\" data-id=\""+index+"\">"+
                //         "<img src=\""+URL.createObjectURL(file)+"\">"+
                //         "<div>"+
                //             "<strong>"+file.name+"</strong><br>"+
                //             "<small>"+(Math.ceil(file.size/1024))+"KB</small>"+
                //         "</div>"+
                //     "</div>"
                // );

                listEl.prepend("<div class=\"line border-top\" data-id=\"" + index + "\">" +
                    "<img src=\"" + URL.createObjectURL(file) + "\">" +
                    "<div>" +
                        "<strong>" + file.name + "</strong><br>" +
                        "<small>" + (Math.ceil(file.size / 1024)) + "KB</small>" +
                        deleteButton + // Adiciona o botão de excluir
                    "</div>" +
                    "</div>"
                );

            } else {

                // Arquivos para mostrar ícones (Font-Awesome)
                var icons = {
                    pdf  : 'fas fa-file-pdf',
                    doc  : 'fas fa-file-word',
                    docx : 'fas fa-file-word',
                    xls  : 'fas fa-file-excel',
                    xlsx : 'fas fa-file-excel',
                    ppt  : 'fas fa-file-powerpoint',
                    pptx : 'fas fa-file-powerpoint',
                    pps  : 'fas fa-file-powerpoint',
                    ppsx : 'fas fa-file-powerpoint',
                    mp3  : 'fas fa-file-audio',
                    ogg  : 'fas fa-file-audio',
                    wma  : 'fas fa-file-audio',
                    zip  : 'fas fa-file-archive',
                    rar  : 'fas fa-file-archive',
                    csv  : 'fas fa-file-csv',
                    txt  : 'fas fa-file-alt',
                };

                if (typeof icons[ext] !== "undefined" ) {

                    icon = icons[ext];

                } else {

                    icon = 'fas fa-file';
                }

                size = Math.ceil(file.size/1024);
                if (size > 1024) {
                    size = Math.ceil(size/1024) + " MB";
                } else {
                    size += " KB";
                }

                listEl.prepend("<div class=\"line bg-light border-top\" data-id=\""+index+"\">"+
                        "<i class=\"" + icon + " fa-2x me-3\"></i>"+
                        "<div>"+
                            "<strong>"+file.name+"</strong><br>"+
                            "<small>"+size+"</small>"+
                        "</div>"+
                    "</div>"
                );
            }

        }

        function showLineError(file, ext) {

            listEl.prepend("<div class=\"line error border-top \">"+
                    "O arquivo <strong>"+file.name+"</strong> não pode ser adicionado<br>"+
                    "<small>Extensão "+ext+" inválida</small>"+
                "</div>"
            );
        }

        function countFiles(n, total)
        {
            boxEl.removeClass("dizuploader__error");

            total = Math.ceil(total/1024);
            if (total > 1024) {
                total = Math.ceil(total/1024) + " MB";
            } else {
                total += " KB";
            }

            if (n==0) {
                clearList();
                countEl.html("");
                clearEl.hide();
            }
            else if (n==1) {
                countEl.html("Foi selecionado 1 arquivo. Total de "+total);
                clearEl.show();
            }
            else {
                countEl.html("Foram selecionados "+n+" arquivos. Total de "+total);
                clearEl.show();
            }

            totalFiles = n;
        }

        function clearList() {

            listEl.html("");

            // Remover Mensagem do Validate
            $(".dizuploader__error__files ").html("").remove();
        }

        return this;

    };

}( jQuery ));
