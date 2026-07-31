class FormValidator {
    static defaults = {
        fieldSelector: "input, select, textarea, wa-input, wa-select, wa-textarea, wa-checkbox, wa-switch",
        fieldWrapperSelector: "[data-field], .form-group, .field, .input-group",
        errorClass: "is-invalid",
        validClass: "is-valid",
        wrapperErrorClass: "has-error",
        wrapperValidClass: "has-valid",
        errorMessageClass: "field-error",
        focusFirstInvalid: true,
        validateOnInput: true,
        validateOnBlur: true,
        validateOnChange: true,
        scrollToFirstInvalid: false,
        scrollOffset: 20,
        stopAtFirstErrorPerField: true,
        trim: true,
        onInit: null,
        onFieldValid: null,
        onFieldInvalid: null,
        onFormValid: null,
        onFormInvalid: null,
        onBeforeSubmit: null,
        onSubmit: null
    };

    static builtinRules = {
        required(value, ruleValue, field, ctx) {
            if (!ruleValue) return true;
            return !ctx.isEmpty(value);
        },

        email(value, ruleValue, field, ctx) {
            if (!ruleValue || ctx.isEmpty(value)) return true;
            return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(value));
        },

        minlength(value, ruleValue, field, ctx) {
            if (ctx.isEmpty(value)) return true;
            return String(value).length >= Number(ruleValue);
        },

        maxlength(value, ruleValue, field, ctx) {
            if (ctx.isEmpty(value)) return true;
            return String(value).length <= Number(ruleValue);
        },

        min(value, ruleValue, field, ctx) {
            if (ctx.isEmpty(value)) return true;
            return Number(value) >= Number(ruleValue);
        },

        max(value, ruleValue, field, ctx) {
            if (ctx.isEmpty(value)) return true;
            return Number(value) <= Number(ruleValue);
        },

        number(value, ruleValue, field, ctx) {
            if (!ruleValue || ctx.isEmpty(value)) return true;
            return !Number.isNaN(Number(value));
        },

        integer(value, ruleValue, field, ctx) {
            if (!ruleValue || ctx.isEmpty(value)) return true;
            return /^-?\d+$/.test(String(value));
        },

        pattern(value, ruleValue, field, ctx) {
            if (ctx.isEmpty(value)) return true;
            const regex = ruleValue instanceof RegExp ? ruleValue : new RegExp(ruleValue);
            return regex.test(String(value));
        },

        equalTo(value, ruleValue, field, ctx) {
            const otherField = ctx.getField(ruleValue);
            if (!otherField) return true;
            const otherValue = ctx.normalize(ctx.getValue(otherField));
            return value === otherValue;
        },

        minItems(value, ruleValue, field, ctx) {
            if (!Array.isArray(value)) return false;
            return value.length >= Number(ruleValue);
        },

        maxItems(value, ruleValue, field, ctx) {
            if (!Array.isArray(value)) return false;
            return value.length <= Number(ruleValue);
        },

        accepted(value, ruleValue, field, ctx) {
            if (!ruleValue) return true;
            if (Array.isArray(value)) return value.length > 0;
            return value !== "";
        },

        requiredIf(value, ruleValue, field, ctx) {
            const mustRequire = typeof ruleValue === "function"
                ? !!ruleValue(ctx.getData(), field, ctx)
                : false;

            if (!mustRequire) return true;
            return !ctx.isEmpty(value);
        },

        requiredUnless(value, ruleValue, field, ctx) {
            const shouldSkip = typeof ruleValue === "function"
                ? !!ruleValue(ctx.getData(), field, ctx)
                : false;

            if (shouldSkip) return true;
            return !ctx.isEmpty(value);
        },

        custom(value, ruleValue, field, ctx) {
            if (typeof ruleValue !== "function") return true;
            return ruleValue(value, field, ctx.getData(), ctx);
        },

        async asyncCustom(value, ruleValue, field, ctx) {
            if (typeof ruleValue !== "function") return true;
            return await ruleValue(value, field, ctx.getData(), ctx);
        }
    };

    static messages = {
        required: "Este campo é obrigatório.",
        email: "Digite um e-mail válido.",
        minlength: ({ ruleValue }) => `Digite pelo menos ${ruleValue} caracteres.`,
        maxlength: ({ ruleValue }) => `Digite no máximo ${ruleValue} caracteres.`,
        min: ({ ruleValue }) => `Informe um valor maior ou igual a ${ruleValue}.`,
        max: ({ ruleValue }) => `Informe um valor menor ou igual a ${ruleValue}.`,
        number: "Informe um número válido.",
        integer: "Informe um número inteiro válido.",
        pattern: "Formato inválido.",
        equalTo: "Os campos não conferem.",
        minItems: ({ ruleValue }) => `Selecione pelo menos ${ruleValue} itens.`,
        maxItems: ({ ruleValue }) => `Selecione no máximo ${ruleValue} itens.`,
        accepted: "Este campo deve ser aceito.",
        requiredIf: "Este campo é obrigatório.",
        requiredUnless: "Este campo é obrigatório.",
        custom: "Campo inválido.",
        asyncCustom: "Campo inválido."
    };

    constructor(form, options = {}) {
        this.form = typeof form === "string" ? document.querySelector(form) : form;

        if (!this.form) {
            throw new Error("Formulário não encontrado.");
        }

        this.options = this.mergeDeep(
            structuredClone(FormValidator.defaults),
            options
        );

        this.rules = options.rules || {};
        this.messages = options.messages || {};
        this.state = {
            fields: new Map(),
            errors: {},
            touched: new Set(),
            validating: new Set(),
            destroyed: false
        };

        this.boundHandlers = {};
        this.init();
    }

    init() {
        this.refreshFields();
        this.bindEvents();

        if (typeof this.options.onInit === "function") {
            this.options.onInit(this);
        }
    }

    destroy() {
        if (this.state.destroyed) return;

        const { input, change, focusout, submit } = this.boundHandlers;

        if (input) this.form.removeEventListener("input", input, true);
        if (change) this.form.removeEventListener("change", change, true);
        if (focusout) this.form.removeEventListener("focusout", focusout, true);
        if (submit) this.form.removeEventListener("submit", submit);

        this.state.destroyed = true;
    }

    refreshFields() {
        this.state.fields.clear();

        const fields = this.form.querySelectorAll(this.options.fieldSelector);

        fields.forEach((field) => {
            if (!field.name || field.disabled) return;

            if (this.isRadio(field) || this.isCheckbox(field)) {
                if (!this.state.fields.has(field.name)) {
                    this.state.fields.set(field.name, field);
                }
                return;
            }

            this.state.fields.set(field.name, field);
        });
    }

    bindEvents() {
        this.boundHandlers.input = async (e) => {
            if (!this.options.validateOnInput) return;
            const field = this.findEventField(e.target);
            if (!field) return;
            this.state.touched.add(field.name);
            await this.validateField(field.name);
        };

        this.boundHandlers.change = async (e) => {
            if (!this.options.validateOnChange) return;
            const field = this.findEventField(e.target);
            if (!field) return;
            this.state.touched.add(field.name);
            await this.validateField(field.name);
        };

        this.boundHandlers.focusout = async (e) => {
            if (!this.options.validateOnBlur) return;
            const field = this.findEventField(e.target);
            if (!field) return;
            this.state.touched.add(field.name);
            await this.validateField(field.name);
        };

        this.boundHandlers.submit = async (e) => {
            e.preventDefault();

            if (typeof this.options.onBeforeSubmit === "function") {
                const proceed = await this.options.onBeforeSubmit(this.getData(), this.form, this);
                if (proceed === false) return;
            }

            const result = await this.validateForm();

            if (!result.valid) {
                if (this.options.focusFirstInvalid && result.firstInvalid) {
                    this.focusField(result.firstInvalid);
                }

                if (this.options.scrollToFirstInvalid && result.firstInvalid) {
                    this.scrollToField(result.firstInvalid);
                }

                if (typeof this.options.onFormInvalid === "function") {
                    this.options.onFormInvalid(result.errors, result, this);
                }

                return;
            }

            if (typeof this.options.onFormValid === "function") {
                this.options.onFormValid(result, this);
            }

            if (typeof this.options.onSubmit === "function") {
                await this.options.onSubmit(this.getData(), this.form, this);
            } else {
                this.form.submit();
            }
        };

        this.form.addEventListener("input", this.boundHandlers.input, true);
        this.form.addEventListener("change", this.boundHandlers.change, true);
        this.form.addEventListener("focusout", this.boundHandlers.focusout, true);
        this.form.addEventListener("submit", this.boundHandlers.submit);
    }

    findEventField(target) {
        if (!target || !target.closest) return null;
        const field = target.closest(this.options.fieldSelector);
        if (!field || !field.name) return null;
        return this.getField(field.name);
    }

    getField(nameOrSelector) {
        if (!nameOrSelector) return null;

        if (
            nameOrSelector.startsWith("#") ||
            nameOrSelector.startsWith(".") ||
            nameOrSelector.startsWith("[")
        ) {
            return this.form.querySelector(nameOrSelector) || document.querySelector(nameOrSelector);
        }

        return this.state.fields.get(nameOrSelector) ||
            this.form.querySelector(`[name="${CSS.escape(nameOrSelector)}"]`);
    }

    getFieldsByName(name) {
        return Array.from(this.form.querySelectorAll(`[name="${CSS.escape(name)}"]`));
    }

    getWrapper(field) {
        if (!field) return null;

        const explicit = field.getAttribute?.("data-field-wrapper");
        if (explicit) {
            return document.querySelector(explicit);
        }

        return field.closest(this.options.fieldWrapperSelector) || field.parentElement;
    }

    getErrorContainer(field) {
        if (!field) return null;

        const explicit = field.getAttribute?.("data-error-target");
        if (explicit) {
            return document.querySelector(explicit);
        }

        return this.getWrapper(field);
    }

    getErrorElement(field) {
        const container = this.getErrorContainer(field);
        if (!container) return null;
        return container.querySelector(`.${this.options.errorMessageClass}`);
    }

    createErrorElement(field) {
        const container = this.getErrorContainer(field);
        if (!container) return null;

        let errorEl = this.getErrorElement(field);
        if (!errorEl) {
            errorEl = document.createElement("div");
            errorEl.className = this.options.errorMessageClass;
            container.appendChild(errorEl);
        }

        return errorEl;
    }

    setError(field, message) {
        if (!field) return;

        const wrapper = this.getWrapper(field);
        const errorEl = this.createErrorElement(field);

        field.classList.add(this.options.errorClass);
        field.classList.remove(this.options.validClass);
        field.setAttribute("aria-invalid", "true");

        if (wrapper) {
            wrapper.classList.add(this.options.wrapperErrorClass);
            wrapper.classList.remove(this.options.wrapperValidClass);
        }

        if (errorEl) {
            errorEl.textContent = message;
        }
    }

    clearError(field) {
        if (!field) return;

        const wrapper = this.getWrapper(field);
        const errorEl = this.getErrorElement(field);

        field.classList.remove(this.options.errorClass);
        field.removeAttribute("aria-invalid");

        if (wrapper) {
            wrapper.classList.remove(this.options.wrapperErrorClass);
        }

        if (errorEl) {
            errorEl.remove();
        }
    }

    setValid(field) {
        if (!field) return;

        const wrapper = this.getWrapper(field);

        field.classList.remove(this.options.errorClass);
        field.classList.add(this.options.validClass);
        field.removeAttribute("aria-invalid");

        if (wrapper) {
            wrapper.classList.remove(this.options.wrapperErrorClass);
            wrapper.classList.add(this.options.wrapperValidClass);
        }
    }

    resetFieldState(field) {
        if (!field) return;

        const wrapper = this.getWrapper(field);
        const errorEl = this.getErrorElement(field);

        field.classList.remove(this.options.errorClass, this.options.validClass);
        field.removeAttribute("aria-invalid");

        if (wrapper) {
            wrapper.classList.remove(
                this.options.wrapperErrorClass,
                this.options.wrapperValidClass
            );
        }

        if (errorEl) {
            errorEl.remove();
        }
    }

    reset() {
        this.refreshFields();

        for (const field of this.state.fields.values()) {
            this.resetFieldState(field);
        }

        this.state.errors = {};
        this.state.touched.clear();
        this.state.validating.clear();
    }

    focusField(field) {
        if (!field) return;
        if (typeof field.focus === "function") field.focus();
    }

    scrollToField(field) {
        if (!field || !field.getBoundingClientRect) return;

        const top = window.scrollY + field.getBoundingClientRect().top - this.options.scrollOffset;
        window.scrollTo({ top, behavior: "smooth" });
    }

    isRadio(field) {
        return (field?.type || "").toLowerCase() === "radio";
    }

    isCheckbox(field) {
        const type = (field?.type || "").toLowerCase();
        const tag = this.getTag(field);
        return type === "checkbox" || tag === "wa-checkbox" || tag === "wa-switch";
    }

    isMultiple(field) {
        const tag = this.getTag(field);
        return (tag === "select" && field.multiple) || (tag === "wa-select" && Array.isArray(field.value));
    }

    getTag(field) {
        return field?.tagName?.toLowerCase() || "";
    }

    normalize(value) {
        if (value == null) return "";
        if (Array.isArray(value)) {
            return value
                .map((v) => this.options.trim ? String(v).trim() : String(v))
                .filter((v) => v !== "");
        }
        return this.options.trim ? String(value).trim() : String(value);
    }

    isEmpty(value) {
        if (Array.isArray(value)) return value.length === 0;
        return value === "";
    }

    getValue(field) {
        if (!field) return "";

        const name = field.name;
        const tag = this.getTag(field);
        const type = (field.type || "").toLowerCase();

        if (type === "radio") {
            const checked = this.form.querySelector(`[name="${CSS.escape(name)}"]:checked`);
            return checked ? checked.value : "";
        }

        if (type === "checkbox") {
            const group = this.getFieldsByName(name).filter((f) => (f.type || "").toLowerCase() === "checkbox");
            if (group.length > 1) {
                return group.filter((f) => f.checked).map((f) => f.value || "on");
            }
            return field.checked ? (field.value || "on") : "";
        }

        if (tag === "wa-checkbox" || tag === "wa-switch") {
            const group = this.getFieldsByName(name).filter((f) => {
                const t = this.getTag(f);
                return t === "wa-checkbox" || t === "wa-switch";
            });

            if (group.length > 1) {
                return group.filter((f) => f.checked).map((f) => f.value || "on");
            }

            return field.checked ? (field.value || "on") : "";
        }

        if (tag === "select" && field.multiple) {
            return Array.from(field.selectedOptions).map((opt) => opt.value);
        }

        if (tag === "wa-select" && Array.isArray(field.value)) {
            return field.value;
        }

        return field.value ?? "";
    }

    getData() {
        this.refreshFields();

        const data = {};

        for (const [name, field] of this.state.fields.entries()) {
            data[name] = this.normalize(this.getValue(field));
        }

        return data;
    }

    toFormData() {
        const data = this.getData();
        const fd = new FormData();

        Object.entries(data).forEach(([key, value]) => {
            if (Array.isArray(value)) {
                value.forEach((item) => fd.append(`${key}[]`, item));
            } else {
                fd.append(key, value);
            }
        });

        return fd;
    }

    toQueryString() {
        const data = this.getData();
        const params = new URLSearchParams();

        Object.entries(data).forEach(([key, value]) => {
            if (Array.isArray(value)) {
                value.forEach((item) => params.append(`${key}[]`, item));
            } else {
                params.append(key, value);
            }
        });

        return params.toString();
    }

    getFieldRules(name) {
        return this.rules[name] || {};
    }

    getFieldMessages(name) {
        return this.messages[name] || {};
    }

    resolveMessage(name, ruleName, ruleValue, fallback) {
        const fieldMessages = this.getFieldMessages(name);
        const custom = fieldMessages[ruleName];

        if (typeof custom === "function") {
            return custom({ name, ruleName, ruleValue, validator: this });
        }

        if (typeof custom === "string") {
            return custom;
        }

        const builtin = FormValidator.messages[ruleName];

        if (typeof builtin === "function") {
            return builtin({ name, ruleName, ruleValue, validator: this });
        }

        if (typeof builtin === "string") {
            return builtin;
        }

        return fallback || "Campo inválido.";
    }

    async runRule(name, field, ruleName, ruleValue) {
        const value = this.normalize(this.getValue(field));
        const rule = FormValidator.builtinRules[ruleName];

        if (!rule) return { valid: true };

        let result = await rule.call(FormValidator.builtinRules, value, ruleValue, field, this);

        if (typeof result === "string") {
            return { valid: false, message: result };
        }

        if (result === false) {
            return {
                valid: false,
                message: this.resolveMessage(name, ruleName, ruleValue)
            };
        }

        if (result && typeof result === "object" && "valid" in result) {
            return {
                valid: !!result.valid,
                message: result.message || this.resolveMessage(name, ruleName, ruleValue)
            };
        }

        return { valid: true };
    }

    async validateField(name) {
        const field = this.getField(name);

        if (!field) {
            return { valid: true, field: null, errors: [] };
        }

        const rules = this.getFieldRules(name);
        const entries = Object.entries(rules);

        this.clearError(field);
        delete this.state.errors[name];

        if (!entries.length) {
            return { valid: true, field, errors: [] };
        }

        this.state.validating.add(name);

        const errors = [];

        for (const [ruleName, ruleValue] of entries) {
            const result = await this.runRule(name, field, ruleName, ruleValue);

            if (!result.valid) {
                errors.push(result.message);

                if (this.options.stopAtFirstErrorPerField) {
                    break;
                }
            }
        }

        this.state.validating.delete(name);

        if (errors.length) {
            const message = errors[0];
            this.state.errors[name] = message;
            this.setError(field, message);

            if (typeof this.options.onFieldInvalid === "function") {
                this.options.onFieldInvalid(name, field, message, this);
            }

            return { valid: false, field, errors };
        }

        this.setValid(field);

        if (typeof this.options.onFieldValid === "function") {
            this.options.onFieldValid(name, field, this);
        }

        return { valid: true, field, errors: [] };
    }

    async validateFields(names = []) {
        const results = await Promise.all(names.map((name) => this.validateField(name)));
        const errors = {};
        let firstInvalid = null;

        results.forEach((result, index) => {
            if (!result.valid) {
                errors[names[index]] = result.errors[0];
                if (!firstInvalid) firstInvalid = result.field;
            }
        });

        return {
            valid: Object.keys(errors).length === 0,
            errors,
            firstInvalid,
            results
        };
    }

    async validateForm() {
        this.refreshFields();

        const names = Object.keys(this.rules);
        const results = await Promise.all(names.map((name) => this.validateField(name)));

        const errors = {};
        let firstInvalid = null;

        results.forEach((result, index) => {
            const name = names[index];

            if (!result.valid) {
                errors[name] = result.errors[0];
                if (!firstInvalid) firstInvalid = result.field;
            }
        });

        this.state.errors = errors;

        return {
            valid: Object.keys(errors).length === 0,
            errors,
            firstInvalid,
            data: this.getData(),
            results
        };
    }

    addRule(fieldName, ruleName, ruleValue) {
        if (!this.rules[fieldName]) this.rules[fieldName] = {};
        this.rules[fieldName][ruleName] = ruleValue;
        return this;
    }

    removeRule(fieldName, ruleName) {
        if (this.rules[fieldName]) {
            delete this.rules[fieldName][ruleName];
        }
        return this;
    }

    setMessages(fieldName, messages) {
        this.messages[fieldName] = {
            ...(this.messages[fieldName] || {}),
            ...messages
        };
        return this;
    }

    static registerRule(name, fn, defaultMessage = "Campo inválido.") {
        FormValidator.builtinRules[name] = fn;
        FormValidator.messages[name] = defaultMessage;
    }

    mergeDeep(target, source) {
        if (!source || typeof source !== "object") return target;

        for (const key of Object.keys(source)) {
            const value = source[key];

            if (
                value &&
                typeof value === "object" &&
                !Array.isArray(value) &&
                !(value instanceof RegExp)
            ) {
                if (!target[key] || typeof target[key] !== "object") {
                    target[key] = {};
                }
                this.mergeDeep(target[key], value);
            } else {
                target[key] = value;
            }
        }

        return target;
    }
}