//
//  SSUIImagePickerHelper.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIImagePickerHelper.h"
#import "UICore.h"
#import "SSUIAssetsManager.h"
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import "UIImage+UI.h"


static NSString * const kLastAlbumKeyPrefix = @"SSUILastAlbumKeyWith";
static NSString * const kContentTypeOfLastAlbumKeyPrefix = @"SSUIContentTypeOfLastAlbumKeyWith";

@implementation SSUIImagePickerHelper

+ (BOOL)imageAssetArray:(NSMutableArray *)imageAssetArray containsImageAsset:(SSUIAsset *)targetImageAsset {
  NSString *targetAssetIdentify = [targetImageAsset assetIdentity];
  for (NSUInteger i = 0; i < [imageAssetArray count]; i++) {
    SSUIAsset *imageAsset = [imageAssetArray objectAtIndex:i];
    if ([[imageAsset assetIdentity] isEqual:targetAssetIdentify]) {
      return YES;
    }
  }
  return NO;
}

+ (void)imageAssetArray:(NSMutableArray *)imageAssetArray removeImageAsset:(SSUIAsset *)targetImageAsset {
  NSString *targetAssetIdentify = [targetImageAsset assetIdentity];
  for (NSUInteger i = 0; i < [imageAssetArray count]; i++) {
    SSUIAsset *imageAsset = [imageAssetArray objectAtIndex:i];
    if ([[imageAsset assetIdentity] isEqual:targetAssetIdentify]) {
      [imageAssetArray removeObject:imageAsset];
      break;
    }
  }
}

+ (void)springAnimationOfImageSelectedCountChangeWithCountLabel:(UILabel *)label {
  [UIHelper actionSpringAnimationForView:label];
}

+ (void)springAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button {
  [UIHelper actionSpringAnimationForView:button];
}

+ (void)removeSpringAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button {
  [button.layer removeAnimationForKey:UISpringAnimationKey];
}

+ (SSUIAssetsGroup *)assetsGroupOfLastestPickerAlbumWithUserIdentify:(NSString *)userIdentify {
  // 获取 NSUserDefaults，里面储存了所有 updateLastestAlbumWithAssetsGroup 的结果
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于获取当前用户最近调用 updateLastestAlbumWithAssetsGroup 储存的相册以及对于的 SSUIAlbumContentType 值
  NSString *lastAlbumKey = [NSString stringWithFormat:@"%@%@", kLastAlbumKeyPrefix, userIdentify];
  NSString *contentTypeOflastAlbumKey = [NSString stringWithFormat:@"%@%@", kContentTypeOfLastAlbumKeyPrefix, userIdentify];
  
  __block SSUIAssetsGroup *assetsGroup;
  
  SSUIAlbumContentType albumContentType = (SSUIAlbumContentType)[userDefaults integerForKey:contentTypeOflastAlbumKey];
  
  NSString *groupIdentifier = [userDefaults valueForKey:lastAlbumKey];
  /**
   *  如果获取到的 SSAssetCollection localIdentifier 不为空，则获取该 URL 对应的相册。
   *  用户升级设备的系统后，这里会从原来的 AssetsLibrary 改为用 PhotoKit，
   *  因此原来储存的 groupIdentifier 实际上会是一个 NSURL 而不是我们需要的 NSString。
   *  所以这里还需要判断一下实际拿到的数据的类型是否为 NSString，如果是才继续进行。
   */
  if (groupIdentifier && [groupIdentifier isKindOfClass:[NSString class]]) {
    PHFetchResult *phFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[groupIdentifier] options:nil];
    if (phFetchResult.count > 0) {
      // 创建一个 PHFetchOptions，用于对内容类型进行控制
      PHFetchOptions *phFetchOptions;
      // 旧版本中没有存储 albumContentType，因此为了防止 crash，这里做一下判断
      if (albumContentType) {
        phFetchOptions = [PHPhotoLibrary createFetchOptionsWithAlbumContentType:albumContentType];
      }
      PHAssetCollection *phAssetCollection = [phFetchResult firstObject];
      assetsGroup = [[SSUIAssetsGroup alloc] initWithCollection:phAssetCollection fetchAssetsOptions:phFetchOptions];
    }
  } else {
    SSUIKitLog(@"Group For localIdentifier is not found!");
  }
  return assetsGroup;
}

+ (void)updateLastestAlbumWithAssetsGroup:(SSUIAssetsGroup *)assetsGroup ablumContentType:(SSUIAlbumContentType)albumContentType userIdentify:(NSString *)userIdentify {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于为当前用户储存相册对应的 SSUIAssetsGroup 与 SSUIAlbumContentType
  NSString *lastAlbumKey = [NSString stringWithFormat:@"%@%@", kLastAlbumKeyPrefix, userIdentify];
  NSString *contentTypeOflastAlbumKey = [NSString stringWithFormat:@"%@%@", kContentTypeOfLastAlbumKeyPrefix, userIdentify];
  [userDefaults setValue:assetsGroup.assetCollection.localIdentifier forKey:lastAlbumKey];
  
  [userDefaults setInteger:albumContentType forKey:contentTypeOflastAlbumKey];
  
  [userDefaults synchronize];
}

@end



