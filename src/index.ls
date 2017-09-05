{concat, empty, head, is-type, map, tail} = require \prelude-js

sexpr-to-postfix = (expr) ->
    | is-type \Array expr then
        op = head expr
        args = tail expr |> map sexpr-to-postfix
        concat args, [op]
    | true then
        expr
