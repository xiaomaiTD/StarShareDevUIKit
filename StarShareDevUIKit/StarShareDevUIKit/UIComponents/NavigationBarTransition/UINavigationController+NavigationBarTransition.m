//
//  UINavigationController+NavigationBarTransition.m
//  Project
//
//  Created by jearoc on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UINavigationController+NavigationBarTransition.h"
#import "UINavigationBar+Transition.h"
#import "UICore.h"
#import "UIExtensions.h"
#import "SSUIViewController.h"

@interface _UITransitionNavigationBar : UINavigationBar
@end

@implementation _UITransitionNavigationBar
- (void)layoutSubviews {
  [super layoutSubviews];
  if (@available(iOS 11,*)) {
    // iOS 11 以前，自己 init 的 navigationBar，它的 backgroundView 默认会一直保持与 navigationBar 的高度相等
    // 但 iOS 11 Beta 1-5 里，自己 init 的 navigationBar.backgroundView.height 默认一直是 44
    // 所以才加上这个兼容
    UIView *backgroundView = [self valueForKey:@"backgroundView"];
    backgroundView.frame = self.bounds;
  }
}
@end

@interface UIViewController (NavigationBarTransition)
@property (nonatomic, strong) _UITransitionNavigationBar *transitionNavigationBar;
@property (nonatomic, assign) BOOL prefersNavigationBarBackgroundViewHidden;
@property(nonatomic, assign) BOOL originClipsToBounds;
@property(nonatomic, strong) UIColor *originContainerViewBackgroundColor;
- (void)addTransitionNavigationBarIfNeeded;
@property (nonatomic, assign) BOOL lockTransitionNavigationBar;
- (BOOL)respondUINavigationControllerDelegate;
@end

@implementation UIViewController (NavigationBarTransition)

#pragma mark - 主流程

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = [self class];
    ReplaceMethod(cls, @selector(viewWillLayoutSubviews), @selector(NavigationBarTransition_viewWillLayoutSubviews));
    ReplaceMethod(cls, @selector(viewWillAppear:), @selector(NavigationBarTransition_viewWillAppear:));
    ReplaceMethod(cls, @selector(viewDidAppear:), @selector(NavigationBarTransition_viewDidAppear:));
    ReplaceMethod(cls, @selector(viewDidDisappear:), @selector(NavigationBarTransition_viewDidDisappear:));
  });
}

- (void)NavigationBarTransition_viewWillAppear:(BOOL)animated {
  [self renderNavigationStyleInViewController:self animated:animated];
  [self NavigationBarTransition_viewWillAppear:animated];
}

- (void)NavigationBarTransition_viewDidAppear:(BOOL)animated {
  if (self.transitionNavigationBar) {
    [UIViewController replaceStyleForNavigationBar:self.transitionNavigationBar withNavigationBar:self.navigationController.navigationBar];
    [self removeTransitionNavigationBar];
    self.lockTransitionNavigationBar = YES;
    
    id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
    [transitionCoordinator containerView].backgroundColor = self.originContainerViewBackgroundColor;
    self.view.clipsToBounds = self.originClipsToBounds;
  }
  self.prefersNavigationBarBackgroundViewHidden = NO;
  [self NavigationBarTransition_viewDidAppear:animated];
}

- (void)NavigationBarTransition_viewDidDisappear:(BOOL)animated {
  if (self.transitionNavigationBar) {
    [self removeTransitionNavigationBar];
    self.lockTransitionNavigationBar = NO;
    
    self.view.clipsToBounds = self.originClipsToBounds;
  }
  [self NavigationBarTransition_viewDidDisappear:animated];
}

- (void)NavigationBarTransition_viewWillLayoutSubviews {
  
  id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
  UIViewController *fromViewController = [transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
  
  BOOL isCurrentToViewController = (self == self.navigationController.viewControllers.lastObject && self == toViewController);
  BOOL isPushingViewContrller = [self.navigationController.viewControllers containsObject:fromViewController];
  
  if (isCurrentToViewController && !self.lockTransitionNavigationBar) {
    
    BOOL shouldCustomNavigationBarTransition = NO;
    
    if (!self.transitionNavigationBar) {
      
      if (isPushingViewContrller) {
        if ([toViewController canCustomNavigationBarTransitionWhenPushAppearing] ||
            [fromViewController canCustomNavigationBarTransitionWhenPushDisappearing]) {
          shouldCustomNavigationBarTransition = YES;
        }
      } else {
        if ([toViewController canCustomNavigationBarTransitionWhenPopAppearing] ||
            [fromViewController canCustomNavigationBarTransitionWhenPopDisappearing]) {
          shouldCustomNavigationBarTransition = YES;
        }
      }
      
      if (shouldCustomNavigationBarTransition) {
        if (self.navigationController.navigationBar.translucent) {
          toViewController.originContainerViewBackgroundColor = [transitionCoordinator containerView].backgroundColor;
          [transitionCoordinator containerView].backgroundColor = [self containerViewBackgroundColor];
        }
        fromViewController.originClipsToBounds = fromViewController.view.clipsToBounds;
        toViewController.originClipsToBounds = toViewController.view.clipsToBounds;
        fromViewController.view.clipsToBounds = NO;
        toViewController.view.clipsToBounds = NO;
        [self addTransitionNavigationBarIfNeeded];
        [self resizeTransitionNavigationBarFrame];
        self.navigationController.navigationBar.transitionNavigationBar = self.transitionNavigationBar;
        self.prefersNavigationBarBackgroundViewHidden = YES;
      }
    }
  }
  
  [self NavigationBarTransition_viewWillLayoutSubviews];
}

- (void)addTransitionNavigationBarIfNeeded {
  
  if (!self.view.window || !self.navigationController.navigationBar) {
    return;
  }
  
  UINavigationBar *originBar = self.navigationController.navigationBar;
  _UITransitionNavigationBar *customBar = [[_UITransitionNavigationBar alloc] init];
  
  if (customBar.barStyle != originBar.barStyle) {
    customBar.barStyle = originBar.barStyle;
  }
  if (customBar.translucent != originBar.translucent) {
    customBar.translucent = originBar.translucent;
  }
  if (![customBar.barTintColor isEqual:originBar.barTintColor]) {
    customBar.barTintColor = originBar.barTintColor;
  }
  UIImage *backgroundImage = [originBar backgroundImageForBarMetrics:UIBarMetricsDefault];
  if (backgroundImage && CGSizeEqualToSize(backgroundImage.size, CGSizeZero)) {
    backgroundImage = [UIImage imageWithColor:UIColorClear];
  }
  [customBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
  [customBar setShadowImage:originBar.shadowImage];
  
  self.transitionNavigationBar = customBar;
  [self resizeTransitionNavigationBarFrame];
  
  if (!self.navigationController.navigationBarHidden) {
    [self.view addSubview:self.transitionNavigationBar];
  }
}

- (void)removeTransitionNavigationBar {
  if (!self.transitionNavigationBar) {
    return;
  }
  [self.transitionNavigationBar removeFromSuperview];
  self.transitionNavigationBar = nil;
}

- (void)resizeTransitionNavigationBarFrame {
  if (!self.view.window) {
    return;
  }
  UIView *backgroundView = [self.navigationController.navigationBar valueForKey:@"backgroundView"];
  CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
  self.transitionNavigationBar.frame = rect;
}

#pragma mark - 工具方法

- (BOOL)respondUINavigationControllerDelegate {
  return [[self class] conformsToProtocol:@protocol(UINavigationCustomTransitionDelegate)];
}

- (void)renderNavigationStyleInViewController:(UIViewController *)viewController animated:(BOOL)animated {
  
  if (viewController != viewController.navigationController.topViewController) {
    return;
  }
  
  if (viewController.respondUINavigationControllerDelegate) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)viewController;
    
    // 控制界面的状态栏颜色
    if ([vc shouldSetStatusBarStyleLight]) {
      if ([[UIApplication sharedApplication] statusBarStyle] < UIStatusBarStyleLightContent) {
        [UIHelper renderStatusBarStyleLight];
      }
    } else {
      if ([[UIApplication sharedApplication] statusBarStyle] >= UIStatusBarStyleLightContent) {
        [UIHelper renderStatusBarStyleDark];
      }
    }
    
    // 显示/隐藏 导航栏
    if ([vc canCustomNavigationBarTransitionIfBarHiddenable]) {
      if ([vc hideNavigationBarWhenTransitioning]) {
        if (!viewController.navigationController.isNavigationBarHidden) {
          [viewController.navigationController setNavigationBarHidden:YES animated:animated];
        }
      } else {
        if (viewController.navigationController.isNavigationBarHidden) {
          [viewController.navigationController setNavigationBarHidden:NO animated:animated];
        }
      }
    }
    
    // 导航栏的背景
    if ([vc respondsToSelector:@selector(navigationBarBackgroundImage)]) {
      UIImage *backgroundImage = [vc navigationBarBackgroundImage];
      [viewController.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    } else {
      [viewController.navigationController.navigationBar setBackgroundImage:NavBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    
    // 导航栏底部的分隔线
    if ([vc respondsToSelector:@selector(navigationBarShadowImage)]) {
      UIImage *shadowImage = [vc navigationBarShadowImage];
      [viewController.navigationController.navigationBar setShadowImage:shadowImage];
    } else {
      [viewController.navigationController.navigationBar setShadowImage:NavBarShadowImage];
    }
    
    // 导航栏上控件的主题色
    if ([vc respondsToSelector:@selector(navigationBarTintColor)]) {
      UIColor *tintColor = [vc navigationBarTintColor];
      viewController.navigationController.navigationBar.tintColor = tintColor;
    } else {
      viewController.navigationController.navigationBar.tintColor = NavBarTintColor;
    }
    
    // 导航栏title的颜色
    if ([vc isKindOfClass:[SSUIViewController class]]) {
      SSUIViewController *viewController = (SSUIViewController *)vc;
      if ([viewController respondsToSelector:@selector(titleViewTintColor)]) {
        UIColor *tintColor = [viewController titleViewTintColor];
        viewController.titleView.tintColor = tintColor;
      } else {
        viewController.titleView.tintColor = NavBarTitleColor;
      }
    }
  }
}

+ (void)replaceStyleForNavigationBar:(UINavigationBar *)navbarA withNavigationBar:(UINavigationBar *)navbarB {
  navbarB.barStyle = navbarA.barStyle;
  navbarB.barTintColor = navbarA.barTintColor;
  [navbarB setBackgroundImage:[navbarA backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
  [navbarB setShadowImage:navbarA.shadowImage];
}

// 该 viewController 是否实现自定义 navBar 动画的协议

- (BOOL)respondCustomNavigationBarTransitionWhenPushAppearing {
  BOOL respondPushAppearing = NO;
  if ([self respondUINavigationControllerDelegate]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPushAppearing)]) {
      respondPushAppearing = YES;
    }
  }
  return respondPushAppearing;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPushDisappearing {
  BOOL respondPushDisappearing = NO;
  if ([self respondUINavigationControllerDelegate]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPushDisappearing)]) {
      respondPushDisappearing = YES;
    }
  }
  return respondPushDisappearing;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPopAppearing {
  BOOL respondPopAppearing = NO;
  if ([self respondUINavigationControllerDelegate]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPopAppearing)]) {
      respondPopAppearing = YES;
    }
  }
  return respondPopAppearing;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPopDisappearing {
  BOOL respondPopDisappearing = NO;
  if ([self respondUINavigationControllerDelegate]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPopDisappearing)]) {
      respondPopDisappearing = YES;
    }
  }
  return respondPopDisappearing;
}

- (BOOL)respondCustomNavigationBarTransitionIfBarHiddenable {
  BOOL respondIfBarHiddenable = NO;
  if ([self respondUINavigationControllerDelegate]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionIfBarHiddenable)]) {
      respondIfBarHiddenable = YES;
    }
  }
  return respondIfBarHiddenable;
}

- (BOOL)respondCustomNavigationBarTransitionWithBarHiddenState {
  BOOL respondWithBarHidden = NO;
  if ([self respondUINavigationControllerDelegate]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    if ([vc respondsToSelector:@selector(preferredNavigationBarHidden)]) {
      respondWithBarHidden = YES;
    }
  }
  return respondWithBarHidden;
}

// 该 viewController 实现自定义 navBar 动画的协议的返回值

- (BOOL)canCustomNavigationBarTransitionWhenPushAppearing {
  if ([self respondCustomNavigationBarTransitionWhenPushAppearing]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    return [vc shouldCustomNavigationBarTransitionWhenPushAppearing];
  }
  return NO;
}

- (BOOL)canCustomNavigationBarTransitionWhenPushDisappearing {
  if ([self respondCustomNavigationBarTransitionWhenPushDisappearing]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    return [vc shouldCustomNavigationBarTransitionWhenPushDisappearing];
  }
  return NO;
}

- (BOOL)canCustomNavigationBarTransitionWhenPopAppearing {
  if ([self respondCustomNavigationBarTransitionWhenPopAppearing]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    return [vc shouldCustomNavigationBarTransitionWhenPopAppearing];
  }
  return NO;
}

- (BOOL)canCustomNavigationBarTransitionWhenPopDisappearing {
  if ([self respondCustomNavigationBarTransitionWhenPopDisappearing]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    return [vc shouldCustomNavigationBarTransitionWhenPopDisappearing];
  }
  return NO;
}

- (BOOL)canCustomNavigationBarTransitionIfBarHiddenable {
  if ([self respondCustomNavigationBarTransitionIfBarHiddenable]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    return [vc shouldCustomNavigationBarTransitionIfBarHiddenable];
  }
  return NO;
}

- (BOOL)hideNavigationBarWhenTransitioning {
  if ([self respondCustomNavigationBarTransitionWithBarHiddenState]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    BOOL hidden = [vc preferredNavigationBarHidden];
    return hidden;
  }
  return NO;
}

- (UIColor *)containerViewBackgroundColor {
  UIColor *backgroundColor = UIColorWhite;
  if ([self respondUINavigationControllerDelegate]) {
    UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)self;
    if ([vc respondsToSelector:@selector(containerViewBackgroundColorWhenTransitioning)]) {
      backgroundColor = [vc containerViewBackgroundColorWhenTransitioning];
    }
  }
  return backgroundColor;
}

#pragma mark - Setter / Getter

- (BOOL)lockTransitionNavigationBar {
  return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLockTransitionNavigationBar:(BOOL)lockTransitionNavigationBar {
  objc_setAssociatedObject(self, @selector(lockTransitionNavigationBar), [[NSNumber alloc] initWithBool:lockTransitionNavigationBar], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationBar *)transitionNavigationBar {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setTransitionNavigationBar:(UINavigationBar *)transitionNavigationBar {
  objc_setAssociatedObject(self, @selector(transitionNavigationBar), transitionNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)prefersNavigationBarBackgroundViewHidden {
  return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setPrefersNavigationBarBackgroundViewHidden:(BOOL)prefersNavigationBarBackgroundViewHidden {
  [[self.navigationController.navigationBar valueForKey:@"backgroundView"] setHidden:prefersNavigationBarBackgroundViewHidden];
  objc_setAssociatedObject(self, @selector(prefersNavigationBarBackgroundViewHidden), [[NSNumber alloc] initWithBool:prefersNavigationBarBackgroundViewHidden], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)originClipsToBounds {
  return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setOriginClipsToBounds:(BOOL)originClipsToBounds {
  objc_setAssociatedObject(self, @selector(originClipsToBounds), [[NSNumber alloc] initWithBool:originClipsToBounds], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)originContainerViewBackgroundColor {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setOriginContainerViewBackgroundColor:(UIColor *)originContainerViewBackgroundColor {
  objc_setAssociatedObject(self, @selector(originContainerViewBackgroundColor), originContainerViewBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UINavigationController (NavigationBarTransition)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = [self class];
    ReplaceMethod(cls, @selector(pushViewController:animated:), @selector(NavigationBarTransition_pushViewController:animated:));
    ReplaceMethod(cls, @selector(popViewControllerAnimated:), @selector(NavigationBarTransition_popViewControllerAnimated:));
    ReplaceMethod(cls, @selector(popToViewController:animated:), @selector(NavigationBarTransition_popToViewController:animated:));
    ReplaceMethod(cls, @selector(popToRootViewControllerAnimated:), @selector(NavigationBarTransition_popToRootViewControllerAnimated:));
  });
}

- (void)NavigationBarTransition_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  UIViewController *disappearingViewController = self.viewControllers.lastObject;
  if (!disappearingViewController) {
    return [self NavigationBarTransition_pushViewController:viewController animated:animated];
  }
  
  BOOL shouldCustomNavigationBarTransition = NO;
  ///< 上一个界面消失时是否需要自定义过渡动画
  if ([disappearingViewController canCustomNavigationBarTransitionWhenPushDisappearing]) {
    shouldCustomNavigationBarTransition = YES;
  }
  ///< 将要出现的界面是否需要自定义过渡动画
  if (!shouldCustomNavigationBarTransition && [viewController canCustomNavigationBarTransitionWhenPushAppearing]) {
    shouldCustomNavigationBarTransition = YES;
  }
  if (shouldCustomNavigationBarTransition) {
    ///< 添加假的过渡导航栏
    [disappearingViewController addTransitionNavigationBarIfNeeded];
    disappearingViewController.prefersNavigationBarBackgroundViewHidden = YES;
  }
  
  return [self NavigationBarTransition_pushViewController:viewController animated:animated];
}

- (UIViewController *)NavigationBarTransition_popViewControllerAnimated:(BOOL)animated {
  UIViewController *disappearingViewController = self.viewControllers.lastObject;
  UIViewController *appearingViewController = self.viewControllers.count >= 2 ? self.viewControllers[self.viewControllers.count - 2] : nil;
  
  if (!disappearingViewController) {
    return [self NavigationBarTransition_popViewControllerAnimated:animated];
  }
  [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
  
  return [self NavigationBarTransition_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)NavigationBarTransition_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
  UIViewController *disappearingViewController = self.viewControllers.lastObject;
  UIViewController *appearingViewController = viewController;
  NSArray<UIViewController *> *poppedViewControllers = [self NavigationBarTransition_popToViewController:viewController animated:animated];
  if (poppedViewControllers) {
    [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
  }
  return poppedViewControllers;
}

- (NSArray<UIViewController *> *)NavigationBarTransition_popToRootViewControllerAnimated:(BOOL)animated {
  NSArray<UIViewController *> *poppedViewControllers = [self NavigationBarTransition_popToRootViewControllerAnimated:animated];
  if (self.viewControllers.count > 1) {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    UIViewController *appearingViewController = self.viewControllers.firstObject;
    if (poppedViewControllers) {
      [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    }
  }
  return poppedViewControllers;
}

- (void)handlePopViewControllerNavigationBarTransitionWithDisappearViewController:(UIViewController *)disappearViewController appearViewController:(UIViewController *)appearViewController {
  BOOL shouldCustomNavigationBarTransition = NO;
  if ([disappearViewController canCustomNavigationBarTransitionWhenPopDisappearing]) {
    shouldCustomNavigationBarTransition = YES;
  }
  if (appearViewController && !shouldCustomNavigationBarTransition && [appearViewController canCustomNavigationBarTransitionWhenPopAppearing]) {
    shouldCustomNavigationBarTransition = YES;
  }
  if (shouldCustomNavigationBarTransition) {
    [disappearViewController addTransitionNavigationBarIfNeeded];
    if (appearViewController.transitionNavigationBar) {
      // 假设从A→B→C，其中A设置了bar的样式，B跟随A所以B里没有设置bar样式的代码，C又把样式改为另一种，此时从C返回B时，由于B没有设置bar的样式的代码，所以bar的样式依然会保留C的，这就错了，所以每次都要手动改回来才保险
      [UIViewController replaceStyleForNavigationBar:appearViewController.transitionNavigationBar withNavigationBar:self.navigationBar];
    }
    disappearViewController.prefersNavigationBarBackgroundViewHidden = YES;
  }
}

@end
