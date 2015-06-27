(function () {
    var appName = "TinyGalleryApp";

    var app = angular.module(appName, []);
    app.service("utils", function () {
        this.range =
            function range(start, stop, step) {
                step = step || 1;
                var a = [start], b = start;
                while (b < stop) {
                    b += step;
                    a.push(b)
                }
                return a;
            };
    });
    var settings = TinyGalleryAppSettings;
    var debug = true;
    var forceNotSorting = false;

    function logDebug(msg) {
        if (debug && console && typeof console.log === "function") console.log("[" + appName + "][DEBUG]: " + msg);
    }

    function logError(msg) {
        if (console && typeof console.log === "function") console.log("[" + appName + "][ERR]: " + msg);
    }

    app.filter('startFrom', function () {
        return function (input, start) {
            if (!input) return [];
            start = +start; //parse to int
            return input.slice(start);
        }
    });

    function applyFromSettingsRules(data) {
        var lId = data.linkId;
        var links = settings.links.filter(function (link) { return link.id === lId; });
        if (links.length == 0) {
            logError("Cannot find link in settings for id: " + lId);
        } else {
            var link = links[0];
            switch (link.type) {
                case "prefix":
                    data.data = data.data.map(function (item) {
                        item.link = link.url + item.link;
                        return item;
                    });
                    if (angular.isDefined(link.newWindow)) { data.newWindow = link.newWindow; }
                    break;
                default:
                    logError("Unknown link type: " + link.type);
                    break;
            }
        }
    }

    logDebug("include dir: " + settings.includeDir);
    logDebug("data dir: " + settings.dataDir);
    app.directive("tinyGallery", function () {
        return {
            restrict: 'E',
            scope: {
                src: "@"
            },
            templateUrl: settings.includeDir + 'tiny-gallery.html',
            controllerAs: "mainCtrl",
            controller: function ($http, $scope, $log, $element, $interval) {
                var mainCtrl = this;
                mainCtrl.data = {};
                mainCtrl.currentPage = 0;
                mainCtrl.pageSize = 9;

                var dataFile = settings.dataDir + $scope.src;
                logDebug("starting loading file: " + dataFile);
                $http.get(dataFile)
                    .success(function (data) {
                        mainCtrl.data = data;
                        var thumbnailIdx = settings.firstThumbnailIndex || 1;
                        data.data.forEach(function (item) {
                            item.defaultThumbnailIdx = item.thumbnail.length > thumbnailIdx ? thumbnailIdx : 0;
                            item.currentThumbnailIdx = item.defaultThumbnailIdx;
                        });
                        mainCtrl.pageSize = mainCtrl.data.itemsPerPage;
                        mainCtrl.thumbnailPrefix = mainCtrl.data.thumbnailPrefix || "";
                        if (mainCtrl.data.flip && !forceNotSorting) mainCtrl.data.data = mainCtrl.data.data.reverse();
                        switch (mainCtrl.data.type) {
                            case "direct":
                                break;
                            case "fromSettings":
                                applyFromSettingsRules(mainCtrl.data);
                                break;
                            default:
                                $log.error("Unknown data type: " + mainCtrl.data.type);
                                break;
                        }
                        mainCtrl.openLinksInNewWindow = angular.isDefined(mainCtrl.data.newWindow) ? mainCtrl.data.newWindow : true;
                        mainCtrl.data.data = mainCtrl.data.data.map(function (item) {
                            item.thumbnail = item.thumbnail.map(function (thumbLink) {
                                return mainCtrl.thumbnailPrefix + thumbLink;
                            });
                            return item;
                        });
                    })
                    .error(function (msg) { $log.error("Unable to fetch data file '" + dataFile + "': " + msg); });

                this.numberOfPages = function () {
                    if (!mainCtrl.data || !mainCtrl.data.data) return 0;
                    return Math.ceil(mainCtrl.data.data.length / mainCtrl.pageSize);
                };
                this.numberOfPages = mainCtrl.numberOfPages;

                this.changePage = function (page, doScroll) {
                    var newPage = page < 0 ? 0 : (page >= mainCtrl.numberOfPages() ? mainCtrl.numberOfPages() - 1 : page);
                    if (newPage != mainCtrl.currentPage) {
                        mainCtrl.currentPage = newPage;
                        if (doScroll) mainCtrl.scrollToTop();
                    }
                };
                this.getCurrentPage = function () { return mainCtrl.currentPage; };
                this.goPageRelative = function (pos, doScroll) { mainCtrl.changePage(mainCtrl.getCurrentPage() + pos, doScroll); };
                this.scrollToTop = function () { $element[0].querySelector(".tg-cells").scrollIntoView(true); }

                this.rotateThumbnail = function () {
                    var item = mainCtrl.itemForThumbnailRotation;
                    if (item) {
                        if (mainCtrl.skipOneThumbRotation) {
                            mainCtrl.skipOneThumbRotation = false;
                        } else {
                            item.currentThumbnailIdx += 1;
                            if (item.currentThumbnailIdx >= item.thumbnail.length) item.currentThumbnailIdx = 0;
                        }
                    }
                };

                this.itemForThumbnailRotation = null;
                this.intervalForThumbnailRotation = null;
                this.startThumbnailRotation = function (item) {
                    this.itemForThumbnailRotation = item;
                    this.itemForThumbnailRotation.currentThumbnailIdx = 0;
                    this.skipOneThumbRotation = true;
                };
                this.stopThumbnailRotation = function (item) {
                    if (this.intervalForThumbnailRotation) {
                        if (this.itemForThumbnailRotation) {
                            this.itemForThumbnailRotation.currentThumbnailIdx = this.itemForThumbnailRotation.defaultThumbnailIdx;
                            this.itemForThumbnailRotation = null;
                        }
                    }
                };
                this.intervalForThumbnailRotation = $interval(this.rotateThumbnail, this.data.thumbnailTimer || 1000);
            }
        };
    });

    app.directive("tinyGalleryControls", function () {
        return {
            restrict: 'E',
            scope: {
                "doScroll": "@",
                ctrl: "="
            },
            templateUrl: settings.includeDir + 'controls.html',
            controller: function ($scope, utils) {
                $scope.utils = utils;
            }
        }
    });

    app.run(function ($location) {
        if ($location.url() === "/noSort") {
            forceNotSorting = true;
        }
    });

    angular.element(document).ready(function () {
        var elems = document.querySelectorAll("tiny-gallery");
        for (var i = 0; i < elems.length; ++i) {
            var item = elems[i];
            angular.bootstrap(item, [appName]);
        }
    });
})
();