require! \prelude-ls : {concat, concat-map, fold, head, is-type, join, map, pairs-to-obj, reverse, split-at, tail}

cons = (item, list) --> concat [[item], list]
cons-last = (item, list) --> concat [list, [item]]
is-array = is-type \Array

class Operator
    (name, arity, variadic, fixity, precedence) ->
        @name = name
        @arity = arity
        @variadic = variadic
        @fixity = fixity
        @precedence = precedence

defop = (name, arity, variadic) -> [name, new Operator name, arity, variadic]

ops =
    pairs-to-obj [
        (defop \+,    2, true,  \infix,  3),
        (defop \-,    2, false, \infix,  3),
        (defop \*,    2, true,  \infix,  2),
        (defop \/,    2, false, \infix,  2),
        (defop \^,    2, false, \infix,  1),
        (defop \neg,  1, false, \prefix, 1),
        (defop \sqrt, 1, false, \prefix, 4)]

#
# Syntax manipulation helpers
#

unvary-application = (op, arity, args) ->
    | args.length <= arity
        cons op, args
    | otherwise
        [these, those] = split-at (arity - 1), args
        nested = unvary-application op, arity, those
        cons op, these |> cons-last nested

vary-application = (op, arity, args) ->
    recur = (expr) ->
        | is-array expr and op == head expr
            vary-application op, arity, expr
        | otherwise
            expr
    lift = (expr) ->
        | is-array expr and op == head expr
            tail expr
        | otherwise
            [expr]
    map recur, args |> concat-map lift

split-variadic = (expr) ->
    | is-array expr
        [op, ...args] = expr
        {variadic, arity} = ops[op]
        if variadic and arity < args.length then
            unvary-application op, arity, args
        else
            map split-variadic, args |> cons op
    | otherwise
        expr

combine-variadic = (expr) ->
    | is-array expr
        [op, ...args] = expr
        {variadic, arity} = ops[op]
        if variadic then
            vary-application op, arity, args |> cons op
        else
            map combine-variadic, args |> cons op
    | otherwise
        expr

#
# Exported conversion functions
#

export postfix-to-sexpr = (line) ->
    push-word = (stack, item) ->
        | item of ops
            {arity} = ops[item]
            [args, stack] = split-at arity, stack
            reverse args |> cons item |> cons _, stack
        | otherwise
            cons item, stack
    fold push-word, [], line |> head |> combine-variadic

export postfix-to-string = (line) -> join ' ' line

export sexpr-to-katex = (expr) ->
    | is-array expr
        [op, ...args] = expr
        switch op
        | \* => "{#{map sexpr-to-katex, args |> join ' '}}"
        | \+ => "{#{map sexpr-to-katex, args |> join ' + '}}"
        | \- \^ => "{#{sexpr-to-katex args[0]} #{op} #{sexpr-to-katex args[1]}}"
        | \/ =>
            if is-array args[0] or is-array args[1] then
                "{\\frac {#{sexpr-to-katex args[0]}}{#{sexpr-to-katex args[1]}}}"
            else
                "{#{sexpr-to-katex args[0]} / #{sexpr-to-katex args[1]}}"
        | \neg => "{- #{sexpr-to-katex args[0]}}"
        | \sqrt => "{\\sqrt #{sexpr-to-katex args[0]}}"
    | otherwise
        expr

export sexpr-to-postfix = combine-variadic >> split-variadic >> (expr) ->
    | is-array expr
        [op, ...args] = expr
        concat-map sexpr-to-postfix, args |> cons-last op
    | otherwise
        [expr]

export sexpr-to-string = (expr) ->
    | is-array expr
        "(#{map sexpr-to-string, expr |> join ' '})"
    | otherwise
        expr
