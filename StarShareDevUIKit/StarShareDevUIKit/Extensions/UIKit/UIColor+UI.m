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

- (CGFloat)hue {
  CGFloat h;
  if ([self getHue:&h saturation:0 brightness:0 alpha:0]) {
    return h;
  }
  return 0;
}

- (CGFloat)saturation {
  CGFloat s;
  if ([self getHue:0 saturation:&s brightness:0 alpha:0]) {
    return s;
  }
  return 0;
}

- (CGFloat)brightness {
  CGFloat b;
  if ([self getHue:0 saturation:0 brightness:&b alpha:0]) {
    return b;
  }
  return 0;
}

- (UIColor *)colorWithoutAlpha {
  CGFloat r;
  CGFloat g;
  CGFloat b;
  if ([self getRed:&r green:&g blue:&b alpha:0]) {
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
  } else {
    return nil;
  }
}

- (BOOL)colorIsDark {
  CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
  [self getRed:&red green:&green blue:&blue alpha:&alpha];
  
  float referenceValue = 0.411;
  float colorDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));
  
  return 1.0 - colorDelta > referenceValue;
}

- (UIColor *)inverseColor {
  const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
  UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                             green:(1.0 - componentColors[1])
                                              blue:(1.0 - componentColors[2])
                                             alpha:componentColors[3]];
  return newColor;
}

- (BOOL)isSystemTintColor {
  return [self isEqual:[UIColor systemTintColor]];
}

+ (UIColor *)systemTintColor {
  static UIColor *systemTintColor = nil;
  if (!systemTintColor) {
    UIView *view = [[UIView alloc] init];
    systemTintColor = view.tintColor;
  }
  return systemTintColor;
}

+ (UIColor *)randomColor {
  CGFloat red = ( arc4random() % 255 / 255.0 );
  CGFloat green = ( arc4random() % 255 / 255.0 );
  CGFloat blue = ( arc4random() % 255 / 255.0 );
  return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
@end
