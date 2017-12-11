//
//  SSUIMenuView.h
//  StarShare_iOS
//
//  Created by BUBUKO on 2017/12/10.
//  Copyright © 2017年 Rui Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSUIMenuNode.h"
#import "SSUIMenuPointer.h"
#import "SSUIMenuScrollView.h"

typedef NS_ENUM(NSUInteger, SSUIMenuViewStyle) {
  SSUIMenuViewStyleDefault,      // 默认
  SSUIMenuViewStyleLine,         // 带下划线 (若要选中字体大小不变，设置选中和非选中大小一样即可)
  SSUIMenuViewStyleTriangle,     // 三角形 (progressHeight 为三角形的高, progressWidths 为底边长)
  SSUIMenuViewStyleFlood,        // 涌入效果 (填充)
  SSUIMenuViewStyleFloodHollow,  // 涌入效果 (空心的)
  SSUIMenuViewStyleSegmented,    // 涌入带边框,即网易新闻选项卡
};

typedef NS_ENUM(NSUInteger, SSUIMenuViewLayoutMode) {
  SSUIMenuViewLayoutModeScatter, // 默认的布局模式, item 会均匀分布在屏幕上，呈分散状
  SSUIMenuViewLayoutModeLeft,    // Item 紧靠屏幕左侧
  SSUIMenuViewLayoutModeRight,   // Item 紧靠屏幕右侧
  SSUIMenuViewLayoutModeCenter,  // Item 紧挨且居中分布
};

@protocol SSUIMenuViewDelegate;
@protocol SSUIMenuViewDataSource;

@interface SSUIMenuView : UIView <SSUIMenuNodeDelegate>

@property (nonatomic, strong) NSArray *pointerWidths;
@property (nonatomic, weak) SSUIMenuPointer *pointer;
@property (nonatomic, assign) CGFloat pointerHeight;
@property (nonatomic, assign) SSUIMenuViewStyle style;
@property (nonatomic, assign) SSUIMenuViewLayoutMode layoutMode;
@property (nonatomic, assign) CGFloat contentMargin;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat pointerBottomSpace;
@property (nonatomic, weak) id<SSUIMenuViewDelegate> delegate;
@property (nonatomic, weak) id<SSUIMenuViewDataSource> dataSource;
@property (nonatomic, weak) UIView *leftView;
@property (nonatomic, weak) UIView *rightView;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat speedFactor;
@property (nonatomic, assign) CGFloat pointerCornerRadius;
@property (nonatomic, assign) BOOL pointerIsNaughty;
@property (nonatomic, assign) BOOL showOnNavigationBar;

- (void)slideMenuAtProgress:(CGFloat)progress;
- (void)selectItemAtIndex:(NSInteger)index;
- (void)resetFrames;
- (void)reload;
- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index andWidth:(BOOL)update;
- (void)updateAttributeTitle:(NSAttributedString *)title atIndex:(NSInteger)index andWidth:(BOOL)update;
- (SSUIMenuNode *)itemAtIndex:(NSInteger)index;
- (void)refreshContenOffset;
- (void)deselectedItemsIfNeeded;
- (void)updateBadgeViewAtIndex:(NSInteger)index;
@end

@protocol SSUIMenuViewDelegate <NSObject>
@optional
- (BOOL)menuView:(SSUIMenuView *)menu shouldSelesctedIndex:(NSInteger)index;
- (void)menuView:(SSUIMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex;
- (CGFloat)menuView:(SSUIMenuView *)menu widthForNodeAtIndex:(NSInteger)index;
- (CGFloat)menuView:(SSUIMenuView *)menu nodeMarginAtIndex:(NSInteger)index;
- (CGFloat)menuView:(SSUIMenuView *)menu titleSizeForState:(SSUIMenuNodeState)state atIndex:(NSInteger)index;
- (UIColor *)menuView:(SSUIMenuView *)menu titleColorForState:(SSUIMenuNodeState)state atIndex:(NSInteger)index;
- (void)menuView:(SSUIMenuView *)menu didLayoutNodeFrame:(SSUIMenuNode *)menuNode atIndex:(NSInteger)index;
@end

@protocol SSUIMenuViewDataSource <NSObject>
@required
- (NSInteger)numbersOfTitlesInMenuView:(SSUIMenuView *)menu;
- (NSString *)menuView:(SSUIMenuView *)menu titleAtIndex:(NSInteger)index;
@optional
- (UIView *)menuView:(SSUIMenuView *)menu badgeViewAtIndex:(NSInteger)index;
- (SSUIMenuNode *)menuView:(SSUIMenuView *)menu initialMenuNode:(SSUIMenuNode *)initialMenuNode atIndex:(NSInteger)index;
@end
