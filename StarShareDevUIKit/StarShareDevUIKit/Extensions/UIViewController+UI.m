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
#import "UICore.h"

@implementation UIViewController (UI)

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
  self.pr_isViewDidAppear = YES;
  if (self.didAppearAndLoadDataBlock && self.pr_isViewDidAppear && self.dataLoaded) {
    self.didAppearAndLoadDataBlock();
    self.didAppearAndLoadDataBlock = nil;
  }
}

static char kAssociatedObjectKey_isViewDidAppear;
- (void)setPr_isViewDidAppear:(BOOL)pr_isViewDidAppear {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_isViewDidAppear, @(pr_isViewDidAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pr_isViewDidAppear {
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
  if (self.didAppearAndLoadDataBlock && dataLoaded && self.pr_isViewDidAppear) {
    self.didAppearAndLoadDataBlock();
    self.didAppearAndLoadDataBlock = nil;
  }
}

- (BOOL)isDataLoaded {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dataLoaded)) boolValue];
}
@end
