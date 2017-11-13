//
//  SSUIAssetsGroup.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIAssetsGroup.h"
#import "UICore.h"
#import "SSUIAsset.h"
#import "SSUIAssetsManager.h"

@interface SSUIAssetsGroup()

@property(nonatomic, strong, readwrite) PHAssetCollection *assetCollection;
@property(nonatomic, strong, readwrite) PHFetchResult *fetchResult;
@end

@implementation SSUIAssetsGroup

- (instancetype)initWithCollection:(PHAssetCollection *)assetCollection fetchAssetsOptions:(PHFetchOptions *)fetchOptions {
  self = [super init];
  if (self) {
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
    self.fetchResult = fetchResult;
    self.assetCollection = assetCollection;
  }
  return self;
}

- (instancetype)initWithCollection:(PHAssetCollection *)assetCollection {
  return [self initWithCollection:assetCollection fetchAssetsOptions:nil];
}

- (NSInteger)numberOfAssets {
  return self.fetchResult.count;
}

- (NSString *)name {
  NSString *resultName = self.assetCollection.localizedTitle;
  return NSLocalizedString(resultName, resultName);
}

- (UIImage *)posterImageWithSize:(CGSize)size {
  __block UIImage *resultImage;
  NSInteger count = self.fetchResult.count;
  if (count > 0) {
    PHAsset *asset = self.fetchResult[count - 1];
    PHImageRequestOptions *pHImageRequestOptions = [[PHImageRequestOptions alloc] init];
    pHImageRequestOptions.synchronous = YES; // 同步请求
    pHImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    // targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    [[[SSUIAssetsManager sharedInstance] cachingImageManager] requestImageForAsset:asset targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale) contentMode:PHImageContentModeAspectFill options:pHImageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
      resultImage = result;
    }];
  }
  return resultImage;
}

- (void)enumerateAssetsWithOptions:(SSUIAlbumSortType)albumSortType usingBlock:(void (^)(SSUIAsset *resultAsset))enumerationBlock {
  NSInteger resultCount = self.fetchResult.count;
  if (albumSortType == SSUIAlbumSortTypeReverse) {
    for (NSInteger i = resultCount - 1; i >= 0; i--) {
      PHAsset *asset = self.fetchResult[i];
      SSUIAsset *ssui_asset = [[SSUIAsset alloc] initWithAsset:asset];
      if (enumerationBlock) {
        enumerationBlock(ssui_asset);
      }
    }
  } else {
    for (NSInteger i = 0; i < resultCount; i++) {
      PHAsset *asset = self.fetchResult[i];
      SSUIAsset *ssui_asset = [[SSUIAsset alloc] initWithAsset:asset];
      if (enumerationBlock) {
        enumerationBlock(ssui_asset);
      }
    }
  }
  /**
   *  For 循环遍历完毕，这时再调用一次 enumerationBlock，并传递 nil 作为实参，作为枚举资源结束的标记。
   *  该处理方式也是参照系统 ALAssetGroup 枚举结束的处理。
   */
  if (enumerationBlock) {
    enumerationBlock(nil);
  }
}

- (void)enumerateAssetsUsingBlock:(void (^)(SSUIAsset *resultAsset))enumerationBlock {
  [self enumerateAssetsWithOptions:SSUIAlbumSortTypePositive usingBlock:enumerationBlock];
}

@end
