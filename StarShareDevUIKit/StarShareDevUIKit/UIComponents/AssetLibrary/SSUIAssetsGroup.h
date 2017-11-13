//
//  SSUIAssetsGroup.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHImageManager.h>

@class SSUIAsset;

/// 相册展示内容的类型
typedef NS_ENUM(NSUInteger, SSUIAlbumContentType) {
  SSUIAlbumContentTypeAll,                                  // 展示所有资源（照片和视频）
  SSUIAlbumContentTypeOnlyPhoto,                            // 只展示照片
  SSUIAlbumContentTypeOnlyVideo,                            // 只展示视频
  SSUIAlbumContentTypeOnlyAudio  NS_ENUM_AVAILABLE_IOS(8_0) // 只展示音频
};

/// 相册展示内容按日期排序的方式
typedef NS_ENUM(NSUInteger, SSUIAlbumSortType) {
  SSUIAlbumSortTypePositive,  // 日期最新的内容排在后面
  SSUIAlbumSortTypeReverse  // 日期最新的内容排在前面
};

@interface SSUIAssetsGroup : NSObject

- (instancetype)initWithCollection:(PHAssetCollection *)assetCollection;
- (instancetype)initWithCollection:(PHAssetCollection *)assetCollection fetchAssetsOptions:(PHFetchOptions *)fetchOptions;
@property(nonatomic, strong, readonly) PHAssetCollection *assetCollection;
@property(nonatomic, strong, readonly) PHFetchResult *fetchResult;

/// 相册的名称
- (NSString *)name;

/// 相册内的资源数量，包括视频、图片、音频（如果支持）这些类型的所有资源
- (NSInteger)numberOfAssets;

/**
 *  相册的缩略图，即系统接口中的相册海报（Poster Image）
 *
 *  @param size 缩略图的 size，仅在 iOS 8.0 及以上的版本有效，其他版本则调用 ALAsset 的接口由系统返回一个固定大小的缩略图
 *
 *  @return 相册的缩略图
 */
- (UIImage *)posterImageWithSize:(CGSize)size;

/**
 *  枚举相册内所有的资源
 *
 *  @param albumSortType    相册内资源的排序方式，可以选择日期最新的排在最前面，也可以选择日期最新的排在最后面
 *  @param enumerationBlock 枚举相册内资源时调用的 block，参数 result 表示每次枚举时对应的资源。
 *                          枚举所有资源结束后，enumerationBlock 会被再调用一次，这时 result 的值为 nil。
 *                          可以以此作为判断枚举结束的标记
 */
- (void)enumerateAssetsWithOptions:(SSUIAlbumSortType)albumSortType usingBlock:(void (^)(SSUIAsset *resultAsset))enumerationBlock;

/**
 *  枚举相册内所有的资源，相册内资源按日期最新的排在最后面
 *
 *  @param enumerationBlock 枚举相册内资源时调用的 block，参数 result 表示每次枚举时对应的资源。
 *                          枚举所有资源结束后，enumerationBlock 会被再调用一次，这时 result 的值为 nil。
 *                          可以以此作为判断枚举结束的标记
 */
- (void)enumerateAssetsUsingBlock:(void (^)(SSUIAsset *result))enumerationBlock;
@end
