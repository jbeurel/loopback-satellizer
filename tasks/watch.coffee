gulp = require 'gulp'
nodemon = require 'gulp-nodemon'
runSequence = require 'run-sequence'

gulp.task 'nodemon', ['build'], ->
  nodemon script: 'server/server.coffee', ext: 'js coffee json'

gulp.task 'watch', ->
  runSequence 'nodemon', ->
    gulp.watch 'client/assets/**/*', ['assets']
    gulp.watch 'client/**/*.coffee', ['coffee']
    gulp.watch 'client/index.jade', ['jade-index']
    gulp.watch 'client/**/*.jade', ['jade']
    gulp.watch 'client/styles/*.less', ['less']