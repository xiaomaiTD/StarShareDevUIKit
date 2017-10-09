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

/**
 *  返回系统字体的细体
 *
 *  @param fontSize 字体大小
 *
 *  @return 变细的系统字体的 UIFont 对象
 */
+ (UIFont *)lightSystemFontOfSize:(CGFloat)fontSize;

/**
 *  根据需要生成一个 UIFont 对象并返回
 *  @param size     字号大小
 *  @param weight   字体粗细
 *  @param italic   是否斜体
 */
+ (UIFont *)systemFontOfSize:(CGFloat)size
                      weight:(UIFontWeightType)weight
                      italic:(BOOL)italic;

/**
 *  根据需要生成一个支持响应动态字体大小调整的 UIFont 对象并返回
 *  @param  size    字号大小
 *  @param  weight  字重
 *  @param  italic  是否斜体
 *  @return         支持响应动态字体大小调整的 UIFont 对象
 */
+ (UIFont *)dynamicSystemFontOfSize:(CGFloat)size
                             weight:(UIFontWeightType)weight
                             italic:(BOOL)italic;

/**
 *  返回支持动态字体的UIFont，支持定义最小和最大字号
 *
 *  @param pointSize        默认的size
 *  @param upperLimitSize   最大的字号限制
 *  @param lowerLimitSize   最小的字号显示
 *  @param weight           字重
 *  @param italic           是否斜体
 *
 *  @return                 支持响应动态字体大小调整的 UIFont 对象
 */
+ (UIFont *)dynamicSystemFontOfSize:(CGFloat)pointSize
                     upperLimitSize:(CGFloat)upperLimitSize
                     lowerLimitSize:(CGFloat)lowerLimitSize
                             weight:(UIFontWeightType)weight
                             italic:(BOOL)italic;
@end
