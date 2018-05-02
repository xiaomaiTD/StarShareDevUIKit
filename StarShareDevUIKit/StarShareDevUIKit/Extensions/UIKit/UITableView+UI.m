//
//  UITableView+UI.m
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UITableView+UI.h"
#import "UICore.h"
#import "UIScrollView+UI.h"

@implementation UITableView (UI)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod([self class], @selector(initWithFrame:style:), @selector(ss_initWithFrame:style:));
    ReplaceMethod([self class], @selector(sizeThatFits:), @selector(ss_sizeThatFits:));
  });
}

- (instancetype)ss_initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
  [self ss_initWithFrame:frame style:style];
  
  // iOS 11 之后 estimatedRowHeight 如果值为 UITableViewAutomaticDimension，estimate 效果也会生效（iOS 11 以前要 > 0 才会生效）。
  // 而当使用 estimate 效果时，会导致 contentSize 之类的计算不准确，所以这里给一个途径让项目可以方便地控制 SSUITableView（及其子类） 和 UITableView（不包含子类，例如 UIPickerTableView）的 estimatedRowHeight 效果的开关
  if ([self isKindOfClass:NSClassFromString(@"SSUITableView")] || [NSStringFromClass(self.class) isEqualToString:@"UITableView"]) {
    if (TableViewEstimatedHeightEnabled) {
      self.estimatedRowHeight = TableViewCellNormalHeight;
      self.estimatedSectionHeaderHeight = TableViewCellNormalHeight;
      self.estimatedSectionFooterHeight = TableViewCellNormalHeight;
    } else {
      self.estimatedRowHeight = 0;
      self.estimatedSectionHeaderHeight = 0;
      self.estimatedSectionFooterHeight = 0;
    }
  }
  return self;
}

- (CGSize)ss_sizeThatFits:(CGSize)size {
  [self alertEstimatedHeightUsageIfDetected];
  CGSize result = [self ss_sizeThatFits:size];
  return result;
}

- (void)renderGlobalStyle {
  
  self.rowHeight = TableViewCellNormalHeight;
  
  UIColor *backgroundColor = nil;
  if (self.style == UITableViewStylePlain) {
    ///< 去掉空白的cell
    backgroundColor = TableViewBackgroundColor;
    self.tableFooterView = [[UIView alloc] init];
  } else {
    backgroundColor = TableViewGroupedBackgroundColor;
  }
  if (backgroundColor) {
    self.backgroundColor = backgroundColor;
  }
  ///< 设置一个空的 backgroundView，去掉系统的，以使 backgroundColor 生效
  self.separatorColor = TableViewSeparatorColor;
  self.backgroundView = [[UIView alloc] init];
  self.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  self.sectionIndexColor = TableSectionIndexColor;
  self.sectionIndexTrackingBackgroundColor = TableSectionIndexTrackingBackgroundColor;
  self.sectionIndexBackgroundColor = TableSectionIndexBackgroundColor;
}

- (NSIndexPath *)indexPathForRowAtView:(UIView *)view {
  if (!view || !view.superview) {
    return nil;
  }
  
  if ([view isKindOfClass:[UITableViewCell class]] && ([NSStringFromClass(view.superview.class) isEqualToString:@"UITableViewWrapperView"] ? view.superview.superview : view.superview) == self) {
    // iOS 11 下，cell.superview 是 UITableView，iOS 11 以前，cell.superview 是 UITableViewWrapperView
    return [self indexPathForCell:(UITableViewCell *)view];
  }
  
  return [self indexPathForRowAtView:view.superview];
}

- (NSInteger)indexForSectionHeaderAtView:(UIView *)view {
  [self alertEstimatedHeightUsageIfDetected];
  
  if (!view || ![view isKindOfClass:[UIView class]]) {
    return -1;
  }
  
  CGPoint origin = [self convertPoint:view.frame.origin fromView:view.superview];
  origin = CGPointToFixed(origin, 4);
  
  NSUInteger numberOfSection = [self numberOfSections];
  for (NSInteger i = numberOfSection - 1; i >= 0; i--) {
    ///< 这个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect，所以要自行区分 headerView 是否被停靠在顶部
    CGRect rectForHeader = [self rectForHeaderInSection:i];
    BOOL isHeaderViewPinToTop = self.style == UITableViewStylePlain && (CGRectGetMinY(rectForHeader) - self.contentOffset.y < self.contentInset.top);
    if (isHeaderViewPinToTop) {
      rectForHeader = CGRectSetY(rectForHeader, CGRectGetMinY(rectForHeader) + (self.contentInset.top - CGRectGetMinY(rectForHeader) + self.contentOffset.y));
    }
    
    rectForHeader = CGRectToFixed(rectForHeader, 4);
    if (CGRectContainsPoint(rectForHeader, origin)) {
      return i;
    }
  }
  return -1;
}

- (UITableCellScenePosition)positionForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger numberOfRowsInSection = [self.dataSource tableView:self numberOfRowsInSection:indexPath.section];
  if (numberOfRowsInSection == 1) {
    return UITableCellScenePositionSingleInSection;
  }
  if (indexPath.row == 0) {
    return UITableCellScenePositionFirstInSection;
  }
  if (indexPath.row == numberOfRowsInSection - 1) {
    return UITableCellScenePositionLastInSection;
  }
  return UITableCellScenePositionMiddleInSection;
}

- (BOOL)cellVisibleAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *visibleCellIndexPaths = self.indexPathsForVisibleRows;
  for (NSIndexPath *visibleIndexPath in visibleCellIndexPaths) {
    if ([indexPath isEqual:visibleIndexPath]) {
      return YES;
    }
  }
  return NO;
}

- (void)clearsSelection {
  NSArray *selectedIndexPaths = [self indexPathsForSelectedRows];
  for (NSIndexPath *indexPath in selectedIndexPaths) {
    [self deselectRowAtIndexPath:indexPath animated:YES];
  }
}

- (void)scrollToRowFittingOffsetY:(CGFloat)offsetY atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
  [self alertEstimatedHeightUsageIfDetected];
  
  if (![self canScroll]) {
    return;
  }
  
  CGRect rectForRow = [self rectForRowAtIndexPath:indexPath];
  
  // 如果要滚到的row在列表尾部，则这个row是不可能滚到顶部的（因为列表尾部已经不够空间了），所以要判断一下
  BOOL canScrollRowToTop = CGRectGetMaxY(rectForRow) + CGRectGetHeight(self.frame) - (offsetY + CGRectGetHeight(rectForRow)) <= self.contentSize.height;
  if (canScrollRowToTop) {
    [self setContentOffset:CGPointMake(self.contentOffset.x, CGRectGetMinY(rectForRow) - offsetY) animated:animated];
  } else {
    if ([self canScroll]) {
      [self scrollToBottomAnimated:animated];
    }
  }
}

- (CGSize)realContentSize {
  [self alertEstimatedHeightUsageIfDetected];
  
  if (!self.dataSource || !self.delegate) {
    return CGSizeZero;
  }
  
  CGSize contentSize = self.contentSize;
  CGFloat footerViewMaxY = CGRectGetMaxY(self.tableFooterView.frame);
  CGSize realContentSize = CGSizeMake(contentSize.width, footerViewMaxY);
  
  NSInteger lastSection = [self numberOfSections] - 1;
  if (lastSection < 0) {
    ///< 说明numberOfSetions为0，tableView没有cell，则直接取footerView的底边缘
    return realContentSize;
  }
  
  CGRect lastSectionRect = [self rectForSection:lastSection];
  realContentSize.height = fmax(realContentSize.height, CGRectGetMaxY(lastSectionRect));
  return realContentSize;
}

- (BOOL)canScroll {
  // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
  if (CGRectGetHeight(self.bounds) <= 0) {
    return NO;
  }
  
  if ([self.tableHeaderView isKindOfClass:[UISearchBar class]]) {
    BOOL canScroll = self.realContentSize.height + UIEdgeInsetsGetVerticalValue(self.contentInset) > CGRectGetHeight(self.bounds);
    return canScroll;
  } else {
    return [super canScroll];
  }
}

- (void)alertEstimatedHeightUsageIfDetected {
  BOOL usingEstimatedRowHeight = self.estimatedRowHeight == UITableViewAutomaticDimension;
  BOOL usingEstimatedSectionHeaderHeight = self.estimatedSectionHeaderHeight == UITableViewAutomaticDimension;
  BOOL usingEstimatedSectionFooterHeight = self.estimatedSectionFooterHeight == UITableViewAutomaticDimension;
  
  if (usingEstimatedRowHeight || usingEstimatedSectionHeaderHeight || usingEstimatedSectionFooterHeight) {
    [self UISymbolicUsingTableViewEstimatedHeightMakeWarning];
  }
}

- (void)UISymbolicUsingTableViewEstimatedHeightMakeWarning {
  NSLog(@"UITableView 的 estimatedRow(SectionHeader / SectionFooter)Height 属性会影响 contentSize、sizeThatFits:、rectForXxx 等方法的计算，导致计算结果不准确，建议重新考虑是否要使用 estimated。可添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

@end
