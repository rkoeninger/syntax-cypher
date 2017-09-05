require! \prelude-ls : {concat, empty, foldr, head, is-type, map, split-at, tail}

cons = (item, list) -> concat [[item], list]

cons-last = (list, item) -> concat [list, [item]]

arities =
    \+    : 2
    \*    : 2
    \-    : 2
    \/    : 2
    \^    : 2
    \neg  : 1
    \sqrt : 1

sexpr-to-postfix = (expr) ->
    | is-type \Array expr
        op = head expr
        args = tail expr |> map sexpr-to-postfix
        cons-last args, op
    | otherwise
        expr

postfix-to-sexpr = (line) ->
    f = (item, stack) ->
        | item of arities
            [args, rest] = split-at arities[item], stack
            cons item, args |> cons _, rest
        | otherwise
            cons item, stack
    foldr f, [], line |> head
