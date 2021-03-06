//
//  UIView+UI.h
//  Project
//
//  Created by pmo on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UI)
- (instancetype)initWithSize:(CGSize)size;
- (void)removeAllSubviews;
- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;
- (UIViewController *)viewController;
- (CGFloat)visibleAlpha;
+ (void)animateWithAnimated:(BOOL)animated
                   duration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion;
+ (void)animateWithAnimated:(BOOL)animated
                   duration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion;
+ (void)animateWithAnimated:(BOOL)animated
                   duration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations;
@end

@interface UIView (Runtime)

/**
 *  判断当前类是否有重写某个指定的 UIView 的方法
 *  @param selector 要判断的方法
 *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIView 默认的实现
 */
- (BOOL)hasOverrideUIKitMethod:(SEL)selector;

@end

typedef NS_OPTIONS(NSUInteger, SSUIBorderViewPosition) {
  SSUIBorderViewPositionNone      = 0,
  SSUIBorderViewPositionTop       = 1 << 0,
  SSUIBorderViewPositionLeft      = 1 << 1,
  SSUIBorderViewPositionBottom    = 1 << 2,
  SSUIBorderViewPositionRight     = 1 << 3
};
@interface UIView (Border)
@property(nonatomic, assign) SSUIBorderViewPosition borderPosition;
@property(nonatomic, assign) IBInspectable CGFloat borderWidth;
@property(nonatomic, strong) IBInspectable UIColor *borderColor;
@property(nonatomic, assign) CGFloat dashPhase;
@property(nonatomic, copy)   NSArray <NSNumber *> *dashPattern;
@property(nonatomic, strong, readonly) CAShapeLayer *borderLayer;
@end

@interface UIView (Layout)
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign) CGFloat left;
@property(nonatomic, assign) CGFloat bottom;
@property(nonatomic, assign) CGFloat right;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat extendToTop;
@property(nonatomic, assign) CGFloat extendToLeft;
@property(nonatomic, assign) CGFloat extendToBottom;
@property(nonatomic, assign) CGFloat extendToRight;
@property(nonatomic, assign, readonly) CGFloat leftWhenCenterInSuperview;
@property(nonatomic, assign, readonly) CGFloat topWhenCenterInSuperview;
@end

@interface UIView (Snapshotting)
- (UIImage *)snapshotLayerImage;
- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates;
@end
