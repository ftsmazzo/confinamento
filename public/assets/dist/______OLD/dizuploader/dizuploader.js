(function ( $ ) {

    $.fn.dizuploader = function( options ) {

        // Opções Padrão
        var settings = $.extend({
            extensions : this.data("extensions") ? this.data("extensions").split(/[\s,]+/).map(ext => ext.toLowerCase()) : ["*"], // Extensões permitidas
            maxFiles   : this.data("max-files") ? this.data("max-files") : false,
            maxSize    : this.data("max-size") ? this.data("max-size") : false,
            dropBody   : false, // Arquivos podem ser soltos no body
            caption    : "Arraste e solte os arquivos. Ou clique para carregar", // Mensagem da caixa de upload
            ajaxUpload : false, // Define se o upload será feito via AJAX
            uploadUrl  : "/upload", // URL do endpoint para upload (usado somente para AJAX)
            ajaxMethod : 'POST',
            onFileUploadSuccess: function(file) {}, // Callback quando um arquivo é carregado com sucesso
            onFileUploadError: function(file) {}, // Callback quando o upload de um arquivo falha
            onAllFilesUploaded: function() {} // Callback quando todos os arquivos foram carregados
        }, options);

        // Atributos do elemento
        var id = this.attr("id");
        var name = this.attr("name");
        var multiple = this.attr("multiple");
        var required = this.attr("required");

        // Adiciona a regra de extensão ao input de arquivo se jQuery Validate estiver presente
        var extensionData = '';
        if ($.fn.validate && settings.extensions[0] !== "*") {
            var extensionsRule = settings.extensions.join('|'); // Converte as extensões para uma string separada por |
            var extensionsMsg = "Alguma(s) extensões não são permitidas. Apenas " + settings.extensions.join(', '); // Mensagem personalizada
            var extensionData = 'data-rule-extension="' + extensionsRule + '" data-msg-extension="' + extensionsMsg + '"';
        }

        // Montar caixa com elementos
        var wrap = '<div class="dizuploader' + (settings.ajaxUpload ? ' ajax-upload' : '') + '">'+
            '<input type="file" '+(id ? 'id="'+id+'"' : '')+' '+(name ? 'name="'+name+'"' : '')+' '+(multiple ? 'multiple' : '')+' '+(required ? 'required' : '')+' '+extensionData+'>'+
            '<label for="dizuploader__files" class="open">' +
                '<i class="fas fa-cloud-upload-alt fa-2x"></i>' +
                '<span>' + settings.caption + '</span>' +
                '<small class="dizuploader__count"></small>' +
                '<div><button type="button" class="dizuploader__clearfiles">✕ Remover todos os arquivos</button></div>' +
            '</label>' +
            '<div class="dizuploader__list"></div>' +
        '</div>';

        // Remover input e colocar caixa no lugar
        this.parent().prepend(wrap);
        this.remove();

        // Variáveis fixas
        var inputEl = $("#" + id);
        var boxEl   = inputEl.parent();
        var countEl = boxEl.find(".dizuploader__count");
        var listEl  = boxEl.find(".dizuploader__list");
        var clearEl = boxEl.find(".dizuploader__clearfiles");
        var labelEl = boxEl.find("label[for=dizuploader__files]");
        var errorLabel = boxEl.find(".dizuploader__error__files"); // Label para mensagens de erro

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
            });

            // Adicionar a classe ao sobrepor
            target.on("dragover dragenter", function(e) {
                uploaderEl.addClass(hoverClass);
            });

            // Remover a classe ao sair, terminar o arraste ou soltar
            target.on("dragleave dragend drop", function(e) {
                uploaderEl.removeClass(hoverClass);
            });

            // Evento ao soltar os arquivos
            target.on('drop', function(e) {
                if (e.originalEvent.dataTransfer && e.originalEvent.dataTransfer.files.length) {
                    var droppedFiles = e.originalEvent.dataTransfer.files;
                    inputEl[0].files = droppedFiles; // Setar arquivos para o input
                    showFiles(droppedFiles); // Mostra arquivos selecionados em uma lista
                }
            });

            uploaderEl.find("span").html(settings.caption);
        }

        // Abrir Caixa de diálogo do input pelo label
        labelEl.not("button").click(function(e) {
            var t = e.target.type;
            if (t != "button") {
                // Disparar Evento Click no Input
                inputEl.click();
            }
        });

        // Ao clicar no botão de arquivo
        inputEl.on("change", function(e) {
            var changedFiles = e.target.files;
            showFiles(changedFiles);
            if (settings.ajaxUpload) {
                uploadFiles(changedFiles); // Upload via AJAX se habilitado
            }
        });

        // Define o atributo "accept" com base nas extensões permitidas
        if (settings.extensions[0] !== "*") {
            var acceptExtensions = settings.extensions.map(ext => "." + ext).join(", ");
            inputEl.attr("accept", acceptExtensions);
        }

        // Limpar todos os arquivos ao clicar no botão "Remover todos os arquivos"
        clearEl.on("click", function(e) {
            e.preventDefault(); // Previne o comportamento padrão
            clearList();        // Limpa a exibição dos arquivos na interface
            inputEl[0].files = FileListItems([]); // Reseta os arquivos do input para um FileList vazio
            countFiles(0);      // Atualiza o contador de arquivos para zero
        });

        // Método para validar o número máximo de arquivos
        inputEl.on('change', function() {
            if (settings.maxFiles && inputEl[0].files.length > settings.maxFiles) {
                errorLabel.text(""); // Limpa mensagens de erro antes de validar
                errorLabel.text("Você pode enviar no máximo " + settings.maxFiles + " arquivos.");
                inputEl.val(''); // Limpa o input
            }
        });

        // Método para validar o tamanho máximo dos arquivos
        inputEl.on('change', function() {
            var totalSize = 0;
            $.each(inputEl[0].files, function(i, file) {
                totalSize += file.size;
            });
            if (settings.maxSize && totalSize > settings.maxSize) {
                errorLabel.text("");
                errorLabel.text("O tamanho total dos arquivos não pode exceder " + (settings.maxSize / 1024 / 1024).toFixed(2) + " MB.");
                inputEl.val(''); // Limpa o input
            }
        });

        // Mostrar arquivos na lista
        function showFiles(files) {
            invalid = 0;
            total = 0;
            clearList();
            errorLabel.html("").remove();

            for (var i = 0; i < files.length; i++) {
                var ext = getExtension(files[i].name);
                if (settings.extensions.includes('*') || settings.extensions.includes(ext)) {
                    showLine(i, files[i], ext);
                    total += files[i].size;
                } else {
                    invalid++;
                    showLineError(files[i], ext, i);
                }
            }

            countFiles(files.length, total);
        }

        function getExtension(path) {
            var basename = path.split(/[\\/]/).pop(),
                pos = basename.lastIndexOf(".");
            if (basename === "" || pos < 1) return "";
            return basename.slice(pos + 1).toLowerCase(); // Convertendo para minúsculas
        }

        function showLine(index, file, ext) {
            var images = ["jpg", "jpeg", "bmp", "gif", "png", "apng", "jfif", "svg"];
            var deleteButton = '<button type="button" class="dizuploader__delete" data-index="'+ index +'">✕</button>';

            var size = Math.ceil(file.size / 1024);
            size = size > 1024 ? Math.ceil(size / 1024) + " MB" : size + " KB";

            if (images.includes(ext)) {

                var lineHtml = "<div class=\"line border-top\" data-id=\"" + index + "\">" +
                    "<img src=\"" + URL.createObjectURL(file) + "\">" +
                    "<div>" +
                        "<strong>" + file.name + "</strong><br>" +
                        "<small>" + size + "</small>" +
                        deleteButton + // Adiciona o botão de excluir
                    "</div>";

                if (settings.ajaxUpload) {

                    lineHtml += "<div class=\"progress\">" +
                            "<div class=\"progress-bar\"></div>" +
                        "</div>";
                }

                lineHtml += "</div>";

                listEl.prepend(lineHtml);

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

                var icon = (typeof icons[ext] !== "undefined") ? icons[ext] : 'fas fa-file';

                var lineHtml = "<div class=\"line border-top\" data-id=\"" + index + "\">" +
                    "<i class=\"" + icon + " fa-2x me-3\"></i>" +
                    "<div>" +
                        "<strong>" + file.name + "</strong><br>" +
                        "<small>" + size + "</small>" +
                        deleteButton + // Adiciona o botão de excluir
                    "</div>";

                if (settings.ajaxUpload) {
                    lineHtml += "<div class=\"progress\"><div class=\"progress-bar\"></div></div>";
                }

                lineHtml += "</div>";

                listEl.prepend(lineHtml);
            }
        }

        // Exclusão de Arquivos
        listEl.on('click', '.dizuploader__delete', function() {
            var index = $(this).data('index'); // Pega o índice do arquivo
            var files = Array.from(inputEl[0].files); // Converte o FileList para um array

            // Remove o arquivo do array
            files.splice(index, 1);

            // Atualiza a lista de arquivos do input
            inputEl[0].files = FileListItems(files);

            // Atualiza a exibição
            showFiles(files);
        });

        // Função para criar novo FileList
        function FileListItems(files) {
            var b = new ClipboardEvent("").clipboardData || new DataTransfer();
            for (var i = 0; i < files.length; i++) {
                b.items.add(files[i]);
            }
            return b.files;
        }

        // Mostrar Mensagem de Erro ao usuário
        function showLineError(file, ext, index) {
            var errorMsg = "<div class=\"line error border-top\" data-id=\"" + index + "\">" +
                file.name + " (." + ext + ") - Extensão não permitida" +
                '<button type="button" class="dizuploader__delete" data-index="'+ index +'">✕</button>' + // Adiciona o botão de excluir
                "</div>";
            listEl.prepend(errorMsg);
        }

        // Contar Arquivos
        function countFiles(n, total) {
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
                countEl.html("Foi selecionado 1 arquivo. (Total de " + total +  ")");
                clearEl.show();
            }
            else {
                countEl.html("Foram selecionados "+n+" arquivos. (Total de " + total + ")");
                clearEl.show();
            }

            totalFiles = n;
        }

        // Limpar a lista de arquivos
        function clearList() {
            listEl.html("");
            countEl.html("");
            errorLabel.html("").remove();
        }

        // Função de upload via AJAX
        function uploadFiles(files) {
            var formData = new FormData();
            var progress = [];
            var errors = 0;

            $.each(files, function(index, file) {
                formData.append('files[]', file);
            });

            // Função de Envio de cada arquivo
            $.ajax({
                url: settings.uploadUrl,
                type: settings.ajaxMethod,
                data: formData,
                processData: false,
                contentType: false,
                xhr: function() {
                    var xhr = new XMLHttpRequest();
                    xhr.upload.addEventListener("progress", function(e) {
                        if (e.lengthComputable) {
                            var percent = (e.loaded / e.total) * 100;
                            progress[index] = percent;
                            updateProgress(index, percent);
                        }
                    }, false);
                    return xhr;
                },
                success: function(response) {
                    if (response.success) {
                        settings.onFileUploadSuccess(files[index]);
                    } else {
                        settings.onFileUploadError(files[index]);
                    }
                    if (index === files.length - 1) {
                        settings.onAllFilesUploaded();
                    }
                },
                error: function() {
                    settings.onFileUploadError(files[index]);
                }
            });
        }

        // Atualiza o progresso de upload
        function updateProgress(index, percent) {
            var progressBar = listEl.find(".line[data-id=" + index + "] .progress-bar");
            progressBar.css('width', percent + '%');
        }

        return this;
    };

})(jQuery);
