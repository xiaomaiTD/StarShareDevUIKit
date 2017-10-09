//
//  UILabel+UI.m
//  Project
//
//  Created by pmo on 2017/10/7.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UILabel+UI.h"

@implementation UILabel (UI)
- (instancetype)initWithFont:(UIFont *)font textColor:(UIColor *)textColor {
  if (self = [super init]) {
    self.font = font;
    self.textColor = textColor;
  }
  return self;
}
@end
