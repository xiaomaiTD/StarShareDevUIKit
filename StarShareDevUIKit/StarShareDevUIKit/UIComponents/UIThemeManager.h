//
//  UIThemeManager.h
//  Project
//
//  Created by pmo on 2017/9/24.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIConfiguration.h"

@protocol UIThemeProtocol <UIConfigurationTemplateProtocol>
@required
- (UIColor *)themeTintColor;
- (UIColor *)themeListTextColor;
- (UIColor *)themeCodeColor;
- (UIColor *)themeGridItemTintColor;
- (NSString *)themeName;
@end

@protocol UIChangingThemeDelegate <NSObject>
@required
- (void)themeBeforeChanged:(NSObject<UIThemeProtocol> *)themeBeforeChanged
              afterChanged:(NSObject<UIThemeProtocol> *)themeAfterChanged;
@end

extern NSString *const UIThemeChangedNotification;
extern NSString *const UIThemeBeforeChangedName;
extern NSString *const UIThemeAfterChangedName;

@interface UIThemeManager : NSObject<UIChangingThemeDelegate>
+ (instancetype)sharedInstance;
@property(nonatomic, strong) NSObject<UIThemeProtocol> *currentTheme;
@end
