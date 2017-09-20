require! \assert : {
    deep-equal,
    equal,
    ok,
    strict-equal
}
require! \prelude-ls : {
    is-type
}
require! '../main/cypher' : {
    postfix-to-sexpr,
    postfix-to-string,
    sexpr-to-postfix,
    sexpr-to-string,
    sexpr-to-tex,
    string-to-postfix,
    string-to-sexpr
}

describe 'postfix -> sexpr' !->
    specify 'should combine variadic applications' !->
        deep-equal [\+ 1 2 3 4], postfix-to-sexpr [1 2 3 4 \+ \+ \+]
        deep-equal [\+ 1 2 3 4], postfix-to-sexpr [1 2 \+ 3 \+ 4 \+]

describe 'postfix -> string' !->
    specify 'should provide consistent spacing' !->
        equal '1 2 3 + *', postfix-to-string [1 2 3 \+ \*]
        equal 'b 2 ^ 4 a c * * -', postfix-to-string [\b 2 \^ 4 \a \c \* \* \-]

describe 'sexpr -> postfix' !->
    specify 'should split variadic applications' !->
        deep-equal [1 2 3 4 \+ \+ \+], sexpr-to-postfix [\+ 1 2 3 4]
        deep-equal [1 2 3 4 \+ \+ \+], sexpr-to-postfix [\+ [\+ 1 2] [\+ 3 4]]

describe 'sexpr -> string' !->
    specify 'should provide consistent spacing' !->
        equal '(+ 1 2 (* 3 4) 5)', sexpr-to-string [\+ 1 2 [\* 3 4] 5]
        equal '(- (^ b 2) (* 4 a c))', sexpr-to-string [\- [\^ \b 2] [\* 4 \a \c]]

describe 'sexpr -> tex' !->
    specify 'should handle variadic applications' !->
        equal '{1 + 2 + 3 + 4}', sexpr-to-tex [\+ 1 2 3 4]
        equal '{a b c}', sexpr-to-tex [\* \a \b \c]

    specify 'should convert division to \\frac' !->
        equal '{\\frac {2 a} b}', sexpr-to-tex [\/ [\* 2 \a] \b]

    specify 'should add parens when nested op of lower precendence' !->
        equal '{a {\\left( {b + c} \\right)}}', sexpr-to-tex [\* \a [\+ \b \c]]

    specify 'should use explicit multiplication op when multiplying constants' !->
        equal '{2 * 3}', sexpr-to-tex [\* 2 3]

    specify 'should always return a string' !->
        ok is-type \String sexpr-to-tex 0
        ok is-type \String sexpr-to-tex \+

describe 'string -> postfix' !->
    specify 'should handle arbitrary spacing' !->
        deep-equal [\a \b \+], string-to-postfix '   a  b    +  '

    specify 'should parse numeric literals' !->
        deep-equal [2 3 \+], string-to-postfix '2 3 +'

    specify 'should return undefined when line doesnt eval to single value' !->
        strict-equal undefined, string-to-postfix '1 2 3 +'

    specify 'should return undefined on stack underflow' !->
        strict-equal undefined, string-to-postfix '1 +'

    specify 'should return undefined when input is blank' !->
        strict-equal undefined, string-to-postfix ''

describe 'string -> sexpr' !->
    specify 'should handle nested expressions' !->
        deep-equal [\* [\+ \a 1] [\- \b 2]], string-to-sexpr '(* (+ a 1) (- b 2))'

    specify 'should handle arbitrary whitespace' !->
        deep-equal [\* [\+ \a 1] [\- \b 2]], string-to-sexpr '   ( *   ( + a    1 ) (- b   2) )   '

    specify 'should parse numeric literals' !->
        deep-equal [\+ 2 3], string-to-sexpr '(+ 2 3)'

    specify 'should read expressions that are falsy in javascript' !->
        deep-equal [\+ 0 0], string-to-sexpr '(+ 0 0)'

    specify 'should return undefined when parens unmatched' !->
        strict-equal undefined, string-to-sexpr '(+ 1 2'
        strict-equal undefined, string-to-sexpr '(+ 1 () 2'

    specify 'should return undefined when application starts with non-operator' !->
        strict-equal undefined, string-to-sexpr '(1 2)'

    specify 'should return undefined when application starts with unknown operator' !->
        strict-equal undefined, string-to-sexpr '($ 1 2)'

    specify 'should return undefined when argument count does not fit arity/variadicity' !->
        strict-equal undefined, string-to-sexpr '(+ 1)'
        strict-equal undefined, string-to-sexpr '(- 1 2 3)'

    specify 'should return undefined when additional non-space chars after complete expression' !->
        strict-equal undefined, string-to-sexpr '(+ a b)  0  '

    specify 'should return undefined when application is empty' !->
        strict-equal undefined, string-to-sexpr '()'

    specify 'should return undefined when input is blank' !->
        strict-equal undefined, string-to-sexpr ''
