var path = require("path");

module.exports = {
    output: {
        filename: "bundle.js"
    },
    resolve: {
        alias: {
        	// vue alias is needed so we get the runtime+compiler version
        	// of vue instead of the default runtime-only version
            vue: "vue/dist/vue.js"
        }
    }
};
