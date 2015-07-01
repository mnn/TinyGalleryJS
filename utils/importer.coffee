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
    if !input
      return []
    input.split('\n').map(parse).filter((a) -> a).map jsonify


app = angular.module('ImporterApp', [])

app.controller 'ConversionController', ($scope) ->
  $scope.inputServices = [{
    name: 'ImgTRex'
    filter: imgtrexToJson
  }]
  $scope.inputService = $scope.inputServices[0]
  $scope.flip = true

  $scope.generateOutput = ->
    data = $scope.inputService.filter($scope.input)
    if $scope.thumbnailTimer == null then $scope.thumbnailTimer = undefined
    if $scope.itemsPerPage == null then $scope.itemsPerPage = undefined

    itemsPerPage: $scope.itemsPerPage
    type: 'direct'
    thumbnailTimer: $scope.thumbnailTimer
    flip: $scope.flip
    data: data

app.filter()

