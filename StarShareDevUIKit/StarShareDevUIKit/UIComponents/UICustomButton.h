//
//  UICustomButton.h
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UIButtonImagePosition) {
  UIButtonImagePositionTop,             // imageView在titleLabel上面
  UIButtonImagePositionLeft,            // imageView在titleLabel左边
  UIButtonImagePositionBottom,          // imageView在titleLabel下面
  UIButtonImagePositionRight,           // imageView在titleLabel右边
};

@interface UICustomButton : UIButton
@property(nonatomic, assign) IBInspectable BOOL adjustsTitleTintColorAutomatically;
@property(nonatomic, assign) IBInspectable BOOL adjustsImageTintColorAutomatically;
@property(nonatomic, strong) IBInspectable UIColor *tintColorAdjustsTitleAndImage;
@property(nonatomic, assign) IBInspectable BOOL adjustsButtonWhenHighlighted;
@property(nonatomic, assign) IBInspectable BOOL adjustsButtonWhenDisabled;
@property(nonatomic, strong, nullable) IBInspectable UIColor *highlightedBackgroundColor;
@property(nonatomic, strong, nullable) IBInspectable UIColor *highlightedBorderColor;
@property(nonatomic, assign) UIButtonImagePosition imagePosition;
@property(nonatomic, assign) IBInspectable CGFloat spacingBetweenImageAndTitle;
@end

NS_ASSUME_NONNULL_END
