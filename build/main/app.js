var ref$, chars, reverse, unchars, postfixToSexpr, postfixToString, sexprToPostfix, sexprToString, sexprToTex, stringToPostfix, stringToSexpr, renderToString, Vue, _, updateFromValidCode, updateFromPostfixError, updateFromSexprError, updateFromPostfixCode, updateFromSexprCode, initVue;
ref$ = require('prelude-ls'), chars = ref$.chars, reverse = ref$.reverse, unchars = ref$.unchars;
ref$ = require('./cypher'), postfixToSexpr = ref$.postfixToSexpr, postfixToString = ref$.postfixToString, sexprToPostfix = ref$.sexprToPostfix, sexprToString = ref$.sexprToString, sexprToTex = ref$.sexprToTex, stringToPostfix = ref$.stringToPostfix, stringToSexpr = ref$.stringToSexpr;
renderToString = require('katex').renderToString;
Vue = require('vue');
_ = require('../../node_modules/bulma/css/bulma.css');
_ = require('../../node_modules/katex/dist/katex.css');
_ = require('../../main.css');
updateFromValidCode = function(it){
  it.postfixDisabled = false;
  it.sexprDisabled = false;
  it.texDisabled = false;
  it.mathDisabled = false;
  it.postfixError = '';
  it.sexprError = '';
};
updateFromPostfixError = function(data, message){
  data.postfixDisabled = false;
  data.sexprDisabled = true;
  data.texDisabled = true;
  data.mathDisabled = true;
  data.postfixError = message;
  data.sexprError = '';
  return data.mathHtml = '';
};
updateFromSexprError = function(data, message){
  data.postfixDisabled = true;
  data.sexprDisabled = false;
  data.texDisabled = true;
  data.mathDisabled = true;
  data.postfixError = '';
  data.sexprError = message;
  return data.mathHtml = '';
};
updateFromPostfixCode = function(it){
  var postfix, sexpr, e;
  try {
    postfix = stringToPostfix(it.postfixCode);
    sexpr = postfixToSexpr(postfix);
    it.sexprCode = sexprToString(sexpr);
    it.texCode = sexprToTex(sexpr);
    it.mathHtml = renderToString(it.texCode);
    updateFromValidCode(it);
  } catch (e$) {
    e = e$;
    updateFromPostfixError(it, e.message);
  }
};
updateFromSexprCode = function(it){
  var sexpr, e;
  try {
    sexpr = stringToSexpr(it.sexprCode);
    it.postfixCode = postfixToString(sexprToPostfix(sexpr));
    it.texCode = sexprToTex(sexpr);
    it.mathHtml = renderToString(it.texCode);
    updateFromValidCode(it);
  } catch (e$) {
    e = e$;
    updateFromSexprError(it, e.message);
  }
};
initVue = function(){
  new Vue({
    el: 'main',
    data: {
      postfixCode: 'b neg b 2 ^ 4 a c * * - sqrt +/- 2 a * /',
      postfixDisabled: false,
      postfixError: '',
      sexprCode: '(/ (+/- (neg b) (sqrt (- (^ b 2) (* 4 a c)))) (* 2 a))',
      sexprDisabled: false,
      sexprError: '',
      texCode: '{\\frac {{- b} \\pm {\\sqrt {{b ^ 2} - {4 a c}}}} {2 a}}',
      texDisabled: false,
      mathHtml: renderToString('{\\frac {{- b} \\pm {\\sqrt {{b ^ 2} - {4 a c}}}} {2 a}}'),
      mathDisabled: false
    },
    template: '<div><div class="box"><div class="level"><div class="level-left"><p class="subtitle is-6 level-item">Reverse Polish Notation</p></div><div class="level-right"><p v-if="postfixError" v-text="postfixError" class="tag is-danger"></p></div></div><input :disabled="postfixDisabled" v-model="postfixCode" @keyup="postfixChanged" :class="{ \'is-danger\': postfixError }" class="input" type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></div><div class="box"><div class="level"><div class="level-left"><p class="subtitle is-6">Symbolic Expressions</p></div><div class="level-right"><p v-if="sexprError" v-text="sexprError" class="tag is-danger"></p></div></div><input :disabled="sexprDisabled" v-model="sexprCode" @keyup="sexprChanged" :class="{ \'is-danger\': sexprError }" class="input" type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></div><div class="box"><p class="subtitle is-6"><span style="font-family: \'CMU Serif\', cmr10, LMRoman10-Regular, \'Nimbus Roman No9 L\', \'Times New Roman\', Times, serif;">T<span style="vertical-align: -0.5ex; margin-left: -0.1667em; margin-right: -0.125em;">E</span>X</span><p><input :disabled="texDisabled" v-model="texCode" class="input" readonly type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"><div :disabled="mathDisabled" class="math" v-html="mathHtml"></div></div></div>',
    methods: {
      postfixChanged: function(){
        updateFromPostfixCode(this);
      },
      sexprChanged: function(){
        updateFromSexprCode(this);
      }
    }
  });
};
setTimeout(initVue, 0);