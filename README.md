TinyGalleryJS
=============
Tiny library providing basic gallery.
It is entirely client-side.
Input gallery is read from a JSON file.
This file can be generated from local files, external files (image hosting) or created by hand.
It supports multiple pages with showing only a few near pages in controls.
In `gallery` mode it shows currently selected image alongside with a bunch of thumbnails of nearby images.
Every item can have a title and a duration label.
Gallery supports multiple thumbnails changing on hover.
These multiple thumbnails can be used when creating a gallery linking videos.


Showcase
========
You can try TGJS [over there](http://mnn.github.io/tgjs).


Features
========
* entirely client side, no need for hosting with dynamic pages support (like PHP or Java)
* data file (JSON) can be generated via in-built importer (image hostings), Gallery Importer application (also generates thumbnails, used for locally hosted files) or, if needed, by hand
* smart pagination
* title and duration labels in tiles view for any picture
* next/previous/close hot keys in detail view
* multiple thumbnails, changing on hover
* proper links even though it is a client side application


Usage
=====
Include dependencies (Angular and ui-router).

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.4.1/angular.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/0.2.15/angular-ui-router.min.js"></script>
```

Optionally state settings.

```javascript
      var TinyGalleryAppSettings = { dataDir: "./data/" };
```

Include built files (you can download them at [releases page](https://github.com/mnn/TinyGalleryJS/releases)).

```html
<script src="tgjs.js"></script>
<link href="tgjs.css" rel="stylesheet" type="text/css"/>
```

And insert a gallery tag.

```html
<tiny-gallery src="data/gallery.json"></tiny-gallery>
```


Configuration
=============
It is done by creating global object named `TinyGalleryAppSettings`.
Configuration object is not required, if not found default values will be used.

## Settings format
| Name                             | Default value          | Description                                                                                |
| -------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------ |
| `dataDir` {string}               | ./                     | path to data directory                                                                     |
| `includeDir` {string}            | ./tiny-gallery-js/     | path to templates directory, do **not** change if you wish to use inline templates         |
| `nearPagesCount` {number}        | 3                      | number of pages on each side of currently selected page (in tiles view)                    |
| `thumbnailsHalfCount` {number}   | 3                      | number of thumbnails on each side of currently active picture (in detail view)             |
| `debug` {boolean}                | false                  | enables console debug output                                                               |
| `firstThumbnailIndex` {number}   | 1                      | index of thumbnail to be shown while not hovered (or 0, if there is not enough thumbnails) |
| `links` {Object[]}               | []                     | allows to abstract some configuration options in data files to a configuration object      |

## Link format (item in settings.links)
| Name                             | Description                                                                                              |
| -------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `id` {string}                    | identifier of this preset, will be used in data file to reference this record                            |
| `url` {string}                   | URL which will be used as a prefix when `prefix` type is chosen                                          |
| `type` {string}                  | currently is supported only `prefix` type, which signals that all links will be prefixed by `url` value  |
| `newWindow` {boolean}            | enables opening of details of pictures in new window                                                     |

## Note
All paths should end with a slash.

## Example
```javascript
      var TinyGalleryAppSettings = {
            dataDir: "./data/",
            links: [{
                id: "service1",
                url: "ladingPage.html#/",
                type: "prefix",
                newWindow: false
            }]
        };
```


Data file format
================

## Data format
| Name                             | Default value          | Description                                                                                 |
| -------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------- |
| `itemsPerPage` {number}          | 9                      | number of pictures per page (tiles view)                                                    |
| `type` {string}                  | none                   | data type, describes handling of links, picture links and thumbnails (described below)      |
| `thumbnailTimer` {number}        | 1000                   | milliseconds between changes of thumbnail when hovered                                      |
| `thumbnailPrefix` {string}       | empty string           | string which will be added to all thumbnails                                                |
| `data` {Object[]}                | none                   | list of items to show (by item is meant one picture object in tiles view)                   |
| `newWindow` {boolean}            | false                  | enables opening of details of pictures in new window                                        |
| `flip`                           | false                  | reverses order of items (last added item will be shown as first)                            |

## Types
| Name              | Description                                                                                                                         |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `direct`          | no special links processing                                                                                                         |
| `fromSettings`    | Uses `linkId` property in data object as a reference to `settings.links`, applies transformations described there.                  |
| `gallery`         | Expects thumbnails and links to be file names and `galleryPrefix` property in data object to be a common prefix (typically a path). Translates links to lead to a detail view of a clicked item. |

## Item format
Properties are interpreted according to `data.type` (and `settings.links`).

| Name                             | Description                                              |
| -------------------------------- | -------------------------------------------------------- |
| `thumbnail` {string[]}           | an array of paths to thumbnails |
| `link` {string}                  | path to a picture of link to a picture page |
| `duration` {string}              | a label shown over picture (tiles view) |
| `title` {string}                 | a label shown over picture (tiles view) |

## Example

### Gallery type
```javascript
{
  "itemsPerPage": 9,
  "type": "gallery",
  "thumbnailTimer": 500,
  "flip": true,
  "galleryPrefix": "gallery/",
  "data": [
    {
      "thumbnail": ["DivineGuardian_tn.jpg"],
      "link": "DivineGuardian.png"
    }, {
      "thumbnail": ["Harpy_tn.jpg"],
      "link": "Harpy.png"
    }
  ]
}
```


Compilation
===========
Required utilities for compilation can be obtained via [npm](https://www.npmjs.com/).

```
npm install
```

If you are planning on modifying this library you can use [bower](http://bower.io/) to get dependencies.

```
bower install
```

Compilation is done via [Gulp](http://gulpjs.com/), all files needed for deployment should appear in directory `build` (templates are in-lined in a JS file).

```
gulp build
```


Limitations
===========
Only one gallery is allowed per page.


License
=======
Common Public Attribution License Version 1.0 (CPAL-1.0)

For more details read `LICENSE` file.
