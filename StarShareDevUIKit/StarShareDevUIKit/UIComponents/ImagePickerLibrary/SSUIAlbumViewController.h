//
//  SSUIAlbumViewController.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIListViewController.h"
#import "SSUIAssetsGroup.h"

extern const CGFloat SSUIAlbumCellDefaultCellHeight;
extern const CGFloat SSUIAlbumCellDefaultNameFontSize;
extern const CGFloat SSUIAlbumCellDefaultAssetsNumberFontSize;
extern const UIEdgeInsets SSUIAlbumCellDefaultNameInsets;

@class SSUIImagePickerViewController;
@class SSUIAlbumViewController;
@class SSUITableCell;

@protocol SSUIAlbumViewControllerDelegate <NSObject>

@required
- (SSUIImagePickerViewController *)imagePickerViewControllerForAlbumViewController:(SSUIAlbumViewController *)albumViewController;
@optional
- (void)albumViewControllerDidCancel:(SSUIAlbumViewController *)albumViewController;
- (void)albumViewControllerWillStartLoad:(SSUIAlbumViewController *)albumViewController;
- (void)albumViewControllerWillFinishLoad:(SSUIAlbumViewController *)albumViewController;
@end

@interface SSUIAlbumViewController : SSUIListViewController

@property(nonatomic, assign) CGFloat albumTableViewCellHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, weak) id<SSUIAlbumViewControllerDelegate> albumViewControllerDelegate;
@property(nonatomic, assign) SSUIAlbumContentType contentType;
@property(nonatomic, copy) NSString *tipTextWhenNoPhotosAuthorization;
@property(nonatomic, copy) NSString *tipTextWhenPhotosEmpty;
@property(nonatomic, assign) BOOL shouldShowDefaultLoadingView;
@end

@interface SSUIAlbumViewController (UIAppearance)

+ (instancetype)appearance;
@end
