//
//  UITableScene.h
//  Project
//
//  Created by jearoc on 2017/9/21.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UITableScene;

@protocol UITableSceneDelegate <UITableViewDelegate>
@optional
- (BOOL)tableView:(UITableScene *)tableView touchesShouldCancelInContentView:(UIView *)view;
@end

@protocol UITableSceneDataSource <UITableViewDataSource>
@optional
- (__kindof UITableViewCell *)tableView:(UITableView *)tableView cellWithIdentifier:(NSString *)identifier;
@end

@interface UITableScene : UITableView
@property(nonatomic, weak) id<UITableSceneDelegate> delegate;
@property(nonatomic, weak) id<UITableSceneDataSource> dataSource;
@end

NS_ASSUME_NONNULL_END
