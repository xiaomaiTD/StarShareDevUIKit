//
//  UIFont+UI.m
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIFont+UI.h"

@implementation UIFont (UI)

+ (UIFont *)lightSystemFontOfSize:(CGFloat)fontSize {
  return [UIFont fontWithName:[[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 ? @".SFUIText-Light" : @"HelveticaNeue-Light" size:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)size weight:(UIFontWeightType)weight italic:(BOOL)italic {
  BOOL isLight = weight == UIFontWeightTypeLight;
  BOOL isBold = weight == UIFontWeightTypeBold;
  
  BOOL shouldUsingHardCode = [[[UIDevice currentDevice] systemVersion] floatValue] < 10.0;// 这 UIFontDescriptor 也是醉人，相同代码只有 iOS 10 能得出正确结果，7-9都无法获取到 Light + Italic 的字体，只能写死。
  if (shouldUsingHardCode) {
    NSString *name = [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0 ? @"HelveticaNeue" : @".SFUIText";
    NSString *fontSuffix = [NSString stringWithFormat:@"%@%@", isLight ? @"Light" : (isBold ? @"Bold" : @""), italic ? @"Italic" : @""];
    NSString *fontName = [NSString stringWithFormat:@"%@%@%@", name, fontSuffix.length > 0 ? @"-" : @"", fontSuffix];
    UIFont *font = [UIFont fontWithName:fontName size:size];
    return font;
  }
  
  // iOS 10 以上使用常规写法
  UIFont *font = nil;
  if ([self.class respondsToSelector:@selector(systemFontOfSize:weight:)]) {
    font = [UIFont systemFontOfSize:size weight:isLight ? UIFontWeightLight : (isBold ? UIFontWeightBold : UIFontWeightRegular)];
    
    // 后面那些都是对斜体的操作，所以如果不需要斜体就直接 return
    if (!italic) {
      return font;
    }
  } else {
    font = [UIFont systemFontOfSize:size];
  }
  
  UIFontDescriptor *fontDescriptor = font.fontDescriptor;
  NSMutableDictionary<NSString *, id> *traitsAttribute = [NSMutableDictionary dictionaryWithDictionary:fontDescriptor.fontAttributes[UIFontDescriptorTraitsAttribute]];
  if (![UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
    traitsAttribute[UIFontWeightTrait] = isLight ? @-1.0 : (isBold ? @1.0 : @0.0);
  }
  if (italic) {
    traitsAttribute[UIFontSlantTrait] = @1.0;
  } else {
    traitsAttribute[UIFontSlantTrait] = @0.0;
  }
  fontDescriptor = [fontDescriptor fontDescriptorByAddingAttributes:@{UIFontDescriptorTraitsAttribute: traitsAttribute}];
  font = [UIFont fontWithDescriptor:fontDescriptor size:0];
  return font;
}

+ (UIFont *)dynamicSystemFontOfSize:(CGFloat)size weight:(UIFontWeightType)weight italic:(BOOL)italic {
  return [self dynamicSystemFontOfSize:size upperLimitSize:size + 5 lowerLimitSize:0 weight:weight italic:italic];
}

+ (UIFont *)dynamicSystemFontOfSize:(CGFloat)pointSize
                     upperLimitSize:(CGFloat)upperLimitSize
                     lowerLimitSize:(CGFloat)lowerLimitSize
                             weight:(UIFontWeightType)weight
                             italic:(BOOL)italic {
  
  // 计算出 body 类型比默认的大小要变化了多少，然后在 pointSize 的基础上叠加这个变化
  UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  CGFloat offsetPointSize = font.pointSize - 17;// default UIFontTextStyleBody fontSize is 17
  CGFloat finalPointSize = pointSize + offsetPointSize;
  finalPointSize = MAX(MIN(finalPointSize, upperLimitSize), lowerLimitSize);
  font = [UIFont systemFontOfSize:finalPointSize weight:weight italic:NO];
  
  return font;
}

@end
