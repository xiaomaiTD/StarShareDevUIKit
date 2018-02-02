//
//  SSUISingleImagePickerPreviewViewController.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2018/2/2.
//  Copyright © 2018年 jearoc. All rights reserved.
//

#import "SSUIImagePickerPreviewViewController.h"

@class SSUISingleImagePickerPreviewViewController;
@class SSUIAssetsGroup;

@protocol SSUISingleImagePickerPreviewViewControllerDelegate <SSUIImagePickerPreviewViewControllerDelegate>

@required
- (void)imagePickerPreviewViewController:(SSUISingleImagePickerPreviewViewController *)imagePickerPreviewViewController didSelectImageWithImagesAsset:(SSUIAsset *)imageAsset;
@end

@interface SSUISingleImagePickerPreviewViewController : SSUIImagePickerPreviewViewController

@property(nonatomic, weak) id<SSUISingleImagePickerPreviewViewControllerDelegate> delegate;
@property(nonatomic, strong) SSUIAssetsGroup *assetsGroup;
@end
