gulp = require 'gulp'
nodemon = require 'gulp-nodemon'
coffeelint = require 'gulp-coffeelint'
runSequence = require 'run-sequence'

gulp.task 'coffeelint', ->
  gulp.src './src/*.coffee'
  .pipe coffeelint()
  .pipe coffeelint.reporter()

gulp.task 'nodemon', ['build'], ->
  nodemon script: 'server/server.coffee', ext: 'js coffee json', ignore: ['client/*', 'www/*']
  .on 'change', ['coffeelint']

gulp.task 'watch', ->
  runSequence 'nodemon', 'lb-services', ->
    gulp.watch 'client/assets/**/*', ['assets']
    gulp.watch 'client/**/*.coffee', ['coffee']
    gulp.watch 'client/index.jade', ['jade-index']
    gulp.watch 'client/**/*.jade', ['jade']
    gulp.watch 'client/styles/*.less', ['less']
