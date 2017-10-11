//
//  UITableView+UIStaticCell.h
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIStaticTableViewCellDataSource;

/**
 *  配合 UIStaticTableViewCellDataSource 使用，主要负责：
 *  1. 提供 property 去绑定一个 static dataSource
 *  2. 重写 setDataSource:、setDelegate: 方法，自动实现 UITableViewDataSource、UITableViewDelegate 里一些必要的方法
 *
 *  使用方式：初始化一个 UIStaticTableViewCellDataSource 并将其赋值给 staticCellDataSource 属性即可。
 *
 *  @warning 当要动态更新 dataSource 时，可直接修改 self.staticCellDataSource.cellDataSections 数组，或者创建一个新的 UIStaticTableViewCellDataSource。不管用哪种方法，都不需要手动调用 reloadData，tableView 会自动刷新的。
 */
@interface UITableView (UIStaticCell)
@property(nonatomic, strong) UIStaticTableViewCellDataSource *staticCellDataSource;
@end
