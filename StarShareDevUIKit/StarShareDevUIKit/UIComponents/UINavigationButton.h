//
//  UINavigationButton.h
//  Project
//
//  Created by pmo on 2017/9/23.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UINavigationButtonPosition) {
  UINavigationButtonPositionNone = -1,
  UINavigationButtonPositionLeft,
  UINavigationButtonPositionRight,
};

typedef NS_ENUM(NSUInteger, UINavigationButtonType) {
  UINavigationButtonTypeNormal,         // 普通导航栏文字按钮
  UINavigationButtonTypeBold,           // 导航栏加粗按钮
  UINavigationButtonTypeImage,          // 图标按钮
  UINavigationButtonTypeBack            // 自定义返回按钮(可以同时带有title)
};

@interface UINavigationButton : UIButton
@property(nonatomic, assign, readonly) UINavigationButtonType type;
@property(nonatomic, assign) BOOL useForBarButtonItem;
- (instancetype)initWithType:(UINavigationButtonType)type
                       title:(nullable NSString *)title;
- (instancetype)initWithType:(UINavigationButtonType)type;
- (instancetype)initWithImage:(nullable UIImage *)image;
+ (nullable UIBarButtonItem *)backBarButtonItemWithTarget:(nullable id)target
                                                   action:(nullable SEL)selector
                                                tintColor:(nullable UIColor *)tintColor;
+ (nullable UIBarButtonItem *)backBarButtonItemWithTarget:(nullable id)target
                                                   action:(nullable SEL)selector;
+ (UIBarButtonItem *)closeBarButtonItemWithTarget:(nullable id)target
                                           action:(nullable SEL)selector
                                        tintColor:(nullable UIColor *)tintColor;
+ (UIBarButtonItem *)closeBarButtonItemWithTarget:(nullable id)target
                                           action:(nullable SEL)selector;
+ (nullable UIBarButtonItem *)barButtonItemWithType:(UINavigationButtonType)type
                                              title:(nullable NSString *)title
                                          tintColor:(nullable UIColor *)tintColor
                                           position:(UINavigationButtonPosition)position
                                             target:(nullable id)target
                                             action:(nullable SEL)selector;
+ (nullable UIBarButtonItem *)barButtonItemWithType:(UINavigationButtonType)type
                                              title:(nullable NSString *)title
                                           position:(UINavigationButtonPosition)position
                                             target:(nullable id)target
                                             action:(nullable SEL)selector;
+ (nullable UIBarButtonItem *)barButtonItemWithNavigationButton:(UINavigationButton *)button
                                                      tintColor:(nullable UIColor *)tintColor
                                                       position:(UINavigationButtonPosition)position
                                                         target:(nullable id)target
                                                         action:(nullable SEL)selector;
+ (nullable UIBarButtonItem *)barButtonItemWithNavigationButton:(UINavigationButton *)button
                                                       position:(UINavigationButtonPosition)position
                                                         target:(nullable id)target
                                                         action:(nullable SEL)selector;
+ (nullable UIBarButtonItem *)barButtonItemWithImage:(nullable UIImage *)image
                                           tintColor:(nullable UIColor *)tintColor
                                            position:(UINavigationButtonPosition)position
                                              target:(nullable id)target
                                              action:(nullable SEL)selector;
+ (nullable UIBarButtonItem *)barButtonItemWithImage:(nullable UIImage *)image
                                            position:(UINavigationButtonPosition)position
                                              target:(nullable id)target
                                              action:(nullable SEL)selector;
@end

NS_ASSUME_NONNULL_END
