//
//  SSUINavigationController.h
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSUINavigationController : UINavigationController<UINavigationControllerDelegate>
- (void)didInitialized NS_REQUIRES_SUPER;
@end

@interface UIViewController (SSUINavigationController)

/// 判断当前 viewController 是否处于手势返回中，仅对当前手势返回涉及到的前后两个 viewController 有效
@property(nonatomic, assign, readonly) BOOL navigationControllerPoppingInteracted;

/// 当前 viewController 是否正在被手势返回 pop
@property(nonatomic, assign, readonly) BOOL poppingByInteractivePopGestureRecognizer;

/// 当前 viewController 是否是手势返回中，背后的那个界面
@property(nonatomic, assign, readonly) BOOL willAppearByInteractivePopGestureRecognizer;
@end

NS_ASSUME_NONNULL_END
