//
//  SSUIButton.h
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSUIButtonImagePosition) {
  SSUIButtonImagePositionTop,             // imageView在titleLabel上面
  SSUIButtonImagePositionLeft,            // imageView在titleLabel左边
  SSUIButtonImagePositionBottom,          // imageView在titleLabel下面
  SSUIButtonImagePositionRight,           // imageView在titleLabel右边
};

typedef NS_ENUM(NSUInteger, SSUIGhostButtonColor) {
  SSUIGhostButtonColorBlue,
  SSUIGhostButtonColorRed,
  SSUIGhostButtonColorGreen,
  SSUIGhostButtonColorGray,
  SSUIGhostButtonColorWhite,
};

typedef NS_ENUM(NSUInteger, SSUIFillButtonColor) {
  SSUIFillButtonColorBlue,
  SSUIFillButtonColorRed,
  SSUIFillButtonColorGreen,
  SSUIFillButtonColorGray,
  SSUIFillButtonColorWhite,
};

@interface SSUIButton : UIButton
@property(nonatomic, assign) IBInspectable BOOL adjustsTitleTintColorAutomatically;
@property(nonatomic, assign) IBInspectable BOOL adjustsImageTintColorAutomatically;
@property(nonatomic, strong) IBInspectable UIColor *tintColorAdjustsTitleAndImage;
@property(nonatomic, assign) IBInspectable BOOL adjustsButtonWhenHighlighted;
@property(nonatomic, assign) IBInspectable BOOL adjustsButtonWhenDisabled;
@property(nonatomic, strong, nullable) IBInspectable UIColor *highlightedBackgroundColor;
@property(nonatomic, strong, nullable) IBInspectable UIColor *highlightedBorderColor;
@property(nonatomic, assign) SSUIButtonImagePosition imagePosition;
@property(nonatomic, assign) IBInspectable CGFloat spacingBetweenImageAndTitle;
@end

@interface SSUILinkButton : SSUIButton
@property(nonatomic, assign) IBInspectable BOOL underlineHidden;
@property(nonatomic, assign) IBInspectable CGFloat underlineWidth;
@property(nonatomic, strong, nullable) IBInspectable UIColor *underlineColor;
@property(nonatomic, assign) UIEdgeInsets underlineInsets;
@end

typedef NSString *_Nonnull(^SSUITimerButtonBeginBlock)(NSTimeInterval currentTime);
typedef NSString *_Nonnull(^SSUITimerButtonCompleteBlock)(void);
@interface SSUITimerButton : SSUIButton
- (void)startTimerWithDuaration:(NSTimeInterval)duration;
@property(nonatomic, copy) SSUITimerButtonBeginBlock excutingBlock;
@property(nonatomic, copy) SSUITimerButtonCompleteBlock completedBlock;
@end

extern const CGFloat SSUIGhostButtonCornerRadiusAdjustsBounds;
@interface SSUIGhostButton : SSUIButton
@property(nonatomic, strong, nullable) IBInspectable UIColor *ghostColor;
@property(nonatomic, assign) CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) BOOL adjustsImageWithGhostColor UI_APPEARANCE_SELECTOR;
- (instancetype)initWithGhostType:(SSUIGhostButtonColor)ghostType;
- (instancetype)initWithGhostColor:(nullable UIColor *)ghostColor;
@end

extern const CGFloat SSUIFillButtonCornerRadiusAdjustsBounds;
@interface SSUIFillButton : SSUIButton
@property(nonatomic, strong, nullable) IBInspectable UIColor *fillColor;
@property(nonatomic, strong, nullable) IBInspectable UIColor *titleTextColor;
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) BOOL adjustsImageWithTitleTextColor UI_APPEARANCE_SELECTOR;
- (instancetype)initWithFillType:(SSUIFillButtonColor)fillType;
- (instancetype)initWithFillType:(SSUIFillButtonColor)fillType frame:(CGRect)frame;
- (instancetype)initWithFillColor:(nullable UIColor *)fillColor titleTextColor:(nullable UIColor *)textColor;
- (instancetype)initWithFillColor:(nullable UIColor *)fillColor titleTextColor:(nullable UIColor *)textColor frame:(CGRect)frame;
@end

typedef enum {
  SSUILoadingButtonAlignmentLeft      = 0,
  SSUILoadingButtonAlignmentCenter    = 1,
  SSUILoadingButtonAlignmentRight     = 2,
} SSUILoadingButtonAlignment;
@interface SSUILoadingButton : SSUIButton
@property(nonatomic, assign) BOOL loading;
@property(nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator; // default UIActivityIndicatorViewStyleWhite
@property(nonatomic, assign) CGFloat spacingWithImageOrTitle; // default is 10 , effective for SSUILoadingButtonAlignmentLeft && SSUILoadingButtonAlignmentRight.
@property(nonatomic, assign) SSUILoadingButtonAlignment activityIndicatorAlignment; // Default SSUILoadingButtonAlignmentLeft,when SSUILoadingButtonAlignmentCenter title and image will be hiden.
@property(nonatomic, assign) BOOL shouldProhibitUserInteractionWhenLoading; // default is YES
@end

NS_ASSUME_NONNULL_END
