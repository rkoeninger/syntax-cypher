var ref$, deepEqual, equal, ok, throws, isType, postfixToSexpr, postfixToString, sexprToPostfix, sexprToString, sexprToTex, stringToPostfix, stringToSexpr;
ref$ = require('assert'), deepEqual = ref$.deepEqual, equal = ref$.equal, ok = ref$.ok, throws = ref$.throws;
isType = require('prelude-ls').isType;
ref$ = require('../main/cypher'), postfixToSexpr = ref$.postfixToSexpr, postfixToString = ref$.postfixToString, sexprToPostfix = ref$.sexprToPostfix, sexprToString = ref$.sexprToString, sexprToTex = ref$.sexprToTex, stringToPostfix = ref$.stringToPostfix, stringToSexpr = ref$.stringToSexpr;
describe('postfix -> sexpr', function(){
  specify('should combine variadic applications', function(){
    deepEqual(['+', 1, 2, 3, 4], postfixToSexpr([1, 2, 3, 4, '+', '+', '+']));
    deepEqual(['+', 1, 2, 3, 4], postfixToSexpr([1, 2, '+', 3, '+', 4, '+']));
  });
});
describe('postfix -> string', function(){
  specify('should provide consistent spacing', function(){
    equal('1 2 3 + *', postfixToString([1, 2, 3, '+', '*']));
    equal('b 2 ^ 4 a c * * -', postfixToString(['b', 2, '^', 4, 'a', 'c', '*', '*', '-']));
  });
});
describe('sexpr -> postfix', function(){
  specify('should split variadic applications', function(){
    deepEqual([1, 2, 3, 4, '+', '+', '+'], sexprToPostfix(['+', 1, 2, 3, 4]));
    deepEqual([1, 2, 3, 4, '+', '+', '+'], sexprToPostfix(['+', ['+', 1, 2], ['+', 3, 4]]));
  });
});
describe('sexpr -> string', function(){
  specify('should provide consistent spacing', function(){
    equal('(+ 1 2 (* 3 4) 5)', sexprToString(['+', 1, 2, ['*', 3, 4], 5]));
    equal('(- (^ b 2) (* 4 a c))', sexprToString(['-', ['^', 'b', 2], ['*', 4, 'a', 'c']]));
  });
});
describe('sexpr -> tex', function(){
  specify('should handle variadic applications', function(){
    equal('{1 + 2 + 3 + 4}', sexprToTex(['+', 1, 2, 3, 4]));
    equal('{a b c}', sexprToTex(['*', 'a', 'b', 'c']));
  });
  specify('should convert division to \\frac', function(){
    equal('{\\frac {2 a} b}', sexprToTex(['/', ['*', 2, 'a'], 'b']));
  });
  specify('should add parens when nested op of lower precendence', function(){
    equal('{a {\\left( {b + c} \\right)}}', sexprToTex(['*', 'a', ['+', 'b', 'c']]));
  });
  specify('should use explicit multiplication op when multiplying constants', function(){
    equal('{2 * 3}', sexprToTex(['*', 2, 3]));
  });
  specify('should always return a string', function(){
    ok(isType('String', sexprToTex(0)));
    ok(isType('String', sexprToTex('+')));
  });
});
describe('string -> postfix', function(){
  specify('should handle arbitrary spacing', function(){
    deepEqual(['a', 'b', '+'], stringToPostfix('   a  b    +  '));
  });
  specify('should parse numeric literals', function(){
    deepEqual([2, 3, '+'], stringToPostfix('2 3 +'));
  });
  specify('should throw when line doesnt eval to single value', function(){
    throws(function(){
      stringToPostfix('1 2 3 +');
    });
  });
  specify('should throw on stack underflow', function(){
    throws(function(){
      stringToPostfix('1 +');
    });
  });
  specify('should throw when input is blank', function(){
    throws(function(){
      stringToPostfix('');
    });
  });
});
describe('string -> sexpr', function(){
  specify('should handle nested expressions', function(){
    deepEqual(['*', ['+', 'a', 1], ['-', 'b', 2]], stringToSexpr('(* (+ a 1) (- b 2))'));
  });
  specify('should handle arbitrary whitespace', function(){
    deepEqual(['*', ['+', 'a', 1], ['-', 'b', 2]], stringToSexpr('   ( *   ( + a    1 ) (- b   2) )   '));
  });
  specify('should parse numeric literals', function(){
    deepEqual(['+', 2, 3], stringToSexpr('(+ 2 3)'));
  });
  specify('should read expressions that are falsy in javascript', function(){
    deepEqual(['+', 0, 0], stringToSexpr('(+ 0 0)'));
  });
  specify('should throw when parens unmatched', function(){
    throws(function(){
      stringToSexpr('(+ 1 2');
    });
    throws(function(){
      stringToSexpr('(+ 1 () 2');
    });
  });
  specify('should throw when application starts with non-operator', function(){
    throws(function(){
      stringToSexpr('(1 2)');
    });
  });
  specify('should throw when application starts with unknown operator', function(){
    throws(function(){
      stringToSexpr('($ 1 2)');
    });
  });
  specify('should throw when argument count does not fit arity/variadicity', function(){
    throws(function(){
      stringToSexpr('(+ 1)');
    });
    throws(function(){
      stringToSexpr('(- 1 2 3)');
    });
  });
  specify('should throw when additional non-space chars after complete expression', function(){
    throws(function(){
      stringToSexpr('(+ a b)  0  ');
    });
  });
  specify('should throw when application is empty', function(){
    throws(function(){
      stringToSexpr('()');
    });
  });
  specify('should throw when input is blank', function(){
    throws(function(){
      stringToSexpr('');
    });
  });
});