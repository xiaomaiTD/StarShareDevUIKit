//
//  UITableView+UI.h
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UITableCellScenePosition) {
  UITableCellScenePositionNone = -1, // 初始化用
  UITableCellScenePositionFirstInSection,
  UITableCellScenePositionMiddleInSection,
  UITableCellScenePositionLastInSection,
  UITableCellScenePositionSingleInSection,
  UITableCellScenePositionNormal,
};

@interface UITableView (UI)
- (void)renderGlobalStyle;
- (NSIndexPath *)indexPathForRowAtView:(UIView *)view;
- (NSInteger)indexForSectionHeaderAtView:(UIView *)view;
- (UITableCellScenePosition)positionForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)cellVisibleAtIndexPath:(NSIndexPath *)indexPath;
- (void)clearsSelection;
///< 将指定的row滚到指定的位置（row的顶边缘和指定位置重叠），并对一些特殊情况做保护（例如列表内容不够一屏、要滚动的row是最后一条等）
- (void)scrollToRowFittingOffsetY:(CGFloat)offsetY atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
@property(nonatomic, assign, readonly) CGSize realContentSize;
- (BOOL)canScroll;
@end
