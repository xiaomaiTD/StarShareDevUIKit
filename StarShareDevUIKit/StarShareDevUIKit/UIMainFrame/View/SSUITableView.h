//
//  SSUITableView.h
//  Project
//
//  Created by jearoc on 2017/9/21.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSUITableView;

@protocol SSUITableViewDelegate <UITableViewDelegate>
@optional
- (BOOL)tableView:(SSUITableView *)tableView touchesShouldCancelInContentView:(UIView *)view;
@end

@protocol SSUITableViewDataSource <UITableViewDataSource>
@optional
- (__kindof UITableViewCell *)tableView:(UITableView *)tableView cellWithIdentifier:(NSString *)identifier;
@end

@interface SSUITableView : UITableView
@property(nonatomic, weak) id<SSUITableViewDelegate> delegate;
@property(nonatomic, weak) id<SSUITableViewDataSource> dataSource;
@end

NS_ASSUME_NONNULL_END
