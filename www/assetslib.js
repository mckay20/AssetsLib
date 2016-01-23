var assetslib = {

	getAllPhotos:function(successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, "AssetsLib", "getAllPhotos", []);
	},

	getPhotoMetadata:function(urlList, successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, "AssetsLib", "getPhotoMetadata", [urlList]);
	},

	getThumbnails:function(urlList, successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, "AssetsLib", "getThumbnails", [urlList]);
	},

	getPhoto:function(url, maxSize, successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, "AssetsLib", "getPhoto", [[url], maxSize]);
	}
};

module.exports = assetslib;