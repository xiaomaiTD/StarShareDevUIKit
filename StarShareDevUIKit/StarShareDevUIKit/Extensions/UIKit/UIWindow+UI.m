//
//  UIWindow+UI.m
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIWindow+UI.h"
#import "UICore.h"

@implementation UIWindow (UI)
+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod([self class], @selector(init), @selector(ss_init));
  });
}

- (instancetype)ss_init {
  if (IOS_VERSION < 9.0) {
    // iOS 9 以前的版本，UIWindow init时如果不给一个frame，默认是CGRectZero，而iOS 9以后的版本，由于增加了分屏（Split View）功能，你的App可能运行在一个非全屏大小的区域内，所以UIWindow如果调用init方法（而不是initWithFrame:）来初始化，系统会自动为你的window设置一个合适的大小。所以这里对iOS 9以前的版本做适配，默认给一个全屏的frame
    UIWindow *window = [self ss_init];
    window.frame = [[UIScreen mainScreen] bounds];
    return window;
  }
  
  return [self ss_init];
}
@end
