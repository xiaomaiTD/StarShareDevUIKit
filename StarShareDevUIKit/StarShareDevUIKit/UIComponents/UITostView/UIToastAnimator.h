//
//  UIToastAnimator.h
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIToastView;

/**
 * `UIToastAnimatorDelegate`是所有`UIToastAnimator`或者其子类必须遵循的协议，是整个动画过程实现的地方。
 */
@protocol UIToastAnimatorDelegate <NSObject>

@required

- (void)showWithCompletion:(void (^)(BOOL finished))completion;
- (void)hideWithCompletion:(void (^)(BOOL finished))completion;
- (BOOL)isShowing;
- (BOOL)isAnimating;
@end


// TODO: 实现多种animation类型

typedef NS_ENUM(NSInteger, UIToastAnimationType) {
  UIToastAnimationTypeFade      = 0,
  UIToastAnimationTypeZoom,
  UIToastAnimationTypeSlide
};

/**
 * `UIToastAnimator`可以让你通过实现一些协议来自定义ToastView显示和隐藏的动画。你可以继承`UIToastAnimator`，然后实现`UIToastAnimatorDelegate`中的方法，即可实现自定义的动画。UIToastAnimator默认也提供了几种type的动画：1、UIToastAnimationTypeFade；2、UIToastAnimationTypeZoom；3、UIToastAnimationTypeSlide；
 */
@interface UIToastAnimator : NSObject <UIToastAnimatorDelegate>

/**
 * 初始化方法，请务必使用这个方法来初始化。
 *
 * @param toastView 要使用这个animator的UIToastView实例。
 */
- (instancetype)initWithToastView:(UIToastView *)toastView NS_DESIGNATED_INITIALIZER;

/**
 * 获取初始化传进来的UIToastView。
 */
@property(nonatomic, weak, readonly) UIToastView *toastView;

/**
 * 指定UIToastAnimator做动画的类型type。此功能暂时未实现，目前所有动画类型都是UIToastAnimationTypeFade。
 */
@property(nonatomic, assign) UIToastAnimationType animationType;

@end
