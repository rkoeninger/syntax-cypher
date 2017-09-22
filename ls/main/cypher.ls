require! \prelude-ls : {
    any,
    chars,
    concat,
    concat-map,
    each,
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

defop = -> [it, new Operator ...]

ops =
    pairs-to-obj [
        defop \+,    2, true,  \infix,  2
        defop \-,    2, false, \infix,  2
        defop \*,    2, true,  \infix,  3
        defop \/,    2, false, \infix,  null
        defop \^,    2, false, \infix,  4
        defop \+/-,  2, false, \infix,  2
        defop \neg,  1, false, \prefix, 4
        defop \sqrt, 1, false, \prefix, null
    ]

#
# General Helpers
#

cons = (item, list) --> concat [[item], list]
cons-last = (item, list) --> concat [list, [item]]
is-array = is-type \Array
is-number = is-type \Number
try-parse-number = ->
    if it == /^(\-|\+)?([0-9]+(\.[0-9]+)?)$/ then
        parse-float it
    else
        it
is-defined = -> not is-type \Undefined it
unfold = (f) ->
    build = ->
        y = f!
        if is-defined y then [y, it]
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

    has-remaining-input: -> slice @pos, @text.length, @text |> chars |> any (== /\S/)

    current: -> if @is-done! then undefined else @text.charAt @pos

    skip-one: !-> @pos++

    skip-while: (f) !->
        while not @is-done! and f @current!
            @skip-one!

    read-literal: ->
        start = @pos
        @skip-while (ch) -> ch != \( && ch != \) && ch == /\S/
        end = @pos
        try-parse-number slice start, end, @text

    read: ~>
        @skip-while (== /\s/)

        if @is-done! then
            throw new Error 'Unexpected end of expression'

        switch @current!
        | \( => @skip-one!; unfold @read
        | \) => @skip-one!; undefined
        | otherwise => @read-literal!

validate-sexpr = (expr) ->
    if is-array expr then
        [op, ...args] = expr
        if op of ops then
            {arity, variadic} = ops[op]
            if args.length < arity then
                throw new Error "Too few arguments for operator #{op}"
            if not variadic and args.length != arity
                throw new Error "Too many arguments for operator #{op}"
            each validate-sexpr, args
        else
            throw new Error "Unrecognized operator #{op}"

#
# Postfix Validation
#

export eval-postfix = (line) ->
    push-word = (stack, item) ->
        | item of ops
            {arity} = ops[item]
            if stack.length < arity then
                throw new Error 'Stack underflow'
            [args, stack] = split-at arity, stack
            reverse args |> cons item |> cons _, stack
        | otherwise
            cons item, stack
    fold push-word, [], line

export validate-postfix = (line) ->
    if eval-postfix line |> (.length) |> (== 1) then
        line
    else
        throw new Error 'Line does not leave exactly 1 value on the stack'

#
# Exported Conversion Functions
#

export postfix-to-sexpr = eval-postfix >> head >> combine-variadic

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

export sexpr-to-tex = (expr, context = null) ->
    | is-array expr
        [op, ...args] = combine-variadic expr
        {precedence} = ops[op]
        recur = sexpr-to-tex _, precedence
        tex =
            switch op
            | \* =>
                sep = if filter is-number, args |> (.length) |> (> 1) then ' * ' else ' '
                "{#{map recur, args |> join sep}}"
            | \+ => "{#{map recur, args |> join ' + '}}"
            | \- \^ => "{#{recur args[0]} #{op} #{recur args[1]}}"
            | \/ => "{\\frac #{recur args[0]} #{recur args[1]}}"
            | \+/- => "{#{recur args[0]} \\pm #{recur args[1]}}"
            | \neg => "{- #{recur args[0]}}"
            | \sqrt => "{\\sqrt #{recur args[0]}}"
        if precedence and context and precedence < context then
            "{\\left( #{tex} \\right)}"
        else
            tex
    | otherwise
        expr.to-string!

export string-to-postfix = -> words it |> filter (== /^\S+$/) |> map try-parse-number |> validate-postfix

export string-to-sexpr = ->
    parser = new SexprParser it
    sexpr = parser.read!
    if validate-sexpr sexpr and not parser.has-remaining-input! then
        sexpr
    else
        throw new Error 'Excess syntax beyond end of first expression'
