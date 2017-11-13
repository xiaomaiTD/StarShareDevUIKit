//
//  SSUIImagePickerHelper.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SSUIAsset.h"
#import "SSUIAssetsGroup.h"

@interface SSUIImagePickerHelper : NSObject

+ (BOOL)imageAssetArray:(NSMutableArray *)imageAssetArray containsImageAsset:(SSUIAsset *)targetImageAsset;
+ (void)imageAssetArray:(NSMutableArray *)imageAssetArray removeImageAsset:(SSUIAsset *)targetImageAsset;
+ (void)springAnimationOfImageSelectedCountChangeWithCountLabel:(UILabel *)label;
+ (void)springAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button;
+ (void)removeSpringAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button;

+ (SSUIAssetsGroup *)assetsGroupOfLastestPickerAlbumWithUserIdentify:(NSString *)userIdentify;
+ (void)updateLastestAlbumWithAssetsGroup:(SSUIAssetsGroup *)assetsGroup ablumContentType:(SSUIAlbumContentType)albumContentType userIdentify:(NSString *)userIdentify;
@end
