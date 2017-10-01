//
//  UIButton+UI.h
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (UI)
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;
- (void)calculateHeightAfterSetAppearance;
- (void)setTitleAttributes:(NSDictionary<NSString *, id> *)attributes forState:(UIControlState)state;
@end
