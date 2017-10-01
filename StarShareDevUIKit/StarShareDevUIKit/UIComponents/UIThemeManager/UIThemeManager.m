//
//  UIThemeManager.m
//  Project
//
//  Created by pmo on 2017/9/24.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIThemeManager.h"

NSString *const UIThemeChangedNotification = @"UIThemeChangedNotification";
NSString *const UIThemeBeforeChangedName = @"UIThemeBeforeChangedName";
NSString *const UIThemeAfterChangedName = @"UIThemeAfterChangedName";

@implementation UIThemeManager

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static UIThemeManager *instance = nil;
  dispatch_once(&onceToken,^{
    instance = [[super allocWithZone:NULL] init];
  });
  return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
  return [self sharedInstance];
}

- (void)setCurrentTheme:(NSObject<UIThemeProtocol> *)currentTheme {
  BOOL isThemeChanged = _currentTheme != currentTheme;
  NSObject<UIThemeProtocol> *themeBeforeChanged = nil;
  if (isThemeChanged) {
    themeBeforeChanged = _currentTheme;
  }
  _currentTheme = currentTheme;
  if (isThemeChanged) {
    [currentTheme setupConfigurationTemplate];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIThemeChangedNotification
                                                        object:self
                                                      userInfo:@{UIThemeBeforeChangedName: themeBeforeChanged ?: [NSNull null], UIThemeAfterChangedName: currentTheme ?: [NSNull null]}];
  }
}


@end
