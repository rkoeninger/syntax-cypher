var del = require("del"),
    gulp = require("gulp"),
    mocha = require("gulp-mocha"),
    gutil = require("gulp-util"),
    ls = require("gulp-livescript"),

    lsFiles = "./ls/**/*.ls",
    jsRoot = "./js",
    testFiles = jsRoot + "/test/**/*.js";

gulp.task("default", ["test"]);

gulp.task("build", () =>
    gulp.src(lsFiles)
        .pipe(ls({bare: true}).on("error", gutil.log))
        .pipe(gulp.dest(jsRoot)));

gulp.task("test", ["build"], () =>
    gulp.src(testFiles, {read: false})
        .pipe(mocha({reporter: "spec"})));

gulp.task("clean", () => del([jsRoot]));

gulp.task("watch", () => {
    gulp.watch(lsFiles, ["build"]);
});
