gulp = require 'gulp'
runSequence = require 'run-sequence'

gulp.task 'watch', ->
  runSequence 'build', ->
    gulp.watch 'client/assets/**/*', ['assets']
    gulp.watch 'client/**/*.coffee', ['coffee']
    gulp.watch 'client/index.jade', ['jade-index']
    gulp.watch 'client/**/*.jade', ['jade']
    gulp.watch 'client/styles/*.less', ['less']