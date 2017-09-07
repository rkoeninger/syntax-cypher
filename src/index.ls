require! \prelude-ls : {concat, concat-map, empty, filter, fold, head, is-type, join, map, pairs-to-obj, reverse, split-at, tail}

cons = (item, list) --> concat [[item], list]
cons-last = (item, list) --> concat [list, [item]]
snoc = (list) -> [(head list), (tail list)]
is-array = is-type \Array

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

unvary-application = (op, arity, args) ->
    | args.length <= arity
        cons op, args
    | otherwise
        [these, those] = split-at (arity - 1), args
        nested = unvary-application op, arity, those
        cons op, these |> cons-last nested

vary-application-h = (op, arity, args) ->
    recur = (expr) ->
        | is-array expr and op == head expr
            vary-application-h op, arity, expr
        | otherwise
            expr
    lift = (expr) ->
        | is-array expr and op == head expr
            tail expr
        | otherwise
            [expr]
    map recur, args |> concat-map lift

vary-application = (op, arity, args) -> vary-application-h op, arity, args |> cons op

split-variadic = (expr) ->
    | is-array expr
        [op, args] = snoc expr
        {variadic, arity} = ops[op]
        if variadic and arity < args.length then
            unvary-application op, arity, args
        else
            map split-variadic, args |> cons op
    | otherwise
        expr

combine-variadic = (expr) ->
    | is-array expr
        [op, args] = snoc expr
        {variadic, arity} = ops[op]
        if variadic then
            vary-application op, arity, args
        else
            map combine-variadic, args |> cons op
    | otherwise
        expr

sexpr-to-postfix = split-variadic >> (expr) ->
    | is-array expr
        [op, args] = snoc expr
        concat-map sexpr-to-postfix, args |> cons-last op
    | otherwise
        [expr]

postfix-to-sexpr = (line) ->
    push-word = (stack, item) ->
        | item of ops
            {arity} = ops[item]
            [args, stack] = split-at arity, stack
            cons item, reverse args |> cons _, stack
        | otherwise
            cons item, stack
    fold push-word, [], line |> head |> combine-variadic

format-sexpr = (expr) ->
    | is-array expr
        "(#{map format-sexpr, expr |> join ' '})"
    | otherwise
        expr

format-postfix = (line) -> join ' ' line
