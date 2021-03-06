//
//  SSUIAsset.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHImageManager.h>

/// Asset 的类型
typedef NS_ENUM(NSUInteger, SSUIAssetType) {
  SSUIAssetTypeUnknow,                              // 未知类型的 Asset
  SSUIAssetTypeImage,                               // 图片类型的 Asset
  SSUIAssetTypeVideo,                               // 视频类型的 Asset
  SSUIAssetTypeAudio,                               // 音频类型的 Asset
};

typedef NS_ENUM(NSUInteger, SSUIAssetSubType) {
  SSUIAssetSubTypeUnknow,                                 // 未知类型
  SSUIAssetSubTypeImage,                                  // 静态图片类型
  SSUIAssetSubTypeLivePhoto NS_ENUM_AVAILABLE_IOS(9_1),   // Live Photo 类型
  SSUIAssetSubTypeGIF                                     // GIF类型
};

/// 从 iCloud 请求 Asset 大图的状态
typedef NS_ENUM(NSUInteger, SSUIAssetDownloadStatus) {
  SSUIAssetDownloadStatusSucceed,     // 下载成功或资源本来已经在本地
  SSUIAssetDownloadStatusDownloading, // 下载中
  SSUIAssetDownloadStatusCanceled,    // 取消下载
  SSUIAssetDownloadStatusFailed,      // 下载失败
};

@class PHAsset;

@interface SSUIAsset : NSObject

@property(nonatomic, assign, readonly) SSUIAssetType assetType;
@property(nonatomic, assign, readonly) SSUIAssetSubType assetSubType;

- (instancetype)initWithAsset:(PHAsset *)asset;

@property(nonatomic, strong, readonly) PHAsset *asset;
@property(nonatomic, assign, readonly) SSUIAssetDownloadStatus downloadStatus; // 从 iCloud 下载资源大图的状态
@property(nonatomic, assign) double downloadProgress; // 从 iCloud 下载资源大图的进度
@property(nonatomic, assign) NSInteger requestID; // 从 iCloud 请求获得资源的大图的请求 ID

/// Asset 的原图（包含系统相册“编辑”功能处理后的效果）
- (UIImage *)originImage;

/// Asset 的缩略图（指定返回的缩略图的大小，仅在 iOS 8.0 及以上的版本有效）
- (UIImage *)thumbnailWithSize:(CGSize)size;

/// Asset 的预览图 (仿照 ALAssetsLibrary 的做法输出与当前设备屏幕大小相同尺寸的图片，如果图片原图小于当前设备屏幕的尺寸，则只输出原图大小的图片)
- (UIImage *)previewImage;

/// 获取图片的 UIImageOrientation 值，仅 assetType 为 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 时有效
- (UIImageOrientation)imageOrientation;

/// Asset 的标识 (每个 SSUIAsset 的标识值不相同，该标识值经过 md5 处理，避免了特殊字符)
- (NSString *)assetIdentity;

/// 获取 Asset 的体积（数据大小）
- (void)assetSize:(void (^)(long long size))completion;
- (NSTimeInterval)duration;

/**
 *  异步请求 Asset 的原图，包含了系统照片“编辑”功能处理后的效果（剪裁，旋转和滤镜等），可能会有网络请求
 *
 *  @param completion        完成请求后调用的 block，参数中包含了请求的原图以及图片信息，在 iOS 8.0 或以上版本中，
 *                           这个 block 会被多次调用，其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图。
 *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
 *
 *  @wraning iOS 8.0 以下中并没有异步请求预览图的接口，因此实际上为同步请求，这时 block 中的第二个参数（图片信息）返回的为 nil。
 *
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler;

/**
 *  异步请求 Asset 的缩略图，不会产生网络请求
 *
 *  @param size       指定返回的缩略图的大小，仅在 iOS 8.0 及以上的版本有效，其他版本则调用 ALAsset 的接口由系统返回一个合适当前平台的图片
 *  @param completion 完成请求后调用的 block，参数中包含了请求的缩略图以及图片信息，在 iOS 8.0 或以上版本中，这个 block 会被多次调用，
 *                    其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图，这时 block 中的第二个参数（图片信息）返回的为 nil。
 *
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion;

/**
 *  异步请求 Asset 的预览图，可能会有网络请求
 *
 *  @param completion        完成请求后调用的 block，参数中包含了请求的预览图以及图片信息，在 iOS 8.0 或以上版本中，
 *                           这个 block 会被多次调用，其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图。
 *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
 *
 *  @wraning iOS 8.0 以下中并没有异步请求预览图的接口，因此实际上为同步请求，这时 block 中的第二个参数（图片信息）返回的为 nil。
 *
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler;

/**
 *  异步请求 Live Photo，可能会有网络请求
 *
 *  @param completion        完成请求后调用的 block，参数中包含了请求的 Live Photo 以及相关信息，若 assetType 不是 SSUIAssetTypeLivePhoto 则为 nil
 *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
 *
 *  @wraning iOS 9.1 以下中并没有 Live Photo，因此无法获取有效结果。
 *
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestLivePhotoWithCompletion:(void (^)(PHLivePhoto *livePhoto, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler NS_AVAILABLE_IOS(9_1);

/**
 *  异步请求 AVPlayerItem，可能会有网络请求
 *
 *  @param completion        完成请求后调用的 block，参数中包含了请求的 AVPlayerItem 以及相关信息，若 assetType 不是 SSUIAssetTypeVideo 则为 nil
 *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
 *
 *  @wraning iOS 8.0 以下中并没有异步请求 AVPlayerItem 的接口，因此实际上为同步请求，这时 block 中的第二个参数（AVPlayerItem 相关信息）返回的为 nil。
 *
 *  @return 返回请求 AVPlayerItem 的请求 id
 */
- (NSInteger)requestPlayerItemWithCompletion:(void (^)(AVPlayerItem *playerItem, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetVideoProgressHandler)phProgressHandler;

/**
 *  异步请求图片的 Data
 *
 *  @param completion 完成请求后调用的 block，参数中包含了请求的图片 Data（若 assetType 不是 SSUIAssetTypeImage 或 SSUIAssetTypeLivePhoto 则为 nil），以及该图片是否为 GIF 的判断值
 *
 *  @wraning iOS 8.0 以下中并没有异步请求 Data 的接口，因此实际上为同步请求，这时 block 中的第二个参数（图片信息）返回的为 nil。
 */
- (void)requestImageData:(void (^)(NSData *imageData, NSDictionary<NSString *, id> *info, BOOL isGif, BOOL isHEIC))completion;

/// 更新下载资源的结果
- (void)updateDownloadStatusWithDownloadResult:(BOOL)succeed;
@end
