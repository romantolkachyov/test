gulp = require('gulp');
gutil = require('gulp-util');

server = require('./gulp/lr');

require('./gulp/vendor')
require('./gulp/flexmodel')

APPS = ['flexmodel']

gulp.task 'build', APPS

gulp.task 'lr-server', ->
    server.listen 35728, (err) ->
        if (err)
            gutil.log(gutil.colors.red('ERROR'), err);

gulp.task 'default', ['build', 'lr-server'], ->
    for app in APPS
        gulp.watch("#{app}/static/**/{*.coffee,*.scss,*.eco}", {maxListeners:999}, [app]);
