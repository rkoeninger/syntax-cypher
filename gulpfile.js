var del = require("del"),
    gulp = require("gulp"),
    mocha = require("gulp-mocha")({reporter: "spec"}),
    gutil = require("gulp-util"),
    lsc = require("gulp-livescript")({bare: true}).on("error", gutil.log),

    dest = gulp.dest.bind(gulp),
    src = gulp.src.bind(gulp),
    task = gulp.task.bind(gulp),
    watch = gulp.watch.bind(gulp),

    jsRoot = "./js",
    lsFiles = "./ls/**/*.ls",
    testFiles = jsRoot + "/test/**/*.js";

task("build", () => src(lsFiles).pipe(lsc).pipe(dest(jsRoot)));

task("clean", () => del([jsRoot]));

task("test", ["build"], () => src(testFiles, {read: false}).pipe(mocha));

task("watch", () => watch(lsFiles, ["build"]));
