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
    },
    module: {
        loaders: [{
            test: /.css$/,
            use: ["style-loader", "css-loader"]
        }, {
            test: /\.(ttf|otf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
            loader: "file-loader?name=fonts/[name].[ext]"
        }, {
            test: /^http(s)?\;\/\//,
            loader: "url-loader"
        }]
    }
};
