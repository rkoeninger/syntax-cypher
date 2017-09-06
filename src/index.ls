require! \prelude-ls : {concat, concat-map, empty, filter, fold, head, is-type, join, map, pairs-to-obj, split-at, tail}

cons = (item, list) --> concat [[item], list]
cons-last = (list, item) --> concat [list, [item]]
snoc = (list) -> [(head list), (tail list)]

class Operator
    (name, arity, variadic) ->
        @name = name
        @arity = arity
        @variadic = variadic

defop = (name, arity, variadic) -> [name, new Operator name, arity, variadic]

ops =
    pairs-to-obj [
        (defop \+,    2, true),
        (defop \*,    2, true),
        (defop \-,    2, false),
        (defop \/,    2, false),
        (defop \^,    2, false),
        (defop \neg,  1, false),
        (defop \sqrt, 1, false)]

unvary-application = (op, args, arity) ->
    | args.length <= arity
        cons op, args
    | otherwise
        [these, those] = split-at (arity - 1), args
        nested = unvary-application op, those, arity
        cons op, these |> cons-last _, nested

vary-application = (op, args, arity) ->
    embed = (expr) ->
        | is-type \Array expr and op == head expr
            tail expr
        | otherwise
            [expr]
    concat-map embed, args |> cons op

split-variadic = (expr) ->
    | is-type \Array expr
        [op, args] = snoc expr
        {variadic, arity} = ops[op]
        if variadic and arity < args.length then
            unvary-application op, args, arity
        else
            map split-variadic, args |> cons op
    | otherwise
        expr

combine-variadic = (expr) ->
    | is-type \Array expr
        [op, args] = snoc expr
        {variadic, arity} = ops[op]
        if variadic then
            vary-application op, args, arity
        else
            map combine-variadic, args |> cons op
    | otherwise
        expr

sexpr-to-postfix = split-variadic >> (expr) ->
    | is-type \Array expr
        [op, args] = snoc expr
        concat-map sexpr-to-postfix, args |> cons-last _, op
    | otherwise
        [expr]

postfix-to-sexpr = (line) ->
    push-word = (stack, item) ->
        | item of ops
            {arity} = ops[item]
            [args, stack] = split-at arity, stack
            cons item, args |> cons _, stack
        | otherwise
            cons item, stack
    fold push-word, [], line |> head |> combine-variadic

format-sexpr = (expr) ->
    | is-type \Array expr
        "(#{map format-sexpr, expr |> join ' '})"
    | otherwise
        expr

format-postfix = (line) -> join ' ' line
