require! \prelude-ls : {concat, empty, foldr, head, is-type, map, pairs-to-obj, split-at}

cons = (item, list) -> concat [[item], list]

cons-last = (list, item) -> concat [list, [item]]

class Operator
    (name, arity, variadic) ->
        @name = name
        @arity = arity
        @variadic = variadic

op = (name, arity, variadic) -> [name, new Operator name, arity, variadic]

ops =
    pairs-to-obj [
        (op \+,    2, true),
        (op \*,    2, true),
        (op \-,    2, false),
        (op \/,    2, false),
        (op \^,    2, false),
        (op \neg,  1, false),
        (op \sqrt, 1, false)]

sexpr-to-postfix = (expr) ->
    | is-type \Array expr
        [func, args] = split-at 0 expr
        map sexpr-to-postfix, args |> cons-last _, func
    | otherwise
        expr

postfix-to-sexpr = (line) ->
    push-word = (item, stack) ->
        | item of ops
            [args, stack] = split-at ops[item].arity, stack
            cons item, args |> cons _, stack
        | otherwise
            cons item, stack
    foldr push-word, [], line |> head
