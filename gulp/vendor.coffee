browserify = require('gulp-browserify');
gulp = require('gulp');
rename = require('gulp-rename');
uglify = require('gulp-uglify');

libs = [
  'jquery',
  'backbone',
  'underscore'
];

gulp.task 'vendor', ->
    production = (process.env.NODE_ENV == 'production');
    # // A dummy entry point for browserify
    stream = gulp.src('./gulp/noop.js', {read: false})
        # Browserify it
        .pipe(browserify({
            debug: false,  # Don't provide source maps for vendor libs
        }))

        .on 'prebundle', ->
            # Require vendor libraries and make them available outside the bundle.
            libs.forEach (lib) ->
                bundle.require(lib)

    if production
        # If this is a production build, minify it
        stream.pipe(uglify());

    # Give the destination file a name, adding '.min' if this is production
    stream.pipe(rename('vendor' + (production ? '.min' : '') + '.js'))
        # Save to the build directory
        .pipe(gulp.dest('build/'));
    return stream;

exports.libs = libs;