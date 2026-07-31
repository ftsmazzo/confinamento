(function($) {
    $.fn.emailTags = function(options) {
        const settings = $.extend({
            width: '100%',
            limit: null,
            initialData: null,
            inputName: 'lista_emails',
            inputPlaceholder: 'exemplo@email.com',
            btnClass: 'primary',
            btnText: '<i class="fa fa-plus" aria-hidden="true"></i> Adicionar',
            tagClass: 'primary',
            tagRounded: false,
            clearOnAdd: true, // Parâmetro final
            onAdd: function(value) {},
            onRemove: function(value) {}
        }, options);

        const validateEmail = (email) => {
            const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            return re.test(String(email).toLowerCase());
        };

        return this.each(function() {
            const wrapper = $(this);

            if (settings.initialData === null) {
                const dataAttr = wrapper.data('initial-emails');
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
            wrapper.addClass('email-tags-wrapper');
            let emailsAdicionados = [];

            let html = `
                <div class="input-group-wrapper mb-2" style="width: ${settings.width};">
                    <div class="input-group">
                        <input type="email" class="form-control email-input" placeholder="${settings.inputPlaceholder}">
                        <button type="button" class="btn btn-${settings.btnClass} adicionar-btn">${settings.btnText}</button>
                    </div>
                </div>
                <div class="tags-container border rounded p-2"></div>
                <input type="hidden" name="${settings.inputName}" class="lista-emails-hidden">`;

            if (settings.limit > 0) {
                html += `<div class="limit-info" style="text-align: right; font-size: 0.8rem; color: #6c757d;"></div>`;
            }

            wrapper.append(html);

            const emailInput = wrapper.find('.email-input');
            const tagsContainer = wrapper.find('.tags-container');
            const hiddenInput = wrapper.find('.lista-emails-hidden');
            const limitInfo = wrapper.find('.limit-info');

            const adicionarTag = (emailValor) => {
                const emailLimpo = emailValor.trim().toLowerCase();
                let foiAdicionado = false; // Flag para controlar a limpeza

                if (!validateEmail(emailLimpo)) {
                    emailInput.addClass("has-error");
                    return foiAdicionado;
                }

                emailInput.removeClass("has-error");

                if (settings.limit && emailsAdicionados.length >= settings.limit) {
                    alert(`Você pode adicionar no máximo ${settings.limit} e-mails.`);
                    return foiAdicionado;
                }
                if (emailsAdicionados.includes(emailLimpo)) {
                    const tagExistente = tagsContainer.find(`[data-email="${emailLimpo}"]`);
                    tagExistente.addClass('duplicate bg-danger').removeClass(`bg-${settings.tagClass}`);
                    setTimeout(() => tagExistente.removeClass('duplicate bg-danger').addClass(`bg-${settings.tagClass}`), 600);
                    return foiAdicionado;
                }

                emailsAdicionados.push(emailLimpo);
                const tagHTML = `<span class="tag badge bg-${settings.tagClass} ${settings.roundedClass} m-1" data-email="${emailLimpo}">${emailLimpo}<span class="remover-tag">×</span></span>`;
                tagsContainer.append(tagHTML);
                atualizarEstado();
                settings.onAdd.call(wrapper, emailLimpo);
                foiAdicionado = true; // Sucesso!
                return foiAdicionado;
            };

            const removerTag = (tagElement) => {
                const emailLimpo = tagElement.data('email').toString();
                emailsAdicionados = emailsAdicionados.filter(email => email !== emailLimpo);
                tagElement.remove();
                atualizarEstado();
                settings.onRemove.call(wrapper, emailLimpo);
            };

            const atualizarEstado = () => {
                hiddenInput.val(emailsAdicionados.join(','));
                if (settings.limit) { limitInfo.text(`${emailsAdicionados.length} / ${settings.limit}`); }
            };

            if (settings.initialData && settings.initialData.length > 0) {
                settings.initialData.forEach(email => {
                    adicionarTag(email);
                });
            }
            atualizarEstado();

            wrapper.on('click', '.adicionar-btn', function() {
                const valor = emailInput.val();
                if (valor) {
                    const sucesso = adicionarTag(valor);
                    // Limpa o input se a tag foi adicionada com sucesso e a opção está ativa
                    if (sucesso && settings.clearOnAdd) {
                        emailInput.val('').focus();
                    }
                } else {
                    emailInput.addClass("has-error");
                }
            });

            emailInput.on('keypress', function(e) { if (e.which === 13) { e.preventDefault(); wrapper.find('.adicionar-btn').click(); } });
            tagsContainer.on('click', '.remover-tag', function() { removerTag($(this).closest('.tag')); });
        });
    };
}(jQuery));
