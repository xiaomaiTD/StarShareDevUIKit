//
//  UIControl+UI.m
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIControl+UI.h"
#import <objc/runtime.h>
#import "UICore.h"

static char kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView;
static char kAssociatedObjectKey_canSetHighlighted;
static char kAssociatedObjectKey_touchEndCount;
static char kAssociatedObjectKey_outsideEdge;

@interface UIControl ()
@property(nonatomic,assign) BOOL canSetHighlighted;
@property(nonatomic,assign) NSInteger touchEndCount;
@end

@implementation UIControl (UI)

- (void)setAutomaticallyAdjustTouchHighlightedInScrollView:(BOOL)automaticallyAdjustTouchHighlightedInScrollView {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView, [NSNumber numberWithBool:automaticallyAdjustTouchHighlightedInScrollView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)automaticallyAdjustTouchHighlightedInScrollView {
  return (BOOL)[objc_getAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView) boolValue];
}

- (void)setCanSetHighlighted:(BOOL)canSetHighlighted {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_canSetHighlighted, [NSNumber numberWithBool:canSetHighlighted], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canSetHighlighted {
  return (BOOL)[objc_getAssociatedObject(self, &kAssociatedObjectKey_canSetHighlighted) boolValue];
}

- (void)setTouchEndCount:(NSInteger)touchEndCount {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_touchEndCount, @(touchEndCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)touchEndCount {
  return [objc_getAssociatedObject(self, &kAssociatedObjectKey_touchEndCount) integerValue];
}

- (void)setOutsideEdge:(UIEdgeInsets)outsideEdge {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_outsideEdge, [NSValue valueWithUIEdgeInsets:outsideEdge], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)outsideEdge {
  return [objc_getAssociatedObject(self, &kAssociatedObjectKey_outsideEdge) UIEdgeInsetsValue];
}

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    Class clz = [self class];
    
    SEL beginSelector = @selector(touchesBegan:withEvent:);
    SEL swizzled_beginSelector = @selector(pr_touchesBegan:withEvent:);
    
    SEL moveSelector = @selector(touchesMoved:withEvent:);
    SEL swizzled_moveSelector = @selector(pr_touchesMoved:withEvent:);
    
    SEL endSelector = @selector(touchesEnded:withEvent:);
    SEL swizzled_endSelector = @selector(pr_touchesEnded:withEvent:);
    
    SEL cancelSelector = @selector(touchesCancelled:withEvent:);
    SEL swizzled_cancelSelector = @selector(pr_touchesCancelled:withEvent:);
    
    SEL pointInsideSelector = @selector(pointInside:withEvent:);
    SEL swizzled_pointInsideSelector = @selector(pr_pointInside:withEvent:);
    
    ReplaceMethod(clz, beginSelector, swizzled_beginSelector);
    ReplaceMethod(clz, moveSelector, swizzled_moveSelector);
    ReplaceMethod(clz, endSelector, swizzled_endSelector);
    ReplaceMethod(clz, cancelSelector, swizzled_cancelSelector);
    ReplaceMethod(clz, pointInsideSelector, swizzled_pointInsideSelector);
    
  });
}

- (void)pr_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.touchEndCount = 0;
  if (self.automaticallyAdjustTouchHighlightedInScrollView) {
    self.canSetHighlighted = YES;
    [self pr_touchesBegan:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (self.canSetHighlighted) {
        [self setHighlighted:YES];
      }
    });
  } else {
    [self pr_touchesBegan:touches withEvent:event];
  }
}

- (void)pr_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.automaticallyAdjustTouchHighlightedInScrollView) {
    self.canSetHighlighted = NO;
    [self pr_touchesMoved:touches withEvent:event];
  } else {
    [self pr_touchesMoved:touches withEvent:event];
  }
}

- (void)pr_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.automaticallyAdjustTouchHighlightedInScrollView) {
    self.canSetHighlighted = NO;
    if (self.touchInside) {
      [self setHighlighted:YES];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果延迟时间太长，会导致快速点击两次，事件会触发两次
        // 对于 3D Touch 的机器，如果点击按钮的时候在按钮上停留事件稍微长一点点，那么 touchesEnded 会被调用两次
        // 把 super touchEnded 放到延迟里调用会导致长按无法触发点击，先这么改，再想想怎么办。// [self touchesEnded:touches withEvent:event];
        [self sendActionsForAllTouchEventsIfCan];
        if (self.highlighted) {
          [self setHighlighted:NO];
        }
      });
    } else {
      [self setHighlighted:NO];
    }
  } else {
    [self pr_touchesEnded:touches withEvent:event];
  }
}

- (void)pr_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.automaticallyAdjustTouchHighlightedInScrollView) {
    self.canSetHighlighted = NO;
    [self pr_touchesCancelled:touches withEvent:event];
    if (self.highlighted) {
      [self setHighlighted:NO];
    }
  } else {
    [self pr_touchesCancelled:touches withEvent:event];
  }
}

- (BOOL)pr_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (([event type] != UIEventTypeTouches)) {
    return [self pr_pointInside:point withEvent:event];
  }
  UIEdgeInsets outsideEdge = self.outsideEdge;
  CGRect boundsInsetOutsideEdge = CGRectMake(CGRectGetMinX(self.bounds) + outsideEdge.left,
                                             CGRectGetMinY(self.bounds) + outsideEdge.top,
                                             CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(outsideEdge),
                                             CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(outsideEdge));
  return CGRectContainsPoint(boundsInsetOutsideEdge, point);
}

// 这段代码需要以一个独立的方法存在，因为一旦有坑，外面可以直接通过runtime调用这个方法
// 但，不要开放到.h文件里，理论上外面不应该用到它
- (void)sendActionsForAllTouchEventsIfCan {
  self.touchEndCount += 1;
  if (self.touchEndCount == 1) {
    [self sendActionsForControlEvents:UIControlEventAllTouchEvents];
  }
}

@end
