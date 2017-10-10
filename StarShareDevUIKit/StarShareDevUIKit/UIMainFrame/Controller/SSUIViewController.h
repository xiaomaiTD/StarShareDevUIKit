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

/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)didInitialized NS_REQUIRES_SUPER;

/**
 *  修改当前界面要支持的横竖屏方向，默认为 SupportedOrientationMask
 */
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

/**
 *  SSUIViewController默认都会增加一个UINavigationTitleView的titleView，然后重写了setTitle来间接设置titleView的值。所以设置title的时候就跟系统的接口一样：self.title = xxx。
 *
 *  同时，UINavigationTitleView提供了更多的功能，具体可以参考UINavigationTitleView的文档。<br/>
 *  @see UINavigationTitleView
 */
@property(nonatomic, strong, readonly) UINavigationTitleView *titleView;

/**
 *  空列表控件，支持显示提示文字、loading、操作按钮
 */
@property(nonatomic, strong) UIEmptyView *emptyView;

/// 当前self.emptyView是否显示
@property(nonatomic, assign, readonly, getter = isEmptyViewShowing) BOOL emptyViewShowing;

/**
 *  显示emptyView
 *  emptyView 的以下系列接口可以按需进行重写
 *
 *  @see UIEmptyView
 */
- (void)showEmptyView;

/**
 *  显示loading的emptyView
 */
- (void)showEmptyViewWithLoading;

/**
 *  显示带text、detailText、button的emptyView
 */
- (void)showEmptyViewWithText:(NSString * _Nullable )text
                   detailText:(NSString * _Nullable)detailText
                  buttonTitle:(NSString * _Nullable)buttonTitle
                 buttonAction:(SEL)action;

/**
 *  显示带image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithImage:(UIImage * _Nullable)image
                          text:(NSString * _Nullable)text
                    detailText:(NSString * _Nullable)detailText
                   buttonTitle:(NSString * _Nullable)buttonTitle
                  buttonAction:(SEL)action;

/**
 *  显示带loading、image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage * _Nullable)image
                            text:(NSString * _Nullable)text
                      detailText:(NSString * _Nullable)detailText
                     buttonTitle:(NSString * _Nullable)buttonTitle
                    buttonAction:(SEL)action;

/**
 *  隐藏emptyView
 */
- (void)hideEmptyView;

/**
 *  布局emptyView，如果emptyView没有被初始化或者没被添加到界面上，则直接忽略掉。
 *
 *  如果有特殊的情况，子类可以重写，实现自己的样式
 *
 *  @return YES表示成功进行一次布局，NO表示本次调用并没有进行布局操作（例如emptyView还没被初始化）
 */
- (BOOL)layoutEmptyView;

@end

@interface SSUIViewController (UIKeyboard)

/// 在 viewDidLoad 内初始化，并且 gestureRecognizerShouldBegin: 必定返回 NO。
@property(nonatomic, strong, readonly) UITapGestureRecognizer *hideKeyboardTapGestureRecognizer;
@property(nonatomic, strong, readonly) UIKeyboardManager *hideKeyboardManager;

/**
 *  当用户点击界面上某个 view 时，如果此时键盘处于升起状态，则可通过重写这个方法并返回一个 YES 来达到“点击空白区域自动降下键盘”的需求。默认返回 NO，也即不处理键盘。
 *  @warning 注意如果被点击的 view 本身消耗了事件（iOS 11 下测试得到这种类型的所有系统的 view 仅有 UIButton 和 UISwitch），则这个方法并不会被触发。
 *  @warning 有可能参数传进去的 view 是某个 subview 的 subview，所以建议用 isDescendantOfView: 来判断是否点到了某个目标 subview
 */
- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view;

@end

@interface SSUIViewController (Hooks)

/**
 *  负责初始化和设置controller里面的view，也就是self.view的subView。目的在于分类代码，所以与view初始化的相关代码都写在这里。
 *
 *  @warning initSubviews只负责subviews的init，不负责布局。布局相关的代码应该写在 <b>needLayoutSubviews</b>
 */
- (void)initSubviews NS_REQUIRES_SUPER;


- (void)needLayoutSubviews NS_REQUIRES_SUPER;

/**
 *  负责设置和更新navigationItem，包括title、leftBarButtonItem、rightBarButtonItem。viewDidLoad里面会自动调用，允许手动调用更新。目的在于分类代码，所有与navigationItem相关的代码都写在这里。在需要修改navigationItem的时候都只调用这个接口。
 *
 *  @param isInEditMode 是否用于编辑模式下
 *  @param animated     是否使用动画呈现
 */
- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated;

/**
 *  负责设置和更新toolbarItem。在viewWillAppear里面自动调用（因为toolbar是navigationController的，是每个界面公用的，所以必须在每个界面的viewWillAppear时更新，不能放在viewDidLoad里），允许手动调用。目的在于分类代码，所有与toolbarItem相关的代码都写在这里。在需要修改toolbarItem的时候都只调用这个接口。
 *
 *  @param isInEditMode 是否用于编辑模式下
 *  @param animated     是否使用动画呈现
 */
- (void)setToolbarItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated;

/**
 *  动态字体的回调函数。
 *
 *  交给子类重写，当系统字体发生变化的时候，会调用这个方法，一些font的设置或者reloadData可以放在里面
 *
 *  @param notification test
 */
- (void)contentSizeCategoryDidChanged:(NSNotification *)notification;

/**
 *  日期变化的的回调函数。比如从当天到第二天
 *
 *  @param notification test
 */
- (void)significantTimeChange:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
