//
//  MTLoading.h
//  MTime_iOS
//
//  Created by BUBUKO on 2017/11/13.
//  Copyright © 2017年 BUBUKO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTLoading : UIView

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL hidesWhenStopped;
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;
@property (nonatomic, readonly) BOOL isAnimating;
@property (nonatomic, readwrite) NSTimeInterval duration;

- (void)setAnimating:(BOOL)animate;
- (void)startAnimating;
- (void)stopAnimating;
@end
