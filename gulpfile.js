var del = require("del"),
    gulp = require("gulp"),
    mocha = require("gulp-mocha"),
    gutil = require("gulp-util"),
    ls = require("gulp-livescript");

gulp.task("default", ["build"]);

gulp.task("build", () => {
    gulp.src("./src/**/*.ls")
        .pipe(ls({bare: true}).on("error", gutil.log))
        .pipe(gulp.dest("./js"));
    gulp.src("./test/**/*.ls")
        .pipe(ls({bare: true}).on("error", gutil.log))
        .pipe(gulp.dest("./testjs"));
});

gulp.task("test", ["build"], () => {
    gulp.src("./testjs/**/*.js", {read: false})
        .pipe(mocha({reporter: "spec"}));
});

gulp.task("clean", () => del(["./js", "./testjs"]));

gulp.task("watch", () => {
	gulp.watch("./src/**/*.ls", ["build"]);
	gulp.watch("./test/**/*.ls", ["build"]);
});
