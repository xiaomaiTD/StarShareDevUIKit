//
//  SSUIImagePickerCollectionViewCell.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "SSUIAsset.h"

@class SSUIPieProgressView;

extern const UIEdgeInsets SSUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins;

@interface SSUIImagePickerCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UIImage *checkboxImage UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIImage *checkboxCheckedImage UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets checkboxButtonMargins UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *progressViewTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIImage *downloadRetryImage UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIImage *videoMarkImage UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets videoMarkImageViewMargins UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont *videoDurationLabelFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *videoDurationLabelTextColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets videoDurationLabelMargins UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong, readonly) UIImageView *contentImageView;
@property(nonatomic, strong, readonly) UIButton *checkboxButton;
@property(nonatomic, strong, readonly) SSUIPieProgressView *progressView;
@property(nonatomic, strong, readonly) UIButton *downloadRetryButton;
@property(nonatomic, strong, readonly) UIImageView *videoMarkImageView;
@property(nonatomic, strong, readonly) UILabel *videoDurationLabel;
@property(nonatomic, strong, readonly) CAGradientLayer *videoBottomShadowLayer;

@property(nonatomic, assign, getter=isEditing) BOOL editing;
@property(nonatomic, assign, getter=isChecked) BOOL checked;
@property(nonatomic, assign) SSUIAssetDownloadStatus downloadStatus;

@end
