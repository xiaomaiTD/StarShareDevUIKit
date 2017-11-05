//
//  UITabBar+UI.m
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UITabBar+UI.h"
#import "UICore.h"
#import "UITabBarItem+UI.h"

NSInteger const kLastTouchedTabBarItemIndexNone = -1;

@interface UITabBar ()
@property(nonatomic, assign) BOOL canItemRespondDoubleTouch;
@property(nonatomic, assign) NSInteger lastTouchedTabBarItemViewIndex;
@property(nonatomic, assign) NSInteger tabBarItemViewTouchCount;
@end

@implementation UITabBar (UI)
+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod([self class], @selector(setItems:animated:), @selector(ss_setItems:animated:));
    ReplaceMethod([self class], @selector(setSelectedItem:), @selector(ss_setSelectedItem:));
  });
}

- (void)ss_setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated {
  [self ss_setItems:items animated:animated];
  
  for (UITabBarItem *item in items) {
    UIControl *itemView = item.barButton;
    [itemView addTarget:self action:@selector(handleTabBarItemViewEvent:) forControlEvents:UIControlEventTouchUpInside];
  }
}

- (void)ss_setSelectedItem:(UITabBarItem *)selectedItem {
  NSInteger olderSelectedIndex = self.selectedItem ? [self.items indexOfObject:self.selectedItem] : -1;
  [self ss_setSelectedItem:selectedItem];
  NSInteger newerSelectedIndex = [self.items indexOfObject:selectedItem];
  // 只有双击当前正在显示的界面的 tabBarItem，才能正常触发双击事件
  self.canItemRespondDoubleTouch = olderSelectedIndex == newerSelectedIndex;
}

- (void)handleTabBarItemViewEvent:(UIControl *)itemView {
  
  if (!self.canItemRespondDoubleTouch) {
    return;
  }
  
  if (!self.selectedItem.doubleTapBlock && !self.selectedItem.onceTapBlock) {
    return;
  }
  
  // 如果一定时间后仍未触发双击，则废弃当前的点击状态
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self revertTabBarItemTouch];
  });
  
  NSInteger selectedIndex = [self.items indexOfObject:self.selectedItem];
  
  if (self.lastTouchedTabBarItemViewIndex == kLastTouchedTabBarItemIndexNone) {
    // 记录第一次点击的 index
    self.lastTouchedTabBarItemViewIndex = selectedIndex;
  } else if (self.lastTouchedTabBarItemViewIndex != selectedIndex) {
    // 后续的点击如果与第一次点击的 index 不一致，则认为是重新开始一次新的点击
    [self revertTabBarItemTouch];
    UITabBarItem *item = self.items[selectedIndex];
    if (item.onceTapBlock) {
      item.onceTapBlock(item, selectedIndex, self.lastTouchedTabBarItemViewIndex);
    }
    self.lastTouchedTabBarItemViewIndex = selectedIndex;
    return;
  }
  
  self.tabBarItemViewTouchCount ++;
  if (self.tabBarItemViewTouchCount == 2) {
    // 第二次点击了相同的 tabBarItem，触发双击事件
    UITabBarItem *item = self.items[selectedIndex];
    if (item.doubleTapBlock) {
      item.doubleTapBlock(item, selectedIndex);
    }
    [self revertTabBarItemTouch];
  }else if(self.tabBarItemViewTouchCount == 1){
    UITabBarItem *item = self.items[selectedIndex];
    if (item.onceTapBlock) {
      item.onceTapBlock(item, selectedIndex, selectedIndex);
    }
  }
}

- (void)revertTabBarItemTouch {
  self.lastTouchedTabBarItemViewIndex = kLastTouchedTabBarItemIndexNone;
  self.tabBarItemViewTouchCount = 0;
}

#pragma mark - Swizzle Property Getter/Setter

static char kAssociatedObjectKey_canItemRespondDoubleTouch;
- (void)setCanItemRespondDoubleTouch:(BOOL)canItemRespondDoubleTouch {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_canItemRespondDoubleTouch, @(canItemRespondDoubleTouch), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canItemRespondDoubleTouch {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_canItemRespondDoubleTouch)) boolValue];
}

static char kAssociatedObjectKey_lastTouchedTabBarItemViewIndex;
- (void)setLastTouchedTabBarItemViewIndex:(NSInteger)lastTouchedTabBarItemViewIndex {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_lastTouchedTabBarItemViewIndex, @(lastTouchedTabBarItemViewIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)lastTouchedTabBarItemViewIndex {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lastTouchedTabBarItemViewIndex)) integerValue];
}

static char kAssociatedObjectKey_tabBarItemViewTouchCount;
- (void)setTabBarItemViewTouchCount:(NSInteger)tabBarItemViewTouchCount {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_tabBarItemViewTouchCount, @(tabBarItemViewTouchCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tabBarItemViewTouchCount {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_tabBarItemViewTouchCount)) integerValue];
}
@end
