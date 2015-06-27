appName = 'TinyGalleryApp'
app = angular.module(appName, [])

logDebug = (msg) ->
  if debug and console and typeof console.log == 'function'
    console.log '[' + appName + '][DEBUG]: ' + msg

logError = (msg) ->
  if console and typeof console.log == 'function'
    console.log '[' + appName + '][ERR]: ' + msg

applyFromSettingsRules = (data) ->
  lId = data.linkId
  links = settings.links.filter((link) -> link.id == lId)
  if links.length == 0
    logError 'Cannot find link in settings for id: ' + lId
  else
    link = links[0]
    switch link.type
      when 'prefix'
        data.data = data.data.map((item) ->
          item.link = link.url + item.link
          item
        )
        if angular.isDefined(link.newWindow)
          data.newWindow = link.newWindow
      else
        logError 'Unknown link type: ' + link.type
        break

app.service 'utils', ->
  @range = (start, stop, step) ->
    step = step or 1
    a = [start]
    b = start
    while b < stop
      b += step
      a.push b
    a
  return # necessary

settings = TinyGalleryAppSettings
debug = true
forceNotSorting = false

app.filter 'startFrom', ->
  (input, start) ->
    if !input
      return []
    start = +start
    #parse to int
    input.slice start

logDebug 'include dir: ' + settings.includeDir
logDebug 'data dir: ' + settings.dataDir

app.directive 'tinyGallery', ->
  restrict: 'E'
  scope:
    src: '@'
  templateUrl: settings.includeDir + 'tiny-gallery.html'
  controllerAs: 'mainCtrl'
  controller: 'MainController'

app.controller "MainController", ($http, $scope, $log, $element, $interval) ->
  mainCtrl = this
  mainCtrl.data = {}
  mainCtrl.currentPage = 0
  mainCtrl.pageSize = 9
  dataFile = settings.dataDir + $scope.src
  logDebug 'starting loading file: ' + dataFile
  $http.get(dataFile).success((data) ->
    mainCtrl.data = data
    thumbnailIdx = settings.firstThumbnailIndex or 1
    data.data.forEach (item) ->
      item.defaultThumbnailIdx = if item.thumbnail.length > thumbnailIdx then thumbnailIdx else 0
      item.currentThumbnailIdx = item.defaultThumbnailIdx
    mainCtrl.pageSize = mainCtrl.data.itemsPerPage
    mainCtrl.thumbnailPrefix = mainCtrl.data.thumbnailPrefix or ''
    if mainCtrl.data.flip and !forceNotSorting
      mainCtrl.data.data = mainCtrl.data.data.reverse()
    switch mainCtrl.data.type
      when 'direct'
        break
      when 'fromSettings'
        applyFromSettingsRules mainCtrl.data
      else
        $log.error 'Unknown data type: ' + mainCtrl.data.type
    mainCtrl.openLinksInNewWindow = if angular.isDefined(mainCtrl.data.newWindow) then mainCtrl.data.newWindow else true
    mainCtrl.data.data = mainCtrl.data.data.map((item) ->
      item.thumbnail = item.thumbnail.map((thumbLink) ->
        mainCtrl.thumbnailPrefix + thumbLink
      )
      item
    )
  ).error (msg) ->
    $log.error 'Unable to fetch data file \'' + dataFile + '\': ' + msg

  @numberOfPages = ->
    if !mainCtrl.data or !mainCtrl.data.data
      return 0
    Math.ceil mainCtrl.data.data.length / mainCtrl.pageSize

  @numberOfPages = mainCtrl.numberOfPages

  @changePage = (page, doScroll) ->
    newPage = if page < 0 then 0 else if page >= mainCtrl.numberOfPages() then mainCtrl.numberOfPages() - 1 else page
    if newPage != mainCtrl.currentPage
      mainCtrl.currentPage = newPage
      if doScroll
        mainCtrl.scrollToTop()

  @getCurrentPage = ->
    mainCtrl.currentPage

  @goPageRelative = (pos, doScroll) ->
    mainCtrl.changePage mainCtrl.getCurrentPage() + pos, doScroll

  @scrollToTop = ->
    $element[0].querySelector('.tg-cells').scrollIntoView true

  @rotateThumbnail = ->
    item = mainCtrl.itemForThumbnailRotation
    if item
      if mainCtrl.skipOneThumbRotation
        mainCtrl.skipOneThumbRotation = false
      else
        item.currentThumbnailIdx += 1
        if item.currentThumbnailIdx >= item.thumbnail.length
          item.currentThumbnailIdx = 0

  @itemForThumbnailRotation = null
  @intervalForThumbnailRotation = null

  @startThumbnailRotation = (item) ->
    @itemForThumbnailRotation = item
    @itemForThumbnailRotation.currentThumbnailIdx = 0
    @skipOneThumbRotation = true

  @stopThumbnailRotation = (item) ->
    if @intervalForThumbnailRotation
      if @itemForThumbnailRotation
        @itemForThumbnailRotation.currentThumbnailIdx = @itemForThumbnailRotation.defaultThumbnailIdx
        @itemForThumbnailRotation = null

  @intervalForThumbnailRotation = $interval(@rotateThumbnail, @data.thumbnailTimer or 1000)

app.directive 'tinyGalleryControls', ->
  restrict: 'E'
  scope:
    'doScroll': '@'
    ctrl: '='
  templateUrl: settings.includeDir + 'controls.html'
  controller: ($scope, utils) -> $scope.utils = utils

app.run ($location) ->
  if $location.url() == '/noSort'
    forceNotSorting = true

angular.element(document).ready ->
  elems = document.querySelectorAll('tiny-gallery')
  for item in elems
    angular.bootstrap item, [appName]
