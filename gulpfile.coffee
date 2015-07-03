gulp = require("gulp")
$ = require("gulp-load-plugins")({lazy: true})
del = require("del")
addStream = require("add-stream");
args = require("yargs").argv
run = require("run-sequence")
fs = require("fs")

constructConfig = ->
  root = "./"
  src = root + "tiny-gallery-js/"
  utils = "utils/"
  pkg =
    npm: root + "package.json"
    bower: root + "bower.json"
  config =
    root: root
    src: src
    allScripts: [src + "**/*.coffee", src + "**/*.js"]
    allLess: [src + "**/*.less"]
    allHtml: [src + "**/*.html"]
    build: root + "build/"
    utils: utils
    importerJs: utils + "importer.coffee"
    compiledJsFile: "tgjs.js"
    compiledCssFile: "tgjs.css"
    templateCache:
      file: "templates.js"
      options:
        module: "TinyGalleryApp"
        standalone: false
        root: "./tiny-gallery-js/"
    dev: false
    dist: root + "dist/"
    pkg: pkg
    packages: [pkg.npm, pkg.bower]
    version: require(pkg.npm).version

config = constructConfig()

gulp.task "help", $.taskListing.withFilters(-> false)
gulp.task "default", ["help"]

busySleep = (time) ->
  stop = new Date().getTime();
  noop = ->
  noop() while (new Date().getTime() < stop + time)

prepareTemplates = ->
  gulp.src config.allHtml
  .pipe $.plumber()
  .pipe $.minifyHtml({empty: true})
  .pipe $.angularTemplatecache(config.templateCache.file, config.templateCache.options)

gulp.task "scripts", ->
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

gulp.task "styles", ->
  log "Processing styles"
  gulp.src config.allLess
  .pipe $.print()
  .pipe $.plumber()
  .pipe $.less()
  .pipe $.autoprefixer({browsers: ["last 2 versions", "> 5%"]})
  .pipe $.concat(config.compiledCssFile)
  .pipe $.if(!config.dev, $.minifyCss())
  .pipe gulp.dest(config.build)

gulp.task "build", (cb) ->
  log "Building"
  run ["styles", "scripts"], -> cb()

gulp.task "rebuild", (cb) ->
  log "Rebuilding"
  run "clean", "build", -> cb()

gulp.task "build-dev", (cb) ->
  config.dev = true
  run "build", -> cb()

gulp.task "rebuild-dev", ["clean"], (cb) ->
  config.dev = true
  run "clean", "build", -> cb()

gulp.task "clean", (cb) ->
  log "Cleaning build and dist directory"
  files = [config.build + "**/*", config.dist + "**/*"]
  clean files, cb

gulp.task "watch", ->
  log "Watching"
  config.dev = true
  gulp.watch config.allLess, ["styles"]
  gulp.watch config.allScripts, ["scripts"]

gulp.task "server", ->
  log("Running server")
  serverOptions =
    livereload:
      enable: true
      filter: (path) -> path.match(/(build)|(testing-app)/)
    directoryListing: true
    open: "testing-app/test.html"
  gulp.src config.root
  .pipe $.webserver(serverOptions)

gulp.task "serve", ["server", "watch"], ->
  log "Serving"

gulp.task "importer", ->
  log "Building importer"
  gulp.src config.importerJs
  .pipe $.plumber()
  .pipe $.coffee()
  .pipe gulp.dest(config.utils)

gulp.task "watch-importer", ->
  gulp.watch [config.importerJs], ["importer"]

gulp.task "pack", ->
  fileName = "tgjs_#{config.version}.zip"
  log "Packing built files to #{fileName}"
  files = fs.readdirSync(config.build)
  if (files.length != 2) then log "Missing files for packaging. " + JSON.stringify(files)

  gulp.src config.build + "**/*.*"
  .pipe $.print()
  .pipe $.plumber()
  .pipe $.zip(fileName)
  .pipe gulp.dest(config.dist)

gulp.task "dist", (cb) ->
  log "Building and packing for distribution"
  run "rebuild", "pack", -> cb()

# Bumps the version
# --type=[pre,patch,minor,major] bumps specified value
# --version=1.2.3 bumps to a specific value
gulp.task "bump", ->
  msg = "Bumping versions"
  type = args.type
  version = args.version
  options = {}
  if version
    options.version = version
    msg += ' to ' + version
  else
    options.type = type
    msg += ' for a ' + type
  log msg
  gulp.src config.packages
  .pipe $.print()
  .pipe $.bump(options)
  .pipe gulp.dest(config.root)

#---

clean = (path, done) ->
  log "Cleaning: " + $.util.colors.blue(path)
  del path, done

log = (msg) ->
  if typeof msg == "object"
    for item of msg
      if msg.hasOwnProperty item
        $.util.log $.util.colors.blue(msg[item])
  else
    $.util.log $.util.colors.blue(msg)
