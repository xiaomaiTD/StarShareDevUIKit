//
//  UITableView+UIStaticCell.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UITableView+UIStaticCell.h"
#import "UICore.h"
#import "UIStaticTableViewCellDataSource.h"
#import <objc/runtime.h>

@interface UIStaticTableViewCellDataSource ()
@property(nonatomic, weak, readwrite) UITableView *tableView;
@end

@implementation UITableView (UIStaticCell)

+ (void)load {
  ReplaceMethod([UITableView class], @selector(setDataSource:), @selector(staticCell_setDataSource:));
  ReplaceMethod([UITableView class], @selector(setDelegate:), @selector(staticCell_setDelegate:));
}

static char kAssociatedObjectKey_staticCellDataSource;
- (void)setStaticCellDataSource:(UIStaticTableViewCellDataSource *)staticCellDataSource {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_staticCellDataSource, staticCellDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  staticCellDataSource.tableView = self;
  [self reloadData];
}

- (UIStaticTableViewCellDataSource *)staticCellDataSource {
  return (UIStaticTableViewCellDataSource *)objc_getAssociatedObject(self, &kAssociatedObjectKey_staticCellDataSource);
}

// 把那些已经手动 addMethod 过的 class 存起来，避免每次都触发 UILog，打了一堆重复的信息
static NSMutableSet<NSString *> *staticTableViewAddedClass;

- (void)addSelector:(SEL)selector withImplementation:(IMP)implementation types:(const char *)types forObject:(NSObject *)object {
  if (!class_addMethod(object.class, selector, implementation, types)) {
    if (!staticTableViewAddedClass) {
      staticTableViewAddedClass = [[NSMutableSet alloc] init];
    }
    NSString *identifier = [NSString stringWithFormat:@"%@%@", NSStringFromClass(object.class), NSStringFromSelector(selector)];
    if (![staticTableViewAddedClass containsObject:identifier]) {
      SSUILog(@"%@, 尝试为 %@ 添加方法 %@ 失败，可能该类里已经实现了这个方法", NSStringFromClass(self.class), NSStringFromClass(object.class), NSStringFromSelector(selector));
      [staticTableViewAddedClass addObject:identifier];
    }
  }
}

#pragma mark - DataSource

NSInteger staticCell_numberOfSections (id current_self, SEL current_cmd, UITableView *tableView) {
  return tableView.staticCellDataSource.cellDataSections.count;
}

NSInteger staticCell_numberOfRows (id current_self, SEL current_cmd, UITableView *tableView, NSInteger section) {
  return tableView.staticCellDataSource.cellDataSections[section].count;
}

id staticCell_cellForRow (id current_self, SEL current_cmd, UITableView *tableView, NSIndexPath *indexPath) {
  SSUITableCell *cell = [tableView.staticCellDataSource cellForRowAtIndexPath:indexPath];
  return cell;
}

- (void)staticCell_setDataSource:(id<UITableViewDataSource>)dataSource {
  if (dataSource && self.staticCellDataSource) {
    // 这些 addMethod 的操作必须要在系统的 setDataSource 执行前就执行，否则 tableView 可能会认为不存在这些 method
    // 并且 addMethod 操作执行一次之后，直到 App 进程被杀死前都会生效，所以多次进入这段代码可能就会提示添加方法失败，请不用在意
    [self addSelector:@selector(numberOfSectionsInTableView:) withImplementation:(IMP)staticCell_numberOfSections types:"l@:@" forObject:dataSource];
    [self addSelector:@selector(tableView:numberOfRowsInSection:) withImplementation:(IMP)staticCell_numberOfRows types:"l@:@l" forObject:dataSource];
    [self addSelector:@selector(tableView:cellForRowAtIndexPath:) withImplementation:(IMP)staticCell_cellForRow types:"@@:@@" forObject:dataSource];
  }
  
  [self staticCell_setDataSource:dataSource];
}

#pragma mark - Delegate

CGFloat staticCell_heightForRow (id current_self, SEL current_cmd, UITableView *tableView, NSIndexPath *indexPath) {
  return [tableView.staticCellDataSource heightForRowAtIndexPath:indexPath];
}

void staticCell_didSelectRow (id current_self, SEL current_cmd, UITableView *tableView, NSIndexPath *indexPath) {
  [tableView.staticCellDataSource didSelectRowAtIndexPath:indexPath];
}

void staticCell_accessoryButtonTapped (id current_self, SEL current_cmd, UITableView *tableView, NSIndexPath *indexPath) {
  [tableView.staticCellDataSource accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)staticCell_setDelegate:(id<UITableViewDelegate>)delegate {
  if (delegate && self.staticCellDataSource) {
    // 这些 addMethod 的操作必须要在系统的 setDataSource 执行前就执行，否则 tableView 可能会认为不存在这些 method
    // 并且 addMethod 操作执行一次之后，直到 App 进程被杀死前都会生效，所以多次进入这段代码可能就会提示添加方法失败，请不用在意
    [self addSelector:@selector(tableView:heightForRowAtIndexPath:) withImplementation:(IMP)staticCell_heightForRow types:"d@:@@" forObject:delegate];
    [self addSelector:@selector(tableView:didSelectRowAtIndexPath:) withImplementation:(IMP)staticCell_didSelectRow types:"v@:@@" forObject:delegate];
    [self addSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:) withImplementation:(IMP)staticCell_accessoryButtonTapped types:"v@:@@" forObject:delegate];
  }
  
  [self staticCell_setDelegate:delegate];
}

@end
