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
require! \vue : Vue

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
        it.tex-code = sexpr-to-tex sexpr
        it.math-html = render-to-string it.tex-code
        update-from-valid-code it
    else
        update-from-postfix-error it

update-from-sexpr-code = !->
    if string-to-sexpr it.sexpr-code then
        it.postfix-code = postfix-to-string sexpr-to-postfix that
        it.tex-code = sexpr-to-tex that
        it.math-html = render-to-string it.tex-code
        update-from-valid-code it
    else
        update-from-sexpr-error it

init-vue = !->
    new Vue do
        el: 'main'
        data:
            postfix-code: 'b neg b 2 ^ 4 a c * * - sqrt +/- 2 a * /'
            postfix-disabled: false
            postfix-error: false
            sexpr-code: '(/ (+/- (neg b) (sqrt (- (^ b 2) (* 4 a c)))) (* 2 a))'
            sexpr-disabled: false
            sexpr-error: false
            tex-code: '{\\frac {{- b} \\pm {\\sqrt {{b ^ 2} - {4 a c}}}} {2 a}}'
            tex-disabled: false
            math-html: render-to-string '{\\frac {{- b} \\pm {\\sqrt {{b ^ 2} - {4 a c}}}} {2 a}}'
            math-disabled: false
        template: '
            <div>
                <div class="box">
                    <p class="subtitle is-6">Reverse Polish Notation</p>
                    <input :disabled="postfixDisabled" v-model="postfixCode" @keyup="postfixChanged" :class="{ \'is-danger\': postfixError }" class="input" type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
                </div>
                <div class="box">
                    <p class="subtitle is-6">Symbolic Expressions</p>
                    <input :disabled="sexprDisabled" v-model="sexprCode" @keyup="sexprChanged" :class="{ \'is-danger\': sexprError }" class="input" type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
                </div>
                <div class="box">
                    <p class="subtitle is-6"><span style="font-family: \'CMU Serif\', cmr10, LMRoman10-Regular, \'Nimbus Roman No9 L\', \'Times New Roman\', Times, serif;">T<span style="vertical-align: -0.5ex; margin-left: -0.1667em; margin-right: -0.125em;">E</span>X</span><p>
                    <input :disabled="texDisabled" v-model="texCode" class="input" readonly type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
                    <div :disabled="mathDisabled" class="math" v-html="mathHtml"></div>
                </div>
            </div>'
        methods:
            postfix-changed: !-> update-from-postfix-code this
            sexpr-changed: !-> update-from-sexpr-code this

setTimeout init-vue, 0
