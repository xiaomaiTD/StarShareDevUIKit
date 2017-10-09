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
- (BOOL)hasOverrideUIKitMethod:(SEL)selector;
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
