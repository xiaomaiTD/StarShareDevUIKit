//
//  SSUIAsset.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIAsset.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "NSString+UI.h"
#import "UICore.h"
#import "SSUIAssetsManager.h"

static NSString * const kAssetInfoImageData = @"imageData";
static NSString * const kAssetInfoOriginInfo = @"originInfo";
static NSString * const kAssetInfoDataUTI = @"dataUTI";
static NSString * const kAssetInfoOrientation = @"orientation";
static NSString * const kAssetInfoSize = @"size";

BeginIgnoreAvailabilityWarning

@interface SSUIAsset ()

@property (nonatomic, assign, readwrite) SSUIAssetType assetType;
@end

@implementation SSUIAsset{
  PHAsset *_asset;
  NSDictionary *_assetInfo;
  float imageSize;
  
  NSString *_assetIdentityHash;
}

- (instancetype)initWithAsset:(PHAsset *)asset {
  if (self = [super init]) {
    _asset = asset;
    switch (asset.mediaType) {
      case PHAssetMediaTypeImage:
        _assetType = SSUIAssetTypeImage;
        if ([[asset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
          _assetSubType = SSUIAssetSubTypeGIF;
        } else {
          if (@available(iOS 9.1, *)) {
            if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
              _assetSubType = SSUIAssetSubTypeLivePhoto;
            } else {
              _assetSubType = SSUIAssetSubTypeImage;
            }
          } else {
            _assetSubType = SSUIAssetSubTypeImage;
          }
        }
        break;
      case PHAssetMediaTypeVideo:
        _assetType = SSUIAssetTypeVideo;
        break;
      case PHAssetMediaTypeAudio:
        _assetType = SSUIAssetTypeAudio;
        break;
      default:
        _assetType = SSUIAssetTypeUnknow;
        break;
    }
  }
  return self;
}

- (PHAsset *)asset {
  return _asset;
}

- (UIImage *)originImage {
  __block UIImage *resultImage = nil;
  PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
  phImageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
  phImageRequestOptions.networkAccessAllowed = YES;
  phImageRequestOptions.synchronous = YES;
  [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestImageForAsset:_asset
                                                                      targetSize:PHImageManagerMaximumSize
                                                                     contentMode:PHImageContentModeDefault
                                                                         options:phImageRequestOptions
                                                                   resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                     resultImage = result;
                                                                   }];
  return resultImage;
}

- (UIImage *)thumbnailWithSize:(CGSize)size {
  __block UIImage *resultImage;
  PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
  phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
  // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
  [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestImageForAsset:_asset
                                                                      targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale)
                                                                     contentMode:PHImageContentModeAspectFill options:phImageRequestOptions
                                                                   resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                     resultImage = result;
                                                                   }];
  return resultImage;
}

- (UIImage *)previewImage {
  __block UIImage *resultImage = nil;
  PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
  imageRequestOptions.networkAccessAllowed = YES;
  imageRequestOptions.synchronous = YES;
  [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestImageForAsset:_asset
                                                                      targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                     contentMode:PHImageContentModeAspectFill
                                                                         options:imageRequestOptions
                                                                   resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                     resultImage = result;
                                                                   }];
  return resultImage;
}

- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
  PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
  imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
  imageRequestOptions.progressHandler = phProgressHandler;
  return [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestImageForAsset:_asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
    if (completion) {
      completion(result, info);
    }
  }];
}

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion {
  PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
  imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
  imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
  // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
  return [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestImageForAsset:_asset targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
    if (completion) {
      completion(result, info);
    }
  }];
}

- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
  PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
  imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
  imageRequestOptions.progressHandler = phProgressHandler;
  return [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestImageForAsset:_asset targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
    if (completion) {
      completion(result, info);
    }
  }];
}

- (NSInteger)requestLivePhotoWithCompletion:(void (^)(PHLivePhoto *livePhoto, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
  if ([[PHCachingImageManager class] instancesRespondToSelector:@selector(requestLivePhotoForAsset:targetSize:contentMode:options:resultHandler:)]) {
    PHLivePhotoRequestOptions *livePhotoRequestOptions = [[PHLivePhotoRequestOptions alloc] init];
    livePhotoRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    livePhotoRequestOptions.progressHandler = phProgressHandler;
    return [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestLivePhotoForAsset:_asset targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) contentMode:PHImageContentModeDefault options:livePhotoRequestOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
      if (completion) {
        completion(livePhoto, info);
      }
    }];
  } else {
    if (completion) {
      completion(nil, nil);
    }
    return 0;
  }
}

- (NSInteger)requestPlayerItemWithCompletion:(void (^)(AVPlayerItem *playerItem, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetVideoProgressHandler)phProgressHandler {
  if ([[PHCachingImageManager class] instancesRespondToSelector:@selector(requestPlayerItemForVideo:options:resultHandler:)]) {
    PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
    videoRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    videoRequestOptions.progressHandler = phProgressHandler;
    return [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestPlayerItemForVideo:_asset options:videoRequestOptions resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
      if (completion) {
        completion(playerItem, info);
      }
    }];
  } else {
    if (completion) {
      completion(nil, nil);
    }
    return 0;
  }
}

- (void)requestImageData:(void (^)(NSData *imageData, NSDictionary<NSString *, id> *info, BOOL isGif, BOOL isHEIC))completion {
  if (self.assetType != SSUIAssetTypeImage) {
    if (completion) {
      completion(nil, nil, NO, NO);
    }
    return;
  }
  if (!_assetInfo) {
    // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
    [self requestPhAssetInfo:^(NSDictionary *phAssetInfo) {
      _assetInfo = phAssetInfo;
      if (completion) {
        NSString *dataUTI = phAssetInfo[kAssetInfoDataUTI];
        BOOL isGIF = self.assetSubType == SSUIAssetSubTypeGIF;
        BOOL isHEIC = [dataUTI isEqualToString:@"public.heic"];
        NSDictionary<NSString *, id> *originInfo = phAssetInfo[kAssetInfoOriginInfo];
        /**
         *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
         *  为了避免这种情况，这里该 block 主动放到主线程执行。
         */
        dispatch_async(dispatch_get_main_queue(), ^{
          completion(phAssetInfo[kAssetInfoImageData], originInfo, isGIF, isHEIC);
        });
      }
    }];
  } else {
    if (completion) {
      NSString *dataUTI = _assetInfo[kAssetInfoDataUTI];
      BOOL isGIF = self.assetSubType == SSUIAssetSubTypeGIF;
      BOOL isHEIC = [@"public.heic" isEqualToString:dataUTI];
      NSDictionary<NSString *, id> *originInfo = _assetInfo[kAssetInfoOriginInfo];
      completion(_assetInfo[kAssetInfoImageData], originInfo, isGIF, isHEIC);
    }
  }
}

- (void)requestPhAssetInfo:(void (^)(NSDictionary *))completion {
  if (!_asset) {
    if (completion) {
      completion(nil);
    }
    return;
  }
  
  if (self.assetType == SSUIAssetTypeVideo) {
    [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestAVAssetForVideo:_asset options:NULL resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
      if ([asset isKindOfClass:[AVURLAsset class]]) {
        NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
        if (info) {
          [tempInfo setObject:info forKey:kAssetInfoOriginInfo];
        }
        
        AVURLAsset *urlAsset = (AVURLAsset*)asset;
        NSNumber *size;
        [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
        [tempInfo setObject:size forKey:kAssetInfoSize];
        if (completion) {
          completion(tempInfo);
        }
      }
    }];
  } else {
    [self requestImageAssetInfo:^(NSDictionary *phAssetInfo) {
      if (completion) {
        completion(phAssetInfo);
      }
    } synchronous:NO];
  }
}

- (UIImageOrientation)imageOrientation {
  UIImageOrientation orientation;
  if (self.assetType == SSUIAssetTypeImage) {
    if (!_assetInfo) {
      // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
      [self requestImageAssetInfo:^(NSDictionary *phAssetInfo) {
        _assetInfo = phAssetInfo;
      } synchronous:YES];
    }
    // 从 PhAssetInfo 中获取 UIImageOrientation 对应的字段
    orientation = (UIImageOrientation)[_assetInfo[kAssetInfoOrientation] integerValue];
  } else {
    orientation = UIImageOrientationUp;
  }
  return orientation;
}

- (NSString *)assetIdentity {
  if (_assetIdentityHash) {
    return _assetIdentityHash;
  }
  NSString *identity = _asset.localIdentifier;
  _assetIdentityHash = [identity md5];
  return _assetIdentityHash;
}

- (void)requestImageAssetInfo:(void (^)(NSDictionary *))completion synchronous:(BOOL)synchronous {
  PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
  imageRequestOptions.synchronous = synchronous;
  imageRequestOptions.networkAccessAllowed = YES;
  [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestImageDataForAsset:_asset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
    if (info) {
      NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
      if (imageData) {
        [tempInfo setObject:imageData forKey:kAssetInfoImageData];
        [tempInfo setObject:@(imageData.length) forKey:kAssetInfoSize];
      }
      
      [tempInfo setObject:info forKey:kAssetInfoOriginInfo];
      if (dataUTI) {
        [tempInfo setObject:dataUTI forKey:kAssetInfoDataUTI];
      }
      [tempInfo setObject:@(orientation) forKey:kAssetInfoOrientation];
      if (completion) {
        completion(tempInfo);
      }
    }
  }];
}

- (void)setDownloadProgress:(double)downloadProgress {
  _downloadProgress = downloadProgress;
  _downloadStatus = SSUIAssetDownloadStatusDownloading;
}

- (void)updateDownloadStatusWithDownloadResult:(BOOL)succeed {
  _downloadStatus = succeed ? SSUIAssetDownloadStatusSucceed : SSUIAssetDownloadStatusFailed;
}

- (void)assetSize:(void (^)(long long size))completion {
  if (!_assetInfo) {
    // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
    [self requestPhAssetInfo:^(NSDictionary *assetInfo) {
      _assetInfo = assetInfo;
      if (completion) {
        /**
         *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
         *  为了避免这种情况，这里该 block 主动放到主线程执行。
         */
        dispatch_async(dispatch_get_main_queue(), ^{
          completion([assetInfo[kAssetInfoSize] longLongValue]);
        });
      }
    }];
  } else {
    if (completion) {
      completion([_assetInfo[kAssetInfoSize] longLongValue]);
    }
  }
}

- (NSTimeInterval)duration {
  if (self.assetType != SSUIAssetTypeVideo) {
    return 0;
  }
  return _asset.duration;
}

EndIgnoreAvailabilityWarning

@end
