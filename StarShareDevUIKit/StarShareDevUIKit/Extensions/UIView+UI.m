//
//  UIView+UI.m
//  Project
//
//  Created by pmo on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIView+UI.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "UICore.h"
#import "NSObject+UI.h"
#import "UIImage+UI.h"

@implementation UIView (UI)

- (instancetype)initWithSize:(CGSize)size {
  return [self initWithFrame:CGRectMakeWithSize(size)];
}

- (void)removeAllSubviews {
  while (self.subviews.count) {
    [self.subviews.lastObject removeFromSuperview];
  }
}

- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius {
  self.layer.shadowColor = color.CGColor;
  self.layer.shadowOffset = offset;
  self.layer.shadowRadius = radius;
  self.layer.shadowOpacity = 1;
  self.layer.shouldRasterize = YES;
  self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (UIViewController *)viewController {
  for (UIView *view = self; view; view = view.superview) {
    UIResponder *nextResponder = [view nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
      return (UIViewController *)nextResponder;
    }
  }
  return nil;
}

- (CGFloat)visibleAlpha {
  if ([self isKindOfClass:[UIWindow class]]) {
    if (self.hidden) return 0;
    return self.alpha;
  }
  if (!self.window) return 0;
  CGFloat alpha = 1;
  UIView *v = self;
  while (v) {
    if (v.hidden) {
      alpha = 0;
      break;
    }
    alpha *= v.alpha;
    v = v.superview;
  }
  return alpha;
}

+ (void)animateWithAnimated:(BOOL)animated
                   duration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion {
  if (animated) {
    [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
  } else {
    if (animations) {
      animations();
    }
    if (completion) {
      completion(YES);
    }
  }
}

+ (void)animateWithAnimated:(BOOL)animated
                   duration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion {
  if (animated) {
    [UIView animateWithDuration:duration animations:animations completion:completion];
  } else {
    if (animations) {
      animations();
    }
    if (completion) {
      completion(YES);
    }
  }
}

+ (void)animateWithAnimated:(BOOL)animated
                   duration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations {
  if (animated) {
    [UIView animateWithDuration:duration animations:animations];
  } else {
    if (animations) {
      animations();
    }
  }
}

@end

@implementation UIView (Runtime)

- (BOOL)hasOverrideUIKitMethod:(SEL)selector {
  // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
  NSMutableArray<Class> *viewSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                             [UILabel class],
                                             [UIButton class],
                                             [UISegmentedControl class],
                                             [UITextField class],
                                             [UISlider class],
                                             [UISwitch class],
                                             [UIActivityIndicatorView class],
                                             [UIProgressView class],
                                             [UIPageControl class],
                                             [UIStepper class],
                                             [UITableView class],
                                             [UITableViewCell class],
                                             [UIImageView class],
                                             [UICollectionView class],
                                             [UICollectionViewCell class],
                                             [UICollectionReusableView class],
                                             [UITextView class],
                                             [UIScrollView class],
                                             [UIDatePicker class],
                                             [UIPickerView class],
                                             [UIWebView class],
                                             [UIWindow class],
                                             [UINavigationBar class],
                                             [UIToolbar class],
                                             [UITabBar class],
                                             [UISearchBar class],
                                             [UIControl class],
                                             [UIView class],
                                             nil];
  
  if (NSClassFromString(@"UIStackView")) {
    [viewSuperclasses addObject:[UIStackView class]];
  }
  if (NSClassFromString(@"UIVisualEffectView")) {
    [viewSuperclasses addObject:[UIVisualEffectView class]];
  }
  
  for (NSInteger i = 0, l = viewSuperclasses.count; i < l; i++) {
    Class superclass = viewSuperclasses[i];
    if ([self hasOverrideMethod:selector ofSuperclass:superclass]) {
      return YES;
    }
  }
  return NO;
}

@end

@implementation UIView (Layout)

- (CGFloat)centerX {
  return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
  self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
  return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
  self.center = CGPointMake(self.center.x, centerY);
}


- (CGPoint)origin {
  return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
  CGRect frame = self.frame;
  frame.origin = origin;
  self.frame = frame;
}

- (CGSize)size {
  return self.frame.size;
}

- (void)setSize:(CGSize)size {
  self.frame = CGRectSetSize(self.frame, size);
}

- (CGFloat)top {
  return CGRectGetMinY(self.frame);
}

- (void)setTop:(CGFloat)top {
  self.frame = CGRectSetY(self.frame, top);
}

- (CGFloat)left {
  return CGRectGetMinX(self.frame);
}

- (void)setLeft:(CGFloat)left {
  self.frame = CGRectSetX(self.frame, left);
}

- (CGFloat)bottom {
  return CGRectGetMaxY(self.frame);
}

- (void)setBottom:(CGFloat)bottom {
  self.frame = CGRectSetY(self.frame, bottom - CGRectGetHeight(self.frame));
}

- (CGFloat)right {
  return CGRectGetMaxX(self.frame);
}

- (void)setRight:(CGFloat)right {
  self.frame = CGRectSetX(self.frame, right - CGRectGetWidth(self.frame));
}

- (CGFloat)width {
  return CGRectGetWidth(self.frame);
}

- (void)setWidth:(CGFloat)width {
  self.frame = CGRectSetWidth(self.frame, width);
}

- (CGFloat)height {
  return CGRectGetHeight(self.frame);
}

- (void)setHeight:(CGFloat)height {
  self.frame = CGRectSetHeight(self.frame, height);
}

- (CGFloat)extendToTop {
  return self.top;
}

- (void)setExtendToTop:(CGFloat)extendToTop {
  self.height = self.bottom - extendToTop;
  self.top = extendToTop;
}

- (CGFloat)extendToLeft {
  return self.left;
}

- (void)setExtendToLeft:(CGFloat)extendToLeft {
  self.width = self.right - extendToLeft;
  self.left = extendToLeft;
}

- (CGFloat)extendToBottom {
  return self.bottom;
}

- (void)setExtendToBottom:(CGFloat)extendToBottom {
  self.height = extendToBottom - self.top;
  self.bottom = extendToBottom;
}

- (CGFloat)extendToRight {
  return self.right;
}

- (void)setExtendToRight:(CGFloat)extendToRight {
  self.width = extendToRight - self.left;
  self.right = extendToRight;
}

- (CGFloat)leftWhenCenterInSuperview {
  return CGFloatGetCenter(CGRectGetWidth(self.superview.bounds), CGRectGetWidth(self.frame));
}

- (CGFloat)topWhenCenterInSuperview {
  return CGFloatGetCenter(CGRectGetHeight(self.superview.bounds), CGRectGetHeight(self.frame));
}

@end

@implementation UIView (Snapshotting)

- (UIImage *)snapshotLayerImage {
  return [UIImage imageWithView:self];
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates {
  return [UIImage imageWithView:self afterScreenUpdates:afterScreenUpdates];
}

@end
