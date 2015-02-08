gulp = require 'gulp'
gutil = require 'gulp-util'
concat = require 'gulp-concat'

gulp.task 'vendor', (done) ->
  gulp.src [
    'bower_components/angular/angular.min.js'
    'bower_components/angular-ui-router/release/angular-ui-router.min.js'
    'bower_components/angular-ui-bootstrap-bower/ui-bootstrap-tpls.min.js'
    'bower_components/moment/moment.js'
    'bower_components/lodash/dist/lodash.js'
  ]
  .pipe(concat('vendor.js'))
  .on 'error', gutil.log
  .pipe gulp.dest('www/js')
  .on 'end', done
  return
