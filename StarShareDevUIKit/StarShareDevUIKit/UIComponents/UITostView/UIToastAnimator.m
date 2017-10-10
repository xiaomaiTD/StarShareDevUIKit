//
//  UIToastAnimator.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIToastAnimator.h"
#import "UICore.h"
#import "UIToastView.h"


@implementation UIToastAnimator {
  BOOL _isShowing;
  BOOL _isAnimating;
}

- (instancetype)init {
  NSAssert(NO, @"请使用initWithToastView:初始化");
  return [self initWithToastView:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  NSAssert(NO, @"请使用initWithToastView:初始化");
  return [self initWithToastView:nil];
}

- (instancetype)initWithToastView:(UIToastView *)toastView {
  NSAssert(toastView, @"toastView不能为空");
  if (self = [super init]) {
    _toastView = toastView;
  }
  return self;
}

- (void)showWithCompletion:(void (^)(BOOL finished))completion {
  _isShowing = YES;
  _isAnimating = YES;
  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
    self.toastView.backgroundView.alpha = 1.0;
    self.toastView.contentView.alpha = 1.0;
  } completion:^(BOOL finished) {
    _isAnimating = NO;
    if (completion) {
      completion(finished);
    }
  }];
}

- (void)hideWithCompletion:(void (^)(BOOL finished))completion {
  _isShowing = NO;
  _isAnimating = YES;
  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
    self.toastView.backgroundView.alpha = 0.0;
    self.toastView.contentView.alpha = 0.0;
  } completion:^(BOOL finished) {
    _isAnimating = NO;
    if (completion) {
      completion(finished);
    }
  }];
}

- (BOOL)isShowing {
  return _isShowing;
}

- (BOOL)isAnimating {
  return _isAnimating;
}

@end
