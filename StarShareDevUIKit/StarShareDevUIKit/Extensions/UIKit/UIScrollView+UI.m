//
//  UIScrollView+UI.m
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIScrollView+UI.h"
#import "UICore.h"

@implementation UIScrollView (UI)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod([self class], @selector(description), @selector(ss_description));
  });
}

- (NSString *)ss_description {
  return [NSString stringWithFormat:@"%@, contentInset = %@", [self ss_description], NSStringFromUIEdgeInsets(self.contentInset)];
}

- (BOOL)alreadyAtTop {
  if (!self.canScroll) {
    return YES;
  }
  
  if (self.contentOffset.y == -self.contentInset.top) {
    return YES;
  }
  
  return NO;
}

- (BOOL)alreadyAtBottom {
  if (!self.canScroll) {
    return YES;
  }
  
  if (self.contentOffset.y == self.contentSize.height + self.contentInset.bottom - CGRectGetHeight(self.bounds)) {
    return YES;
  }
  
  return NO;
}

- (BOOL)canScroll {
  // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
  if (CGSizeIsEmpty(self.bounds.size)) {
    return NO;
  }
  BOOL canVerticalScroll = self.contentSize.height + UIEdgeInsetsGetVerticalValue(self.contentInset) > CGRectGetHeight(self.bounds);
  BOOL canHorizontalScoll = self.contentSize.width + UIEdgeInsetsGetHorizontalValue(self.contentInset) > CGRectGetWidth(self.bounds);
  return canVerticalScroll || canHorizontalScoll;
}

- (void)scrollToTopForce:(BOOL)force animated:(BOOL)animated {
  if (force || (!force && [self canScroll])) {
    CGPoint contentOffset = CGPointMake(-self.contentInset.left, -self.contentInset.top);
    if (@available(ios 11, *)) {
      if (self.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
        contentOffset = CGPointMake(-self.adjustedContentInset.left, -self.adjustedContentInset.top);
      }
    }
    [self setContentOffset:contentOffset animated:animated];
  }
}

- (void)scrollToTopAnimated:(BOOL)animated {
  [self scrollToTopForce:NO animated:animated];
}

- (void)scrollToTop {
  [self scrollToTopAnimated:NO];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
  if ([self canScroll]) {
    [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height + self.contentInset.bottom - CGRectGetHeight(self.bounds)) animated:animated];
  }
}

- (void)scrollToBottom {
  [self scrollToBottomAnimated:NO];
}

- (void)stopDeceleratingIfNeeded {
  if (self.decelerating) {
    [self setContentOffset:self.contentOffset animated:NO];
  }
}

@end
