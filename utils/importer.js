(function () {
    var imgtrexToJson = (function () {
        var patty = /^.*href="(.*?)".*src="(.*?)".*$/;

        function parse(input) {
            var match = input.match(patty);
            if (match && match.length == 3) return [match[1], match[2]];
            else return undefined;
        }

        function jsonify(input) {
            return {thumbnail: [input[1]], link: input[0]};
        }

        return function (input) {
            if (!input) return [];
            return input
                .split("\n")
                .map(parse)
                .filter(function (a) {return a;})
                .map(jsonify);
        }
    })();

    var app = angular.module("ImporterApp", []);
    app
        .controller("ConversionController", function ($scope) {
            $scope.inputServices = [
                {
                    name: "ImgTRex",
                    filter: imgtrexToJson
                }
            ];
            $scope.inputService = $scope.inputServices[0];
            $scope.flip = true;
            $scope.generateOutput = function () {
                var data = $scope.inputService.filter($scope.input);
                if ($scope.thumbnailTimer === "") $scope.thumbnailTimer = undefined;
                return {
                    itemsPerPage: $scope.itemsPerPage,
                    type: "direct",
                    thumbnailTimer: $scope.thumbnailTimer,
                    flip: $scope.flip,
                    data: data
                };
            }
        })
    ;

    app.filter()

})();