require! \assert : {deepEqual, equal}
require! '../main/index' : {postfix-to-sexpr, postfix-to-string, sexpr-to-postfix, sexpr-to-string, sexpr-to-tex}

describe 'postfix -> sexpr' ->
    specify 'should combine variadic applications' ->
        deepEqual [\+ 1 2 3 4], postfix-to-sexpr [1 2 3 4 \+ \+ \+]
        deepEqual [\+ 1 2 3 4], postfix-to-sexpr [1 2 \+ 3 \+ 4 \+]

describe 'postfix -> string' ->
    specify 'should provide consistent spacing' ->
        equal '1 2 3 + *', postfix-to-string [1 2 3 \+ \*]
        equal 'b 2 ^ 4 a c * * -', postfix-to-string [\b 2 \^ 4 \a \c \* \* \-]

describe 'sexpr -> tex' ->
    specify 'should handle variadic applications' ->
        equal '{1 + 2 + 3 + 4}', sexpr-to-tex [\+ 1 2 3 4]
        equal '{a b c}', sexpr-to-tex [\* \a \b \c]

    specify 'should convert division to \\frac' ->
        equal '{\\frac {2 a} b}', sexpr-to-tex [\/ [\* 2 \a] \b]

describe 'sexpr -> postfix' ->
    specify 'should split variadic applications' ->
        deepEqual [1 2 3 4 \+ \+ \+], sexpr-to-postfix [\+ 1 2 3 4]
        deepEqual [1 2 3 4 \+ \+ \+], sexpr-to-postfix [\+ [\+ 1 2] [\+ 3 4]]

describe 'sexpr -> string' ->
    specify 'should provide consistent spacing' ->
        equal '(+ 1 2 (* 3 4) 5)', sexpr-to-string [\+ 1 2 [\* 3 4] 5]
        equal '(- (^ b 2) (* 4 a c))', sexpr-to-string [\- [\^ \b 2] [\* 4 \a \c]]
