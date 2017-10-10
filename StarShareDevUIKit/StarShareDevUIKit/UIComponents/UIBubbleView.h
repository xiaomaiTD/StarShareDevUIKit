//
//  UIBubbleView.h
//  Project
//
//  Created by jearoc on 2017/10/9.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 用于属性 maximumItemSize，是它的默认值。表示 item 的最大宽高会自动根据当前 bubbleView 的内容大小来调整，从而避免 item 内容过多时可能溢出 bubbleView。
extern const CGSize UIBubbleViewAutomaticalMaximumItemSize;

@interface UIBubbleView : UIView

/**
 *  UIBubbleView 内部的间距，默认为 UIEdgeInsetsZero
 */
@property(nonatomic, assign) UIEdgeInsets padding;

/**
 *  item 的最小宽高，默认为 CGSizeZero，也即不限制。
 */
@property(nonatomic, assign) IBInspectable CGSize minimumItemSize;

/**
 *  item 的最大宽高，默认为 UIBubbleViewAutomaticalMaximumItemSize，也即不超过 floatLayoutView 自身最大内容宽高。
 */
@property(nonatomic, assign) IBInspectable CGSize maximumItemSize;

/**
 *  item 之间的间距，默认为 UIEdgeInsetsZero。
 *
 *  @warning 上、下、左、右四个边缘的 item 布局时不会考虑 itemMargins.left/bottom/left/right。
 */
@property(nonatomic, assign) UIEdgeInsets itemMargins;

@end
