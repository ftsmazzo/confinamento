(function($) {
    $.fn.phoneTags = function(options) {
        const settings = $.extend({
            width: '100%',
            limit: null,
            initialData: null,
            inputName: 'lista_telefones',
            inputPlaceholder: '(00) 00000-0000',
            btnClass: 'primary',
            btnText: '<i class="fa fa-plus" aria-hidden="true"></i> Adicionar',
            tagClass: 'primary',
            tagRounded: false,
            clearOnAdd: true, // Parâmetro final
            onAdd: function(value) {},
            onRemove: function(value) {}
        }, options);

        return this.each(function() {
            const wrapper = $(this);

            if (settings.initialData === null) {
                const dataAttr = wrapper.data('initial-phones');
                const content = wrapper.text().trim();
                if (dataAttr) {
                    settings.initialData = String(dataAttr).split(',').map(s => s.trim()).filter(Boolean);
                } else if (content) {
                    settings.initialData = content.split(',').map(s => s.trim()).filter(Boolean);
                } else {
                    settings.initialData = [];
                }
            }

            settings.roundedClass = settings.tagRounded ? 'rounded-pill' : '';

            wrapper.empty();
            wrapper.addClass('phone-tags-wrapper');
            let telefonesAdicionados = [];

            let html = `
                <div class="input-group-wrapper mb-2" style="width: ${settings.width};">
                    <div class="input-group">
                        <input type="text" class="form-control telefone-input" placeholder="${settings.inputPlaceholder}">
                        <button type="button" class="btn btn-${settings.btnClass} adicionar-btn">${settings.btnText}</button>
                    </div>
                </div>
                <div class="tags-container border rounded p-2"></div>
                <input type="hidden" name="${settings.inputName}" class="lista-telefones-hidden">`;

            if (settings.limit > 0) {
                html += `<div class="limit-info" style="text-align: right; font-size: 0.8rem; color: #6c757d;"></div>`;
            }

            wrapper.append(html);

            const telefoneInput = wrapper.find('.telefone-input');
            const tagsContainer = wrapper.find('.tags-container');
            const hiddenInput = wrapper.find('.lista-telefones-hidden');
            const limitInfo = wrapper.find('.limit-info');

            const maskBehavior = (val) => val.replace(/\D/g, '').length === 11 ? '(00) 00000-0000' : '(00) 0000-00009';
            const maskOptions = { onKeyPress: function(val, e, field, options) { field.mask(maskBehavior.apply({}, arguments), options); } };
            telefoneInput.mask(maskBehavior, maskOptions);

            const adicionarTag = (telefoneValor) => {
                const numeroLimpo = telefoneValor.replace(/\D/g, '');
                let foiAdicionado = false; // Flag para controlar a limpeza

                if (settings.limit && telefonesAdicionados.length >= settings.limit) {
                    alert(`Você pode adicionar no máximo ${settings.limit} telefones.`);
                    return foiAdicionado;
                }
                if (telefonesAdicionados.includes(numeroLimpo)) {
                    const tagExistente = tagsContainer.find(`[data-telefone="${numeroLimpo}"]`);
                    tagExistente.addClass('duplicate bg-danger').removeClass(`bg-${settings.tagClass}`);
                    setTimeout(() => tagExistente.removeClass('duplicate bg-danger').addClass(`bg-${settings.tagClass}`), 600);
                    return foiAdicionado;
                }

                telefonesAdicionados.push(numeroLimpo);
                const tagHTML = `<span class="tag badge bg-${settings.tagClass} ${settings.roundedClass} m-1" data-telefone="${numeroLimpo}">${telefoneValor}<span class="remover-tag">×</span></span>`;
                tagsContainer.append(tagHTML);
                atualizarEstado();
                settings.onAdd.call(wrapper, numeroLimpo);
                foiAdicionado = true; // Sucesso!
                return foiAdicionado;
            };

            const removerTag = (tagElement) => {
                const numeroLimpo = tagElement.data('telefone').toString();
                telefonesAdicionados = telefonesAdicionados.filter(tel => tel !== numeroLimpo);
                tagElement.remove();
                atualizarEstado();
                settings.onRemove.call(wrapper, numeroLimpo);
            };

            const atualizarEstado = () => {
                hiddenInput.val(telefonesAdicionados.join(','));
                if (settings.limit) { limitInfo.text(`${telefonesAdicionados.length} / ${settings.limit}`); }
            };

            if (settings.initialData && settings.initialData.length > 0) {
                settings.initialData.forEach(numero => {
                    const tempInput = $('<input>').mask(maskBehavior, maskOptions);
                    tempInput.val(numero).trigger('input');
                    adicionarTag(tempInput.val());
                });
            }
            atualizarEstado();

            wrapper.on('click', '.adicionar-btn', function() {
                const valor = telefoneInput.val();
                if (valor.length >= 14) {
                    telefoneInput.removeClass("has-error");
                    const sucesso = adicionarTag(valor);
                    // Limpa o input se a tag foi adicionada com sucesso e a opção está ativa
                    if (sucesso && settings.clearOnAdd) {
                        telefoneInput.val('').focus();
                    }
                } else {
                    telefoneInput.addClass("has-error");
                }
            });

            telefoneInput.on('keypress', function(e) { if (e.which === 13) { e.preventDefault(); wrapper.find('.adicionar-btn').click(); } });
            tagsContainer.on('click', '.remover-tag', function() { removerTag($(this).closest('.tag')); });
        });
    };
}(jQuery));
