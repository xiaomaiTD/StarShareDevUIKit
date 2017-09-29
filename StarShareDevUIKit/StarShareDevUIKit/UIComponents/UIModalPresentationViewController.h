//
//  UIModalPresentationViewController.h
//  Project
//
//  Created by jearoc on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIModalPresentationViewController;
@class UIModalPresentationWindow;

typedef NS_ENUM(NSUInteger, UIModalPresentationAnimationStyle) {
  UIModalPresentationAnimationStyleFade,    // 渐现渐隐，默认
  UIModalPresentationAnimationStylePopup,   // 从中心点弹出
  UIModalPresentationAnimationStyleSlide    // 从下往上升起
};

@protocol UIModalPresentationContentViewControllerProtocol <NSObject>
@optional
- (CGSize)preferredContentSizeInModalPresentationViewController:(UIModalPresentationViewController *)controller limitSize:(CGSize)limitSize;
@end

@protocol UIModalPresentationViewControllerDelegate <NSObject>
@optional
- (BOOL)shouldHideModalPresentationViewController:(UIModalPresentationViewController *)controller;
- (void)willHideModalPresentationViewController:(UIModalPresentationViewController *)controller;
- (void)didHideModalPresentationViewController:(UIModalPresentationViewController *)controller;
- (void)requestHideAllModalPresentationViewController;
@end


@interface UIModalPresentationViewController : UIViewController{
  UITapGestureRecognizer      *_dimmingViewTapGestureRecognizer;
  CGFloat                     _keyboardHeight;
}

@property(nonatomic, weak) id<UIModalPresentationViewControllerDelegate> delegate;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIViewController<UIModalPresentationContentViewControllerProtocol> *contentViewController;
@property(nonatomic, assign) UIEdgeInsets contentViewMargins UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat maximumContentViewWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIView *dimmingView;
@property(nonatomic, copy) void (^didHideByDimmingViewTappedBlock)(void);
@property(nonatomic, assign, getter=isModal) BOOL modal;
@property(nonatomic, assign, readonly, getter=isVisible) BOOL visible;
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;
@property(nonatomic, assign) UIModalPresentationAnimationStyle animationStyle UI_APPEARANCE_SELECTOR;
@property(nonatomic, copy) void (^layoutBlock)(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame);
@property(nonatomic, copy) void (^showingAnimation)(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished));
@property(nonatomic, copy) void (^hidingAnimation)(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished));

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)showInView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)hideInView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
@end

@interface UIModalPresentationViewController (Manager)
+ (BOOL)isAnyModalPresentationViewControllerVisible;
+ (BOOL)hideAllVisibleModalPresentationViewControllerIfCan;
@end

@interface UIModalPresentationViewController (UIAppearance)
+ (instancetype)appearance;
@end

@interface UIModalPresentationWindow : UIWindow
@end

@interface UIViewController (UIModalPresentationViewController)
@property(nonatomic, weak, readonly) UIModalPresentationViewController *modalPresentedViewController;
@end
