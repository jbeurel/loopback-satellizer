gulp = require 'gulp'

rename = require 'gulp-rename'
loopbackAngular = require 'gulp-loopback-sdk-angular'

gulp.task 'lb-services', ->
  gulp.src "server/server.coffee"
  .pipe loopbackAngular
    apiUrl: "/api"
  .pipe rename 'lb-services.js'
  .pipe gulp.dest "www/js"
