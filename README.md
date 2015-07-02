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
**TODO**

Example:
```
      var TinyGalleryAppSettings = {
            includeDir: "../tiny-gallery-js/",
            dataDir: "./",
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
**TODO**

Example:
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
