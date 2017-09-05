var gulp = require("gulp"),
    gutil = require("gulp-util"),
    ls = require("gulp-livescript");

gulp.task("default", ["build"]);

gulp.task("build", () =>
    gulp.src("./src/**/*.ls")
        .pipe(ls({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest("./js")));
