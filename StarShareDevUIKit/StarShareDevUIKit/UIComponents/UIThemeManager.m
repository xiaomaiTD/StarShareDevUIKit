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

- (instancetype)init {
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleThemeChangedNotification:)
                                                 name:UIThemeChangedNotification object:nil];
  }
  return self;
}

- (void)handleThemeChangedNotification:(NSNotification *)notification {
  NSObject<UIThemeProtocol> *themeBeforeChanged = notification.userInfo[UIThemeBeforeChangedName];
  themeBeforeChanged = [themeBeforeChanged isKindOfClass:[NSNull class]] ? nil : themeBeforeChanged;
  
  NSObject<UIThemeProtocol> *themeAfterChanged = notification.userInfo[UIThemeAfterChangedName];
  themeAfterChanged = [themeAfterChanged isKindOfClass:[NSNull class]] ? nil : themeAfterChanged;
  
  [self themeBeforeChanged:themeBeforeChanged afterChanged:themeAfterChanged];
}

- (void)setCurrentTheme:(NSObject<UIThemeProtocol> *)currentTheme {
  BOOL isThemeChanged = _currentTheme != currentTheme;
  NSObject<UIThemeProtocol> *themeBeforeChanged = nil;
  if (isThemeChanged) {
    themeBeforeChanged = _currentTheme;
  }
  _currentTheme = currentTheme;
  if (isThemeChanged && themeBeforeChanged) {
    [currentTheme applyConfigurationTemplate];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIThemeChangedNotification
                                                        object:self
                                                      userInfo:@{UIThemeBeforeChangedName: themeBeforeChanged ?: [NSNull null],
                                                                 UIThemeAfterChangedName: currentTheme ?: [NSNull null]}];
  }
}

#pragma mark - <QDChangingThemeDelegate>

- (void)themeBeforeChanged:(NSObject<UIThemeProtocol> *)themeBeforeChanged
              afterChanged:(NSObject<UIThemeProtocol> *)themeAfterChanged {
  // 主题发生变化，在这里更新全局 UI 控件的 appearance
}
@end
