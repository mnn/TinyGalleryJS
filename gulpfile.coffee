gulp = require('gulp')
$ = require('gulp-load-plugins')({lazy: true})
del = require('del')

constructConfig = ->
  root = "./"
  src = root + "tiny-gallery-js/"
  utils = "utils/"
  config =
    root: root
    src: src
    allScripts: [src + "**/*.coffee", src + "**/*.js"]
    allLess: [src + "**/*.less"]
    allHtml: [src + "**/*.html"]
    build: root + "build/"
    utils: utils
    importerJs: utils + "importer.coffee"

config = constructConfig()

gulp.task 'help', $.taskListing
gulp.task 'default', ['help']

gulp.task 'scripts', ->
  log("Processing scripts")
  gulp.src(config.allScripts)
  .pipe($.print())
  .pipe($.plumber())
  .pipe($.if(/[.]coffee$/, $.coffee()))
  .pipe($.ngAnnotate())
  .pipe($.uglify())
  .pipe(gulp.dest(config.build))


gulp.task 'styles', ->
  log("Processing styles")
  gulp.src(config.allLess)
  .pipe($.print())
  .pipe($.plumber())
  .pipe($.less())
  .pipe($.autoprefixer({browsers: ['last 2 versions', '> 5%']}))
  .pipe(gulp.dest(config.build))

gulp.task 'build', ['styles', 'scripts'], ->
  log("Building")

gulp.task 'rebuild', ['clean'], ->
  log("Rebuilding")
  gulp.start 'build'

gulp.task 'clean', (cb) ->
  log("Cleaning build directory")
  files = config.build + '**/*'
  clean(files, cb)

gulp.task 'watch', ->
  log("Watching")
  log(config.allLess)
  gulp.watch config.allLess, ['styles']
  gulp.watch config.allScripts, ['scripts']

gulp.task 'server', ->
  log("Running server")
  serverOptions =
    livereload:
      enable: true
      filter: (path) -> path.match(/(build)|(testing-app)/)
    directoryListing: true
    open: "testing-app/test.html"
  gulp.src(config.root)
  .pipe($.webserver(serverOptions))

gulp.task 'serve', ['server', 'watch'], ->
  log("Serving")

gulp.task 'importer', ->
  log("Building importer")
  gulp.src(config.importerJs)
  .pipe($.coffee())
  .pipe(gulp.dest(config.utils))

gulp.task 'watch-importer', ->
  gulp.watch [config.importerJs], ['importer']

#---

clean = (path, done) ->
  log('Cleaning: ' + $.util.colors.blue(path))
  del(path, done)

log = (msg) ->
  if typeof msg == 'object'
    for item of msg
      if msg.hasOwnProperty item
        $.util.log $.util.colors.blue(msg[item])
  else
    $.util.log $.util.colors.blue(msg)
