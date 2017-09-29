//
//  UIFont+UI.h
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIFontLightMake(size) [UIFont lightSystemFontOfSize:size]
#define UIFontLightWithFont(_font) [UIFont lightSystemFontOfSize:_font.pointSize]
#define UIDynamicFontMake(_pointSize) [UIFont dynamicSystemFontOfSize:_pointSize weight:UIFontWeightNormal italic:NO]
#define UIDynamicFontMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:UIFontWeightNormal italic:NO]
#define UIDynamicFontBoldMake(_pointSize) [UIFont dynamicSystemFontOfSize:_pointSize weight:UIFontWeightBold italic:NO]
#define UIDynamicFontBoldMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:UIFontWeightBold italic:NO]
#define UIDynamicFontLightMake(_pointSize) [UIFont dynamicSystemFontOfSize:_pointSize weight:UIFontWeightLight italic:NO]
#define UIDynamicFontLightMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:UIFontWeightLight italic:NO]

typedef NS_ENUM(NSUInteger, UIFontWeightType) {
  UIFontWeightTypeLight,
  UIFontWeightTypeNormal,
  UIFontWeightTypeBold
};

@interface UIFont (UI)
+ (UIFont *)lightSystemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)systemFontOfSize:(CGFloat)size
                      weight:(UIFontWeightType)weight
                      italic:(BOOL)italic;
+ (UIFont *)dynamicSystemFontOfSize:(CGFloat)size
                             weight:(UIFontWeightType)weight
                             italic:(BOOL)italic;
+ (UIFont *)dynamicSystemFontOfSize:(CGFloat)pointSize
                     upperLimitSize:(CGFloat)upperLimitSize
                     lowerLimitSize:(CGFloat)lowerLimitSize
                             weight:(UIFontWeightType)weight
                             italic:(BOOL)italic;
@end
