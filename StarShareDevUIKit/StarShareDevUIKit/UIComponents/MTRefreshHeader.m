//
//  MTRefreshHeader.m
//  MTime_iOS
//
//  Created by BUBUKO on 2017/11/13.
//  Copyright © 2017年 BUBUKO. All rights reserved.
//

#import "MTRefreshHeader.h"
#import "MTLoading.h"

@interface MTRefreshHeader ()
@property (strong, nonatomic, readwrite) MTLoading *loading;
@property (strong, nonatomic, readwrite) UIImageView *arrowView;
@property (strong, nonatomic) CAShapeLayer *hoopLayer;
@end

@implementation MTRefreshHeader{
  
}

#pragma mark - 重写父类的方法
- (void)prepare
{
  [super prepare];
}

- (void)placeSubviews
{
  [super placeSubviews];
  
  self.mj_h = 70;
  
  CGFloat arrowCenterX = self.mj_w * 0.5;
  if (!self.stateLabel.hidden) {
    CGFloat stateWidth = self.stateLabel.mj_textWith;
    CGFloat timeWidth = 0.0;
    if (!self.lastUpdatedTimeLabel.hidden) {
      timeWidth = self.lastUpdatedTimeLabel.mj_textWith;
    }
    CGFloat textWidth = MAX(stateWidth, timeWidth);
    arrowCenterX -= textWidth / 2 + self.labelLeftInset;
  }
  CGFloat arrowCenterY = self.mj_h * 0.5;
  CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);
  
  self.arrowView.mj_size = CGSizeMake(self.arrowView.image.size.width*0.75, self.arrowView.image.size.height*0.75);
  self.arrowView.center = arrowCenter;
  self.loading.center = arrowCenter;
  self.hoopLayer.position = arrowCenter;
  
  self.arrowView.tintColor = self.stateLabel.textColor;
}

- (void)setState:(MJRefreshState)state
{
  MJRefreshCheckState
  
  if (state == MJRefreshStateIdle) {
    [self.loading stopAnimating];
    self.arrowView.hidden = YES;
    self.hoopLayer.hidden = NO;
  } else if (state == MJRefreshStatePulling) {
    [self.loading stopAnimating];
    self.arrowView.hidden = NO;
    self.hoopLayer.hidden = NO;
  } else if (state == MJRefreshStateRefreshing) {
    [self.loading startAnimating];
    self.arrowView.hidden = YES;
    self.hoopLayer.hidden = YES;
    self.hoopLayer.strokeEnd = 1.0;
  }
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
  [super setPullingPercent:pullingPercent];
  self.hoopLayer.hidden = NO;
  self.hoopLayer.strokeEnd = pullingPercent;
}

#pragma mark - getter

- (UIImageView *)arrowView
{
  if (!_arrowView) {
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[[self _arrowImage] imageWithTintColor:[UIColor colorWithHexString:@"#575757"]]];
    arrowView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_arrowView = arrowView];
  }
  return _arrowView;
}

- (MTLoading *)loading
{
  if (!_loading) {
    MTLoading *loading = [[MTLoading alloc] init];
    loading.lineWidth = 1;
    loading.duration = 1;
    loading.tintColor = [UIColor colorWithHexString:@"#575757"];
    loading.size = CGSizeMake(25, 25);
    [self addSubview:_loading = loading];
  }
  return _loading;
}

- (CAShapeLayer *)hoopLayer
{
  if (!_hoopLayer) {
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    CGRect rect = layer.frame;
    rect.size = CGSizeMake(25, 25);
    layer.frame = rect;
    
    layer.cornerRadius = 25/2.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(layer.bounds, 0, 0) cornerRadius:(25/2.0)];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor colorWithHexString:@"#575757"].CGColor;
    layer.lineWidth = 1;
    layer.lineCap = kCALineCapRound;
    layer.strokeStart = 0;
    layer.strokeEnd = 0;
    layer.hidden = YES;
    [self.layer addSublayer:_hoopLayer = layer];
  }
  return _hoopLayer;
}

- (UIImage *)_arrowImage{
  
  CGFloat lineWidth = 2;
  CGSize size = CGSizeMake(15, 15);
  size = CGSizeFlatted(size);
  CGContextInspectSize(size);
  
  UIImage *resultImage = nil;
  UIColor *tintColor = [UIColor lightGrayColor];
  
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextInspectContext(context);
  UIBezierPath *path = nil;
  CGFloat drawOffset = lineWidth / 2;
  
  path = [UIBezierPath bezierPath];
  path.lineWidth = lineWidth;
  path.lineCapStyle = kCGLineCapRound;
  path.lineJoinStyle = kCGLineJoinRound;
  [path moveToPoint:CGPointMake(size.width/2.0, size.height - drawOffset)];
  [path addLineToPoint:CGPointMake(0 + drawOffset, size.height / 2.0)];
  [path moveToPoint:CGPointMake(size.width/2.0, size.height - drawOffset)];
  [path addLineToPoint:CGPointMake(size.width - drawOffset, size.height / 2.0)];
  [path moveToPoint:CGPointMake(size.width/2.0, size.height - drawOffset)];
  [path addLineToPoint:CGPointMake(size.width/2.0, drawOffset)];
  
  CGContextSetStrokeColorWithColor(context, tintColor.CGColor);
  [path stroke];
  
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return resultImage;
}

@end
