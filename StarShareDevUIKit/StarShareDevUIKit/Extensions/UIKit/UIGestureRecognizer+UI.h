//
//  UIGestureRecognizer+UI.h
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (UI)

/// 获取当前手势直接作用到的 view（注意与 view 属性区分开：view 属性表示手势被添加到哪个 view 上，targetView 则是 view 属性里的某个 subview）
@property(nullable, nonatomic, weak, readonly) UIView *targetView;

@end
