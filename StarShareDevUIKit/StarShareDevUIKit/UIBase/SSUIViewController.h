//
//  SSUIViewController.h
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSUINavigationController.h"
#import "UIComponents.h"
#import "UIExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSUIViewController : UIViewController<UINavigationCustomTransitionDelegate>
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)didInitialized NS_REQUIRES_SUPER;
@property(nonatomic, assign) BOOL autorotate;
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;
@property(nonatomic, strong, readonly) UINavigationTitleView *titleView;
@property(nonatomic, strong) UIEmptyView *emptyView;
@property(nonatomic, assign, readonly, getter = isEmptyViewShowing) BOOL emptyViewShowing;
- (void)showEmptyView;
- (void)showEmptyViewWithLoading;
- (void)showEmptyViewWithText:(NSString * _Nullable )text
                   detailText:(NSString * _Nullable)detailText
                  buttonTitle:(NSString * _Nullable)buttonTitle
                 buttonAction:(SEL)action;
- (void)showEmptyViewWithImage:(UIImage * _Nullable)image
                          text:(NSString * _Nullable)text
                    detailText:(NSString * _Nullable)detailText
                   buttonTitle:(NSString * _Nullable)buttonTitle
                  buttonAction:(SEL)action;
- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage * _Nullable)image
                            text:(NSString * _Nullable)text
                      detailText:(NSString * _Nullable)detailText
                     buttonTitle:(NSString * _Nullable)buttonTitle
                    buttonAction:(SEL)action;
- (void)hideEmptyView;
- (BOOL)layoutEmptyView;
@end

@interface SSUIViewController (UIKeyboard)
@property(nonatomic, strong, readonly) UITapGestureRecognizer *hideKeyboardTapGestureRecognizer;
@property(nonatomic, strong, readonly) UIKeyboardManager *hideKeyboardManager;
- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view;
@end

@interface SSUIViewController (Hooks)
- (void)initSubviews NS_REQUIRES_SUPER;
- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated;
- (void)setToolbarItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated;
- (void)contentSizeCategoryDidChanged:(NSNotification *)notification;
- (void)significantTimeChange:(NSNotification *)notification;
@end

NS_ASSUME_NONNULL_END
