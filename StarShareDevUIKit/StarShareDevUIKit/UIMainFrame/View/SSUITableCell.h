//
//  SSUITableCell.h
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIComponents.h"
#import "UIExtensions.h"

@interface SSUITableCell : UITableViewCell
@property(nonatomic, assign, readonly) UITableViewCellStyle style;
@property(nonatomic, assign) UIEdgeInsets imageEdgeInsets;
@property(nonatomic, assign) UIEdgeInsets textLabelEdgeInsets;
@property(nonatomic, assign) UIEdgeInsets detailTextLabelEdgeInsets;
@property(nonatomic, assign) UIEdgeInsets accessoryEdgeInsets;
@property(nonatomic, assign) UIEdgeInsets accessoryHitTestEdgeInsets;
@property(nonatomic, assign, getter = isEnabled) BOOL enabled;
@property(nonatomic, weak) UITableView *parentTableView;
@property(nonatomic, assign, readonly) UITableCellScenePosition cellPosition;
- (instancetype)initForTableView:(UITableView *)tableView withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (instancetype)initForTableView:(UITableView *)tableView withReuseIdentifier:(NSString *)reuseIdentifier;
@end

@interface SSUITableCell (Hooks)
/// 用于继承的接口，设置一些cell相关的UI，需要自 cellForRowAtIndexPath 里面调用。默认实现是设置当前cell在哪个position。
- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath;
@end
