require! \prelude-ls : {
    concat,
    concat-map,
    filter,
    fold,
    head,
    is-type,
    join,
    map,
    pairs-to-obj,
    reverse,
    slice,
    split-at,
    tail,
    unfoldr,
    unwords,
    words
}

#
# Operator Definitions
#

class Operator
    (@name, @arity, @variadic, @fixity, @precedence) -> this

defop = (name) -> [name, new Operator ...]

ops =
    pairs-to-obj [
        defop \+,    2, true,  \infix,  3
        defop \-,    2, false, \infix,  3
        defop \*,    2, true,  \infix,  2
        defop \/,    2, false, \infix,  2
        defop \^,    2, false, \infix,  1
        defop \neg,  1, false, \prefix, 1
        defop \sqrt, 1, false, \prefix, 4
    ]

#
# General Helpers
#

cons = (item, list) --> concat [[item], list]
cons-last = (item, list) --> concat [list, [item]]
is-array = is-type \Array
unfold = (f) ->
    build = (x) ->
        y = f!
        if y then [y, x] else null
    unfoldr build, 0

#
# Variadic Application Helpers
#

unvary-application = (op, arity, args) ->
    | args.length <= arity
        cons op, args
    | otherwise
        [these, those] = split-at (arity - 1), args
        nested = unvary-application op, arity, those
        cons op, these |> cons-last nested

vary-application = (op, arity, args) ->
    combine = (expr) ->
        if is-array expr and op == head expr then
            vary-application op, arity, expr |> tail
        else
            [expr]
    concat-map combine, args

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
# S-Expression Parsing
#

class SexprParser
    (text) ->
        @pos = 0
        @text = text

    is-done: -> @text.length <= @pos

    current: -> if @is-done! then undefined else @text.charAt @pos

    skip-one: !-> @pos++

    skip-while: (f) !->
        while not @is-done! and f @current!
            @skip-one!

    read-literal: ->
        start = @pos
        @skip-while (ch) -> ch != \( && ch != \) && ch == /\S/
        end = @pos
        unparsed-literal = slice start, end, @text

        if unparsed-literal == /^\x2D?\d/ then
            parse-float unparsed-literal
        else
            unparsed-literal

    read-one: ~>
        @skip-while (== /\s/)

        if @is-done! then
            throw new Error "Unexpected end of expression"

        switch @current!
        | \( => @skip-one!; unfold @read-one
        | \) => @skip-one!; undefined
        | otherwise => @read-literal!

#
# Exported Conversion Functions
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

export postfix-to-string = unwords

export sexpr-to-postfix = combine-variadic >> split-variadic >> (expr) ->
    | is-array expr
        [op, ...args] = expr
        concat-map sexpr-to-postfix, args |> cons-last op
    | otherwise
        [expr]

export sexpr-to-string = (expr) ->
    | is-array expr
        "(#{map sexpr-to-string, expr |> unwords})"
    | otherwise
        expr

export sexpr-to-tex = (expr) ->
    | is-array expr
        [op, ...args] = expr
        switch op
        | \* => "{#{map sexpr-to-tex, args |> unwords}}"
        | \+ => "{#{map sexpr-to-tex, args |> join ' + '}}"
        | \- \^ => "{#{sexpr-to-tex args[0]} #{op} #{sexpr-to-tex args[1]}}"
        | \/ => "{\\frac #{sexpr-to-tex args[0]} #{sexpr-to-tex args[1]}}"
        | \neg => "{- #{sexpr-to-tex args[0]}}"
        | \sqrt => "{\\sqrt #{sexpr-to-tex args[0]}}"
    | otherwise
        expr

export string-to-postfix = words >> filter (== /^\S+$/)

export string-to-sexpr = (s) -> new SexprParser s .read-one!
