//
//  SSUIListViewController.h
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIListViewController.h"
#import "SSUIViewController.h"
#import "SSUITableView.h"
#import "UIComponents.h"

@interface SSUIListViewController : SSUIViewController<SSUITableViewDelegate, SSUITableViewDataSource, UIChangingThemeDelegate>
- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)didInitializedWithStyle:(UITableViewStyle)style NS_REQUIRES_SUPER;
@property(nonatomic, assign, readonly) UITableViewStyle style;
@property(nonatomic, strong, readonly) SSUITableView *tableView;

/**
 修改 UITableView ContentInset ，一旦修改了此属性并且不等于 {-1, -1, -1, -1} 的时候，系统的 automaticallyAdjustsScrollViewInsets 和 iOS 11 下的新属性 contentInsetAdjustmentBehavior 可能会影响到 ContentInset | adjustedContentInset 其实这个时候 UITableView ContentInset 并不是等于你设置的 tableViewInitialContentInset ，所以在这个时候如果想要使用此属性 必须设置 automaticallyAdjustsScrollViewInsets = NO，或者 contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever。
 */
@property(nonatomic, assign) UIEdgeInsets tableViewInitialContentInset;
@property(nonatomic, assign) UIEdgeInsets tableViewInitialScrollIndicatorInsets;
- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force;
@end

@interface SSUIListViewController (Hooks)
- (void)initTableView NS_REQUIRES_SUPER;
- (BOOL)shouldHideTableHeaderViewInitial;
@end
