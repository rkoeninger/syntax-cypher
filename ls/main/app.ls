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
    it.math-disabled = false
    it.postfix-error = false
    it.sexpr-error = false

update-from-postfix-error = !->
    it.postfix-disabled = false
    it.sexpr-disabled = true
    it.tex-disabled = true
    it.math-disabled = true
    it.postfix-error = true
    it.sexpr-error = false
    it.math-html = ''

update-from-sexpr-error = !->
    it.postfix-disabled = true
    it.sexpr-disabled = false
    it.tex-disabled = true
    it.math-disabled = true
    it.postfix-error = false
    it.sexpr-error = true
    it.math-html = ''

update-from-postfix-code = !->
    if string-to-postfix it.postfix-code then
        sexpr = postfix-to-sexpr that
        it.sexpr-code = sexpr-to-string sexpr
        tex = sexpr-to-tex sexpr
        it.tex-code = tex
        it.math-html = render-to-string tex
        update-from-valid-code it
    else
        update-from-postfix-error it

update-from-sexpr-code = !->
    if string-to-sexpr it.sexpr-code then
        it.postfix-code = postfix-to-string sexpr-to-postfix that
        tex = sexpr-to-tex that
        it.tex-code = tex
        it.math-html = render-to-string tex
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
            tex-code: '{a + b}'
            tex-disabled: false
            math-html: render-to-string '{a + b}'
            math-disabled: false
        template: '
            <div>
                <div class="box">
                    <p class="subtitle is-6">Reverse Polish Notation</p>
                    <textarea v-bind:disabled="postfixDisabled" v-model="postfixCode" v-on:keyup="postfixChanged" v-bind:class="{ \'is-danger\': postfixError }" class="textarea" type="text" rows="1" columns="80" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                </div>
                <div class="box">
                    <p class="subtitle is-6">Symbolic Expressions</p>
                    <textarea v-bind:disabled="sexprDisabled" v-model="sexprCode" v-on:keyup="sexprChanged" v-bind:class="{ \'is-danger\': sexprError }" class="textarea" type="text" rows="1" columns="80" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                </div>
                <div class="box">
                    <p class="subtitle is-6"><span style="font-family: \'CMU Serif\', cmr10, LMRoman10-Regular, \'Nimbus Roman No9 L\', \'Times New Roman\', Times, serif;">T<span style="vertical-align: -0.5ex; margin-left: -0.1667em; margin-right: -0.125em;">E</span>X</span><p>
                    <textarea v-bind:disabled="texDisabled" v-model="texCode" readonly class="textarea" type="text" rows="1" columns="80" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
                </div>
                <div class="box">
                    <p class="subtitle is-6">Mathematical Notation</p>
                    <div v-bind:disabled="mathDisabled" class="math" v-html="mathHtml"></div>
                </div>
            </div>'
        methods:
            postfix-changed: !-> update-from-postfix-code this
            sexpr-changed: !-> update-from-sexpr-code this

setTimeout init-vue, 0
