//
//  UINavigationController+UI.h
//  Project
//
//  Created by pmo on 2017/9/24.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (UI)
- (nullable UIViewController *)rootViewController;
@end

@interface UINavigationController (Hooks)
- (void)willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@protocol UINavigationControllerBackButtonHandlerProtocol <NSObject>
@optional
- (BOOL)shouldHoldBackButtonEvent;
- (BOOL)canPopViewController;
- (BOOL)forceEnableInteractivePopGestureRecognizer;
@end

@protocol UINavigationCustomTransitionDelegate <NSObject>
@required
- (BOOL)shouldSetStatusBarStyleLight;
- (BOOL)preferredNavigationBarHidden;
@optional
- (void)willPopInNavigationControllerWithAnimated:(BOOL)animated;
- (void)didPopInNavigationControllerWithAnimated:(BOOL)animated;
- (void)viewControllerKeepingAppearWhenSetViewControllersWithAnimated:(BOOL)animated;
- (nullable UIColor *)titleViewTintColor;
- (nullable UIImage *)navigationBarBackgroundImage;
- (nullable UIImage *)navigationBarShadowImage;
- (nullable UIColor *)navigationBarTintColor;
- (nullable NSString *)backBarButtonItemTitleWithPreviousViewController:(nullable UIViewController *)viewController;
- (BOOL)shouldCustomNavigationBarTransitionWhenPushAppearing;
- (BOOL)shouldCustomNavigationBarTransitionWhenPushDisappearing;
- (BOOL)shouldCustomNavigationBarTransitionWhenPopAppearing;
- (BOOL)shouldCustomNavigationBarTransitionWhenPopDisappearing;
- (nullable UIColor *)containerViewBackgroundColorWhenTransitioning;
- (BOOL)shouldCustomNavigationBarTransitionIfBarHiddenable;
@end

NS_ASSUME_NONNULL_END
