//
//  CALayer+UI.h
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (UI)
- (void)sendSublayerToBack:(CALayer *)sublayer;
- (void)bringSublayerToFront:(CALayer *)sublayer;
- (void)removeDefaultAnimations;
+ (CAShapeLayer *)seperatorDashLayerWithLineLength:(NSInteger)lineLength
                                       lineSpacing:(NSInteger)lineSpacing
                                         lineWidth:(CGFloat)lineWidth
                                         lineColor:(CGColorRef)lineColor
                                      isHorizontal:(BOOL)isHorizontal;
+ (CAShapeLayer *)seperatorDashLayerInHorizontal;
+ (CAShapeLayer *)seperatorDashLayerInVertical;
+ (CALayer *)separatorLayer;
+ (CALayer *)separatorLayerForTableView;
@end
