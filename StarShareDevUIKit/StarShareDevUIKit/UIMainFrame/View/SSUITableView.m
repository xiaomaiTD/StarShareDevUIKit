//
//  SSUITableView.m
//  Project
//
//  Created by jearoc on 2017/9/21.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUITableView.h"
#import "UIExtensions.h"

@implementation SSUITableView

@dynamic delegate;
@dynamic dataSource;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
  if (self = [super initWithFrame:frame style:style]) {
    [self didInitialized];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self didInitialized];
  }
  return self;
}

- (void)didInitialized {
  [self renderGlobalStyle];
}

- (void)dealloc {
  self.delegate = nil;
  self.dataSource = nil;
}

- (void)setTableFooterView:(UIView *)tableFooterView {
  ///< 保证一直存在tableFooterView，以去掉列表内容不满一屏时尾部的空白分割线
  if (!tableFooterView) {
    tableFooterView = [[UIView alloc] init];
  }
  [super setTableFooterView:tableFooterView];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
  if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:touchesShouldCancelInContentView:)]) {
    return [self.delegate tableView:self touchesShouldCancelInContentView:view];
  }
  ///< 默认情况下只有当view是非UIControl的时候才会返回yes，这里统一对UIButton也返回yes
  ///< 原因是UITableView上面把事件延迟去掉了，但是这样如果拖动的时候手指是在UIControl上面的话，就拖动不了了
  if ([view isKindOfClass:[UIControl class]]) {
    if ([view isKindOfClass:[UIButton class]]) {
      return YES;
    } else {
      return NO;
    }
  }
  return YES;
}

#ifdef DEBUG

- (void)setContentOffset:(CGPoint)contentOffset {
  [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
  [super setContentOffset:contentOffset animated:animated];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
  [super setContentInset:contentInset];
}

#endif

@end

@implementation SSUITableView (Style)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = [self class];
    ReplaceMethod(cls, @selector(setSeparatorStyle:), @selector(ss_setSeparatorStyle:));
  });
}

- (void)ss_setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
{
  [self ss_setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

static char SSUITableViewCellSeparatorStyleKey;

- (SSUITableViewCellSeparatorStyle)cellSeparatorStyle{
  id obj = objc_getAssociatedObject(self, &SSUITableViewCellSeparatorStyleKey);
  return obj ? [obj integerValue] : SSUITableViewCellSeparatorStyleNone;
}

- (void)setCellSeparatorStyle:(SSUITableViewCellSeparatorStyle)cellSeparatorStyle {
  objc_setAssociatedObject(self, &SSUITableViewCellSeparatorStyleKey, @(cellSeparatorStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
