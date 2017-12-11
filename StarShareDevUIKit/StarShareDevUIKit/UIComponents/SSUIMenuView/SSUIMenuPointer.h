//
//  SSUIMenuPointer.h
//  StarShare_iOS
//
//  Created by BUBUKO on 2017/12/10.
//  Copyright © 2017年 Rui Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSUIMenuPointer : UIView

@property (nonatomic, strong) NSArray *itemFrames;
@property (nonatomic, assign) CGColorRef color;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat speedFactor;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) BOOL naughty;
@property (nonatomic, assign) BOOL isTriangle;
@property (nonatomic, assign) BOOL hollow;
@property (nonatomic, assign) BOOL hasBorder;

- (void)setProgressWithOutAnimate:(CGFloat)progress;
- (void)moveToPostion:(NSInteger)pos;
@end

NS_ASSUME_NONNULL_END
