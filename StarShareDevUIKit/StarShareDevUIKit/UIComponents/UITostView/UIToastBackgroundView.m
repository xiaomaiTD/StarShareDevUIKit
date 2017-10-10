//
//  UIToastBackgroundView.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIToastBackgroundView.h"
#import "UICore.h"

@interface UIToastBackgroundView ()
@property(nonatomic, strong) UIView *effectView;
@end

@implementation UIToastBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.layer.allowsGroupOpacity = NO;
    self.backgroundColor = self.styleColor;
    self.layer.cornerRadius = self.cornerRadius;
    
  }
  return self;
}

- (void)setShouldBlurBackgroundView:(BOOL)shouldBlurBackgroundView {
  _shouldBlurBackgroundView = shouldBlurBackgroundView;
  if (shouldBlurBackgroundView) {
    if (NSClassFromString(@"UIBlurEffect")) {
      UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
      UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
      effectView.layer.cornerRadius = self.cornerRadius;
      effectView.layer.masksToBounds = YES;
      [self addSubview:effectView];
      self.effectView = effectView;
    }
  } else {
    if (self.effectView) {
      [self.effectView removeFromSuperview];
      self.effectView = nil;
    }
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (self.effectView) {
    self.effectView.frame = self.bounds;
  }
}

#pragma mark - UIAppearance

- (void)setStyleColor:(UIColor *)styleColor {
  _styleColor = styleColor;
  self.backgroundColor = styleColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
  _cornerRadius = cornerRadius;
  self.layer.cornerRadius = cornerRadius;
  if (self.effectView) {
    self.effectView.layer.cornerRadius = cornerRadius;
  }
}

@end

@interface UIToastBackgroundView (UIAppearance)

@end

@implementation UIToastBackgroundView (UIAppearance)

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self setDefaultAppearance];
  });
}

+ (void)setDefaultAppearance {
  UIToastBackgroundView *appearance = [UIToastBackgroundView appearance];
  appearance.styleColor = UIColorMakeWithRGBA(0, 0, 0, 0.8);
  appearance.cornerRadius = 10.0;
}

@end
