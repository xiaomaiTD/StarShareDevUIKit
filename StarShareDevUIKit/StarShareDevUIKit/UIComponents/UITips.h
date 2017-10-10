//
//  UITips.h
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIToastView.h"

/**
 * 简单封装了 UIToastView，支持弹出纯文本、loading、succeed、error、info 等五种 tips。如果这些接口还满足不了业务的需求，可以通过 QMUITips 的分类自行添加接口。
 * 注意用类方法显示 tips 的话，会导致父类的 willShowBlock 无法正常工作，具体请查看 willShowBlock 的注释。
 * @see [UIToastView willShowBlock]
 */
@interface UITips : UIToastView

NS_ASSUME_NONNULL_BEGIN

/// 实例方法：需要自己addSubview，hide之后不会自动removeFromSuperView

- (void)showWithText:(nullable NSString *)text;
- (void)showWithText:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showLoading;
- (void)showLoading:(nullable NSString *)text;
- (void)showLoadingHideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showSucceed:(nullable NSString *)text;
- (void)showSucceed:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showError:(nullable NSString *)text;
- (void)showError:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showInfo:(nullable NSString *)text;
- (void)showInfo:(nullable NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText;
- (void)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

/// 类方法：主要用在局部一次性使用的场景，hide之后会自动removeFromSuperView

+ (UITips *)createTipsToView:(UIView *)view;

+ (UITips *)showWithText:(nullable NSString *)text inView:(UIView *)view;
+ (UITips *)showWithText:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (UITips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (UITips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (UITips *)showLoadingInView:(UIView *)view;
+ (UITips *)showLoading:(nullable NSString *)text inView:(UIView *)view;
+ (UITips *)showLoadingInView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (UITips *)showLoading:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (UITips *)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (UITips *)showLoading:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (UITips *)showSucceed:(nullable NSString *)text inView:(UIView *)view;
+ (UITips *)showSucceed:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (UITips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (UITips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (UITips *)showError:(nullable NSString *)text inView:(UIView *)view;
+ (UITips *)showError:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (UITips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (UITips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (UITips *)showInfo:(nullable NSString *)text inView:(UIView *)view;
+ (UITips *)showInfo:(nullable NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (UITips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view;
+ (UITips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

NS_ASSUME_NONNULL_END

@end
