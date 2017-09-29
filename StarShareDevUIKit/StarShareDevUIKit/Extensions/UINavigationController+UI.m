//
//  UINavigationController+UI.m
//  Project
//
//  Created by pmo on 2017/9/24.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UINavigationController+UI.h"
#import "UIViewController+UI.h"
#import "UICore.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface UINavigationController (BackButtonHandlerProtocol)
- (nullable UIViewController *)tmp_topViewController;
@end

@implementation UINavigationController (BackButtonHandlerProtocol)
- (UIViewController *)tmp_topViewController {
  return objc_getAssociatedObject(self, _cmd);
}
- (void)setTmp_topViewController:(UIViewController *)viewController {
  objc_setAssociatedObject(self, @selector(tmp_topViewController), viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation UINavigationController (UI)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod([self class], @selector(viewDidLoad), @selector(ui_viewDidLoad));
    ReplaceMethod([self class], @selector(navigationBar:shouldPopItem:), @selector(ui_navigationBar:shouldPopItem:));
  });
}

- (nullable UIViewController *)rootViewController {
  return self.viewControllers.firstObject;
}

static char originGestureDelegateKey;
- (void)ui_viewDidLoad {
  [self ui_viewDidLoad];
  objc_setAssociatedObject(self, &originGestureDelegateKey, self.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
  self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

- (BOOL)canPopViewController:(UIViewController *)viewController {
  BOOL canPopViewController = YES;
  
  if ([viewController respondsToSelector:@selector(shouldHoldBackButtonEvent)] &&
      [viewController shouldHoldBackButtonEvent] &&
      [viewController respondsToSelector:@selector(canPopViewController)] &&
      ![viewController canPopViewController]) {
    canPopViewController = NO;
  }
  
  return canPopViewController;
}

- (BOOL)ui_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
  BOOL isPopedByCoding = item != [self topViewController].navigationItem;
  BOOL canPopViewController = !isPopedByCoding && [self canPopViewController:self.tmp_topViewController ?: [self topViewController]];
  
  if (canPopViewController || isPopedByCoding) {
    self.tmp_topViewController = nil;
    return [self ui_navigationBar:navigationBar shouldPopItem:item];
  } else {
    [self resetSubviewsInNavBar:navigationBar];
    self.tmp_topViewController = nil;
  }
  
  return NO;
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
  // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
  for(UIView *subview in [navBar subviews]) {
    if(subview.alpha < 1.0) {
      [UIView animateWithDuration:.25 animations:^{
        subview.alpha = 1.0;
      }];
    }
  }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer == self.interactivePopGestureRecognizer) {
    self.tmp_topViewController = self.topViewController;
    BOOL canPopViewController = [self canPopViewController:self.tmp_topViewController];
    if (canPopViewController) {
      id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
      if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        return [originGestureDelegate gestureRecognizerShouldBegin:gestureRecognizer];
      } else {
        return NO;
      }
    } else {
      return NO;
    }
  }
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if (gestureRecognizer == self.interactivePopGestureRecognizer) {
    id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
    if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
      // 先判断要不要强制开启手势返回
      UIViewController *viewController = [self topViewController];
      if (self.viewControllers.count > 1 &&
          self.interactivePopGestureRecognizer.enabled &&
          [viewController respondsToSelector:@selector(forceEnableInteractivePopGestureRecognizer)] &&
          [viewController forceEnableInteractivePopGestureRecognizer]) {
        return YES;
      }
      // 调用默认的实现
      return [originGestureDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
  }
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  if (gestureRecognizer == self.interactivePopGestureRecognizer) {
    id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
    if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
      return [originGestureDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
  }
  return NO;
}

// 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  if (gestureRecognizer == self.interactivePopGestureRecognizer) {
    // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
    // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
    return YES;
  }
  return NO;
}

@end

@implementation UINavigationController (Hooks)
- (void)willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {}
- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {}
@end

