//
//  SSUIVisualEffectView.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/16.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIVisualEffectView.h"

@implementation SSUIVisualEffectView
{
  UIVisualEffectView *_effectView_8;  // iOS8 及以上
  UIToolbar *_effectView_7;           // iOS7
  UIView *_effectView_6;              // iOS6 及以下
}

- (instancetype)init {
  self = [self initWithStyle:SSUIVisualEffectViewStyleLight];
  if (self) {
  }
  return self;
}

- (instancetype)initWithStyle:(SSUIVisualEffectViewStyle)style {
  self = [super init];
  if (self) {
    _style = style;
    [self initEffectViewUI];
  }
  return self;
}

- (void)initEffectViewUI {
  if ([UIVisualEffectView class]) {
    UIBlurEffectStyle effStyle;
    switch (_style) {
      case SSUIVisualEffectViewStyleExtraLight:
        effStyle = UIBlurEffectStyleExtraLight;
        break;
      case SSUIVisualEffectViewStyleLight:
        effStyle = UIBlurEffectStyleLight;
        break;
      case SSUIVisualEffectViewStyleDark:
        effStyle = UIBlurEffectStyleDark;
      default:
        break;
    }
    _effectView_8 = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:effStyle]];
    _effectView_8.clipsToBounds = YES;
    [self addSubview:_effectView_8];
  } else {
    _effectView_7 = [[UIToolbar alloc] init];
    _effectView_7.clipsToBounds = YES;
    [self addSubview:_effectView_7];
  }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  _effectView_6.backgroundColor = backgroundColor;
  _effectView_7.backgroundColor = backgroundColor;
  _effectView_8.backgroundColor = backgroundColor;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if ([UIVisualEffectView class]) {
    _effectView_8.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
  } else {
    _effectView_7.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
  }
}

@end
