//
//  UIToastBackgroundView.h
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToastBackgroundView : UIView

/**
 * 是否需要磨砂，默认NO。仅支持iOS8及以上版本。可以通过修改`styleColor`来控制磨砂的效果。
 */
@property(nonatomic, assign) BOOL shouldBlurBackgroundView;

/**
 * 如果不设置磨砂，则styleColor直接作为`UIToastBackgroundView`的backgroundColor；如果需要磨砂，则会新增加一个`UIVisualEffectView`放在`UIToastBackgroundView`上面
 */
@property(nonatomic, strong) UIColor *styleColor UI_APPEARANCE_SELECTOR;

/**
 * 设置圆角。
 */
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

@end
