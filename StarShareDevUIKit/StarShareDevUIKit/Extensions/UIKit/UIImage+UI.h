//
//  UIImage+UI.h
//  Project
//
//  Created by pmo on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIImageShape) {
  UIImageShapeOval,                 // 椭圆
  UIImageShapeTriangle,             // 三角形
  UIImageShapeDisclosureIndicator,  // 列表cell右边的箭头
  UIImageShapeCheckmark,            // 列表cell右边的checkmark
  UIImageShapeNavBack,              // 返回按钮的箭头
  UIImageShapeNavClose,             // 导航栏的关闭icon
  UIImageShapeNavAdd                // 导航栏的加号icon
};


@interface UIImage (UI)
+ (UIImage *)imageWithView:(UIView *)view;
+ (UIImage *)imageWithView:(UIView *)view afterScreenUpdates:(BOOL)afterUpdates;
+ (UIImage *)imageWithShape:(UIImageShape)shape
                       size:(CGSize)size
                  tintColor:(UIColor *)tintColor;
+ (UIImage *)imageWithShape:(UIImageShape)shape
                       size:(CGSize)size
                  lineWidth:(CGFloat)lineWidth
                  tintColor:(UIColor *)tintColor;
+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)imageWithOrientation:(UIImageOrientation)orientation;
- (UIImage *)imageWithSpacingExtensionInsets:(UIEdgeInsets)extension;
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;
@end
