//
//  CALayer+UI.m
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "CALayer+UI.h"
#import "UICore.h"

@implementation CALayer (UI)

- (void)sendSublayerToBack:(CALayer *)sublayer {
  if (sublayer.superlayer == self) {
    [sublayer removeFromSuperlayer];
    [self insertSublayer:sublayer atIndex:0];
  }
}

- (void)bringSublayerToFront:(CALayer *)sublayer {
  if (sublayer.superlayer == self) {
    [sublayer removeFromSuperlayer];
    [self insertSublayer:sublayer atIndex:(unsigned)self.sublayers.count];
  }
}

- (void)removeDefaultAnimations {
  NSMutableDictionary<NSString *, id<CAAction>> *actions = @{NSStringFromSelector(@selector(bounds)): [NSNull null],
                                                             NSStringFromSelector(@selector(position)): [NSNull null],
                                                             NSStringFromSelector(@selector(zPosition)): [NSNull null],
                                                             NSStringFromSelector(@selector(anchorPoint)): [NSNull null],
                                                             NSStringFromSelector(@selector(anchorPointZ)): [NSNull null],
                                                             NSStringFromSelector(@selector(transform)): [NSNull null],
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
                                                             NSStringFromSelector(@selector(hidden)): [NSNull null],
                                                             NSStringFromSelector(@selector(doubleSided)): [NSNull null],
#pragma clang diagnostic pop
                                                             NSStringFromSelector(@selector(sublayerTransform)): [NSNull null],
                                                             NSStringFromSelector(@selector(masksToBounds)): [NSNull null],
                                                             NSStringFromSelector(@selector(contents)): [NSNull null],
                                                             NSStringFromSelector(@selector(contentsRect)): [NSNull null],
                                                             NSStringFromSelector(@selector(contentsScale)): [NSNull null],
                                                             NSStringFromSelector(@selector(contentsCenter)): [NSNull null],
                                                             NSStringFromSelector(@selector(minificationFilterBias)): [NSNull null],
                                                             NSStringFromSelector(@selector(backgroundColor)): [NSNull null],
                                                             NSStringFromSelector(@selector(cornerRadius)): [NSNull null],
                                                             NSStringFromSelector(@selector(borderWidth)): [NSNull null],
                                                             NSStringFromSelector(@selector(borderColor)): [NSNull null],
                                                             NSStringFromSelector(@selector(opacity)): [NSNull null],
                                                             NSStringFromSelector(@selector(compositingFilter)): [NSNull null],
                                                             NSStringFromSelector(@selector(filters)): [NSNull null],
                                                             NSStringFromSelector(@selector(backgroundFilters)): [NSNull null],
                                                             NSStringFromSelector(@selector(shouldRasterize)): [NSNull null],
                                                             NSStringFromSelector(@selector(rasterizationScale)): [NSNull null],
                                                             NSStringFromSelector(@selector(shadowColor)): [NSNull null],
                                                             NSStringFromSelector(@selector(shadowOpacity)): [NSNull null],
                                                             NSStringFromSelector(@selector(shadowOffset)): [NSNull null],
                                                             NSStringFromSelector(@selector(shadowRadius)): [NSNull null],
                                                             NSStringFromSelector(@selector(shadowPath)): [NSNull null]}.mutableCopy;
  
  if ([self isKindOfClass:[CAShapeLayer class]]) {
    [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(path)): [NSNull null],
                                        NSStringFromSelector(@selector(fillColor)): [NSNull null],
                                        NSStringFromSelector(@selector(strokeColor)): [NSNull null],
                                        NSStringFromSelector(@selector(strokeStart)): [NSNull null],
                                        NSStringFromSelector(@selector(strokeEnd)): [NSNull null],
                                        NSStringFromSelector(@selector(lineWidth)): [NSNull null],
                                        NSStringFromSelector(@selector(miterLimit)): [NSNull null],
                                        NSStringFromSelector(@selector(lineDashPhase)): [NSNull null]}];
  }
  
  if ([self isKindOfClass:[CAGradientLayer class]]) {
    [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(colors)): [NSNull null],
                                        NSStringFromSelector(@selector(locations)): [NSNull null],
                                        NSStringFromSelector(@selector(startPoint)): [NSNull null],
                                        NSStringFromSelector(@selector(endPoint)): [NSNull null]}];
  }
  
  self.actions = actions;
}

+ (CAShapeLayer *)seperatorDashLayerWithLineLength:(NSInteger)lineLength
                                       lineSpacing:(NSInteger)lineSpacing
                                         lineWidth:(CGFloat)lineWidth
                                         lineColor:(CGColorRef)lineColor
                                      isHorizontal:(BOOL)isHorizontal {
  CAShapeLayer *layer = [CAShapeLayer layer];
  layer.fillColor = UIColorClear.CGColor;
  layer.strokeColor = lineColor;
  layer.lineWidth = lineWidth;
  layer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:lineLength], [NSNumber numberWithInteger:lineSpacing], nil];
  layer.masksToBounds = YES;
  
  CGMutablePathRef path = CGPathCreateMutable();
  if (isHorizontal) {
    CGPathMoveToPoint(path, NULL, 0, lineWidth / 2);
    CGPathAddLineToPoint(path, NULL, SCREEN_WIDTH, lineWidth / 2);
  } else {
    CGPathMoveToPoint(path, NULL, lineWidth / 2, 0);
    CGPathAddLineToPoint(path, NULL, lineWidth / 2, SCREEN_HEIGHT);
  }
  layer.path = path;
  CGPathRelease(path);
  
  return layer;
}
+ (CAShapeLayer *)seperatorDashLayerInHorizontal {
  CAShapeLayer *layer = [CAShapeLayer seperatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:YES];
  return layer;
}
+ (CAShapeLayer *)seperatorDashLayerInVertical {
  CAShapeLayer *layer = [CAShapeLayer seperatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:NO];
  return layer;
}

+ (CALayer *)separatorLayer {
  CALayer *layer = [CALayer layer];
  [layer removeDefaultAnimations];
  layer.backgroundColor = UIColorSeparator.CGColor;
  layer.frame = CGRectMake(0, 0, 0, PixelOne);
  return layer;
}

+ (CALayer *)separatorLayerForTableView {
  CALayer *layer = [self separatorLayer];
  layer.backgroundColor = TableViewSeparatorColor.CGColor;
  return layer;
}

@end
