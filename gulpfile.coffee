gulp = require('gulp')
$ = require('gulp-load-plugins')({lazy: true})
del = require('del')
addStream = require('add-stream');

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
    compiledJsFile: 'tgjs.js'
    compiledCssFile: 'tgjs.css'
    templateCache:
      file: 'templates.js'
      options:
        module: 'TinyGalleryApp'
        standalone: false
        root: './tiny-gallery-js/'
    dev: false

config = constructConfig()

gulp.task 'help', $.taskListing
gulp.task 'default', ['help']

prepareTemplates = ->
  gulp.src config.allHtml
  .pipe $.minifyHtml({empty: true})
  .pipe $.angularTemplatecache(config.templateCache.file, config.templateCache.options)


gulp.task 'scripts', ->
  log("Processing scripts")
  gulp.src config.allScripts
  .pipe $.print()
  .pipe $.plumber()
  .pipe $.if(/[.]coffee$/, $.coffee())
  .pipe addStream.obj(prepareTemplates())
  .pipe $.concat(config.compiledJsFile)
  .pipe $.if(!config.dev, $.ngAnnotate())
  .pipe $.if(!config.dev, $.uglify())
  .pipe gulp.dest(config.build)


gulp.task 'styles', ->
  log "Processing styles"
  gulp.src config.allLess
  .pipe $.print()
  .pipe $.plumber()
  .pipe $.less()
  .pipe $.autoprefixer({browsers: ['last 2 versions', '> 5%']})
  .pipe $.concat(config.compiledCssFile)
  .pipe $.if(!config.dev, $.minifyCss())
  .pipe gulp.dest(config.build)

gulp.task 'build', ['styles', 'scripts'], ->
  log "Building"

gulp.task 'rebuild', ['clean'], ->
  log "Rebuilding"
  gulp.start 'build'

gulp.task 'build-dev', ->
  config.dev = true
  gulp.start 'build'

gulp.task 'clean', (cb) ->
  log "Cleaning build directory"
  files = config.build + '**/*'
  clean files, cb

gulp.task 'watch', ->
  log "Watching"
  config.dev = true
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
  gulp.src config.root
  .pipe $.webserver(serverOptions)

gulp.task 'serve', ['server', 'watch'], ->
  log "Serving"

gulp.task 'importer', ->
  log "Building importer"
  gulp.src config.importerJs
  .pipe $.coffee()
  .pipe gulp.dest(config.utils)

gulp.task 'watch-importer', ->
  gulp.watch [config.importerJs], ['importer']

#---

clean = (path, done) ->
  log 'Cleaning: ' + $.util.colors.blue(path)
  del path, done

log = (msg) ->
  if typeof msg == 'object'
    for item of msg
      if msg.hasOwnProperty item
        $.util.log $.util.colors.blue(msg[item])
  else
    $.util.log $.util.colors.blue(msg)
