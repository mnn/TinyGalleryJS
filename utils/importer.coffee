imgtrexToJson = do ->
  patty = /^.*href="(.*?)".*src="(.*?)".*$/

  parse = (input) ->
    match = input.match(patty)
    if match and match.length == 3 then [match[1], match[2]]
    else undefined

  jsonify = (input) ->
    thumbnail: [input[1]]
    link: input[0]

  (input) ->
    if !input then return []
    input.split('\n').map(parse).filter((a) -> a).map jsonify

triEzyToJson = do ->
  # TODO
  (input) ->
    if !input then return []

zimgToJson = do ->
  patty = /^(.*)\.(.*)$/

  parse = (input) ->
    match = input.match(patty)
    if match and match.length == 3 then [match[1], match[2]]
    else undefined

  jsonify = (input) ->
    thumbnail: [input[0] + '.th.' + input[1]]
    link: input[0] + '.' + input[1]

  (input) ->
    if !input then return []
    input.split('\n').map(parse).filter((a) -> a).map jsonify

app = angular.module('ImporterApp', [])

app.controller 'ConversionController', ($scope) ->
  $scope.inputServices = [{
    name: 'ImgTrex.com'
    filter: imgtrexToJson
    type: 'direct'
  }, {
    name: '3ezy.net'
    filter: triEzyToJson
    type: 'gallery'
  }, {
    name: 'Zimg.se'
    filter: zimgToJson
    type: 'gallery'
  }]
  $scope.inputService = $scope.inputServices[0]
  $scope.flip = true

  $scope.generateOutput = ->
    service = $scope.inputService
    data = service.filter($scope.input)
    if $scope.thumbnailTimer == null then $scope.thumbnailTimer = undefined
    if $scope.itemsPerPage == null then $scope.itemsPerPage = undefined

    itemsPerPage: $scope.itemsPerPage
    type: service.type
    thumbnailTimer: $scope.thumbnailTimer
    flip: $scope.flip
    data: data

app.filter()
