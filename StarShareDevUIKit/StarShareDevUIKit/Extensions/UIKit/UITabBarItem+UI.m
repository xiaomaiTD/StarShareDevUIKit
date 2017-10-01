//
//  UITabBarItem+UI.m
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UITabBarItem+UI.h"
#import "UICore.h"

@implementation UITabBarItem (UI)
- (UIControl *)barButton {
  return [self valueForKey:@"view"];
}

- (UIImageView *)imageView {
  UIControl *barButton = [self barButton];
  
  if (!barButton) {
    return nil;
  }
  
  for (UIView *subview in barButton.subviews) {
    // iOS10及以后，imageView都是用UITabBarSwappableImageView实现的，所以遇到这个class就直接拿
    if ([NSStringFromClass([subview class]) isEqualToString:@"UITabBarSwappableImageView"]) {
      return (UIImageView *)subview;
    }
    
    if (IOS_VERSION < 10) {
      // iOS10以前，选中的item的高亮是用UITabBarSelectionIndicatorView实现的，所以要屏蔽掉
      if ([subview isKindOfClass:[UIImageView class]] && ![NSStringFromClass([subview class]) isEqualToString:@"UITabBarSelectionIndicatorView"]) {
        return (UIImageView *)subview;
      }
    }
    
  }
  return nil;
}

static char kAssociatedObjectKey_doubleTapBlock;
- (void)setDoubleTapBlock:(void (^)(UITabBarItem *, NSInteger))doubleTapBlock {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_doubleTapBlock, doubleTapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UITabBarItem *, NSInteger))doubleTapBlock {
  return (void (^)(UITabBarItem *, NSInteger))objc_getAssociatedObject(self, &kAssociatedObjectKey_doubleTapBlock);
}
@end
