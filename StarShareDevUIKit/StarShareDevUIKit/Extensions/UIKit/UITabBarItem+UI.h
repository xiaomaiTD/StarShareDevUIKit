//
//  UITabBarItem+UI.h
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (UI)
@property(nonatomic, copy) void (^doubleTapBlock)(UITabBarItem *tabBarItem, NSInteger index);
- (UIControl *)barButton;
- (UIImageView *)imageView;
@end
