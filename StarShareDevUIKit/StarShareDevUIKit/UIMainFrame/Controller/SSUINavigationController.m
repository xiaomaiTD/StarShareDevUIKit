//
//  SSUINavigationController.m
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import "SSUINavigationController.h"
#import "UICommonDefines.h"
#import "UIComponents.h"
#import "UIExtensions.h"
#import <objc/runtime.h>
#import "UICore.h"

@implementation UIViewController (SSUINavigationController)

- (BOOL)navigationControllerPoppingInteracted {
  return self.poppingByInteractivePopGestureRecognizer || self.willAppearByInteractivePopGestureRecognizer;
}

static char kAssociatedObjectKey_poppingByInteractivePopGestureRecognizer;
- (void)setPoppingByInteractivePopGestureRecognizer:(BOOL)poppingByInteractivePopGestureRecognizer {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_poppingByInteractivePopGestureRecognizer,
                           @(poppingByInteractivePopGestureRecognizer),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)poppingByInteractivePopGestureRecognizer {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_poppingByInteractivePopGestureRecognizer)) boolValue];
}

static char kAssociatedObjectKey_willAppearByInteractivePopGestureRecognizer;
- (void)setWillAppearByInteractivePopGestureRecognizer:(BOOL)willAppearByInteractivePopGestureRecognizer {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_willAppearByInteractivePopGestureRecognizer,
                           @(willAppearByInteractivePopGestureRecognizer),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)willAppearByInteractivePopGestureRecognizer {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_willAppearByInteractivePopGestureRecognizer)) boolValue];
}
@end

@interface UIViewController (SSUINavigationControllerTransition)
@property(nonatomic, assign) BOOL isViewWillAppear;
@end

@implementation UIViewController (SSUINavigationControllerTransition)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = [self class];
    ExchangeImplementations(cls, @selector(viewWillAppear:), @selector(observe_viewWillAppear:));
    ExchangeImplementations(cls, @selector(viewDidAppear:), @selector(observe_viewDidAppear:));
    ExchangeImplementations(cls, @selector(viewDidDisappear:), @selector(observe_viewDidDisappear:));
  });
}

- (void)observe_viewWillAppear:(BOOL)animated {
  [self observe_viewWillAppear:animated];
  self.isViewWillAppear = YES;
}

- (void)observe_viewDidAppear:(BOOL)animated {
  [self observe_viewDidAppear:animated];
  self.poppingByInteractivePopGestureRecognizer = NO;
  self.willAppearByInteractivePopGestureRecognizer = NO;
}

- (void)observe_viewDidDisappear:(BOOL)animated {
  [self observe_viewDidDisappear:animated];
  self.isViewWillAppear = NO;
  self.poppingByInteractivePopGestureRecognizer = NO;
  self.willAppearByInteractivePopGestureRecognizer = NO;
}

- (BOOL)isViewWillAppear {
  return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsViewWillAppear:(BOOL)isViewWillAppear {
  [self willChangeValueForKey:@"isViewWillAppear"];
  objc_setAssociatedObject(self, @selector(isViewWillAppear), [[NSNumber alloc] initWithBool:isViewWillAppear], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self didChangeValueForKey:@"isViewWillAppear"];
}

@end

@interface SSUINavigationController ()

@property(nonatomic, assign) BOOL isViewControllerTransiting;
@property(nonatomic, weak) UIViewController *viewControllerPopping;
@property(nonatomic, weak) id <UINavigationControllerDelegate> delegateProxy;
@end

@implementation SSUINavigationController

#pragma mark - 生命周期函数 && 基类方法重写

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
  self.navigationBar.tintColor = NavBarTintColor;
  self.toolbar.tintColor = ToolBarTintColor;
}

- (void)dealloc {
  self.delegate = nil;
}
  
- (void)viewDidLoad {
  [super viewDidLoad];
  if (!self.delegate) {
    self.delegate = self;
  }
  [self.interactivePopGestureRecognizer addTarget:self
                                           action:@selector(handleInteractivePopGestureRecognizer:)];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self willShowViewController:self.topViewController animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self didShowViewController:self.topViewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
  if (self.viewControllers.count < 2) {
    return [super popViewControllerAnimated:animated];
  }
  
  if (animated) {
    self.isViewControllerTransiting = YES;
  }
  
  UIViewController *viewController = [self topViewController];
  self.viewControllerPopping = viewController;
  if ([viewController respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
    [((UIViewController<UINavigationCustomTransitionDelegate> *)viewController) willPopInNavigationControllerWithAnimated:animated];
  }
  viewController = [super popViewControllerAnimated:animated];
  if ([viewController respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
    [((UIViewController<UINavigationCustomTransitionDelegate> *)viewController) didPopInNavigationControllerWithAnimated:animated];
  }
  return viewController;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (!viewController || self.topViewController == viewController) {
    return [super popToViewController:viewController animated:animated];
  }
  
  if (animated) {
    self.isViewControllerTransiting = YES;
  }
  
  self.viewControllerPopping = self.topViewController;
  for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
    UIViewController *viewControllerPopping = self.viewControllers[i];
    if (viewControllerPopping == viewController) {
      break;
    }
    if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
      BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;
      [((UIViewController<UINavigationCustomTransitionDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
    }
  }
  
  NSArray<UIViewController *> *poppedViewControllers = [super popToViewController:viewController animated:animated];
  for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
    UIViewController *viewControllerPopped = poppedViewControllers[i];
    if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
      BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;
      [((UIViewController<UINavigationCustomTransitionDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
    }
  }
  
  return poppedViewControllers;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
  if (self.topViewController == self.viewControllers.firstObject) {
    return nil;
  }
  
  if (animated) {
    self.isViewControllerTransiting = YES;
  }
  
  self.viewControllerPopping = self.topViewController;
  for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
    UIViewController *viewControllerPopping = self.viewControllers[i];
    if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
      BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;
      [((UIViewController<UINavigationCustomTransitionDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
    }
  }
  
  NSArray<UIViewController *> * poppedViewControllers = [super popToRootViewControllerAnimated:animated];
  for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
    UIViewController *viewControllerPopped = poppedViewControllers[i];
    if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
      BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;
      [((UIViewController<UINavigationCustomTransitionDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
    }
  }
  return poppedViewControllers;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
  UIViewController *topViewController = self.topViewController;
  
  NSMutableArray<UIViewController *> *viewControllersPopping = self.viewControllers.mutableCopy;
  [viewControllersPopping removeObjectsInArray:viewControllers];
  [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
      BOOL animatedArgument = obj == topViewController ? animated : NO;
      [((UIViewController<UINavigationCustomTransitionDelegate> *)obj) willPopInNavigationControllerWithAnimated:animatedArgument];
    }
  }];
  
  [super setViewControllers:viewControllers animated:animated];
  
  [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
      BOOL animatedArgument = obj == topViewController ? animated : NO;
      [((UIViewController<UINavigationCustomTransitionDelegate> *)obj) didPopInNavigationControllerWithAnimated:animatedArgument];
    }
  }];
  
  if (topViewController == viewControllers.lastObject) {
    if ([topViewController respondsToSelector:@selector(viewControllerKeepingAppearWhenSetViewControllersWithAnimated:)]) {
      [((UIViewController<UINavigationCustomTransitionDelegate> *)topViewController) viewControllerKeepingAppearWhenSetViewControllersWithAnimated:animated];
    }
  }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (self.isViewControllerTransiting || !viewController) {
    SSUIKitLog(@"%@, 上一次界面切换的动画尚未结束就试图进行新的 push 操作，为了避免产生 bug，拦截了这次 push。\n%s, isViewControllerTransiting = %@, viewController = %@, self.viewControllers = %@", NSStringFromClass(self.class),  __func__, @(self.isViewControllerTransiting), viewController, self.viewControllers);
    return;
  }
  
  if (!self.presentedViewController && animated) {
    self.isViewControllerTransiting = YES;
  }
  
  if (self.presentedViewController) {
    SSUIKitLog(@"push 的时候 navigationController 存在一个盖在上面的 presentedViewController，可能导致一些 UINavigationControllerDelegate 不会被调用");
  }
  
  UIViewController *currentViewController = self.topViewController;
  if (currentViewController) {
    if (!NeedsBackBarButtonItemTitle) {
      currentViewController.navigationItem.backBarButtonItem = [UINavigationButton barButtonItemWithType:UINavigationButtonTypeNormal
                                                                                                   title:@""
                                                                                                position:UINavigationButtonPositionLeft
                                                                                                  target:nil
                                                                                                  action:NULL];
    } else {
      UIViewController<UINavigationCustomTransitionDelegate> *vc = (UIViewController<UINavigationCustomTransitionDelegate> *)viewController;
      if ([vc respondsToSelector:@selector(backBarButtonItemTitleWithPreviousViewController:)]) {
        NSString *title = [vc backBarButtonItemTitleWithPreviousViewController:currentViewController];
        currentViewController.navigationItem.backBarButtonItem = [UINavigationButton barButtonItemWithType:UINavigationButtonTypeNormal
                                                                                                     title:title
                                                                                                  position:UINavigationButtonPositionLeft
                                                                                                    target:nil
                                                                                                    action:NULL];
      }
    }
  }
  [super pushViewController:viewController animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
  self.delegateProxy = delegate != self ? delegate : nil;
  [super setDelegate:delegate ? self : nil];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
  ///< 重写这个方法才能让 viewControllers 对 statusBar 的控制生效
  return self.topViewController;
}

#pragma mark - 自定义方法

- (BOOL)isViewControllerTransiting {
  // 如果配置表里这个开关关闭，则为了使 isViewControllerTransiting 功能失效，强制返回 NO
  if (!NavPreventConcurrentTransitions) {
    return NO;
  }
  return _isViewControllerTransiting;
}

#pragma mark - 接管系统手势返回的回调

- (void)handleInteractivePopGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
  UIGestureRecognizerState state = gestureRecognizer.state;
  if (state == UIGestureRecognizerStateBegan) {
    [self.viewControllerPopping addObserver:self forKeyPath:@"isViewWillAppear" options:NSKeyValueObservingOptionNew context:nil];
  }
  
  UIViewController *viewControllerWillDisappear = self.viewControllerPopping;
  UIViewController *viewControllerWillAppear = self.topViewController;
  
  if (state == UIGestureRecognizerStateEnded) {
    if (CGRectGetMinX(self.topViewController.view.superview.frame) < 0) {
      SSUIKitLog(@"手势返回放弃了");
      viewControllerWillDisappear = self.topViewController;
      viewControllerWillAppear = self.viewControllerPopping;
    } else {
      SSUIKitLog(@"执行手势返回");
    }
  }
  
  viewControllerWillDisappear.poppingByInteractivePopGestureRecognizer = YES;
  viewControllerWillDisappear.willAppearByInteractivePopGestureRecognizer = NO;
  
  viewControllerWillDisappear.poppingByInteractivePopGestureRecognizer = NO;
  viewControllerWillAppear.willAppearByInteractivePopGestureRecognizer = YES;
  
  if ([viewControllerWillDisappear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:)]) {
    [((UIViewController<UINavigationCustomTransitionDelegate> *)viewControllerWillDisappear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
  }
  
  if ([viewControllerWillAppear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:)]) {
    [((UIViewController<UINavigationCustomTransitionDelegate> *)viewControllerWillAppear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if ([keyPath isEqualToString:@"isViewWillAppear"]) {
    [self.viewControllerPopping removeObserver:self forKeyPath:@"isViewWillAppear"];
    NSNumber *newValue = change[NSKeyValueChangeNewKey];
    if (newValue.boolValue) {
      [self navigationController:self willShowViewController:self.viewControllerPopping animated:YES];
      self.viewControllerPopping = nil;
      self.isViewControllerTransiting = NO;
    }
  }
}

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  [self willShowViewController:viewController animated:animated];
  if ([self.delegateProxy respondsToSelector:_cmd]) {
    [self.delegateProxy navigationController:navigationController
                      willShowViewController:viewController
                                    animated:animated];
  }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  self.viewControllerPopping = nil;
  self.isViewControllerTransiting = NO;
  [self didShowViewController:viewController animated:animated];
  if ([self.delegateProxy respondsToSelector:_cmd]) {
    [self.delegateProxy navigationController:navigationController
                       didShowViewController:viewController
                                    animated:animated];
  }
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
  if ([self.delegateProxy respondsToSelector:_cmd]) {
    return [self.delegateProxy navigationController:navigationController
        interactionControllerForAnimationController:animationController];
  }
  
  return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
  if ([self.delegateProxy respondsToSelector:_cmd]) {
    return [self.delegateProxy navigationController:navigationController
                    animationControllerForOperation:operation
                                 fromViewController:fromVC
                                   toViewController:toVC];
  }
  
  return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
  return [super methodSignatureForSelector:aSelector] ?: [(id)self.delegateProxy methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
  if ([(id)self.delegateProxy respondsToSelector:anInvocation.selector]) {
    [anInvocation invokeWithTarget:(id)self.delegateProxy];
  }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  return [super respondsToSelector:aSelector] || ([self shouldRespondDelegeateProxyWithSelector:aSelector] && [self.delegateProxy respondsToSelector:aSelector]);
}

- (BOOL)shouldRespondDelegeateProxyWithSelector:(SEL)aSelctor {
  return
  [NSStringFromSelector(aSelctor)
   isEqualToString:@"navigationController:willShowViewController:animated:"] ||
  [NSStringFromSelector(aSelctor)
   isEqualToString:@"navigationController:didShowViewController:animated:"] ||
  [NSStringFromSelector(aSelctor)
   isEqualToString:@"navigationController:interactionControllerForAnimationController:"] ||
  [NSStringFromSelector(aSelctor)
   isEqualToString:@"navigationController:animationControllerForOperation:fromViewController:toViewController:"];
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
  return [self.topViewController hasOverrideUIKitMethod:_cmd] ? [self.topViewController shouldAutorotate] : YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return [self.topViewController hasOverrideUIKitMethod:_cmd] ? [self.topViewController supportedInterfaceOrientations] : UIInterfaceOrientationMaskPortrait;
}
@end

