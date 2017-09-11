require! \assert : {deepEqual, equal}
require! '../main/index' : {format-postfix, format-sexpr, postfix-to-sexpr, sexpr-to-katex, sexpr-to-postfix}

describe 'postfix -> sexpr' ->
    specify 'should combine variadic applications' ->
        deepEqual([\+ 1 2 3 4], postfix-to-sexpr [1 2 3 4 \+ \+ \+])

describe 'sexpr -> postfix' ->
    specify 'should split variadic applications' ->
        deepEqual([1 2 3 4 \+ \+ \+], sexpr-to-postfix [\+ 1 2 3 4])

describe 'formatting postfix' ->
    specify 'should provide consistent spacing' ->
        equal('1 2 3 + *', format-postfix [1 2 3 \+ \*])

describe 'formatting sexprs' ->
    specify 'should provide consistent spacing' ->
        equal('(+ 1 2 (* 3 4) 5)', format-sexpr [\+ 1 2 [\* 3 4] 5])
