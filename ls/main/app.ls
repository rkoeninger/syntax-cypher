require! \prelude-ls : {
    map
}
# require! 'cypher' : {
#     postfix-to-sexpr
# }

reverseString = (s) -> s.split('').reverse('').join('')

init-vue = !->
    new Vue {
        el: 'main'
        data:
            message1: 'hi'
            message2: 'ih'
        template: '
            <div>
                <input v-model="message1" v-on:keyup="convert1">
                <input v-model="message2" v-on:keyup="convert2">
            </div>'
        methods:
            convert1: !-> this.message2 = reverseString this.message1
            convert2: !-> this.message1 = reverseString this.message2
    }

setTimeout init-vue, 0
