//
//  UIViewController+UI.m
//  Project
//
//  Created by jearoc on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIViewController+UI.h"
#import "UINavigationController+UI.h"
#import "NSObject+UI.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface UIViewController ()
@property(nonatomic, assign) BOOL ss_isViewDidAppear;
@end

@implementation UIViewController (UI)

void ss_loadViewIfNeeded (id current_self, SEL current_cmd) {
  // 主动调用 self.view，从而触发 loadView，以模拟 iOS 9.0 以下的系统 loadViewIfNeeded 行为
  NSLog(@"%@", ((UIViewController *)current_self).view);
}

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    // 为 description 增加更丰富的信息
    ReplaceMethod([UIViewController class], @selector(description), @selector(ss_description));
    
    // 兼容 iOS 9.0 以下的版本对 loadViewIfNeeded 方法的调用
    if (![[UIViewController class] instancesRespondToSelector:@selector(loadViewIfNeeded)]) {
      Class metaclass = [self class];
      BOOL success = class_addMethod(metaclass, @selector(loadViewIfNeeded), (IMP)ss_loadViewIfNeeded, "v@:");
      NSLog(@"%@ %s, success = %@", NSStringFromClass([self class]), __func__, StringFromBOOL(success));
    }
    
    // 实现 AutomaticallyRotateDeviceOrientation 开关的功能
    ReplaceMethod([UIViewController class], @selector(viewWillAppear:), @selector(ss_viewWillAppear:));
  });
}

- (NSString *)ss_description {
  NSString *result = [NSString stringWithFormat:@"%@\nsuperclass:\t\t\t\t%@\ntitle:\t\t\t\t\t%@\nview:\t\t\t\t\t%@", [self ss_description], NSStringFromClass(self.superclass), self.title, [self isViewLoaded] ? self.view : nil];
  
  if ([self isKindOfClass:[UINavigationController class]]) {
    
    UINavigationController *navController = (UINavigationController *)self;
    NSString *navDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\ntopViewController:\t\t%@\nvisibleViewController:\t%@", @(navController.viewControllers.count), [self descriptionWithViewControllers:navController.viewControllers], [navController.topViewController ss_description], [navController.visibleViewController ss_description]];
    result = [result stringByAppendingString:navDescription];
    
  } else if ([self isKindOfClass:[UITabBarController class]]) {
    
    UITabBarController *tabBarController = (UITabBarController *)self;
    NSString *tabBarDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\nselectedViewController(%@):\t%@", @(tabBarController.viewControllers.count), [self descriptionWithViewControllers:tabBarController.viewControllers], @(tabBarController.selectedIndex), [tabBarController.selectedViewController ss_description]];
    result = [result stringByAppendingString:tabBarDescription];
    
  }
  return result;
}

- (NSString *)descriptionWithViewControllers:(NSArray<UIViewController *> *)viewControllers {
  NSMutableString *string = [[NSMutableString alloc] init];
  [string appendString:@"(\n"];
  for (NSInteger i = 0, l = viewControllers.count; i < l; i++) {
    [string appendFormat:@"\t\t\t\t\t\t\t[%@]%@%@\n", @(i), [viewControllers[i] ss_description], i < l - 1 ? @"," : @""];
  }
  [string appendString:@"\t\t\t\t\t\t)"];
  return [string copy];
}

- (void)ss_viewWillAppear:(BOOL)animated {
  [self ss_viewWillAppear:animated];
  if (!AutomaticallyRotateDeviceOrientation) {
    return;
  }
  
  UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  UIDeviceOrientation deviceOrientationBeforeChangingByHelper = [UIHelper sharedInstance].orientationBeforeChangingByHelper;
  BOOL shouldConsiderBeforeChanging = deviceOrientationBeforeChangingByHelper != UIDeviceOrientationUnknown;
  UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
  
  // 虽然这两者的 unknow 值是相同的，但在启动 App 时可能只有其中一个是 unknown
  if (statusBarOrientation == UIInterfaceOrientationUnknown || deviceOrientation == UIDeviceOrientationUnknown) return;
  
  // 如果当前设备方向和界面支持的方向不一致，则主动进行旋转
  UIDeviceOrientation deviceOrientationToRotate = [self interfaceOrientationMask:self.supportedInterfaceOrientations
                                                       containsDeviceOrientation:deviceOrientation] ?
  deviceOrientation :
  [self deviceOrientationWithInterfaceOrientationMask:self.supportedInterfaceOrientations];
  
  // 之前没用私有接口修改过，拿就按最标准的方式去旋转
  if (!shouldConsiderBeforeChanging) {
    if ([UIHelper rotateToDeviceOrientation:deviceOrientationToRotate]) {
      [UIHelper sharedInstance].orientationBeforeChangingByHelper = deviceOrientation;
    } else {
      [UIHelper sharedInstance].orientationBeforeChangingByHelper = UIDeviceOrientationUnknown;
    }
    return;
  }
  
  // 用私有接口修改过方向，但下一个界面和当前界面方向不相同，则要把修改前记录下来的那个设备方向考虑进来
  deviceOrientationToRotate = [self interfaceOrientationMask:self.supportedInterfaceOrientations
                                   containsDeviceOrientation:deviceOrientationBeforeChangingByHelper] ?
  
  deviceOrientationBeforeChangingByHelper :
  [self deviceOrientationWithInterfaceOrientationMask:self.supportedInterfaceOrientations];
  
  [UIHelper rotateToDeviceOrientation:deviceOrientationToRotate];
}

- (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask {
  if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
    return [UIDevice currentDevice].orientation;
  }
  if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
    return [UIDevice currentDevice].orientation;
  }
  if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
    return UIDeviceOrientationPortrait;
  }
  if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
    return [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
  }
  if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
    return UIDeviceOrientationLandscapeRight;
  }
  if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
    return UIDeviceOrientationLandscapeLeft;
  }
  if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
    return UIDeviceOrientationPortraitUpsideDown;
  }
  return [UIDevice currentDevice].orientation;
}

- (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
  if (deviceOrientation == UIDeviceOrientationUnknown) {
    return YES;// YES 表示不用额外处理
  }
  
  if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
    return YES;
  }
  if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
    return UIInterfaceOrientationPortraitUpsideDown != deviceOrientation;
  }
  if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
    return UIInterfaceOrientationPortrait == deviceOrientation;
  }
  if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
    return UIInterfaceOrientationLandscapeLeft == deviceOrientation || UIInterfaceOrientationLandscapeRight == deviceOrientation;
  }
  if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
    return UIInterfaceOrientationLandscapeLeft == deviceOrientation;
  }
  if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
    return UIInterfaceOrientationLandscapeRight == deviceOrientation;
  }
  if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
    return UIInterfaceOrientationPortraitUpsideDown == deviceOrientation;
  }
  
  return YES;
}

#pragma mark - Public

- (UIViewController *)previousViewController {
  if (self.navigationController.viewControllers &&
      self.navigationController.viewControllers.count > 1 &&
      self.navigationController.topViewController == self) {
    NSUInteger count = self.navigationController.viewControllers.count;
    return (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count - 2];
  }
  return nil;
}

- (NSString *)previousViewControllerTitle {
  UIViewController *previousViewController = [self previousViewController];
  if (previousViewController) {
    return previousViewController.title;
  }
  return nil;
}

- (BOOL)isPresented {
  UIViewController *viewController = self;
  if (self.navigationController) {
    if (self.navigationController.rootViewController != self) {
      return NO;
    }
    viewController = self.navigationController;
  }
  BOOL result = viewController.presentingViewController.presentedViewController == viewController;
  return result;
}

- (UIViewController *)visibleViewControllerIfExist {
  
  if (self.presentedViewController) {
    return [self.presentedViewController visibleViewControllerIfExist];
  }
  
  if ([self isKindOfClass:[UINavigationController class]]) {
    return [((UINavigationController *)self).visibleViewController visibleViewControllerIfExist];
  }
  
  if ([self isKindOfClass:[UITabBarController class]]) {
    return [((UITabBarController *)self).selectedViewController visibleViewControllerIfExist];
  }
  
  if ([self isViewLoadedAndVisible]) {
    return self;
  } else {
    NSLog(@"visibleViewControllerIfExist:，找不到可见的viewController。self = %@, window = %@", self,self.view.window);
    return nil;
  }
}

- (BOOL)isViewLoadedAndVisible {
  return self.isViewLoaded && self.view.window;
}

- (CGFloat)navigationBarMaxYInViewCoordinator {
  if (!self.isViewLoaded) {
    return 0;
  }
  if (!self.navigationController.navigationBar || self.navigationController.navigationBarHidden) {
    return 0;
  }
  CGRect navigationBarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.navigationController.navigationBar.frame fromView:self.navigationController.navigationBar.superview]);
  CGFloat result = CGRectGetMaxY(navigationBarFrame);
  return result;
}

- (CGFloat)toolbarSpacingInViewCoordinator {
  if (!self.isViewLoaded) {
    return 0;
  }
  if (!self.navigationController.toolbar || self.navigationController.toolbarHidden) {
    return 0;
  }
  CGRect toolbarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.navigationController.toolbar.frame fromView:self.navigationController.toolbar.superview]);
  CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(toolbarFrame);
  return result;
}

- (CGFloat)tabBarSpacingInViewCoordinator {
  if (!self.isViewLoaded) {
    return 0;
  }
  if (!self.tabBarController.tabBar || self.tabBarController.tabBar.hidden) {
    return 0;
  }
  CGRect tabBarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.tabBarController.tabBar.frame fromView:self.tabBarController.tabBar.superview]);
  CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(tabBarFrame);
  return result;
}


@end

@implementation UIViewController (Runtime)

- (BOOL)hasOverrideUIKitMethod:(SEL)selector {
  NSMutableArray<Class> *viewControllerSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                                       [UIImagePickerController class],
                                                       [UINavigationController class],
                                                       [UITableViewController class],
                                                       [UICollectionViewController class],
                                                       [UITabBarController class],
                                                       [UISplitViewController class],
                                                       [UIPageViewController class],
                                                       [UIViewController class],
                                                       nil];
  
  if (NSClassFromString(@"UIAlertController")) {
    [viewControllerSuperclasses addObject:[UIAlertController class]];
  }
  if (NSClassFromString(@"UISearchController")) {
    [viewControllerSuperclasses addObject:[UISearchController class]];
  }
  for (NSInteger i = 0, l = viewControllerSuperclasses.count; i < l; i++) {
    Class superclass = viewControllerSuperclasses[i];
    if ([self hasOverrideMethod:selector ofSuperclass:superclass]) {
      return YES;
    }
  }
  return NO;
}

@end

@implementation UIViewController (Handler)
- (BOOL)shouldHoldBackButtonEven{ return NO;}
- (BOOL)canPopViewController{ return YES;}
- (BOOL)forceEnableInteractivePopGestureRecognizer{ return NO;}
@end

@implementation UIViewController (Data)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod(self.class, @selector(viewDidAppear:), @selector(pr_viewDidAppear:));
  });
}

- (void)pr_viewDidAppear:(BOOL)animated {
  [self pr_viewDidAppear:animated];
  self.ss_isViewDidAppear = YES;
  if (self.didAppearAndLoadDataBlock && self.ss_isViewDidAppear && self.dataLoaded) {
    self.didAppearAndLoadDataBlock();
    self.didAppearAndLoadDataBlock = nil;
  }
}

static char kAssociatedObjectKey_isViewDidAppear;
- (void)setSs_isViewDidAppear:(BOOL)ss_isViewDidAppear {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_isViewDidAppear, @(ss_isViewDidAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ss_isViewDidAppear {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_isViewDidAppear)) boolValue];
}

static char kAssociatedObjectKey_didAppearAndLoadDataBlock;
- (void)setDidAppearAndLoadDataBlock:(void (^)(void))didAppearAndLoadDataBlock {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_didAppearAndLoadDataBlock, didAppearAndLoadDataBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))didAppearAndLoadDataBlock {
  return (void (^)(void))objc_getAssociatedObject(self, &kAssociatedObjectKey_didAppearAndLoadDataBlock);
}

static char kAssociatedObjectKey_dataLoaded;
- (void)setDataLoaded:(BOOL)dataLoaded {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_dataLoaded, @(dataLoaded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  if (self.didAppearAndLoadDataBlock && dataLoaded && self.ss_isViewDidAppear) {
    self.didAppearAndLoadDataBlock();
    self.didAppearAndLoadDataBlock = nil;
  }
}

- (BOOL)isDataLoaded {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dataLoaded)) boolValue];
}
@end
