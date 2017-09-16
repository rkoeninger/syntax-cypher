require! \prelude-ls : {
    chars,
    reverse,
    unchars
}
require! './cypher' : {
    postfix-to-sexpr,
    postfix-to-string,
    sexpr-to-postfix,
    sexpr-to-string,
    sexpr-to-tex,
    string-to-postfix,
    string-to-sexpr,
}
require! \katex : {
    render-to-string
}
# require! \vue # not working

update-from-valid-code = !->
    it.postfix-disabled = false
    it.sexpr-disabled = false
    it.tex-disabled = false
    it.postfix-error = false
    it.sexpr-error = false

update-from-postfix-error = !->
    it.postfix-disabled = false
    it.sexpr-disabled = true
    it.tex-disabled = true
    it.postfix-error = true
    it.sexpr-error = false
    it.tex-code = ''

update-from-sexpr-error = !->
    it.postfix-disabled = true
    it.sexpr-disabled = false
    it.tex-disabled = true
    it.postfix-error = false
    it.sexpr-error = true
    it.tex-code = ''

update-from-postfix-code = !->
    if string-to-postfix it.postfix-code then
        sexpr = postfix-to-sexpr that
        it.sexpr-code = sexpr-to-string sexpr
        it.tex-code = render-to-string sexpr-to-tex sexpr
        update-from-valid-code it
    else
        update-from-postfix-error it

update-from-sexpr-code = !->
    if string-to-sexpr it.sexpr-code then
        it.postfix-code = postfix-to-string sexpr-to-postfix that
        it.tex-code = render-to-string sexpr-to-tex that
        update-from-valid-code it
    else
        update-from-sexpr-error it

init-vue = !->
    new Vue do
        el: 'main'
        data:
            sexpr-code: '(+ a b)'
            sexpr-disabled: false
            sexpr-error: false
            postfix-code: 'a b +'
            postfix-disabled: false
            postfix-error: false
            tex-code: ''
            tex-disabled: false
        template: '
            <div>
                <div class="box editor postfix">
                    <p class="subtitle is-6">Reverse Polish</p>
                    <textarea v-bind:disabled="postfixDisabled" v-bind:class="{ \'is-danger\': postfixError }" class="textarea" type="text" rows="1" columns="80" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" v-model="postfixCode" v-on:keyup="postfixChanged"></textarea>
                </div>
                <div class="box editor sexpr">
                    <p class="subtitle is-6">S-Expressions</p>
                    <textarea v-bind:disabled="sexprDisabled" v-bind:class="{ \'is-danger\': sexprError }" class="textarea" type="text" rows="1" columns="80" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" v-model="sexprCode" v-on:keyup="sexprChanged"></textarea>
                </div>
                <div class="box">
                    <p class="subtitle is-6">Mathematical Notation</p>
                    <div v-bind:disabled="texDisabled" class="display tex" v-html="texCode"></div>
                </div>
            </div>'
        methods:
            postfix-changed: !-> update-from-postfix-code this
            sexpr-changed: !-> update-from-sexpr-code this

setTimeout init-vue, 0
