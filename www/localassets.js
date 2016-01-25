var localassets = {

	getAllPhotos:function(successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, "LocalAssets", "getAllPhotos", []);
	},

	getPhotoMetadata:function(idList, successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, "LocalAssets", "getPhotoMetadata", [idList]);
	},

	getThumbnails:function(idList, successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, "LocalAssets", "getThumbnails", [idList]);
	},

	getPhoto:function(id, maxSize, successCallback, errorCallback) {
		cordova.exec(successCallback, errorCallback, "LocalAssets", "getPhoto", [[id], maxSize]);
	}
};

module.exports = localassets;