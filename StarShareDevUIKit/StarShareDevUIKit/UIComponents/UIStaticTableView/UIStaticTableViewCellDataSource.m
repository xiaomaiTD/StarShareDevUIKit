//
//  UIStaticTableViewCellDataSource.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIStaticTableViewCellDataSource.h"
#import "UICore.h"
#import "UIStaticTableViewCellData.h"
#import "SSUITableCell.h"
#import "UITableView+UIStaticCell.h"
#import "UIExtensions.h"
#import <objc/runtime.h>

@interface UIStaticTableViewCellDataSource ()
@end

@implementation UIStaticTableViewCellDataSource

- (instancetype)init {
  if (self = [super init]) {
  }
  return self;
}

- (instancetype)initWithCellDataSections:(NSArray<NSArray<UIStaticTableViewCellData *> *> *)cellDataSections {
  if (self = [super init]) {
    self.cellDataSections = cellDataSections;
  }
  return self;
}

- (void)setCellDataSections:(NSArray<NSArray<UIStaticTableViewCellData *> *> *)cellDataSections {
  _cellDataSections = cellDataSections;
  [self.tableView reloadData];
}

// 在 UITableView (StaticCell) 那边会把 tableView 的 property 改为 readwrite，所以这里补上 setter
- (void)setTableView:(UITableView *)tableView {
  _tableView = tableView;
  // 触发 UITableView (StaticCell) 里重写的 setter 里的逻辑
  tableView.delegate = tableView.delegate;
  tableView.dataSource = tableView.dataSource;
}

@end

@interface UIStaticTableViewCellData (Manual)

@property(nonatomic, strong, readwrite) NSIndexPath *indexPath;
@end

@implementation UIStaticTableViewCellDataSource (Manual)

- (UIStaticTableViewCellData *)cellDataAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section >= self.cellDataSections.count) {
    NSLog(@"cellDataWithIndexPath:%@, data not exist in section!", indexPath);
    return nil;
  }
  
  NSArray<UIStaticTableViewCellData *> *rowDatas = [self.cellDataSections objectAtIndex:indexPath.section];
  if (indexPath.row >= rowDatas.count) {
    NSLog(@"cellDataWithIndexPath:%@, data not exist in row!", indexPath);
    return nil;
  }
  
  UIStaticTableViewCellData *cellData = [rowDatas objectAtIndex:indexPath.row];
  [cellData setIndexPath:indexPath];// 在这里才为 cellData.indexPath 赋值
  return cellData;
}

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
  UIStaticTableViewCellData *data = [self cellDataAtIndexPath:indexPath];
  return [NSString stringWithFormat:@"cell_%@", @(data.identifier)];
}

- (SSUITableCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UIStaticTableViewCellData *data = [self cellDataAtIndexPath:indexPath];
  if (!data) {
    return nil;
  }
  
  NSString *identifier = [self reuseIdentifierForCellAtIndexPath:indexPath];
  
  SSUITableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[data.cellClass alloc] initForTableView:self.tableView withStyle:data.style reuseIdentifier:identifier];
  }
  cell.imageView.image = data.image;
  cell.textLabel.text = data.text;
  cell.detailTextLabel.text = data.detailText;
  cell.accessoryType = [UIStaticTableViewCellData tableViewCellAccessoryTypeWithStaticAccessoryType:data.accessoryType];
  
  // 为某些控件类型的accessory添加控件及相应的事件绑定
  if (data.accessoryType == UIStaticTableViewCellAccessoryTypeSwitch) {
    UISwitch *switcher;
    BOOL switcherOn = NO;
    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
      switcher = (UISwitch *)cell.accessoryView;
    } else {
      switcher = [[UISwitch alloc] init];
    }
    if ([data.accessoryValueObject isKindOfClass:[NSNumber class]]) {
      switcherOn = [((NSNumber *)data.accessoryValueObject) boolValue];
    }
    switcher.on = switcherOn;
    [switcher removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [switcher addTarget:data.accessoryTarget action:data.accessoryAction forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = switcher;
  }
  
  // 统一设置selectionStyle
  if (data.accessoryType == UIStaticTableViewCellAccessoryTypeSwitch || (!data.didSelectTarget || !data.didSelectAction)) {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  } else {
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  }
  
  if (data.accessoryType == UIStaticTableViewCellAccessoryTypeDoneButton) {
    UIView *accessoryView = cell.accessoryView;
    if ([accessoryView isKindOfClass:[UIButton class]]) {
      [(UIButton *)accessoryView setImage:TableViewCellDoneButtonImage forState:UIControlStateNormal];
      [(UIButton *)accessoryView sizeToFit];
    }
  }
  
  [cell updateCellAppearanceWithIndexPath:indexPath];
  
  return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  UIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
  return cellData.height;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
  if (!cellData || !cellData.didSelectTarget || !cellData.didSelectAction) {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    return;
  }
  
  // 1、分发选中事件（UISwitch 类型不支持 didSelect）
  if ([cellData.didSelectTarget respondsToSelector:cellData.didSelectAction] && cellData.accessoryType != UIStaticTableViewCellAccessoryTypeSwitch) {
    BeginIgnorePerformSelectorLeaksWarning
    [cellData.didSelectTarget performSelector:cellData.didSelectAction withObject:cellData];
    EndIgnorePerformSelectorLeaksWarning
  }
  
  // 2、处理点击状态（对checkmark类型的cell，选中后自动反选）
  if (cellData.accessoryType == UIStaticTableViewCellAccessoryTypeCheckmark) {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

- (void)accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  UIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
  if ([cellData.accessoryTarget respondsToSelector:cellData.accessoryAction]) {
    BeginIgnorePerformSelectorLeaksWarning
    [cellData.accessoryTarget performSelector:cellData.accessoryAction withObject:cellData];
    EndIgnorePerformSelectorLeaksWarning
  }
}

@end

