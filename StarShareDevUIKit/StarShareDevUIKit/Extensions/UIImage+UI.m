//
//  UIImage+UI.m
//  Project
//
//  Created by pmo on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIImage+UI.h"
#import "UICore.h"

@implementation UIImage (UI)
+ (UIImage *)imageWithView:(UIView *)view {
  CGContextInspectSize(view.bounds.size);
  UIImage *resultImage = nil;
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextInspectContext(context);
  [view.layer renderInContext:context];
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resultImage;
}

+ (UIImage *)imageWithView:(UIView *)view afterScreenUpdates:(BOOL)afterUpdates {
  // iOS 7 截图新方式，性能好会好一点，不过不一定适用，因为这个方法的使用条件是：界面要已经render完，否则截到得图将会是empty。
  UIImage *resultImage = nil;
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
  [view drawViewHierarchyInRect:CGRectMakeWithSize(view.bounds.size) afterScreenUpdates:afterUpdates];
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resultImage;
}

+ (UIImage *)imageWithShape:(UIImageShape)shape
                       size:(CGSize)size
                  tintColor:(UIColor *)tintColor {
  CGFloat lineWidth = 0;
  switch (shape) {
    case UIImageShapeNavBack:
      lineWidth = 3;
      break;
    case UIImageShapeDisclosureIndicator:
      lineWidth = 3;
      break;
    case UIImageShapeCheckmark:
      lineWidth = 3;
      break;
    case UIImageShapeNavClose:
      lineWidth = 3;
      break;
    case UIImageShapeNavAdd:
      lineWidth = 3;
      break;
    default:
      break;
  }
  return [UIImage imageWithShape:shape size:size lineWidth:lineWidth tintColor:tintColor];
}

+ (UIImage *)imageWithShape:(UIImageShape)shape
                       size:(CGSize)size
                  lineWidth:(CGFloat)lineWidth
                  tintColor:(UIColor *)tintColor {
  size = CGSizeFlatted(size);
  CGContextInspectSize(size);
  
  UIImage *resultImage = nil;
  tintColor = tintColor ? tintColor : [UIColor whiteColor];
  
  
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextInspectContext(context);
  UIBezierPath *path = nil;
  BOOL drawByStroke = NO;
  CGFloat drawOffset = lineWidth / 2;
  switch (shape) {
    case UIImageShapeOval: {
      path = [UIBezierPath bezierPathWithOvalInRect:CGRectMakeWithSize(size)];
    }
      break;
    case UIImageShapeTriangle: {
      path = [UIBezierPath bezierPath];
      [path moveToPoint:CGPointMake(0, size.height)];
      [path addLineToPoint:CGPointMake(size.width / 2, 0)];
      [path addLineToPoint:CGPointMake(size.width, size.height)];
      [path closePath];
    }
      break;
    case UIImageShapeNavBack: {
      drawByStroke = YES;
      path = [UIBezierPath bezierPath];
      path.lineWidth = lineWidth;
      [path moveToPoint:CGPointMake(size.width - drawOffset, drawOffset)];
      [path addLineToPoint:CGPointMake(0 + drawOffset, size.height / 2.0)];
      [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height - drawOffset)];
    }
      break;
    case UIImageShapeDisclosureIndicator: {
      path = [UIBezierPath bezierPath];
      drawByStroke = YES;
      path.lineWidth = lineWidth;
      [path moveToPoint:CGPointMake(drawOffset, drawOffset)];
      [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height / 2)];
      [path addLineToPoint:CGPointMake(drawOffset, size.height - drawOffset)];
    }
      break;
    case UIImageShapeCheckmark: {
      CGFloat lineAngle = M_PI_4;
      path = [UIBezierPath bezierPath];
      [path moveToPoint:CGPointMake(0, size.height / 2)];
      [path addLineToPoint:CGPointMake(size.width / 3, size.height)];
      [path addLineToPoint:CGPointMake(size.width, lineWidth * sin(lineAngle))];
      [path addLineToPoint:CGPointMake(size.width - lineWidth * cos(lineAngle), 0)];
      [path addLineToPoint:CGPointMake(size.width / 3, size.height - lineWidth / sin(lineAngle))];
      [path addLineToPoint:CGPointMake(lineWidth * sin(lineAngle), size.height / 2 - lineWidth * sin(lineAngle))];
      [path closePath];
    }
      break;
    case UIImageShapeNavClose: {
      drawByStroke = YES;
      path = [UIBezierPath bezierPath];
      [path moveToPoint:CGPointMake(0, 0)];
      [path addLineToPoint:CGPointMake(size.width, size.height)];
      [path closePath];
      [path moveToPoint:CGPointMake(size.width, 0)];
      [path addLineToPoint:CGPointMake(0, size.height)];
      [path closePath];
      path.lineWidth = lineWidth;
      path.lineCapStyle = kCGLineCapRound;
    }
      break;
    case UIImageShapeNavAdd: {
      drawByStroke = YES;
      path = [UIBezierPath bezierPath];
      [path moveToPoint:CGPointMake(size.width/2.0, 0)];
      [path addLineToPoint:CGPointMake(size.width/2.0, size.height)];
      [path closePath];
      [path moveToPoint:CGPointMake(0, size.height/2.0)];
      [path addLineToPoint:CGPointMake(size.width, size.height/2.0)];
      [path closePath];
      path.lineWidth = lineWidth;
      path.lineCapStyle = kCGLineCapRound;
    }
      break;
    default:
      break;
  }
  
  if (drawByStroke) {
    CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
    [path stroke];
  } else {
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    [path fill];
  }
  
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return resultImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius {
  size = CGSizeFlatted(size);
  CGContextInspectSize(size);
  
  UIImage *resultImage = nil;
  color = color ? color : [UIColor whiteColor];
  
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, color.CGColor);
  
  if (cornerRadius > 0) {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMakeWithSize(size) cornerRadius:cornerRadius];
    [path addClip];
    [path fill];
  } else {
    CGContextFillRect(context, CGRectMakeWithSize(size));
  }
  
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resultImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
  return [self imageWithColor:color size:CGSizeMake(1, 1) cornerRadius:0];
}

- (UIImage *)imageWithSpacingExtensionInsets:(UIEdgeInsets)extension {
  CGSize contextSize = CGSizeMake(self.size.width + UIEdgeInsetsGetHorizontalValue(extension), self.size.height + UIEdgeInsetsGetVerticalValue(extension));
  UIGraphicsBeginImageContextWithOptions(contextSize, NO, self.scale);
  [self drawAtPoint:CGPointMake(extension.left, extension.top)];
  UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return finalImage;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha
{
  UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
  
  CGContextScaleCTM(ctx, 1, -1);
  
  CGContextTranslateCTM(ctx, 0, -area.size.height);
  
  CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
  
  CGContextSetAlpha(ctx, alpha);
  
  CGContextDrawImage(ctx, area, self.CGImage);
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return newImage;
}

#define AngleWithDegrees(deg) (M_PI * (deg) / 180.0)

- (UIImage *)imageWithOrientation:(UIImageOrientation)orientation {
  if (orientation == UIImageOrientationUp) {
    return self;
  }
  
  CGSize contextSize = self.size;
  if (orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight) {
    contextSize = CGSizeMake(contextSize.height, contextSize.width);
  }
  
  contextSize = CGSizeMake(flatfSpecificScale(contextSize.width, self.scale),
                           flatfSpecificScale(contextSize.height, self.scale));
  
  UIGraphicsBeginImageContextWithOptions(contextSize, NO, self.scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextInspectContext(context);
  
  // 画布的原点在左上角，旋转后可能图片就飞到画布外了，所以旋转前先把图片摆到特定位置再旋转，图片刚好就落在画布里
  switch (orientation) {
    case UIImageOrientationUp:
      // 上
      break;
    case UIImageOrientationDown:
      // 下
      CGContextTranslateCTM(context, contextSize.width, contextSize.height);
      CGContextRotateCTM(context, AngleWithDegrees(180));
      break;
    case UIImageOrientationLeft:
      // 左
      CGContextTranslateCTM(context, 0, contextSize.height);
      CGContextRotateCTM(context, AngleWithDegrees(-90));
      break;
    case UIImageOrientationRight:
      // 右
      CGContextTranslateCTM(context, contextSize.width, 0);
      CGContextRotateCTM(context, AngleWithDegrees(90));
      break;
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
      // 向上、向下翻转是一样的
      CGContextTranslateCTM(context, 0, contextSize.height);
      CGContextScaleCTM(context, 1, -1);
      break;
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
      // 向左、向右翻转是一样的
      CGContextTranslateCTM(context, contextSize.width, 0);
      CGContextScaleCTM(context, -1, 1);
      break;
  }
  
  // 在前面画布的旋转、移动的结果上绘制自身即可，这里不用考虑旋转带来的宽高置换的问题
  [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
  
  UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return imageOut;
}

@end
