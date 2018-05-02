//
//  UIImageView+UI.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/18.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIImageView+UI.h"
#import "UICore.h"

@implementation UIImageView (UI)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ExchangeImplementations([self class], @selector(didMoveToSuperview), @selector(ss_didMoveToSuperview));
  });
}

- (void)ss_didMoveToSuperview{
  [self ss_didMoveToSuperview];
}
@end
