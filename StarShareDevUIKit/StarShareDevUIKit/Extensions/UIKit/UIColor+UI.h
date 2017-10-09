//
//  UIColor+UI.h
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UI)
- (UIColor *)colorWithAlphaAddedToWhite:(CGFloat)alpha;
- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;
- (CGFloat)hue;
- (CGFloat)saturation;
- (CGFloat)brightness;
- (UIColor *)colorWithoutAlpha;
- (BOOL)colorIsDark;
- (UIColor *)inverseColor;
- (BOOL)isSystemTintColor;
+ (UIColor *)systemTintColor;
+ (UIColor *)randomColor;
@end
