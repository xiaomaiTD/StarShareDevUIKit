//
//  SSUIImagePickerViewController.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIViewController.h"
#import "SSUIAsset.h"
#import "SSUIAssetsGroup.h"
#import "SSUIImagePickerPreviewViewController.h"

@class SSUIImagePickerViewController;
@class SSUIButton;

@protocol SSUIImagePickerViewControllerDelegate <NSObject>

@optional
- (SSUIImagePickerPreviewViewController *)imagePickerPreviewViewControllerForImagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController;
- (SSUIAlbumSortType)albumSortTypeForImagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController;
- (void)imagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController didFinishPickingImageWithImagesAssetArray:(NSMutableArray<SSUIAsset *> *)imagesAssetArray;
- (void)imagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController didSelectImageWithImagesAsset:(SSUIAsset *)imageAsset afterImagePickerPreviewViewControllerUpdate:(SSUIImagePickerPreviewViewController *)imagePickerPreviewViewController;

- (void)imagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController willCheckImageAtIndex:(NSInteger)index;
- (void)imagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController didCheckImageAtIndex:(NSInteger)index;
- (void)imagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController willUncheckImageAtIndex:(NSInteger)index;
- (void)imagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController didUncheckImageAtIndex:(NSInteger)index;

- (void)imagePickerViewControllerDidCancel:(SSUIImagePickerViewController *)imagePickerViewController;
- (void)imagePickerViewControllerWillStartLoad:(SSUIImagePickerViewController *)imagePickerViewController;
- (void)imagePickerViewControllerWillFinishLoad:(SSUIImagePickerViewController *)imagePickerViewController;
@end

@interface SSUIImagePickerViewController : SSUIViewController<UICollectionViewDataSource,UICollectionViewDelegate,SSUIImagePickerPreviewViewControllerDelegate>


@property(nonatomic, assign) CGFloat minimumImageWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic, weak) id<SSUIImagePickerViewControllerDelegate>imagePickerViewControllerDelegate;
@property(nonatomic, strong, readonly) UICollectionViewFlowLayout *collectionViewLayout;
@property(nonatomic, strong, readonly) UICollectionView *collectionView;
@property(nonatomic, strong, readonly) UIView *operationToolBarView;
@property(nonatomic, strong, readonly) SSUIButton *previewButton;
@property(nonatomic, strong, readonly) SSUIButton *sendButton;
@property(nonatomic, strong, readonly) UILabel *imageCountLabel;

- (void)refreshWithImagesArray:(NSMutableArray<SSUIAsset *> *)imagesArray;
- (void)refreshWithAssetsGroup:(SSUIAssetsGroup *)assetsGroup;

@property(nonatomic, strong, readonly) NSMutableArray<SSUIAsset *> *imagesAssetArray;
@property(nonatomic, strong, readonly) SSUIAssetsGroup *assetsGroup;
@property(nonatomic, strong) NSMutableArray<SSUIAsset *> *selectedImageAssetArray;
@property(nonatomic, assign) BOOL allowsMultipleSelection;
@property(nonatomic, assign) NSUInteger maximumSelectImageCount;
@property(nonatomic, assign) NSUInteger minimumSelectImageCount;
@property(nonatomic, copy) NSString *alertTitleWhenExceedMaxSelectImageCount;
@property(nonatomic, copy) NSString *alertButtonTitleWhenExceedMaxSelectImageCount;

@property(nonatomic, assign) BOOL shouldShowDefaultLoadingView;
@end

@interface SSUIImagePickerViewController (UIAppearance)

+ (instancetype)appearance;
@end
