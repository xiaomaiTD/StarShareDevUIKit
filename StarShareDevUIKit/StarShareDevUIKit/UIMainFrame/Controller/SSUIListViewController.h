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
@property(nonatomic, assign) UIEdgeInsets tableViewInitialContentInset;
@property(nonatomic, assign) UIEdgeInsets tableViewInitialScrollIndicatorInsets;
- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force;
@end

@interface SSUIListViewController (Hooks)
- (void)initTableView;
- (BOOL)shouldHideTableHeaderViewInitial;
@end
