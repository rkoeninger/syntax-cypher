require! {
  \prelude-ls : {
    chars
    reverse
    unchars
  }
  './cypher' : {
    asm-to-string
    postfix-to-asm
    postfix-to-sexpr
    postfix-to-string
    sexpr-to-postfix
    sexpr-to-string
    sexpr-to-tex
    string-to-postfix
    string-to-sexpr
  }
  \katex : {
    render-to-string
  }
  '../../node_modules/vue/dist/vue.js' : Vue
}

update-from-valid-code = !->
  it.asm-disabled = false
  it.postfix-disabled = false
  it.sexpr-disabled = false
  it.tex-disabled = false
  it.math-disabled = false
  it.postfix-error = ''
  it.sexpr-error = ''

update-from-postfix-error = (it, message) !->
  it.asm-disabled = true
  it.postfix-disabled = false
  it.sexpr-disabled = true
  it.tex-disabled = true
  it.math-disabled = true
  it.postfix-error = message
  it.sexpr-error = ''
  it.math-html = ''

update-from-sexpr-error = (it, message) !->
  it.asm-disabled = true
  it.postfix-disabled = true
  it.sexpr-disabled = false
  it.tex-disabled = true
  it.math-disabled = true
  it.postfix-error = ''
  it.sexpr-error = message
  it.math-html = ''

update-from-postfix-code = !->
  try
    postfix = string-to-postfix it.postfix-code
    sexpr = postfix-to-sexpr postfix
    it.asm-code = asm-to-string postfix-to-asm postfix
    it.sexpr-code = sexpr-to-string sexpr
    it.tex-code = sexpr-to-tex sexpr
    it.math-html = render-to-string it.tex-code
    update-from-valid-code it
  catch
    update-from-postfix-error it, e.message

update-from-sexpr-code = !->
  try
    sexpr = string-to-sexpr it.sexpr-code
    postfix = sexpr-to-postfix sexpr
    it.asm-code = asm-to-string postfix-to-asm postfix
    it.postfix-code = postfix-to-string postfix
    it.tex-code = sexpr-to-tex sexpr
    it.math-html = render-to-string it.tex-code
    update-from-valid-code it
  catch
    update-from-sexpr-error it, e.message

init-vue = !->
  new Vue do
    el: 'main'
    data:
      asm-code: 'ADD R1 1; SUB 0 R2'
      asm-disabled: false
      postfix-code: 'b neg b 2 ^ 4 a c * * - sqrt +/- 2 a * /'
      postfix-disabled: false
      postfix-error: ''
      sexpr-code: '(/ (+/- (neg b) (sqrt (- (^ b 2) (* 4 a c)))) (* 2 a))'
      sexpr-disabled: false
      sexpr-error: ''
      tex-code: '{\\frac {{- b} \\pm {\\sqrt {{b ^ 2} - {4 a c}}}} {2 a}}'
      tex-disabled: false
      math-html: render-to-string '{\\frac {{- b} \\pm {\\sqrt {{b ^ 2} - {4 a c}}}} {2 a}}'
      math-disabled: false
    template: '
      <div>
        <div class="box">
          <div class="level">
            <div class="level-left">
              <p class="subtitle is-6 level-item">Reverse Polish Notation</p>
            </div>
            <div class="level-right">
              <p v-if="postfixError" v-text="postfixError" class="tag is-danger"></p>
            </div>
          </div>
          <input :disabled="postfixDisabled" v-model="postfixCode" @keyup="postfixChanged" :class="{ \'is-danger\': postfixError }" class="input" type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
        </div>
        <div class="box">
          <div class="level">
            <div class="level-left">
              <p class="subtitle is-6">Symbolic Expressions</p>
            </div>
            <div class="level-right">
              <p v-if="sexprError" v-text="sexprError" class="tag is-danger"></p>
            </div>
          </div>
          <input :disabled="sexprDisabled" v-model="sexprCode" @keyup="sexprChanged" :class="{ \'is-danger\': sexprError }" class="input" type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
        </div>
        <div class="box">
          <p class="subtitle is-6">Assembly</p>
          <input :disabled="asmDisabled" v-model="asmCode" class="input" readonly type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
        </div>
        <div class="box">
          <p class="subtitle is-6"><span style="font-family: \'CMU Serif\', cmr10, LMRoman10-Regular, \'Nimbus Roman No9 L\', \'Times New Roman\', Times, serif;">T<span style="vertical-align: -0.5ex; margin-left: -0.1667em; margin-right: -0.125em;">E</span>X</span><p>
          <input :disabled="texDisabled" v-model="texCode" class="input" readonly type="text" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
          <div :disabled="mathDisabled" class="math" v-html="mathHtml"></div>
        </div>
      </div>'
    methods:
      postfix-changed: !-> update-from-postfix-code this
      sexpr-changed: !-> update-from-sexpr-code this

setTimeout init-vue, 0
