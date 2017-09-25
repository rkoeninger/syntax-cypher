var ref$, any, chars, concat, concatMap, each, filter, fold, head, isType, join, map, pairsToObj, reverse, slice, splitAt, tail, unfoldr, unwords, words, Operator, defop, ops, cons, consLast, isArray, isNumber, tryParseNumber, isDefined, unfold, unvaryApplication, varyApplication, splitVariadic, combineVariadic, SexprParser, validateSexpr, evalPostfix, validatePostfix, postfixToSexpr, postfixToString, sexprToPostfix, sexprToString, sexprToTex, stringToPostfix, stringToSexpr, slice$ = [].slice, out$ = typeof exports != 'undefined' && exports || this;
ref$ = require('prelude-ls'), any = ref$.any, chars = ref$.chars, concat = ref$.concat, concatMap = ref$.concatMap, each = ref$.each, filter = ref$.filter, fold = ref$.fold, head = ref$.head, isType = ref$.isType, join = ref$.join, map = ref$.map, pairsToObj = ref$.pairsToObj, reverse = ref$.reverse, slice = ref$.slice, splitAt = ref$.splitAt, tail = ref$.tail, unfoldr = ref$.unfoldr, unwords = ref$.unwords, words = ref$.words;
Operator = (function(){
  Operator.displayName = 'Operator';
  var prototype = Operator.prototype, constructor = Operator;
  function Operator(name, arity, variadic, fixity, precedence){
    this;
    this.name = name;
    this.arity = arity;
    this.variadic = variadic;
    this.fixity = fixity;
    this.precedence = precedence;
  }
  return Operator;
}());
defop = function(it){
  return [
    it, (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args), t;
      return (t = typeof result)  == "object" || t == "function" ? result || child : child;
  })(Operator, arguments, function(){})
  ];
};
ops = pairsToObj([defop('+', 2, true, 'infix', 2), defop('-', 2, false, 'infix', 2), defop('*', 2, true, 'infix', 3), defop('/', 2, false, 'infix', null), defop('^', 2, false, 'infix', 4), defop('+/-', 2, false, 'infix', 2), defop('neg', 1, false, 'prefix', 4), defop('sqrt', 1, false, 'prefix', null)]);
cons = curry$(function(item, list){
  return concat([[item], list]);
});
consLast = curry$(function(item, list){
  return concat([list, [item]]);
});
isArray = isType('Array');
isNumber = isType('Number');
tryParseNumber = function(it){
  if (/^(\-|\+)?([0-9]+(\.[0-9]+)?)$/.exec(it)) {
    return parseFloat(it);
  } else {
    return it;
  }
};
isDefined = function(it){
  return !isType('Undefined', it);
};
unfold = function(f){
  var build;
  build = function(it){
    var y;
    y = f();
    if (isDefined(y)) {
      return [y, it];
    }
  };
  return unfoldr(build, 0);
};
unvaryApplication = function(op, arity, args){
  var ref$, these, those, nested;
  switch (false) {
  case !(args.length <= arity):
    return cons(op, args);
  default:
    ref$ = splitAt(arity - 1, args), these = ref$[0], those = ref$[1];
    nested = unvaryApplication(op, arity, those);
    return consLast(nested)(
    cons(op, these));
  }
};
varyApplication = function(op, arity, args){
  var combine;
  combine = function(expr){
    if (isArray(expr) && op === head(expr)) {
      return tail(
      varyApplication(op, arity, expr));
    } else {
      return [expr];
    }
  };
  return concatMap(combine, args);
};
splitVariadic = function(expr){
  var op, args, ref$, variadic, arity;
  switch (false) {
  case !isArray(expr):
    op = expr[0], args = slice$.call(expr, 1);
    ref$ = ops[op], variadic = ref$.variadic, arity = ref$.arity;
    if (variadic && arity < args.length) {
      return unvaryApplication(op, arity, args);
    } else {
      return cons(op)(
      map(splitVariadic, args));
    }
    break;
  default:
    return expr;
  }
};
combineVariadic = function(expr){
  var op, args, ref$, variadic, arity;
  switch (false) {
  case !isArray(expr):
    op = expr[0], args = slice$.call(expr, 1);
    ref$ = ops[op], variadic = ref$.variadic, arity = ref$.arity;
    if (variadic) {
      return cons(op)(
      varyApplication(op, arity, args));
    } else {
      return cons(op)(
      map(combineVariadic, args));
    }
    break;
  default:
    return expr;
  }
};
SexprParser = (function(){
  SexprParser.displayName = 'SexprParser';
  var prototype = SexprParser.prototype, constructor = SexprParser;
  function SexprParser(text){
    this.read = bind$(this, 'read', prototype);
    this.pos = 0;
    this.text = text;
  }
  SexprParser.prototype.isDone = function(){
    return this.text.length <= this.pos;
  };
  SexprParser.prototype.hasRemainingInput = function(){
    var this$ = this;
    return any((function(it){
      return /\S/.exec(it);
    }))(
    chars(
    slice(this.pos, this.text.length, this.text)));
  };
  SexprParser.prototype.current = function(){
    if (this.isDone()) {
      return undefined;
    } else {
      return this.text.charAt(this.pos);
    }
  };
  SexprParser.prototype.skipOne = function(){
    this.pos++;
  };
  SexprParser.prototype.skipWhile = function(f){
    while (!this.isDone() && f(this.current())) {
      this.skipOne();
    }
  };
  SexprParser.prototype.readLiteral = function(){
    var start, end;
    start = this.pos;
    this.skipWhile(function(ch){
      return ch !== '(' && ch !== ')' && /\S/.exec(ch);
    });
    end = this.pos;
    return tryParseNumber(slice(start, end, this.text));
  };
  SexprParser.prototype.read = function(){
    var this$ = this;
    this.skipWhile((function(it){
      return /\s/.exec(it);
    }));
    if (this.isDone()) {
      throw new Error('Unexpected end of expression');
    }
    switch (this.current()) {
    case '(':
      this.skipOne();
      return unfold(this.read);
    case ')':
      this.skipOne();
      return undefined;
    default:
      return this.readLiteral();
    }
  };
  return SexprParser;
}());
validateSexpr = function(expr){
  var op, args, ref$, arity, variadic;
  if (isArray(expr)) {
    op = expr[0], args = slice$.call(expr, 1);
    if (op in ops) {
      ref$ = ops[op], arity = ref$.arity, variadic = ref$.variadic;
      if (args.length < arity) {
        throw new Error("Too few arguments for operator " + op);
      }
      if (!variadic && args.length !== arity) {
        throw new Error("Too many arguments for operator " + op);
      }
      return each(validateSexpr, args);
    } else {
      throw new Error("Unrecognized operator " + op);
    }
  }
};
out$.evalPostfix = evalPostfix = function(line){
  var pushWord;
  pushWord = function(stack, item){
    var arity, ref$, args;
    switch (false) {
    case !(item in ops):
      arity = ops[item].arity;
      if (stack.length < arity) {
        throw new Error('Stack underflow');
      }
      ref$ = splitAt(arity, stack), args = ref$[0], stack = ref$[1];
      return cons(cons(item)(
      reverse(args)), stack);
    default:
      return cons(item, stack);
    }
  };
  return fold(pushWord, [], line);
};
out$.validatePostfix = validatePostfix = function(line){
  var this$ = this;
  if ((function(it){
    return it === 1;
  })(
  function(it){
    return it.length;
  }(
  evalPostfix(line)))) {
    return line;
  } else {
    throw new Error('Line does not leave exactly 1 value on the stack');
  }
};
out$.postfixToSexpr = postfixToSexpr = compose$(evalPostfix, head, combineVariadic);
out$.postfixToString = postfixToString = unwords;
out$.sexprToPostfix = sexprToPostfix = compose$(combineVariadic, splitVariadic, function(expr){
  var op, args;
  switch (false) {
  case !isArray(expr):
    op = expr[0], args = slice$.call(expr, 1);
    return consLast(op)(
    concatMap(sexprToPostfix, args));
  default:
    return [expr];
  }
});
out$.sexprToString = sexprToString = function(expr){
  switch (false) {
  case !isArray(expr):
    return "(" + unwords(
    map(sexprToString, expr)) + ")";
  default:
    return expr;
  }
};
out$.sexprToTex = sexprToTex = function(expr, context){
  var ref$, op, args, precedence, recur, tex, sep, this$ = this;
  context == null && (context = null);
  switch (false) {
  case !isArray(expr):
    ref$ = combineVariadic(expr), op = ref$[0], args = slice$.call(ref$, 1);
    precedence = ops[op].precedence;
    recur = partialize$.apply(this, [sexprToTex, [void 8, precedence], [0]]);
    tex = (function(){
      switch (op) {
      case '*':
        sep = (function(it){
          return it > 1;
        })(
        function(it){
          return it.length;
        }(
        filter(isNumber, args))) ? ' * ' : ' ';
        return "{" + join(sep)(
        map(recur, args)) + "}";
      case '+':
        return "{" + join(' + ')(
        map(recur, args)) + "}";
      case '-':
      case '^':
        return "{" + recur(args[0]) + " " + op + " " + recur(args[1]) + "}";
      case '/':
        return "{\\frac " + recur(args[0]) + " " + recur(args[1]) + "}";
      case '+/-':
        return "{" + recur(args[0]) + " \\pm " + recur(args[1]) + "}";
      case 'neg':
        return "{- " + recur(args[0]) + "}";
      case 'sqrt':
        return "{\\sqrt " + recur(args[0]) + "}";
      }
    }());
    if (precedence && context && precedence < context) {
      return "{\\left( " + tex + " \\right)}";
    } else {
      return tex;
    }
    break;
  default:
    return expr.toString();
  }
};
out$.stringToPostfix = stringToPostfix = function(it){
  var this$ = this;
  return validatePostfix(
  map(tryParseNumber)(
  filter((function(it){
    return /^\S+$/.exec(it);
  }))(
  words(it))));
};
out$.stringToSexpr = stringToSexpr = function(it){
  var parser, sexpr;
  parser = new SexprParser(it);
  sexpr = parser.read();
  if (validateSexpr(sexpr) && !parser.hasRemainingInput()) {
    return sexpr;
  } else {
    throw new Error('Excess syntax beyond end of first expression');
  }
};
function curry$(f, bound){
  var context,
  _curry = function(args) {
    return f.length > 1 ? function(){
      var params = args ? args.concat() : [];
      context = bound ? context || this : this;
      return params.push.apply(params, arguments) <
          f.length && arguments.length ?
        _curry.call(context, params) : f.apply(context, params);
    } : f;
  };
  return _curry();
}
function bind$(obj, key, target){
  return function(){ return (target || obj)[key].apply(obj, arguments) };
}
function compose$() {
  var functions = arguments;
  return function() {
    var i, result;
    result = functions[0].apply(this, arguments);
    for (i = 1; i < functions.length; ++i) {
      result = functions[i](result);
    }
    return result;
  };
}
function partialize$(f, args, where){
  var context = this;
  return function(){
    var params = slice$.call(arguments), i,
        len = params.length, wlen = where.length,
        ta = args ? args.concat() : [], tw = where ? where.concat() : [];
    for(i = 0; i < len; ++i) { ta[tw[0]] = params[i]; tw.shift(); }
    return len < wlen && len ?
      partialize$.apply(context, [f, ta, tw]) : f.apply(context, ta);
  };
}