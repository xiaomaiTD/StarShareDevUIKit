//
//  UICollectionViewPagingLayout.h
//  Project
//
//  Created by pmo on 2017/10/7.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UICollectionViewPagingLayoutStyle) {
  UICollectionViewPagingLayoutStyleDefault, // 普通模式，水平滑动
  UICollectionViewPagingLayoutStyleScale,   // 缩放模式，两边的item会小一点，逐渐向中间放大
  UICollectionViewPagingLayoutStyleRotation // 旋转模式，围绕底部某个点为中心旋转
};

@interface UICollectionViewPagingLayout : UICollectionViewFlowLayout
- (instancetype)initWithStyle:(UICollectionViewPagingLayoutStyle)style NS_DESIGNATED_INITIALIZER;
@property(nonatomic, assign, readonly) UICollectionViewPagingLayoutStyle style;
/**
 *  规定超过这个滚动速度就强制翻页，从而使翻页更容易触发。默认为 0.4
 */
@property(nonatomic, assign) CGFloat velocityForEnsurePageDown;
/**
 *  是否支持一次滑动可以滚动多个 item，默认为 YES
 */
@property(nonatomic, assign) BOOL allowsMultipleItemScroll;
/**
 *  规定了当支持一次滑动允许滚动多个 item 的时候，滑动速度要达到多少才会滚动多个 item，默认为 0.7
 *
 *  仅当 allowsMultipleItemScroll 为 YES 时生效
 */
@property(nonatomic, assign) CGFloat mutipleItemScrollVelocityLimit;

@end


@interface UICollectionViewPagingLayout (ScaleStyle)
@property(nonatomic, assign) CGFloat maximumScale;
@property(nonatomic, assign) CGFloat minimumScale;
@end

extern const CGFloat UICollectionViewPagingLayoutRotationRadiusAutomatic;

@interface UICollectionViewPagingLayout (RotationStyle)
/**
 *  旋转卡片相关
 *  左右两个卡片最终旋转的角度有 rotationRadius * 90 计算出来
 *  rotationRadius表示旋转的半径
 *  @warning 仅当 style 为 QMUICollectionViewPagingLayoutStyleRotation 时才生效
 */
@property(nonatomic, assign) CGFloat rotationRatio;
@property(nonatomic, assign) CGFloat rotationRadius;
@end
