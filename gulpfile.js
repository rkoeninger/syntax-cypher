var del = require("del"),
    gulp = require("gulp"),
    mocha = require("gulp-mocha")({reporter: "spec"}),
    gutil = require("gulp-util"),
    lsc = require("gulp-livescript")({bare: true}).on("error", gutil.log),
    webpack = require("webpack-stream")({config: {output: {filename: "bundle.js"}}}),

    dest = gulp.dest.bind(gulp),
    src = gulp.src.bind(gulp),
    task = gulp.task.bind(gulp),
    watch = gulp.watch.bind(gulp),

    lsFiles = "./ls/**/*.ls",
    jsRoot = "./js",
    jsFiles = jsRoot + "/**/*.js",
    jsMainFiles = jsRoot + "/main/**/*.js",
    jsTestFiles = jsRoot + "/test/**/*.js";

task("build", () => src(lsFiles).pipe(lsc).pipe(dest(jsRoot)));

task("clean", () => del([jsRoot]));

task("test", ["build"], () => src(jsTestFiles, {read: false}).pipe(mocha));

task("watch", () => watch(lsFiles, ["test"]));

task("webpack", ["build"], () => src(jsMainFiles).pipe(webpack).pipe(dest(jsRoot)));
