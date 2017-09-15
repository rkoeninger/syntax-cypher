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
require! \vue

update-from-postfix-code = (data) !->
    sexpr = postfix-to-sexpr string-to-postfix data.postfix-code
    data.sexpr-code = sexpr-to-string sexpr
    data.tex-code = render-to-string sexpr-to-tex sexpr

update-from-sexpr-code = (data) !->
    sexpr = string-to-sexpr data.sexpr-code
    data.postfix-code = postfix-to-string sexpr-to-postfix sexpr
    data.tex-code = render-to-string sexpr-to-tex sexpr

init-vue = !->
    new Vue do
        el: 'main'
        data:
            sexpr-code: '(+ a b)'
            postfix-code: 'a b +'
            tex-code: '{a + b}'
        template: '
            <div>
                <textarea class="editor postfix" v-model="postfixCode" v-on:keyup="postfixChanged"></textarea>
                <textarea class="editor sexpr" v-model="sexprCode" v-on:keyup="sexprChanged"></textarea>
                <span class="display tex" v-html="texCode"></span>
            </div>'
        methods:
            postfix-changed: !-> update-from-postfix-code this
            sexpr-changed: !-> update-from-sexpr-code this

setTimeout init-vue, 0
