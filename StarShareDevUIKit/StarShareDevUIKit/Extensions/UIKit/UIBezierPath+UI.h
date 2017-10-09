//
//  UIBezierPath+UI.h
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (UI)

/**
 * 创建一条支持四个角的圆角值不相同的路径
 * @param rect 路径的rect
 * @param cornerRadius 圆角大小的数字，长度必须为4，顺序分别为[左上角、左下角、右下角、右上角]
 * @param lineWidth 描边的大小，如果不需要描边（例如path是用于fill而不是用于stroke），则填0
 */
+ (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect
                          cornerRadiusArray:(NSArray<NSNumber *> *)cornerRadius
                                  lineWidth:(CGFloat)lineWidth;

@end
