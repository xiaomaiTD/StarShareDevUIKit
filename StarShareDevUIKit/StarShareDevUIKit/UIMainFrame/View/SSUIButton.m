//
//  SSUIButton.m
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIButton.h"
#import "UICore.h"
#import "UIExtensions.h"

@interface SSUIButton ()
@property(nonatomic, strong) CALayer *highlightedBackgroundLayer;
@property(nonatomic, strong) UIColor *originBorderColor;
- (void)didInitialized;// UISubclassingHooks
@end

@implementation SSUIButton

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self didInitialized];
    
    self.tintColor = ButtonTintColor;
    if (!self.adjustsTitleTintColorAutomatically) {
      [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    
    // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
    self.contentEdgeInsets = UIEdgeInsetsMake(CGFLOAT_MIN, 0, CGFLOAT_MIN, 0);
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self didInitialized];
  }
  return self;
}

- (void)didInitialized {
  self.adjustsTitleTintColorAutomatically = NO;
  self.adjustsImageTintColorAutomatically = NO;
  
  // 默认接管highlighted和disabled的表现，去掉系统默认的表现
  self.adjustsImageWhenHighlighted = NO;
  self.adjustsImageWhenDisabled = NO;
  self.adjustsButtonWhenHighlighted = YES;
  self.adjustsButtonWhenDisabled = YES;
  
  // 图片默认在按钮左边，与系统UIButton保持一致
  self.imagePosition = SSUIButtonImagePositionLeft;
}

- (CGSize)sizeThatFits:(CGSize)size {
  // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
  if (CGSizeEqualToSize(self.bounds.size, size)) {
    size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  }
  
  BOOL isImageViewShowing = self.imageView && !self.imageView.hidden;
  BOOL isTitleLabelShowing = self.titleLabel && !self.titleLabel.hidden;
  CGSize imageTotalSize = CGSizeZero;// 包含 imageEdgeInsets 那些空间
  CGSize titleTotalSize = CGSizeZero;// 包含 titleEdgeInsets 那些空间
  CGFloat spacingBetweenImageAndTitle = isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0;// 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
  UIEdgeInsets contentEdgeInsets = UIEdgeInsetsRemoveFloatMin(self.contentEdgeInsets);
  CGSize resultSize = CGSizeZero;
  CGSize contentLimitSize = CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(contentEdgeInsets), size.height - UIEdgeInsetsGetVerticalValue(contentEdgeInsets));
  
  switch (self.imagePosition) {
    case SSUIButtonImagePositionTop:
    case SSUIButtonImagePositionBottom: {
      // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度
      if (isImageViewShowing) {
        CGFloat imageLimitWidth = contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
        CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, CGFLOAT_MAX)];// 假设图片高度必定完整显示
        imageSize.width = fmin(imageSize.width, imageLimitWidth);
        imageTotalSize = CGSizeMake(imageSize.width + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
      }
      
      if (isTitleLabelShowing) {
        CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentLimitSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
        titleSize.height = fmin(titleSize.height, titleLimitSize.height);
        titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
      }
      
      resultSize.width = UIEdgeInsetsGetHorizontalValue(contentEdgeInsets);
      resultSize.width += fmax(imageTotalSize.width, titleTotalSize.width);
      resultSize.height = UIEdgeInsetsGetVerticalValue(contentEdgeInsets) + imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height;
    }
      break;
      
    case SSUIButtonImagePositionLeft:
    case SSUIButtonImagePositionRight: {
      // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度
      // 注意这里有一个和系统不一致的行为：当 titleLabel 为多行时，系统的 sizeThatFits: 计算结果固定是单行的，所以当 UIButtonImagePositionLeft 并且titleLabel 多行的情况下，UICustomButton 计算的结果与系统不一致
      
      if (isImageViewShowing) {
        CGFloat imageLimitHeight = contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
        CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageLimitHeight)];// 假设图片宽度必定完整显示，高度不超过按钮内容
        imageSize.height = fmin(imageSize.height, imageLimitHeight);
        imageTotalSize = CGSizeMake(imageSize.width + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
      }
      
      if (isTitleLabelShowing) {
        CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - imageTotalSize.width - spacingBetweenImageAndTitle, contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
        titleSize.height = fmin(titleSize.height, titleLimitSize.height);
        titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
      }
      
      resultSize.width = UIEdgeInsetsGetHorizontalValue(contentEdgeInsets) + imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
      resultSize.height = UIEdgeInsetsGetVerticalValue(contentEdgeInsets);
      resultSize.height += fmax(imageTotalSize.height, titleTotalSize.height);
    }
      break;
  }
  return resultSize;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if (CGRectIsEmpty(self.bounds)) {
    return;
  }
  
  BOOL isImageViewShowing = self.imageView && !self.imageView.hidden;
  BOOL isTitleLabelShowing = self.titleLabel && !self.titleLabel.hidden;
  CGSize imageLimitSize = CGSizeZero;
  CGSize titleLimitSize = CGSizeZero;
  CGSize imageTotalSize = CGSizeZero;// 包含 imageEdgeInsets 那些空间
  CGSize titleTotalSize = CGSizeZero;// 包含 titleEdgeInsets 那些空间
  CGFloat spacingBetweenImageAndTitle = isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0;// 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局
  CGRect imageFrame = CGRectZero;
  CGRect titleFrame = CGRectZero;
  UIEdgeInsets contentEdgeInsets = UIEdgeInsetsRemoveFloatMin(self.contentEdgeInsets);
  CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(contentEdgeInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(contentEdgeInsets));
  
  // 图片的布局原则都是尽量完整展示，所以不管 imagePosition 的值是什么，这个计算过程都是相同的
  if (isImageViewShowing) {
    imageLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
    CGSize imageSize = [self.imageView sizeThatFits:imageLimitSize];
    imageSize.width = fmin(imageLimitSize.width, imageSize.width);
    imageSize.height = fmin(imageLimitSize.height, imageSize.height);
    imageFrame = CGRectMakeWithSize(imageSize);
    imageTotalSize = CGSizeMake(imageSize.width + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
  }
  
  if (self.imagePosition == SSUIButtonImagePositionTop || self.imagePosition == SSUIButtonImagePositionBottom) {
    
    if (isTitleLabelShowing) {
      titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
      CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
      titleSize.width = fmin(titleLimitSize.width, titleSize.width);
      titleSize.height = fmin(titleLimitSize.height, titleSize.height);
      titleFrame = CGRectMakeWithSize(titleSize);
      titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
    }
    
    switch (self.contentHorizontalAlignment) {
      case UIControlContentHorizontalAlignmentLeft:
        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame;
        break;
      case UIControlContentHorizontalAlignmentCenter:
        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left + CGFloatGetCenter(imageLimitSize.width, CGRectGetWidth(imageFrame))) : imageFrame;
        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left + CGFloatGetCenter(titleLimitSize.width, CGRectGetWidth(titleFrame))) : titleFrame;
        break;
      case UIControlContentHorizontalAlignmentRight:
        imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
        titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
        break;
      case UIControlContentHorizontalAlignmentFill:
        if (isImageViewShowing) {
          imageFrame = CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
          imageFrame = CGRectSetWidth(imageFrame, imageLimitSize.width);
        }
        if (isTitleLabelShowing) {
          titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
          titleFrame = CGRectSetWidth(titleFrame, titleLimitSize.width);
        }
        break;
      default:
        break;
    }
    
    if (self.imagePosition == SSUIButtonImagePositionTop) {
      switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
          imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
          titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
          break;
        case UIControlContentVerticalAlignmentCenter: {
          CGFloat contentHeight = imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height;
          CGFloat minY = CGFloatGetCenter(contentSize.height, contentHeight) + contentEdgeInsets.top;
          imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, minY + self.imageEdgeInsets.top) : imageFrame;
          titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, minY + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
        }
          break;
        case UIControlContentVerticalAlignmentBottom:
          titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
          imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - titleTotalSize.height - spacingBetweenImageAndTitle - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
          break;
        case UIControlContentVerticalAlignmentFill: {
          if (isImageViewShowing && isTitleLabelShowing) {
            
            // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label
            imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
            titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
            titleFrame = isTitleLabelShowing ? CGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame)) : titleFrame;
            
          } else if (isImageViewShowing) {
            imageFrame = CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
            imageFrame = CGRectSetHeight(imageFrame, contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
          } else {
            titleFrame = CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
            titleFrame = CGRectSetHeight(titleFrame, contentSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
          }
        }
          break;
      }
    } else {
      switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentTop:
          titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top) : titleFrame;
          imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + titleTotalSize.height + spacingBetweenImageAndTitle + self.imageEdgeInsets.top) : imageFrame;
          break;
        case UIControlContentVerticalAlignmentCenter: {
          CGFloat contentHeight = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageAndTitle;
          CGFloat minY = CGFloatGetCenter(contentSize.height, contentHeight) + contentEdgeInsets.top;
          titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, minY + self.titleEdgeInsets.top) : titleFrame;
          imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, minY + titleTotalSize.height + spacingBetweenImageAndTitle + self.imageEdgeInsets.top) : imageFrame;
        }
          break;
        case UIControlContentVerticalAlignmentBottom:
          imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
          titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
          break;
        case UIControlContentVerticalAlignmentFill: {
          if (isImageViewShowing && isTitleLabelShowing) {
            
            // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label
            imageFrame = CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
            titleFrame = CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
            titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
            
          } else if (isImageViewShowing) {
            imageFrame = CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
            imageFrame = CGRectSetHeight(imageFrame, contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
          } else {
            titleFrame = CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
            titleFrame = CGRectSetHeight(titleFrame, contentSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
          }
        }
          break;
      }
    }
    
    self.imageView.frame = CGRectFlatted(imageFrame);
    self.titleLabel.frame = CGRectFlatted(titleFrame);
    
  } else if (self.imagePosition == SSUIButtonImagePositionLeft || self.imagePosition == SSUIButtonImagePositionRight) {
    
    if (isTitleLabelShowing) {
      titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - imageTotalSize.width - spacingBetweenImageAndTitle, contentSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
      CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
      titleSize.width = fmin(titleLimitSize.width, titleSize.width);
      titleSize.height = fmin(titleLimitSize.height, titleSize.height);
      titleFrame = CGRectMakeWithSize(titleSize);
      titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
    }
    
    switch (self.contentVerticalAlignment) {
      case UIControlContentVerticalAlignmentTop:
        imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
        titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top) : titleFrame;
        
        break;
      case UIControlContentVerticalAlignmentCenter:
        imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, contentEdgeInsets.top + CGFloatGetCenter(contentSize.height, CGRectGetHeight(imageFrame)) + self.imageEdgeInsets.top) : imageFrame;
        titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, contentEdgeInsets.top + CGFloatGetCenter(contentSize.height, CGRectGetHeight(titleFrame)) + self.titleEdgeInsets.top) : titleFrame;
        break;
      case UIControlContentVerticalAlignmentBottom:
        imageFrame = isImageViewShowing ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
        titleFrame = isTitleLabelShowing ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
        break;
      case UIControlContentVerticalAlignmentFill:
        if (isImageViewShowing) {
          imageFrame = CGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
          imageFrame = CGRectSetHeight(imageFrame, contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
        }
        if (isTitleLabelShowing) {
          titleFrame = CGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
          titleFrame = CGRectSetHeight(titleFrame, contentSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        }
        break;
    }
    
    if (self.imagePosition == SSUIButtonImagePositionLeft) {
      switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentLeft:
          imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
          titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
          break;
        case UIControlContentHorizontalAlignmentCenter: {
          CGFloat contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
          CGFloat minX = contentEdgeInsets.left + CGFloatGetCenter(contentSize.width, contentWidth);
          imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, minX + self.imageEdgeInsets.left) : imageFrame;
          titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, minX + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
        }
          break;
        case UIControlContentHorizontalAlignmentRight: {
          if (imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width) {
            // 图片和文字总宽超过按钮宽度，则优先完整显示图片
            imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
            titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
          } else {
            // 内容不超过按钮宽度，则靠右布局即可
            titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
            imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - titleTotalSize.width - spacingBetweenImageAndTitle - imageTotalSize.width + self.imageEdgeInsets.left) : imageFrame;
          }
        }
          break;
        case UIControlContentHorizontalAlignmentFill: {
          if (isImageViewShowing && isTitleLabelShowing) {
            // 同时显示图片和 label 的情况下，图片按本身宽度显示，剩余空间留给 label
            imageFrame = CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
            titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left);
            titleFrame = CGRectSetWidth(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame));
          } else if (isImageViewShowing) {
            imageFrame = CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
            imageFrame = CGRectSetWidth(imageFrame, contentSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets));
          } else {
            titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
            titleFrame = CGRectSetWidth(titleFrame, contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets));
          }
        }
          break;
        default:
          break;
      }
    } else {
      switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentLeft: {
          if (imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width) {
            // 图片和文字总宽超过按钮宽度，则优先完整显示图片
            imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
            titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleTotalSize.width + self.titleEdgeInsets.left) : titleFrame;
          } else {
            // 内容不超过按钮宽度，则靠左布局即可
            titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame;
            imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, contentEdgeInsets.left + titleTotalSize.width + spacingBetweenImageAndTitle + self.imageEdgeInsets.left) : imageFrame;
          }
        }
          break;
        case UIControlContentHorizontalAlignmentCenter: {
          CGFloat contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
          CGFloat minX = contentEdgeInsets.left + CGFloatGetCenter(contentSize.width, contentWidth);
          titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, minX + self.titleEdgeInsets.left) : titleFrame;
          imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, minX + titleTotalSize.width + spacingBetweenImageAndTitle + self.imageEdgeInsets.left) : imageFrame;
        }
          break;
        case UIControlContentHorizontalAlignmentRight:
          imageFrame = isImageViewShowing ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
          titleFrame = isTitleLabelShowing ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
          break;
        case UIControlContentHorizontalAlignmentFill: {
          if (isImageViewShowing && isTitleLabelShowing) {
            // 图片按自身大小显示，剩余空间由标题占满
            imageFrame = CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame));
            titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
            titleFrame = CGRectSetWidth(titleFrame, CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - self.spacingBetweenImageAndTitle - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame));
            
          } else if (isImageViewShowing) {
            imageFrame = CGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
            imageFrame = CGRectSetWidth(imageFrame, contentSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets));
          } else {
            titleFrame = CGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
            titleFrame = CGRectSetWidth(titleFrame, contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets));
          }
        }
          break;
        default:
          break;
      }
    }
    
    self.imageView.frame = CGRectFlatted(imageFrame);
    self.titleLabel.frame = CGRectFlatted(titleFrame);
  }
}

- (void)setSpacingBetweenImageAndTitle:(CGFloat)spacingBetweenImageAndTitle {
  _spacingBetweenImageAndTitle = spacingBetweenImageAndTitle;
  
  [self setNeedsLayout];
}

- (void)setImagePosition:(SSUIButtonImagePosition)imagePosition {
  _imagePosition = imagePosition;
  
  [self setNeedsLayout];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
  _highlightedBackgroundColor = highlightedBackgroundColor;
  if (_highlightedBackgroundColor) {
    // 只要开启了highlightedBackgroundColor，就默认不需要alpha的高亮
    self.adjustsButtonWhenHighlighted = NO;
  }
}

- (void)setHighlightedBorderColor:(UIColor *)highlightedBorderColor {
  _highlightedBorderColor = highlightedBorderColor;
  if (_highlightedBorderColor) {
    // 只要开启了highlightedBorderColor，就默认不需要alpha的高亮
    self.adjustsButtonWhenHighlighted = NO;
  }
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  
  if (highlighted && !self.originBorderColor) {
    // 手指按在按钮上会不断触发setHighlighted:，所以这里做了保护，设置过一次就不用再设置了
    self.originBorderColor = [UIColor colorWithCGColor:self.layer.borderColor];
  }
  
  // 渲染背景色
  if (self.highlightedBackgroundColor || self.highlightedBorderColor) {
    [self adjustsButtonHighlighted];
  }
  // 如果此时是disabled，则disabled的样式优先
  if (!self.enabled) {
    return;
  }
  // 自定义highlighted样式
  if (self.adjustsButtonWhenHighlighted) {
    if (highlighted) {
      self.alpha = ButtonHighlightedAlpha;
    } else {
      [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
      }];
    }
  }
}

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  if (!enabled && self.adjustsButtonWhenDisabled) {
    self.alpha = ButtonDisabledAlpha;
  } else {
    [UIView animateWithDuration:0.25f animations:^{
      self.alpha = 1;
    }];
  }
}

- (void)adjustsButtonHighlighted {
  if (self.highlightedBackgroundColor) {
    if (!self.highlightedBackgroundLayer) {
      self.highlightedBackgroundLayer = [CALayer layer];
      [self.highlightedBackgroundLayer removeDefaultAnimations];
      [self.layer insertSublayer:self.highlightedBackgroundLayer atIndex:0];
    }
    self.highlightedBackgroundLayer.frame = self.bounds;
    self.highlightedBackgroundLayer.cornerRadius = self.layer.cornerRadius;
    self.highlightedBackgroundLayer.backgroundColor = self.highlighted ? self.highlightedBackgroundColor.CGColor : UIColorClear.CGColor;
  }
  
  if (self.highlightedBorderColor) {
    self.layer.borderColor = self.highlighted ? self.highlightedBorderColor.CGColor : self.originBorderColor.CGColor;
  }
}

- (void)setAdjustsTitleTintColorAutomatically:(BOOL)adjustsTitleTintColorAutomatically {
  _adjustsTitleTintColorAutomatically = adjustsTitleTintColorAutomatically;
  [self updateTitleColorIfNeeded];
}

- (void)updateTitleColorIfNeeded {
  if (self.adjustsTitleTintColorAutomatically && self.currentTitleColor) {
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
  }
  if (self.adjustsTitleTintColorAutomatically && self.currentAttributedTitle) {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.currentAttributedTitle];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.tintColor range:NSMakeRange(0, attributedString.length)];
    [self setAttributedTitle:attributedString forState:UIControlStateNormal];
  }
}

- (void)setAdjustsImageTintColorAutomatically:(BOOL)adjustsImageTintColorAutomatically {
  BOOL valueDifference = _adjustsImageTintColorAutomatically != adjustsImageTintColorAutomatically;
  _adjustsImageTintColorAutomatically = adjustsImageTintColorAutomatically;
  
  if (valueDifference) {
    [self updateImageRenderingModeIfNeeded];
  }
}

- (void)updateImageRenderingModeIfNeeded {
  if (self.currentImage) {
    NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
    for (NSNumber *number in states) {
      UIImage *image = [self imageForState:[number unsignedIntegerValue]];
      if (!image) {
        continue;
      }
      
      if (self.adjustsImageTintColorAutomatically) {
        // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
        [self setImage:image forState:[number unsignedIntegerValue]];
      } else {
        // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
        [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
      }
    }
  }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
  if (self.adjustsImageTintColorAutomatically) {
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }
  [super setImage:image forState:state];
}

- (void)tintColorDidChange {
  [super tintColorDidChange];
  
  [self updateTitleColorIfNeeded];
  
  if (self.adjustsImageTintColorAutomatically) {
    [self updateImageRenderingModeIfNeeded];
  }
}

- (void)setTintColorAdjustsTitleAndImage:(UIColor *)tintColorAdjustsTitleAndImage {
  if (tintColorAdjustsTitleAndImage) {
    self.tintColor = tintColorAdjustsTitleAndImage;
    self.adjustsTitleTintColorAutomatically = YES;
    self.adjustsImageTintColorAutomatically = YES;
  }
}

- (UIColor *)tintColorAdjustsTitleAndImage {
  return self.tintColor;
}

@end

@interface SSUILinkButton ()
@property(nonatomic, strong) CALayer *underlineLayer;
@end

@implementation SSUILinkButton

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self didInitialized];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self didInitialized];
  }
  return self;
}

- (void)didInitialized {
  [super didInitialized];
  
  self.underlineLayer = [CALayer layer];
  [self.underlineLayer removeDefaultAnimations];
  [self.layer addSublayer:self.underlineLayer];
  
  self.underlineHidden = NO;
  self.underlineWidth = 1;
  self.underlineColor = nil;
  self.underlineInsets = UIEdgeInsetsZero;
}

- (void)setUnderlineHidden:(BOOL)underlineHidden {
  _underlineHidden = underlineHidden;
  self.underlineLayer.hidden = underlineHidden;
}

- (void)setUnderlineWidth:(CGFloat)underlineWidth {
  _underlineWidth = underlineWidth;
  [self setNeedsLayout];
}

- (void)setUnderlineColor:(UIColor *)underlineColor {
  _underlineColor = underlineColor;
  [self updateUnderlineColor];
}

- (void)setUnderlineInsets:(UIEdgeInsets)underlineInsets {
  _underlineInsets = underlineInsets;
  [self setNeedsLayout];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (!self.underlineLayer.hidden) {
    self.underlineLayer.frame = CGRectMake(self.underlineInsets.left, CGRectGetMaxY(self.titleLabel.frame) + self.underlineInsets.top - self.underlineInsets.bottom, CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.underlineInsets), self.underlineWidth);
  }
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
  [super setTitleColor:color forState:state];
  [self updateUnderlineColor];
}

- (void)updateUnderlineColor {
  UIColor *color = self.underlineColor ? : [self titleColorForState:UIControlStateNormal];
  self.underlineLayer.backgroundColor = color.CGColor;
}

@end

@implementation SSUITimerButton

- (void)startTimerWithDuaration:(NSTimeInterval)duration
{
  __weak typeof(self) weakSelf = self;
  __block NSTimeInterval remainTime = duration;
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
  dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
  dispatch_source_set_event_handler(timer, ^{
    if (remainTime <= 0) {
      dispatch_source_cancel(timer);
      dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.enabled = YES;
        if (weakSelf.completedBlock) {
          NSString *title = weakSelf.completedBlock();
          [weakSelf setTitle:title forState:UIControlStateNormal];
        }
      });
    } else {
      remainTime--;
      if (weakSelf.excutingBlock) {
        dispatch_sync(dispatch_get_main_queue(), ^{
          weakSelf.enabled = NO;
          NSString *title = weakSelf.excutingBlock(remainTime);
          [weakSelf setTitle:title forState:UIControlStateNormal];
        });
      }
    }
  });
  dispatch_resume(timer);
}

@end

const CGFloat SSUIGhostButtonCornerRadiusAdjustsBounds = -1;

@implementation SSUIGhostButton

- (instancetype)initWithFrame:(CGRect)frame {
  return [self initWithGhostType:SSUIGhostButtonColorBlue frame:frame];
}

- (instancetype)initWithGhostType:(SSUIGhostButtonColor)ghostType {
  return [self initWithGhostType:ghostType frame:CGRectZero];
}

- (instancetype)initWithGhostType:(SSUIGhostButtonColor)ghostType frame:(CGRect)frame {
  UIColor *ghostColor = nil;
  switch (ghostType) {
    case SSUIGhostButtonColorBlue:
      ghostColor = GhostButtonColorBlue;
      break;
    case SSUIGhostButtonColorRed:
      ghostColor = GhostButtonColorRed;
      break;
    case SSUIGhostButtonColorGreen:
      ghostColor = GhostButtonColorGreen;
      break;
    case SSUIGhostButtonColorGray:
      ghostColor = GhostButtonColorGray;
      break;
    case SSUIGhostButtonColorWhite:
      ghostColor = GhostButtonColorWhite;
      break;
    default:
      break;
  }
  return [self initWithGhostColor:ghostColor frame:frame];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor {
  return [self initWithGhostColor:ghostColor frame:CGRectZero];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor frame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self initializeWithGhostColor:ghostColor];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self initializeWithGhostColor:GhostButtonColorBlue];
  }
  return self;
}

- (void)initializeWithGhostColor:(UIColor *)ghostColor {
  self.ghostColor = ghostColor;
}

- (void)setGhostColor:(UIColor *)ghostColor {
  _ghostColor = ghostColor;
  [self setTitleColor:_ghostColor forState:UIControlStateNormal];
  self.layer.borderColor = _ghostColor.CGColor;
  if (self.adjustsImageWithGhostColor) {
    [self updateImageColor];
  }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
  _borderWidth = borderWidth;
  self.layer.borderWidth = _borderWidth;
}

- (void)setAdjustsImageWithGhostColor:(BOOL)adjustsImageWithGhostColor {
  _adjustsImageWithGhostColor = adjustsImageWithGhostColor;
  [self updateImageColor];
}

- (void)updateImageColor {
  self.imageView.tintColor = self.adjustsImageWithGhostColor ? self.ghostColor : nil;
  if (self.currentImage) {
    NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
    for (NSNumber *number in states) {
      UIImage *image = [self imageForState:[number unsignedIntegerValue]];
      if (!image) {
        continue;
      }
      if (self.adjustsImageWithGhostColor) {
        // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
        [self setImage:image forState:[number unsignedIntegerValue]];
      } else {
        // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
        [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
      }
    }
  }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
  if (self.adjustsImageWithGhostColor) {
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }
  [super setImage:image forState:state];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
  [super layoutSublayersOfLayer:layer];
  if (self.cornerRadius != SSUIGhostButtonCornerRadiusAdjustsBounds) {
    self.layer.cornerRadius = self.cornerRadius;
  } else {
    self.layer.cornerRadius = flat(CGRectGetHeight(self.bounds) / 2);
  }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
  _cornerRadius = cornerRadius;
  [self setNeedsLayout];
}

@end

@interface SSUIGhostButton (UIAppearance)

@end

@implementation SSUIGhostButton (UIAppearance)

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self setDefaultAppearance];
  });
}

+ (void)setDefaultAppearance {
  SSUIGhostButton *appearance = [SSUIGhostButton appearance];
  appearance.borderWidth = 1;
  appearance.cornerRadius = SSUIGhostButtonCornerRadiusAdjustsBounds;
  appearance.adjustsImageWithGhostColor = NO;
}

@end

const CGFloat SSUIFillButtonCornerRadiusAdjustsBounds = -1;

@implementation SSUIFillButton

- (instancetype)init {
  return [self initWithFillType:SSUIFillButtonColorBlue];
}

- (instancetype)initWithFrame:(CGRect)frame {
  return [self initWithFillType:SSUIFillButtonColorBlue frame:frame];
}

- (instancetype)initWithFillType:(SSUIFillButtonColor)fillType {
  return [self initWithFillType:fillType frame:CGRectZero];
}

- (instancetype)initWithFillType:(SSUIFillButtonColor)fillType frame:(CGRect)frame {
  UIColor *fillColor = nil;
  UIColor *textColor = UIColorWhite;
  switch (fillType) {
    case SSUIFillButtonColorBlue:
      fillColor = FillButtonColorBlue;
      break;
    case SSUIFillButtonColorRed:
      fillColor = FillButtonColorRed;
      break;
    case SSUIFillButtonColorGreen:
      fillColor = FillButtonColorGreen;
      break;
    case SSUIFillButtonColorGray:
      fillColor = FillButtonColorGray;
      break;
    case SSUIFillButtonColorWhite:
      fillColor = FillButtonColorWhite;
      textColor = UIColorBlue;
    default:
      break;
  }
  return [self initWithFillColor:fillColor titleTextColor:textColor frame:frame];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor {
  return [self initWithFillColor:fillColor titleTextColor:textColor frame:CGRectZero];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor frame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.fillColor = fillColor;
    self.titleTextColor = textColor;
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    self.fillColor = FillButtonColorBlue;
    self.titleTextColor = UIColorWhite;
  }
  return self;
}

- (void)setAdjustsImageWithTitleTextColor:(BOOL)adjustsImageWithTitleTextColor {
  _adjustsImageWithTitleTextColor = adjustsImageWithTitleTextColor;
  if (adjustsImageWithTitleTextColor) {
    [self updateImageColor];
  }
}

- (void)setFillColor:(UIColor *)fillColor {
  _fillColor = fillColor;
  self.backgroundColor = fillColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
  _titleTextColor = titleTextColor;
  [self setTitleColor:titleTextColor forState:UIControlStateNormal];
  if (self.adjustsImageWithTitleTextColor) {
    [self updateImageColor];
  }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
  if (self.adjustsImageWithTitleTextColor) {
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }
  [super setImage:image forState:state];
}

- (void)updateImageColor {
  self.imageView.tintColor = self.adjustsImageWithTitleTextColor ? self.titleTextColor : nil;
  if (self.currentImage) {
    NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
    for (NSNumber *number in states) {
      UIImage *image = [self imageForState:[number unsignedIntegerValue]];
      if (!image) {
        continue;
      }
      if (self.adjustsImageWithTitleTextColor) {
        // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
        [self setImage:image forState:[number unsignedIntegerValue]];
      } else {
        // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
        [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
      }
    }
  }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
  [super layoutSublayersOfLayer:layer];
  if (self.cornerRadius != SSUIFillButtonCornerRadiusAdjustsBounds) {
    self.layer.cornerRadius = self.cornerRadius;
  } else {
    self.layer.cornerRadius = flat(CGRectGetHeight(self.bounds) / 2);
  }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
  _cornerRadius = cornerRadius;
  [self setNeedsLayout];
}

@end

@interface SSUILoadingButton ()
@property (nonatomic, strong) NSString *title;
@end

@implementation SSUILoadingButton

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self didInitialized];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self didInitialized];
  }
  return self;
}

- (void)didInitialized {
  [super didInitialized];
  
  _loading = NO;
  _spacingWithImageOrTitle = 10;
  _activityIndicatorAlignment = SSUILoadingButtonAlignmentLeft;
  _shouldProhibitUserInteractionWhenLoading = YES;
  
  _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [_activityIndicator setHidesWhenStopped:YES];
  [_activityIndicator stopAnimating];
  _activityIndicator.userInteractionEnabled = NO;
  [self addSubview:_activityIndicator];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  if (_loading) {
    self.imageView.hidden = _activityIndicatorAlignment == SSUILoadingButtonAlignmentCenter;
    self.titleLabel.hidden = _activityIndicatorAlignment == SSUILoadingButtonAlignmentCenter;
    [_activityIndicator startAnimating];
  }else{
    self.imageView.hidden = NO;
    self.titleLabel.hidden = NO;
    [_activityIndicator stopAnimating];
  }
  
  if (_activityIndicatorAlignment == SSUILoadingButtonAlignmentCenter) {
    _activityIndicator.center = CGPointMake(self.width/2.0, self.height/2.0);
  }else if (_activityIndicatorAlignment == SSUILoadingButtonAlignmentLeft){
    _activityIndicator.centerY = self.height/2.0;
    
    // 有没有图片
    if (self.imageView && !CGSizeEqualToSize(self.imageView.size, CGSizeZero)) {
      if (self.imagePosition != SSUILoadingButtonAlignmentLeft) {
        if (self.titleLabel && !CGSizeEqualToSize(self.titleLabel.size, CGSizeZero)){
          _activityIndicator.right = self.titleLabel.left - _spacingWithImageOrTitle;
        }else{
          _activityIndicator.right = self.imageView.left - _spacingWithImageOrTitle;
        }
      }else{
        _activityIndicator.right = self.imageView.left - _spacingWithImageOrTitle;
      }
    }else if (self.titleLabel && !CGSizeEqualToSize(self.titleLabel.size, CGSizeZero)){
      _activityIndicator.right = self.titleLabel.left - _spacingWithImageOrTitle;
    }else{
      _activityIndicator.center = CGPointMake(self.width/2.0, self.height/2.0);
    }
  }else if (_activityIndicatorAlignment == SSUILoadingButtonAlignmentRight){
    _activityIndicator.centerY = self.height/2.0;
    
    // 有没有图片
    if (self.imageView && !CGSizeEqualToSize(self.imageView.size, CGSizeZero)) {
      if (self.imagePosition != SSUILoadingButtonAlignmentRight) {
        if (self.titleLabel && !CGSizeEqualToSize(self.titleLabel.size, CGSizeZero)){
          _activityIndicator.left = self.titleLabel.right + _spacingWithImageOrTitle;
        }else{
          _activityIndicator.left = self.imageView.right + _spacingWithImageOrTitle;
        }
      }else{
        _activityIndicator.left = self.imageView.right + _spacingWithImageOrTitle;
      }
    }else if (self.titleLabel && !CGSizeEqualToSize(self.titleLabel.size, CGSizeZero)){
      _activityIndicator.left = self.titleLabel.right + _spacingWithImageOrTitle;
    }else{
      _activityIndicator.center = CGPointMake(self.width/2.0, self.height/2.0);
    }
  }
}

- (void)setActivityIndicatorAlignment:(SSUILoadingButtonAlignment)activityIndicatorAlignment
{
  _activityIndicatorAlignment = activityIndicatorAlignment;
  [self setNeedsLayout];
}

- (void)setSpacingWithImageOrTitle:(CGFloat)spacingWithImageOrTitle
{
  _spacingWithImageOrTitle = spacingWithImageOrTitle;
  [self setNeedsLayout];
}

- (void)setLoading:(BOOL)loading
{
  _loading = loading;
  if(_shouldProhibitUserInteractionWhenLoading)self.enabled = !loading;
  [self setNeedsLayout];
}

- (void)setShouldProhibitUserInteractionWhenLoading:(BOOL)shouldProhibitUserInteractionWhenLoading
{
  _shouldProhibitUserInteractionWhenLoading = shouldProhibitUserInteractionWhenLoading;
  if (shouldProhibitUserInteractionWhenLoading) {
    self.enabled = !_loading;
  }else{
    self.enabled = YES;
  }
}

@end

@interface SSUIFillButton (UIAppearance)

@end

@implementation SSUIFillButton (UIAppearance)

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self setDefaultAppearance];
  });
}

+ (void)setDefaultAppearance {
  SSUIFillButton *appearance = [SSUIFillButton appearance];
  appearance.cornerRadius = SSUIFillButtonCornerRadiusAdjustsBounds;
  appearance.adjustsImageWithTitleTextColor = NO;
}

@end
