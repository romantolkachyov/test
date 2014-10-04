gulp = require('gulp');

utils = require('./utils')

gulp.task 'flexmodel', ->
    utils.build_app('flexmodel')