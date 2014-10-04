fs = require 'fs'
pkg = require '../package.json'
gulp = require 'gulp'
gutil = require 'gulp-util'
rename = require 'gulp-rename'
concat = require 'gulp-concat'
sass = require 'gulp-sass'
watch = require 'gulp-watch'
livereload = require 'gulp-livereload'
source = require 'vinyl-source-stream'
watchify = require 'watchify'
browserify = require 'browserify'

server = require './lr'


watch_bundle = (app_name, name) ->
    """ Слежение за изменениями в бандле и быстрая его перестройка
    """

    bundler = watchify browserify("./#{app_name}/static/scripts/#{name}.coffee", watchify.args)

    bundler.transform('coffeeify')
    bundler.transform('browserify-eco')

    bundler.on 'update', ->
        rebundle()

    bundler.add("./#{app_name}/static/scripts/#{name}.coffee")

    rebundle = ->
        return bundler.bundle()
            .on('error', gutil.log.bind(gutil, 'Browserify Error'))
            .pipe(source("#{app_name}.#{name}.js"))
            .pipe(gulp.dest("./static/build/"))

    return rebundle()


module.exports.build_app = (app_name) ->
    production = (process.env.NODE_ENV == 'production');

    static_dir = "#{app_name}/static"
    scripts_dir = "#{static_dir}/scripts/"
    style_dir = "#{static_dir}/scss/"

    # Поиск входных точек в бандлы Browserify
    if fs.existsSync scripts_dir
        counter = 0
        for file in fs.readdirSync scripts_dir
            # проверяем имя каждого файла в диретории скриптов приложение
            if file[-7..] == '.coffee'
                module_name = file[..-8]
                # создаем bundle из каждого coffee файла
                watch_bundle app_name, module_name
                counter += 1

    # Поиск входных точек для сборки стилей
    if fs.existsSync style_dir
        counter = 0
        for file in fs.readdirSync style_dir
            if file[-5..] == '.scss'
                module_name = file[..-6]
                gulp.src("#{style_dir}#{module_name}.scss")
                    .pipe(watch({name: "#{module_name}.scss"})) # TODO: watch related style changes
                    .pipe(sass({includePaths: ["project/static/scss"]}))
                    # .pipe(concat("#{app_name}.#{module_name}.css"))
                    .pipe(rename("#{app_name}.#{module_name}.css"))
                    .pipe(gulp.dest('static/build/'))
                    .pipe(livereload(server))
