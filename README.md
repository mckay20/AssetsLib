phonegap-plugin-localassets
=========================

phonegap plugin for accessing assets from iOS and Android

phonegap-plugin-localassets supports retrieval of all photo library thumbnails on iOS devices and displaying them in phonegap application.

## Install
Use cordova command line tools to add phonegap-plugin-localassets to your project

* In your project source directory execute: `cordova plugin add https://github.com/mckay20/phonegap-plugin-localassets.git`

On the javascript side, the localassets class is going to be avaiable in global scope `navigator.localassets`

## API

getAllPhotos
```javascript
///
// Gets all available photo ids and photo basic exif data on a device
// @param   successCallback   callback function which will get the array with json objects in the following format:
//                            {
//                              "id": id,
                                "date": seconds Since 1970,
                                "lat": -111,
                                "lng": 40
//                            }
// @param   errorCallback   callback function which will get the error
navigator.localassets.getAllPhotos(successCallback, errorCallback)
```

getThumbnails
```javascript
///
// Gets base64encoded thumbnails data for a given list of photo urls
// @param   idList           Array of string ids, for example: [photometa[0].id]  or  [photometa[0].id,photometa[1].id]
// @param   successCallback   callback function which will get the array with json objects in the following format:
//                            {
//                              "id": id,
                                "date": seconds Since 1970,
                                "lat": -111,
                                "lng": 40
                                "data": base64encoded,
                                "orientation": 3
//                            }
// @param   errorCallback   callback function which will get the error
navigator.localassets.getThumbnails(idList, successCallback, errorCallback)
```

getPhoto
```javascript
///
// Gets base64encoded photo data for a given photo. You can specify the max width or height
// @param   id                The id of the photo to get a large version of
// @param   maxSize           The max width or height (based on photo dimensions) of the resized photo.
// @param   successCallback   callback function which will get the json object in the following format:
//                            {
//                              "id": id,
                                "date": seconds Since 1970,
                                "lat": -111,
                                "lng": 40
                                "data": base64encoded,
                                "orientation": 3
//                            }
// @param   errorCallback   callback function which will get the error
navigator.localassets.getPhoto(id, maxSize, successCallback, errorCallback)
```


## Examples
*All examples assume you have successfully added phonegap-plugin-localassets to your project*


To get an iOS photo library meta data use getAllPhotoMetadata:

```javascript
getAllPhotos:function() {
  if (navigator.localassets) {
    navigator.localassets.getAllPhotos(this.onGetAllPhotosSuccess, this.onGetAllPhotosError);
  }
},
onGetAllPhotosSuccess:function(data){
  this.photometa = data;
  alert("onGetAllPhotosSuccess\n" + data.length);
},
onGetAllPhotosError:function(error){
  console.error("onGetAllPhotosError > " + error);
}
```

To get one or more thumbnails for a list of asset url's:

```javascript
getThumbnails:function(idList, successCallback, errorCallback){
  if (navigator.localassets) {
    navigator.localassets.getThumbnails(idList, this.onGetThumbnailsSuccess, this.onGetThumbnailsError);
  }
},
onGetThumbnailsSuccess:function(data){
  this.thumbnails = data;
  alert("onGetThumbnailsSuccess\n" + data.length);
},
onGetThumbnailsError:function(error){
  console.error("onGetThumbnailsError > " + error);
}
```


To get full sized photo for a photo id:

```javascript
getPhoto:function(id, maxSize, successCallback, errorCallback){
  if (navigator.localassets) {
    navigator.localassets.getThumbnails(id, maxSize, this.onGetPhotoSuccess, this.onGetPhotoError);
  }
},
onGetPhotoSuccess:function(data){
  this.thumbnails = data;
  alert("onGetThumbnailsSuccess\n" + data.length);
},
onGetPhotoError:function(error){
  console.error("onGetThumbnailsError > " + error);
}
```
