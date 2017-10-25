//
//  SSUISwitch.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/10/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSUISwitch : UIControl

@property(nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *onTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *offTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *thumbTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,getter=isOn) BOOL on;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setOn:(BOOL)on animated:(BOOL)animated;
- (void)setOnImageNamed:(NSString*)imageName;
- (void)setOffImageNamed:(NSString*)imageName;
@end
