//
//  UIColor+UI.m
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIColor+UI.h"
#import "UICore.h"

@implementation UIColor (UI)

- (UIColor *)colorWithAlpha:(CGFloat)alpha backgroundColor:(UIColor *)backgroundColor {
  return [UIColor colorWithBackendColor:backgroundColor frontColor:[self colorWithAlphaComponent:alpha]];
  
}

- (UIColor *)colorWithAlphaAddedToWhite:(CGFloat)alpha {
  return [self colorWithAlpha:alpha backgroundColor:UIColorWhite];
}

+ (UIColor *)colorWithBackendColor:(UIColor *)backendColor frontColor:(UIColor *)frontColor {
  CGFloat bgAlpha = [backendColor alpha];
  CGFloat bgRed = [backendColor red];
  CGFloat bgGreen = [backendColor green];
  CGFloat bgBlue = [backendColor blue];
  
  CGFloat frAlpha = [frontColor alpha];
  CGFloat frRed = [frontColor red];
  CGFloat frGreen = [frontColor green];
  CGFloat frBlue = [frontColor blue];
  
  CGFloat resultAlpha = frAlpha + bgAlpha * (1 - frAlpha);
  CGFloat resultRed = (frRed * frAlpha + bgRed * bgAlpha * (1 - frAlpha)) / resultAlpha;
  CGFloat resultGreen = (frGreen * frAlpha + bgGreen * bgAlpha * (1 - frAlpha)) / resultAlpha;
  CGFloat resultBlue = (frBlue * frAlpha + bgBlue * bgAlpha * (1 - frAlpha)) / resultAlpha;
  return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:resultAlpha];
}

- (CGFloat)red {
  CGFloat r;
  if ([self getRed:&r green:0 blue:0 alpha:0]) {
    return r;
  }
  return 0;
}

- (CGFloat)green {
  CGFloat g;
  if ([self getRed:0 green:&g blue:0 alpha:0]) {
    return g;
  }
  return 0;
}

- (CGFloat)blue {
  CGFloat b;
  if ([self getRed:0 green:0 blue:&b alpha:0]) {
    return b;
  }
  return 0;
}

- (CGFloat)alpha {
  CGFloat a;
  if ([self getRed:0 green:0 blue:0 alpha:&a]) {
    return a;
  }
  return 0;
}

@end
