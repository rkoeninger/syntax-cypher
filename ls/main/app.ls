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

reverseString = chars >> reverse >> unchars

init-vue = !->
    new Vue do
        el: 'main'
        data:
            sexpr-code: '(+ a b)'
            postfix-code: 'a b +'
            tex-code: '{a + b}'
        template: '
            <div>
                <textarea v-model="sexprCode" v-on:keyup="sexprChanged"></textarea>
                <textarea v-model="postfixCode" v-on:keyup="postfixChanged"></textarea>
                <span>{{ texCode }}</span>
            </div>'
        methods:
            sexpr-changed: !->
                sexpr = string-to-sexpr @sexpr-code
                @postfix-code = postfix-to-string sexpr-to-postfix sexpr
                @tex-code = sexpr-to-tex sexpr
            postfix-changed: !->
                sexpr = postfix-to-sexpr string-to-postfix @postfix-code
                @sexpr-code = sexpr-to-string sexpr
                @tex-code = sexpr-to-tex sexpr

setTimeout init-vue, 0
