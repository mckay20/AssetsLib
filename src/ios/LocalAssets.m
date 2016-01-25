//
//  AssetsLib.m
//
//  Created by glowmar on 12/27/13.
//
//

#import "LocalAssets.h"
#import "AssetsLibrary/ALAssetsLibrary.h"
#import "AssetsLibrary/ALAssetsFilter.h"
#import "AssetsLibrary/ALAssetsGroup.h"
#import "AssetsLibrary/ALAsset.h"
#import "AssetsLibrary/ALAssetRepresentation.h"
#import "PHAssetUtility.h"
@import Photos;


@interface AssetsLib ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property int assetsCount;

@end


@implementation AssetsLib


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// getAllPhotoThumbnails

- (void)getAllPhotos:(CDVInvokedUrlCommand*)command
{
    NSLog(@"getAllPhotos");
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    if (!self.assets) {
        _assets = [[NSMutableArray alloc] init];
    } else {
        [self.assets removeAllObjects];
    }
    self.assetsCount = 0;

    [self getAllPhotosComplete:command with:nil];

    /*
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.assets addObject:result];
            if ([self.assets count] == self.assetsCount)
            {
                NSLog(@"Got all %d photos",self.assetsCount);
                [self getAllPhotosComplete:command with:nil];
            }
        }
    };

    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {

        NSString* errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        NSLog(@"Problem reading assets library %@",errorMessage);
        [self getAllPhotosComplete:command with:errorMessage];
    };

    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        // NSLog(@"AssetsLib::getAllPhotos::listGroupBlock > %@ (%d)   type: %@    url: %@",[group valueForProperty:ALAssetsGroupPropertyName],[group numberOfAssets],[group valueForProperty:ALAssetsGroupPropertyType],[group valueForProperty:ALAssetsGroupPropertyURL]);
        if ([group numberOfAssets] > 0)
        {
            NSLog(@"Got asset group \"%@\" with %ld photos",[group valueForProperty:ALAssetsGroupPropertyName],(long)[group numberOfAssets]);
            [self.groups addObject:group];
            self.assetsCount += [group numberOfAssets];
        }
        else
        {
            NSLog(@"Got all %lu asset groups with total %d assets",(unsigned long)[self.groups count],self.assetsCount);
            for (group in self.groups)
            {   // Enumarate each asset group
                ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
                [group setAssetsFilter:onlyPhotosFilter];
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
            }
        }
    };

    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAll; // ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos | ALAssetsGroupPhotoStream;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    */
}

- (void)getAllPhotosComplete:(CDVInvokedUrlCommand*)command with:(NSString*)error
{
    /*
    if (error != nil && [error length] > 0)
    {   // Call error
        NSLog(@"Error occured for command.callbackId:%@, error:%@", command.callbackId, error);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    }
    else
    {   // Call was successful
        NSMutableDictionary* photos = [NSMutableDictionary dictionaryWithDictionary:@{}];
        for (int i=0; i<[self.assets count]; i++)
        {
            ALAsset* asset = self.assets[i];
            NSString* url = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            NSDictionary* photo = @{
                                    @"url": url
                                   };
            [photos setObject:photo forKey:photo[@"url"]];
        }
        NSArray* photoMsg = [photos allValues];
        NSLog(@"Sending to phonegap application message with %lu photos",(unsigned long)[photoMsg count]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:photoMsg];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    */

    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];

    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];

    NSMutableDictionary *pics = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        //[NSLog(@"asset %@", asset);
        CLLocation *location = asset.location;
        if(location == nil)
            location = [CLLocation new];


        if(asset.mediaType == PHAssetMediaTypeImage){
            // Build Image URL = assets-library://asset/asset.JPG?id=91B1C271-C617-49CE-A074-E391BA7F843F&ext=JPG
            NSDictionary* photo = @{
                                @"id": asset.localIdentifier,
                                @"date": [NSNumber numberWithInt:asset.creationDate.timeIntervalSince1970],
                                @"lat": [NSNumber numberWithFloat: location.coordinate.latitude],
                                @"lng": [NSNumber numberWithFloat: location.coordinate.longitude]
                                };

            [pics setObject:photo forKey:photo[@"id"]];
        }
        if(idx == allPhotosResult.count -1){
            NSArray* photoMsg = [pics allValues];

            CDVPluginResult* pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:photoMsg];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }

    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// getPhotoMetadata

- (void)getPhotoMetadata:(CDVInvokedUrlCommand*)command
{
    NSLog(@"getPhotoMetadata");

    ALAssetsLibraryProcessBlock processMetadataBlock = ^(ALAsset *asset) {
        if (self.dateFormatter == nil) {
            _dateFormatter = [[NSDateFormatter alloc] init];
            _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        }
        NSString* url = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        NSString* date = [self.dateFormatter stringFromDate:[asset valueForProperty:ALAssetPropertyDate]];

        NSDictionary* photo = @{
                                @"url": url,
                                @"date": date
                               };
        NSMutableDictionary* photometa = [self getImageMeta:asset];
        [photometa addEntriesFromDictionary:photo];
        return photometa;
    };

    [self getPhotos:command processBlock:processMetadataBlock];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// getThumbnails

- (void)getThumbnails:(CDVInvokedUrlCommand*)command
{
    NSLog(@"getThumbnails");
    NSArray* idList = [command.arguments objectAtIndex:0];


    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithLocalIdentifiers:idList options:nil];

    NSMutableDictionary *pics = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {

        [self getImageForAsset:asset size:200 callback:^(UIImage *result, NSDictionary *info) {
            CLLocation *location = asset.location;
            if(location == nil)
                location = [CLLocation new];

            @try{
                NSDictionary* photo = @{
                                    @"id": asset.localIdentifier,
                                    @"data": result.base64String,
                                    @"date": [NSNumber numberWithInt:asset.creationDate.timeIntervalSince1970],
                                    @"lat": [NSNumber numberWithFloat: location.coordinate.latitude],
                                    @"lng": [NSNumber numberWithFloat: location.coordinate.longitude],
                                    @"orientation": [[NSString alloc]initWithFormat:@"%@",[info objectForKey:@"PHImageFileOrientationKey"]]
                                    };

                [pics setObject:photo forKey:photo[@"id"]];
            }
            @catch(NSException *exception){
                NSLog(@"%@", exception.reason);

                NSDictionary* photo = @{
                                        @"id": [NSNumber numberWithInt:arc4random_uniform(74)],
                                        @"data": @"",
                                        @"date": [NSNumber numberWithInt:asset.creationDate.timeIntervalSince1970],
                                        @"lat": [NSNumber numberWithFloat: location.coordinate.latitude],
                                        @"lng": [NSNumber numberWithFloat: location.coordinate.longitude]
                                        };

                [pics setObject:photo forKey:photo[@"id"]];
            }

            if(pics.count == allPhotosResult.count){
                NSArray* photoMsg = [pics allValues];

                CDVPluginResult* pluginResult = nil;
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:photoMsg];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];

    /*
    ALAssetsLibraryProcessBlock processThumbnailsBlock = ^(ALAsset *asset) {
        NSString* url = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        CGImageRef thumbnailImageRef = [asset thumbnail];
        UIImage* thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
        NSString* base64encoded = [UIImagePNGRepresentation(thumbnail) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSDictionary* photo = @{
                                @"url": url,
                                @"base64encoded": base64encoded
                               };
        return photo;
    };

    [self.commandDelegate runInBackground:^{
        [self getPhotos:command processBlock:processThumbnailsBlock];
    }];
     */
}

- (void)getImageForAsset:(PHAsset *)asset size:(int)size callback:(void (^) (UIImage *result, NSDictionary *info))resultCallback
{
    NSInteger retinaScale = [UIScreen mainScreen].scale;
    float maxSize = size*retinaScale;

    CGSize retinaSquare = CGSizeMake(asset.pixelWidth / (double)asset.pixelHeight * maxSize, maxSize);
    if(asset.pixelWidth > asset.pixelHeight){
        retinaSquare = CGSizeMake(maxSize, asset.pixelHeight / (double)asset.pixelWidth * maxSize);
    }

    PHImageRequestOptions *cropToSquare = [[PHImageRequestOptions alloc] init];
    cropToSquare.resizeMode = PHImageRequestOptionsResizeModeFast;
    cropToSquare.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

//    CGFloat cropSideLength = MIN(asset.pixelWidth, asset.pixelHeight);
//    CGRect square = CGRectMake(0, 0, cropSideLength, cropSideLength);
//    CGRect cropRect = CGRectApplyAffineTransform(square,
//                                                 CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
//                                                                            1.0 / asset.pixelHeight));

    //cropToSquare.normalizedCropRect = cropRect;

    [[PHImageManager defaultManager]
     requestImageForAsset:(PHAsset *)asset
     targetSize:retinaSquare
     contentMode:PHImageContentModeAspectFill
     options:cropToSquare
     resultHandler:resultCallback];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Gets asset representation meta data
- (void)getPhoto:(CDVInvokedUrlCommand*)command
{
    NSArray* idList = [command.arguments objectAtIndex:0];
    NSInteger maxSize = (int)[command.arguments objectAtIndex:1];

    PHFetchResult *allPhotosResult = [PHAsset fetchAssetsWithLocalIdentifiers:idList options:nil];

    NSMutableDictionary *pics = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [allPhotosResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {

        int finalSize;
        NSUInteger size = asset.pixelHeight;
        if(asset.pixelWidth > asset.pixelHeight)
            size = asset.pixelWidth;

        if(maxSize > size)
            finalSize = (int)size;
        else
            finalSize = (int)maxSize;

        CLLocation *location = asset.location;
        if(location == nil)
            location = [CLLocation new];

        [self getImageForAsset:asset size:finalSize callback:^(UIImage *result, NSDictionary *info) {
            NSDictionary* photo = @{
                                    @"id": asset.localIdentifier,
                                    @"data": result.base64String,
                                    @"date": [NSNumber numberWithInt:asset.creationDate.timeIntervalSince1970],
                                    @"lat": [NSNumber numberWithFloat: location.coordinate.latitude],
                                    @"lng": [NSNumber numberWithFloat: location.coordinate.longitude],
                                    @"orientation": [[NSString alloc]initWithFormat:@"%@",[info objectForKey:@"PHImageFileOrientationKey"]]
                                    };

            [pics setObject:photo forKey:photo[@"id"]];

            if(pics.count == allPhotosResult.count){
                NSArray* photoMsg = [pics allValues];

                CDVPluginResult* pluginResult = nil;
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:photoMsg];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Gets asset representation meta data
- (NSMutableDictionary* ) getImageMeta:(ALAsset*)asset
{
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    struct CGSize size = [representation dimensions];
    NSDictionary* metadata = [representation metadata];

    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[representation filename] forKey:@"filename"];
    [dict setValue:@(size.width) forKey:@"width"];
    [dict setValue:@(size.height) forKey:@"height"];

    //@"{GPS}"
    NSDictionary* gps = [metadata objectForKey:@"{GPS}"];
    if (gps != nil){
        NSNumber* Latitude     = [gps objectForKey:@"Latitude"];
        NSNumber* Longitude    = [gps objectForKey:@"Longitude"];
        NSString* LatitudeRef  = [gps objectForKey:@"LatitudeRef"];
        NSString* LongitudeRef = [gps objectForKey:@"LongitudeRef"];
        [dict setValue:Latitude forKey:@"gps_Latitude"];
        [dict setValue:Longitude forKey:@"gps_Longitude"];
        [dict setValue:LatitudeRef forKey:@"gps_LatitudeRef"];
        [dict setValue:LongitudeRef forKey:@"gps_LongitudeRef"];
    }
    //@"{Exif}"
    NSDictionary* exif = [metadata objectForKey:@"{Exif}"];
    if (exif != nil){
        NSString* DateTimeOriginal  = [exif objectForKey:@"DateTimeOriginal"];
        NSString* DateTimeDigitized = [exif objectForKey:@"DateTimeDigitized"];
        [dict setValue:DateTimeOriginal forKey:@"exif_DateTimeOriginal"];
        [dict setValue:DateTimeDigitized forKey:@"exif_DateTimeDigitized"];
    }
    //@"{IPTC}"
    NSDictionary* iptc = [metadata objectForKey:@"{IPTC}"];
    if (iptc != nil){
        NSArray* Keywords = [iptc objectForKey:@"Keywords"];
        [dict setValue:Keywords forKey:@"iptc_Keywords"];
    }
    //[AssetsLib logDict:dict];
    return dict;
}

+ (void) logDict:(NSDictionary*)dict
{
    for (id key in dict)
    {
        NSLog(@"key: %@, value: %@ ", key, [dict objectForKey:key]);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Common method which gets assets for one or more url's and processes them given processBlock

// This block is executed for each asset
typedef NSDictionary* (^ALAssetsLibraryProcessBlock)(ALAsset *asset);

- (void)getPhotos:(CDVInvokedUrlCommand*)command processBlock:(ALAssetsLibraryProcessBlock)process
{
    NSArray* urlList = [command.arguments objectAtIndex:0];
    if (urlList != nil && [urlList count] > 0)
    {
        if (self.assetsLibrary == nil) {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }

        NSMutableDictionary* photos = [NSMutableDictionary dictionaryWithDictionary:@{}];

        for (int i=0; i<[urlList count]; i++)
        {
            NSString* urlString = [urlList objectAtIndex:i];
            NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            /*PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc]init];
            editOptions.networkAccessAllowed = YES;
            [asset requestContentEditingInputWithOptions:editOptions completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                CIImage *image = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
                NSLog(@"metadata: %@", image.properties.description);
            }];*/

            //NSLog(@"Asset url: %@", url);
            [self.assetsLibrary assetForURL:url
                                resultBlock: ^(ALAsset *asset){
                                    NSDictionary* photo = process(asset);
                                    NSLog(@"Done %d: %@", i, photo[@"url"]);
                                    [photos setObject:photo forKey:photo[@"url"]];
                                    if ([urlList count] == [photos count])
                                    {
                                        NSArray* photoMsg = [photos allValues];
                                        NSLog(@"Sending to phonegap application message with %lu photos",(unsigned long)[photoMsg count]);
                                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:photoMsg];
                                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                    }
                                }
                               failureBlock: ^(NSError *error)
             {
                 NSLog(@"Failed to process asset(s)");
                 [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
             }
             ];
        }
    }
    else
    {
        NSLog(@"Missing parameter urlList");
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

@end
