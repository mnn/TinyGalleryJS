appName = 'TinyGalleryApp'
app = angular.module(appName, ['ui.router'])

LinkPageChangedEvent = "LinkPageChanged"

app.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
  .state 'tiles',
    url: '/tiles/{page:int}'
    templateUrl: settings.includeDir + 'tiles.html'
    controller: ($stateParams, $rootScope) ->
      $rootScope.$emit(LinkPageChangedEvent, $stateParams.page)
      $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) =>
        if(toState.name == 'tiles')
          $rootScope.$emit(LinkPageChangedEvent, toParams.page)

  .state 'detail',
    url: '/detail/{id:int}'
    templateUrl: settings.includeDir + 'detail.html'
    controllerAs: 'detailCtrl'
    controller: ($stateParams, $scope) ->
      @thumbnailsHalfCount = 3
      @pictureId = $stateParams.id
      $scope.mainCtrl.dataPromise.then =>
        data = $scope.mainCtrl.data.data
        @picture = data[@pictureId]
        $scope.picture = @picture
        $scope.pictureId = @pictureId
        start = @pictureId - @thumbnailsHalfCount
        stop = @pictureId + @thumbnailsHalfCount + 1
        if start < 0
          stop += -start
          start = 0
        lastId = data.length - 1
        if stop > lastId
          start -= stop - lastId
          start = 0 if start < 0
          stop = lastId + 1
        $scope.pictures = data.slice(start, stop)

  $urlRouterProvider.otherwise('/tiles/0');
  return

logDebug = (msg) ->
  if debug and console and typeof console.log == 'function'
    console.log '[' + appName + '][DEBUG]: ' + msg

logError = (msg) ->
  if console and typeof console.log == 'function'
    console.log '[' + appName + '][ERR]: ' + msg

applyNewWindow = (link, data) ->
  if angular.isDefined(link.newWindow)
    data.newWindow = link.newWindow

applyFromSettingsRules = (data) ->
  lId = data.linkId
  links = settings.links.filter((link) -> link.id == lId)
  if links.length == 0
    logError 'Cannot find link in settings for id: ' + lId
  else
    link = links[0]
    switch link.type
      when 'prefix'
        data.data = data.data.map (item) ->
          item.link = link.url + item.link
          item
        applyNewWindow(link, data)
      else
        logError 'Unknown link type: ' + link.type
        break

applyGalleryLinks = (data) ->
  idx = 0
  data.newWindow = false
  data.data = data.data.map (item) ->
    item.galleryPicture = data.galleryPrefix + item.link
    item.thumbnail = item.thumbnail.map (tn) ->
      tn = data.galleryPrefix + tn
      tn
    item.link = "#/detail/" + idx++
    item

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

app.controller "MainController", ($http, $scope, $log, $element, $interval, $rootScope) ->
  mainCtrl = this
  mainCtrl.data = {}
  mainCtrl.currentPage = 0
  mainCtrl.pageSize = 9
  dataFile = settings.dataDir + $scope.src
  logDebug 'starting loading file: ' + dataFile
  mainCtrl.initPage = 0
  mainCtrl.dataLoaded = false
  @dataPromise = $http.get(dataFile).success((data) ->
    mainCtrl.data = data
    thumbnailIdx = settings.firstThumbnailIndex or 1
    idCounter = 0
    if mainCtrl.data.flip and !forceNotSorting
      mainCtrl.data.data = mainCtrl.data.data.reverse()
    data.data.forEach (item) ->
      item.defaultThumbnailIdx = if item.thumbnail.length > thumbnailIdx then thumbnailIdx else 0
      item.currentThumbnailIdx = item.defaultThumbnailIdx
      item.id = idCounter++
    mainCtrl.pageSize = mainCtrl.data.itemsPerPage
    mainCtrl.thumbnailPrefix = mainCtrl.data.thumbnailPrefix or ''
    switch mainCtrl.data.type
      when 'direct'
        break
      when 'fromSettings'
        applyFromSettingsRules mainCtrl.data
      when 'gallery'
        applyGalleryLinks mainCtrl.data
        break
      else
        $log.error 'Unknown data type: ' + mainCtrl.data.type
    mainCtrl.openLinksInNewWindow = if angular.isDefined(mainCtrl.data.newWindow) then mainCtrl.data.newWindow else true
    mainCtrl.data.data = mainCtrl.data.data.map((item) ->
      item.thumbnail = item.thumbnail.map((thumbLink) ->
        mainCtrl.thumbnailPrefix + thumbLink
      )
      item
    )
    mainCtrl.dataLoaded = true
    mainCtrl.numberOfPictures = -> mainCtrl.data.data.length
    if mainCtrl.initPage != 0 then mainCtrl.changePage(mainCtrl.initPage, false)
  ).error (msg) ->
    $log.error 'Unable to fetch data file \'' + dataFile + '\': ' + msg

  $rootScope.$on LinkPageChangedEvent, (event, page) =>
    if @dataLoaded
      @changePage page, true
    else
      @initPage = page

  @numberOfPages = ->
    if !mainCtrl.data or !mainCtrl.data.data
      return 0
    Math.ceil mainCtrl.data.data.length / mainCtrl.pageSize

  @numberOfPages = mainCtrl.numberOfPages

  @changePage = (page, doScroll) ->
    newPage = if page < 0 then 0 else if page >= mainCtrl.numberOfPages() then mainCtrl.numberOfPages() - 1 else page
    logDebug("Changing page to #{newPage} (raw = #{page})")
    if newPage != mainCtrl.currentPage
      mainCtrl.currentPage = newPage
      if doScroll # TODO: rewrite to scroll only if currently scrolled bellow top controls
        mainCtrl.scrollToTop()

  @getCurrentPage = ->
    mainCtrl.currentPage

  @pageForPicture = (id) ->
    id / mainCtrl.pageSize

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

app.run ($location, $rootScope, $state, $stateParams) ->
  $rootScope.$on("$stateChangeError", console.log.bind(console));
  if $location.url() == '/noSort'
    forceNotSorting = true

angular.element(document).ready ->
  elems = document.querySelectorAll('tiny-gallery')
  for item in elems
    angular.bootstrap item, [appName]
