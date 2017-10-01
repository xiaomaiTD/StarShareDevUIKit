//
//  UIGestureRecognizer+UI.h
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (UI)
@property(nullable, nonatomic, weak, readonly) UIView *targetView;
@end
