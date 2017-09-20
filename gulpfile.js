var del = require("del"),
    gulp = require("gulp"),
    mocha = require("gulp-mocha")({reporter: "spec"}),
    gutil = require("gulp-util"),
    lsc = require("gulp-livescript")({bare: true}).on("error", gutil.log),
    webpack = require("webpack-stream")({config: {output: {filename: "bundle.js"}, resolve: {alias: {vue: "vue/dist/vue.js"}}}}),
    // ^ vue alias is needed so we get the runtime+compiler version of vue instead of the default runtime-only version

    dest = gulp.dest.bind(gulp),
    src = gulp.src.bind(gulp),
    task = gulp.task.bind(gulp),
    watch = gulp.watch.bind(gulp),

    lsFiles = "./ls/**/*.ls",
    jsRoot = "./js",
    jsFiles = jsRoot + "/**/*.js",
    jsMainFiles = jsRoot + "/main/**/*.js",
    jsTestFiles = jsRoot + "/test/**/*.js",
    distRoot = "./dist";

task("build", () => src(lsFiles).pipe(lsc).pipe(dest(jsRoot)));

task("bundle", ["build"], () => src(jsMainFiles).pipe(webpack).pipe(dest(distRoot)));

task("clean", () => del([jsRoot, distRoot]));

task("test", ["build"], () => src(jsTestFiles, {read: false}).pipe(mocha));

task("watch", () => watch(lsFiles, ["test"]));
