#import <Cordova/CDVPlugin.h>
@import Photos;

@interface LocalAssets : CDVPlugin

- (void)getAllPhotos:(CDVInvokedUrlCommand*)command;
- (void)getPhotoMetadata:(CDVInvokedUrlCommand*)command;
- (void)getThumbnails:(CDVInvokedUrlCommand*)command;
- (void)getPhoto:(CDVInvokedUrlCommand*)command;

@end
