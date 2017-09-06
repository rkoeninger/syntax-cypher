var del = require("del"),
    gulp = require("gulp"),
    gutil = require("gulp-util"),
    ls = require("gulp-livescript");

gulp.task("default", ["build"]);

gulp.task("build", () =>
    gulp.src("./src/**/*.ls")
        .pipe(ls({bare: true}).on("error", gutil.log))
        .pipe(gulp.dest("./js")));

gulp.task("test", ["build"], () => {
    console.log("no tests defined.");
});

gulp.task("clean", () => del(["./js"]));

gulp.task("watch", () => gulp.watch("./src/**/*.ls", ["build"]));
