//
//  UIViewController+UI.h
//  Project
//
//  Created by jearoc on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICore.h"
#import "UINavigationController+UI.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UINavigationControllerBackButtonHandlerProtocol;

@interface UIViewController (UI)

/** 获取和自身处于同一个UINavigationController里的上一个UIViewController */
@property(nullable, nonatomic, weak, readonly) UIViewController *previousViewController;

/** 获取上一个UIViewController的title，可用于设置自定义返回按钮的文字 */
@property(nullable, nonatomic, copy, readonly) NSString *previousViewControllerTitle;

/**
 *  获取当前controller里的最高层可见viewController（可见的意思是还会判断self.view.window是否存在）
 *
 *  @see 如果要获取当前App里的可见viewController，请使用 [UIHelper visibleViewController]
 *
 *  @return 当前controller里的最高层可见viewController
 */
- (nullable UIViewController *)visibleViewControllerIfExist;

/**
 *  当前 viewController 是否是被以 present 的方式显示的，是则返回 YES，否则返回 NO
 *  @warning 对于被放在 UINavigationController 里显示的 UIViewController，如果 self 是 self.navigationController 的第一个 viewController，则如果 self.navigationController 是被 present 起来的，那么 self.isPresented = self.navigationController.isPresented = YES。利用这个特性，可以方便地给 navigationController 的第一个界面的左上角添加关闭按钮。
 */
- (BOOL)isPresented;

/**
 *  是否应该响应一些UI相关的通知，例如 UIKeyboardNotification、UIMenuControllerNotification等，因为有可能当前界面已经被切走了（push到其他界面），但仍可能收到通知，所以在响应通知之前都应该做一下这个判断
 */
- (BOOL)isViewLoadedAndVisible;

/**
 *  是否应该响应，有些操作是在push以后都不再进行和响应的pop回来的时候再继续响应,和上面方法不同的是：这个值会在willAppear的时候返回 YES，disAppear饿时候返回 NO。
 */
- (BOOL)isActive;

/**
 *   UINavigationBar 在 self.view 坐标系里的 maxY，一般用于 self.view.subviews 布局时参考用
 *  @warning 如果不存在 UINavigationBar，则为 0
 */
@property(nonatomic, assign, readonly) CGFloat navigationBarMaxYInViewCoordinator;

/**
 *  底部 UIToolbar 在 self.view 坐标系里的占位高度，一般用于 self.view.subviews 布局时参考用
 *  @warning 如果不存在 UIToolbar，则为 0
 */
@property(nonatomic, assign, readonly) CGFloat toolbarSpacingInViewCoordinator;

/**
 *  底部 UITabBar 在 self.view 坐标系里的占位高度，一般用于 self.view.subviews 布局时参考用
 *  @warning 如果不存在 UITabBar，则为 0
 */
@property(nonatomic, assign, readonly) CGFloat tabBarSpacingInViewCoordinator;

@end

@interface UIViewController (Runtime)

/**
 *  判断当前类是否有重写某个指定的 UIViewController 的方法
 *  @param selector 要判断的方法
 *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIViewController 默认的实现
 */
- (BOOL)hasOverrideUIKitMethod:(_Nonnull SEL)selector;

@end

/**
 *  日常业务中经常碰到这样的场景：进入界面后会异步加载数据，当数据加载完并且 viewDidAppear: 后要执行一些操作（例如滚动列表到某一行并高亮它），若数据在 viewDidAppear: 前就已经加载完，也需要等到 viewDidAppear: 时才做那些操作。
 *  当你需要实现这种场景的效果时，可以用以下两个属性，具体请查看属性注释。
 */
@interface UIViewController (Data)

/// 当数据加载完（什么时候算是“加载完”需要通过属性 dataLoaded 来设置）并且界面已经走过 viewDidAppear: 时，这个 block 会被执行，执行结束后 block 会被清空，以避免重复调用。
@property(nullable, nonatomic, copy) void (^didAppearAndLoadDataBlock)(void);

/// 请在你的数据加载完成时手动修改这个属性为 YES，如果此时界面已经走过 viewDidAppear:，则 didAppearAndLoadDataBlock 会被立即执行，如果此时界面尚未走 viewDidAppear:，则等到 viewDidAppear: 时，didAppearAndLoadDataBlock 就会被自动执行。
@property(nonatomic, assign, getter = isDataLoaded) BOOL dataLoaded;

@end

@interface UIViewController (Handler)<UINavigationControllerBackButtonHandlerProtocol>
@end

NS_ASSUME_NONNULL_END
