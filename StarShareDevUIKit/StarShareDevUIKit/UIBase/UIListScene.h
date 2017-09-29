//
//  UIListScene.h
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIScene.h"
#import "UITableScene.h"
#import "UIComponents.h"

@interface UIListScene : UIScene<UITableSceneDelegate, UITableSceneDataSource, UIChangingThemeDelegate>
- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)didInitializedWithStyle:(UITableViewStyle)style NS_REQUIRES_SUPER;
@property(nonatomic, assign, readonly) UITableViewStyle style;
@property(nonatomic, strong, readonly) UITableScene *tableView;
@property(nonatomic, assign) UIEdgeInsets tableViewInitialContentInset;
@property(nonatomic, assign) UIEdgeInsets tableViewInitialScrollIndicatorInsets;
- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force;
@end

@interface UIListScene (Hooks)
- (void)initTableView;
- (BOOL)shouldHideTableHeaderViewInitial;
@end
