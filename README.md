TinyGalleryJS
=============
Tiny library providing basic gallery.
It is entirely client-side. Input gallery is read in a JSON file. This file can be generated from local files, external files (image hosting) or created by hand.
It supports multiple pages with showing only a fre near pages in controls.
In `gallery` mode it shows currently selected image alongside with a bunch of thumbnails of nearby images.


Showcase
========
You can try TGJS [over there](http://mnn.github.io/tgjs).


Configuration
=============
It is done by creating global object named `TinyGalleryAppSettings`.
Configuration object is not required, if not found default values will be used.

## Settings format
| Name                           | Default value          | Description                                                                                |
| ------------------------------ | ---------------------- | ------------------------------------------------------------------------------------------ |
| dataDir {string}               | ./                     | path to data directory                                                                     |
| includeDir {string}            | ./tiny-gallery-js/     | path to templates directory, do **not** change if you wish to use inline templates         |
| nearPagesCount {number}        | 3                      | number of pages on each side of currently selected page (in tiles view)                    |
| thumbnailsHalfCount {number}   | 3                      | number of thumbnails on each side of currently active picture (in detail view)             |
| debug {boolean}                | false                  | enables console debug output                                                               |
| firstThumbnailIndex {number}   | 1                      | index of thumbnail to be shown while not hovered (or 0, if there is not enough thumbnails) |
| links {Object[]}               | []                     | allows to abstract some configuration in data files to configuration                       |

## Link format (item in settings.links)
| Name                           | Description                                                                                              |
| ------------------------------ | -------------------------------------------------------------------------------------------------------- |
| id {string}                    | identifier of this preset, will be used in data file to reference this record                            |
| url {string}                   | URL which will be used as a prefix when `prefix` type is chosen                                          |
| type {string}                  | currently is supported only `prefix` type, which signals that all links will be prefixed by `url` value  |
| newWindow {boolean}            | enables opening of details of pictures in new window                                                     |

## Note
All paths should end with a slash.

## Example
```
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
| Name                           | Default value          | Description                                                                                |
| ------------------------------ | ---------------------- | ------------------------------------------------------------------------------------------ |
| itemsPerPage {number}          | 9                      | number of pictures per page (tiles view) |
| type {string}                  | none                   | data type, describes handling of links, picture links and thumbnails (described below) |
| thumbnailTimer {number}        | 1000                   | ms between changes of thumbnail when hovered |
| thumbnailPrefix {string}       | empty string           |
| data {Object[]}                | none                   | list of items to show (by item is meant one picture object in tiles view) |
| newWindow {boolean}            | false                  | enables opening of details of pictures in new window |
| flip                           | false                  | reverses order of items (last added item will be shown as first) |

## Types
| Name            | Description                                                                                                                         |
| direct          | no special links processing                                                                                                         |
| fromSettings    | uses `linkId` property in data object as a reference to `settings.links`, applies transformations describes there                   |
| gallery         | expects thumbnails and links to be file names and `galleryPrefix` property in data object to be a common prefix (typically a path). translates links to lead to a detail view of a clicked item. |

## Item format
**TODO**

## Example

### Gallery type
```
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
[Gulp](http://gulpjs.com/)
```
gulp build
```


License
=======
Common Public Attribution License Version 1.0 (CPAL-1.0)

For more details read `LICENSE` file.
