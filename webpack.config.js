const path = require("path");

module.exports = {
    mode: "development",
    entry: "./build/main/app.js",
    output: {
        path: path.resolve(__dirname, "dist"),
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
        rules: [{
            test: /\.css$/,
            use: ["style-loader", "css-loader"]
        }, {
            test: /\.(png|svg|jpg|gif)$/,
            use: ["file-loader"]
        }, {
            test: /\.(woff|woff2|eot|ttf|otf)$/,
            use: ["file-loader"]
        }]
    }
};
