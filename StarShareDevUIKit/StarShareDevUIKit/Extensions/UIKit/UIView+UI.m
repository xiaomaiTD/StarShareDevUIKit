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
#import <QuartzCore/QuartzCore.h>
#import "UICore.h"
#import "NSObject+UI.h"
#import "UIImage+UI.h"
#import "CALayer+UI.h"

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

@implementation UIView (Border)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod([self class], @selector(initWithFrame:), @selector(pr_initWithFrame:));
    ReplaceMethod([self class], @selector(initWithCoder:), @selector(pr_initWithCoder:));
    ReplaceMethod([self class], @selector(layoutSublayersOfLayer:), @selector(pr_layoutSublayersOfLayer:));
  });
}

- (instancetype)pr_initWithFrame:(CGRect)frame {
  [self pr_initWithFrame:frame];
  [self setDefaultStyle];
  return self;
}

- (instancetype)pr_initWithCoder:(NSCoder *)aDecoder {
  [self pr_initWithCoder:aDecoder];
  [self setDefaultStyle];
  return self;
}

- (void)pr_layoutSublayersOfLayer:(CALayer *)layer {
  
  [self pr_layoutSublayersOfLayer:layer];
  
  if ((!self.borderLayer && self.borderPosition == SSUIBorderViewPositionNone) || (!self.borderLayer && self.borderWidth == 0)) {
    return;
  }
  
  if (self.borderLayer && self.borderPosition == SSUIBorderViewPositionNone && !self.borderLayer.path) {
    return;
  }
  
  if (self.borderLayer && self.borderWidth == 0 && self.borderLayer.lineWidth == 0) {
    return;
  }
  
  if (!self.borderLayer) {
    self.borderLayer = [CAShapeLayer layer];
    [self.borderLayer removeDefaultAnimations];
    [self.layer addSublayer:self.borderLayer];
  }
  self.borderLayer.frame = self.bounds;
  
  CGFloat borderWidth = self.borderWidth;
  self.borderLayer.lineWidth = borderWidth;
  self.borderLayer.strokeColor = self.borderColor.CGColor;
  self.borderLayer.lineDashPhase = self.dashPhase;
  if (self.dashPattern) {
    self.borderLayer.lineDashPattern = self.dashPattern;
  }
  
  UIBezierPath *path = nil;
  
  if (self.borderPosition != SSUIBorderViewPositionNone) {
    path = [UIBezierPath bezierPath];
  }
  
  if (self.borderPosition & SSUIBorderViewPositionTop) {
    [path moveToPoint:CGPointMake(0, borderWidth / 2)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), borderWidth / 2)];
  }
  
  if (self.borderPosition & SSUIBorderViewPositionLeft) {
    [path moveToPoint:CGPointMake(borderWidth / 2, 0)];
    [path addLineToPoint:CGPointMake(borderWidth / 2, CGRectGetHeight(self.bounds) - 0)];
  }
  
  if (self.borderPosition & SSUIBorderViewPositionBottom) {
    [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.bounds) - borderWidth / 2)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - borderWidth / 2)];
  }
  
  if (self.borderPosition & SSUIBorderViewPositionRight) {
    [path moveToPoint:CGPointMake(CGRectGetWidth(self.bounds) - borderWidth / 2, 0)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - borderWidth / 2, CGRectGetHeight(self.bounds))];
  }
  
  self.borderLayer.path = path.CGPath;
}

- (void)setDefaultStyle {
  self.borderWidth = PixelOne;
  self.borderColor = UIColorSeparator;
}

static char kAssociatedObjectKey_borderPosition;
- (void) setBorderPosition:(SSUIBorderViewPosition)borderPosition {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self setNeedsLayout];
}

- (SSUIBorderViewPosition)borderPosition {
  return (SSUIBorderViewPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setBorderWidth:(CGFloat)borderWidth {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self setNeedsLayout];
}

- (CGFloat)borderWidth {
  return (CGFloat)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth) floatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setBorderColor:(UIColor *)borderColor {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self setNeedsLayout];
}

- (UIColor *)borderColor {
  return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setDashPhase:(CGFloat)dashPhase {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self setNeedsLayout];
}

- (CGFloat)dashPhase {
  return (CGFloat)[objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) floatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setDashPattern:(NSArray<NSNumber *> *)dashPattern {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [self setNeedsLayout];
}

- (NSArray *)dashPattern {
  return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

static char kAssociatedObjectKey_borderLayer;
- (void)setBorderLayer:(CAShapeLayer *)borderLayer {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLayer, borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)borderLayer {
  return (CAShapeLayer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLayer);
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
