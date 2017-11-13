//
//  SSUIImagePickerPreviewViewController.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIImagePreviewViewController.h"
#import "SSUIImagePreviewViewController.h"
#import "SSUIAsset.h"

@class SSUIButton;
@class SSUIPieProgressView;
@class SSUIImagePickerViewController;
@class SSUIImagePickerPreviewViewController;

@protocol SSUIImagePickerPreviewViewControllerDelegate <NSObject>

@optional
- (void)imagePickerPreviewViewControllerDidCancel:(SSUIImagePickerPreviewViewController *)imagePickerPreviewViewController;

- (void)imagePickerPreviewViewController:(SSUIImagePickerPreviewViewController *)imagePickerPreviewViewController
                   willCheckImageAtIndex:(NSInteger)index;
- (void)imagePickerPreviewViewController:(SSUIImagePickerPreviewViewController *)imagePickerPreviewViewController
                    didCheckImageAtIndex:(NSInteger)index;

- (void)imagePickerPreviewViewController:(SSUIImagePickerPreviewViewController *)imagePickerPreviewViewController
                 willUncheckImageAtIndex:(NSInteger)index;
- (void)imagePickerPreviewViewController:(SSUIImagePickerPreviewViewController *)imagePickerPreviewViewController
                  didUncheckImageAtIndex:(NSInteger)index;
@end


@interface SSUIImagePickerPreviewViewController : SSUIImagePreviewViewController<SSUIImagePreviewViewDelegate>

@property(nonatomic, weak) id<SSUIImagePickerPreviewViewControllerDelegate> delegate;
@property(nonatomic, strong, readonly) UIView *topToolBarView;
@property(nonatomic, strong) UIColor *toolBarBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *toolBarTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong, readonly) SSUIButton *backButton;
@property(nonatomic, strong, readonly) SSUIButton *checkboxButton;
@property(nonatomic, strong, readonly) SSUIPieProgressView *progressView;
@property(nonatomic, strong, readonly) UIButton *downloadRetryButton;

@property(nonatomic, strong) NSMutableArray<SSUIAsset *> *imagesAssetArray;
@property(nonatomic, strong) NSMutableArray<SSUIAsset *> *selectedImageAssetArray;

@property(nonatomic, assign) SSUIAssetDownloadStatus downloadStatus;
@property(nonatomic, assign) NSUInteger maximumSelectImageCount;
@property(nonatomic, assign) NSUInteger minimumSelectImageCount;
@property(nonatomic, copy) NSString *alertTitleWhenExceedMaxSelectImageCount;
@property(nonatomic, copy) NSString *alertButtonTitleWhenExceedMaxSelectImageCount;

- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSArray<SSUIAsset *> *)imageAssetArray
                                 selectedImageAssetArray:(NSArray<SSUIAsset *> *)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode;

@end


@interface SSUIImagePickerPreviewViewController (UIAppearance)

+ (instancetype)appearance;
@end
