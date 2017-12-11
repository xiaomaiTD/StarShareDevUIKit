//
//  SSUIMenuView.m
//  StarShare_iOS
//
//  Created by BUBUKO on 2017/12/10.
//  Copyright © 2017年 Rui Wang. All rights reserved.
//

#import "SSUIMenuView.h"

@interface SSUIMenuView ()

@property (nonatomic, weak) SSUIMenuNode *selNode;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, readonly) NSInteger titlesCount;
@end

static NSInteger const SSUIMenuNodeTagOffset  = 6250;
static NSInteger const SSUIBadgeViewTagOffset = 1212;

@implementation SSUIMenuView

#pragma mark - Setter

- (void)setLayoutMode:(SSUIMenuViewLayoutMode)layoutMode {
  _layoutMode = layoutMode;
  if (!self.superview) { return; }
  [self reload];
}

- (void)setFrame:(CGRect)frame {
  
  if (@available(iOS 11.0, *)) {
    if (self.showOnNavigationBar) { frame.origin.x = 0; }
  }
  
  [super setFrame:frame];
  
  if (!self.scrollView) { return; }
  
  CGFloat leftMargin = self.contentMargin + self.leftView.frame.size.width;
  CGFloat rightMargin = self.contentMargin + self.rightView.frame.size.width;
  CGFloat contentWidth = self.scrollView.frame.size.width + leftMargin + rightMargin;
  CGFloat startX = self.leftView ? self.leftView.frame.origin.x : self.scrollView.frame.origin.x - self.contentMargin;
  
  if (startX + contentWidth / 2 != self.bounds.size.width / 2) {
    
    CGFloat xOffset = (self.bounds.size.width - contentWidth) / 2;
    self.leftView.frame = ({
      CGRect frame = self.leftView.frame;
      frame.origin.x = xOffset;
      frame;
    });
    
    self.scrollView.frame = ({
      CGRect frame = self.scrollView.frame;
      frame.origin.x = self.leftView ? CGRectGetMaxX(self.leftView.frame) + self.contentMargin : xOffset;
      frame;
    });
    
    self.rightView.frame = ({
      CGRect frame = self.rightView.frame;
      frame.origin.x = CGRectGetMaxX(self.scrollView.frame) + self.contentMargin;
      frame;
    });
  }
}

- (void)setPointerCornerRadius:(CGFloat)pointerCornerRadius {
  _pointerCornerRadius = pointerCornerRadius;
  if (self.pointer) {
    self.pointer.cornerRadius = _pointerCornerRadius;
  }
}

- (void)setSpeedFactor:(CGFloat)speedFactor {
  _speedFactor = speedFactor;
  if (self.pointer) {
    self.pointer.speedFactor = _speedFactor;
  }
  
  [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj isKindOfClass:[SSUIMenuNode class]]) {
      ((SSUIMenuNode *)obj).speedFactor = _speedFactor;
    }
  }];
}

- (void)setPointerWidths:(NSArray *)pointerWidths {
  _pointerWidths = pointerWidths;
  
  if (!self.pointer.superview) { return; }
  
  [self resetFramesFromIndex:0];
}

- (void)setLeftView:(UIView *)leftView {
  if (self.leftView) {
    [self.leftView removeFromSuperview];
    _leftView = nil;
  }
  if (leftView) {
    [self addSubview:leftView];
    _leftView = leftView;
  }
  [self resetFrames];
}

- (void)setRightView:(UIView *)rightView {
  if (self.rightView) {
    [self.rightView removeFromSuperview];
    _rightView = nil;
  }
  if (rightView) {
    [self addSubview:rightView];
    _rightView = rightView;
  }
  [self resetFrames];
}

- (void)setContentMargin:(CGFloat)contentMargin {
  _contentMargin = contentMargin;
  if (self.scrollView) {
    [self resetFrames];
  }
}

#pragma mark - Getter

- (UIColor *)lineColor {
  if (!_lineColor) {
    _lineColor = [self colorForState:SSUIMenuNodeStateSelected atIndex:0];
  }
  return _lineColor;
}

- (NSMutableArray *)frames {
  if (_frames == nil) {
    _frames = [NSMutableArray array];
  }
  return _frames;
}

- (UIColor *)colorForState:(SSUIMenuNodeState)state atIndex:(NSInteger)index {
  if ([self.delegate respondsToSelector:@selector(menuView:titleColorForState:atIndex:)]) {
    return [self.delegate menuView:self titleColorForState:state atIndex:index];
  }
  return [UIColor blackColor];
}

- (CGFloat)sizeForState:(SSUIMenuNodeState)state atIndex:(NSInteger)index {
  if ([self.delegate respondsToSelector:@selector(menuView:titleSizeForState:atIndex:)]) {
    return [self.delegate menuView:self titleSizeForState:state atIndex:index];
  }
  return 15.0;
}

- (UIView *)badgeViewAtIndex:(NSInteger)index {
  if (![self.dataSource respondsToSelector:@selector(menuView:badgeViewAtIndex:)]) {
    return nil;
  }
  UIView *badgeView = [self.dataSource menuView:self badgeViewAtIndex:index];
  if (!badgeView) {
    return nil;
  }
  badgeView.tag = index + SSUIBadgeViewTagOffset;
  
  return badgeView;
}

#pragma mark - Public Methods

- (SSUIMenuNode *)nodeAtIndex:(NSInteger)index {
  return (SSUIMenuNode *)[self viewWithTag:(index + SSUIMenuNodeTagOffset)];
}

- (void)setPointerIsNaughty:(BOOL)pointerIsNaughty {
  _pointerIsNaughty = pointerIsNaughty;
  if (self.pointer) {
    self.pointer.naughty = pointerIsNaughty;
  }
}

- (void)reload {
  [self.frames removeAllObjects];
  [self.pointer removeFromSuperview];
  [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [obj removeFromSuperview];
  }];
  
  [self addNodes];
  [self makeStyle];
  [self addBadgeViews];
}

- (void)slideMenuAtProgress:(CGFloat)progress {
  if (self.pointer) {
    self.pointer.progress = progress;
  }
  NSInteger tag = (NSInteger)progress + SSUIMenuNodeTagOffset;
  CGFloat rate = progress - tag + SSUIMenuNodeTagOffset;
  SSUIMenuNode *currentNode = (SSUIMenuNode *)[self viewWithTag:tag];
  SSUIMenuNode *nextNode = (SSUIMenuNode *)[self viewWithTag:tag+1];
  if (rate == 0.0) {
    [self.selNode setSelected:NO withAnimation:NO];
    self.selNode = currentNode;
    [self.selNode setSelected:YES withAnimation:NO];
    [self refreshContenOffset];
    return;
  }
  currentNode.rate = 1-rate;
  nextNode.rate = rate;
}

- (void)selectNodeAtIndex:(NSInteger)index {
  NSInteger tag = index + SSUIMenuNodeTagOffset;
  NSInteger currentIndex = self.selNode.tag - SSUIMenuNodeTagOffset;
  self.selectIndex = index;
  if (index == currentIndex || !self.selNode) { return; }
  
  SSUIMenuNode *node = (SSUIMenuNode *)[self viewWithTag:tag];
  [self.selNode setSelected:NO withAnimation:NO];
  self.selNode = node;
  [self.selNode setSelected:YES withAnimation:NO];
  [self.pointer setProgressWithOutAnimate:index];
  if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
    [self.delegate menuView:self didSelesctedIndex:index currentIndex:currentIndex];
  }
  [self refreshContenOffset];
}

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index andWidth:(BOOL)update {
  if (index >= self.titlesCount || index < 0) { return; }
  
  SSUIMenuNode *node = (SSUIMenuNode *)[self viewWithTag:(SSUIMenuNodeTagOffset + index)];
  node.text = title;
  if (!update) { return; }
  [self resetFrames];
}

- (void)updateAttributeTitle:(NSAttributedString *)title atIndex:(NSInteger)index andWidth:(BOOL)update {
  if (index >= self.titlesCount || index < 0) { return; }
  
  SSUIMenuNode *node = (SSUIMenuNode *)[self viewWithTag:(SSUIMenuNodeTagOffset + index)];
  node.attributedText = title;
  if (!update) { return; }
  [self resetFrames];
}

- (void)updateBadgeViewAtIndex:(NSInteger)index {
  UIView *oldBadgeView = [self.scrollView viewWithTag:SSUIBadgeViewTagOffset + index];
  if (oldBadgeView) {
    [oldBadgeView removeFromSuperview];
  }
  
  [self addBadgeViewAtIndex:index];
  [self resetBadgeFrame:index];
}

- (void)refreshContenOffset {
  CGRect frame = self.selNode.frame;
  CGFloat itemX = frame.origin.x;
  CGFloat width = self.scrollView.frame.size.width;
  CGSize contentSize = self.scrollView.contentSize;
  if (itemX > width/2) {
    CGFloat targetX;
    if ((contentSize.width-itemX) <= width/2) {
      targetX = contentSize.width - width;
    } else {
      targetX = frame.origin.x - width/2 + frame.size.width/2;
    }
    // 应该有更好的解决方法
    if (targetX + width > contentSize.width) {
      targetX = contentSize.width - width;
    }
    [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
  } else {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
  }
}

#pragma mark - Data source

- (NSInteger)titlesCount {
  return [self.dataSource numbersOfTitlesInMenuView:self];
}

#pragma mark - Private Methods

- (void)willMoveToSuperview:(UIView *)newSuperview {
  [super willMoveToSuperview:newSuperview];
  
  if (self.scrollView) { return; }
  
  [self addScrollView];
  [self addNodes];
  [self makeStyle];
  [self addBadgeViews];
  [self resetSelectionIfNeeded];
}

- (void)resetSelectionIfNeeded {
  if (self.selectIndex == 0) { return; }
  [self selectItemAtIndex:self.selectIndex];
}

- (void)resetFrames {
  CGRect frame = self.bounds;
  if (self.rightView) {
    CGRect rightFrame = self.rightView.frame;
    rightFrame.origin.x = frame.size.width - rightFrame.size.width;
    self.rightView.frame = rightFrame;
    frame.size.width -= rightFrame.size.width;
  }
  
  if (self.leftView) {
    CGRect leftFrame = self.leftView.frame;
    leftFrame.origin.x = 0;
    self.leftView.frame = leftFrame;
    frame.origin.x += leftFrame.size.width;
    frame.size.width -= leftFrame.size.width;
  }
  
  frame.origin.x += self.contentMargin;
  frame.size.width -= self.contentMargin * 2;
  self.scrollView.frame = frame;
  [self resetFramesFromIndex:0];
}

- (void)resetFramesFromIndex:(NSInteger)index {
  [self.frames removeAllObjects];
  [self calculateNodeFrames];
  for (NSInteger i = index; i < self.titlesCount; i++) {
    [self resetNodeFrame:i];
    [self resetBadgeFrame:i];
  }
  if (!self.pointer.superview) { return; }
  CGRect frame = CGRectZero;
  if (self.style == SSUIMenuViewStyleDefault) { return; }
  if (self.style == SSUIMenuViewStyleLine || self.style == SSUIMenuViewStyleTriangle) {
    self.pointerHeight = self.pointerHeight > 0 ? self.pointerHeight : 2.0;
    frame = CGRectMake(0, self.frame.size.height - self.pointerHeight - self.pointerBottomSpace, self.scrollView.contentSize.width, self.pointerHeight);
  } else {
    self.pointerHeight = self.pointerHeight > 0 ? self.pointerHeight : self.frame.size.height * 0.8;
    frame = CGRectMake(0, (self.frame.size.height - self.pointerHeight) / 2, self.scrollView.contentSize.width, self.pointerHeight);
    self.pointerCornerRadius = self.pointerCornerRadius > 0 ? self.pointerCornerRadius : self.pointerHeight / 2.0;
  }
  frame.size.width = self.scrollView.contentSize.width;
  self.pointer.frame = frame;
  self.pointer.cornerRadius = self.pointerCornerRadius;
  self.pointer.itemFrames = [self convertPointerWidthsToFrames];
  [self.pointer setNeedsDisplay];
}

- (void)resetNodeFrame:(NSInteger)index {
  SSUIMenuNode *node = (SSUIMenuNode *)[self viewWithTag:(SSUIMenuNodeTagOffset + index)];
  CGRect frame = [self.frames[index] CGRectValue];
  node.frame = frame;
  if ([self.delegate respondsToSelector:@selector(menuView:didLayoutNodeFrame:atIndex:)]) {
    [self.delegate menuView:self didLayoutNodeFrame:node atIndex:index];
  }
}

- (void)resetBadgeFrame:(NSInteger)index {
  CGRect frame = [self.frames[index] CGRectValue];
  UIView *badgeView = [self.scrollView viewWithTag:(SSUIBadgeViewTagOffset + index)];
  if (badgeView) {
    CGRect badgeFrame = [self badgeViewAtIndex:index].frame;
    badgeFrame.origin.x += frame.origin.x;
    badgeView.frame = badgeFrame;
  }
}

- (NSArray *)convertPointerWidthsToFrames {
  if (!self.frames.count) { NSAssert(NO, @"BUUUUUUUG...SHOULDN'T COME HERE!!"); }
  
  if (self.pointerWidths.count < self.titlesCount) return self.frames;
  
  NSMutableArray *pointerFrames = [NSMutableArray array];
  NSInteger count = (self.frames.count <= self.pointerWidths.count) ? self.frames.count : self.pointerWidths.count;
  for (int i = 0; i < count; i++) {
    CGRect nodeFrame = [self.frames[i] CGRectValue];
    CGFloat pointerWidth = [self.pointerWidths[i] floatValue];
    CGFloat x = nodeFrame.origin.x + (nodeFrame.size.width - pointerWidth) / 2;
    CGRect pointerFrame = CGRectMake(x, nodeFrame.origin.y, pointerWidth, 0);
    [pointerFrames addObject:[NSValue valueWithCGRect:pointerFrame]];
  }
  return pointerFrames.copy;
}

- (void)addBadgeViews {
  for (int i = 0; i < self.titlesCount; i++) {
    [self addBadgeViewAtIndex:i];
  }
}

- (void)addBadgeViewAtIndex:(NSInteger)index {
  UIView *badgeView = [self badgeViewAtIndex:index];
  if (badgeView) {
    [self.scrollView addSubview:badgeView];
  }
}

- (void)makeStyle {
  CGRect frame = CGRectZero;
  if (self.style == SSUIMenuViewStyleDefault) { return; }
  if (self.style == SSUIMenuViewStyleLine) {
    self.pointerHeight = self.pointerHeight > 0 ? self.pointerHeight : 2.0;
    frame = CGRectMake(0, self.frame.size.height - self.pointerHeight - self.pointerBottomSpace, self.scrollView.contentSize.width, self.pointerHeight);
  } else {
    self.pointerHeight = self.pointerHeight > 0 ? self.pointerHeight : self.frame.size.height * 0.8;
    frame = CGRectMake(0, (self.frame.size.height - self.pointerHeight) / 2, self.scrollView.contentSize.width, self.pointerHeight);
    self.pointerCornerRadius = self.pointerCornerRadius > 0 ? self.pointerCornerRadius : self.pointerHeight / 2.0;
  }
  [self addPointerWithFrame:frame
                 isTriangle:(self.style == SSUIMenuViewStyleTriangle)
                  hasBorder:(self.style == SSUIMenuViewStyleSegmented)
                     hollow:(self.style == SSUIMenuViewStyleFloodHollow)
               cornerRadius:self.pointerCornerRadius];
}

- (void)deselectedItemsIfNeeded {
  [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (![obj isKindOfClass:[SSUIMenuNode class]] || obj == self.selNode) { return; }
    [(SSUIMenuNode *)obj setSelected:NO withAnimation:NO];
  }];
}

- (void)addScrollView {
  CGFloat width = self.frame.size.width - self.contentMargin * 2;
  CGFloat height = self.frame.size.height;
  CGRect frame = CGRectMake(self.contentMargin, 0, width, height);
  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator   = NO;
  scrollView.backgroundColor = [UIColor clearColor];
  scrollView.scrollsToTop = NO;
  [self addSubview:scrollView];
  self.scrollView = scrollView;
}

- (void)addNodes {
  [self calculateNodeFrames];
  
  for (int i = 0; i < self.titlesCount; i++) {
    CGRect frame = [self.frames[i] CGRectValue];
    SSUIMenuNode *node = [[SSUIMenuNode alloc] initWithFrame:frame];
    node.tag = (i + SSUIMenuNodeTagOffset);
    node.delegate = self;
    node.text = [self.dataSource menuView:self titleAtIndex:i];
    node.textAlignment = NSTextAlignmentCenter;
    node.userInteractionEnabled = YES;
    node.backgroundColor = [UIColor clearColor];
    node.normalSize    = [self sizeForState:SSUIMenuNodeStateNormal atIndex:i];
    node.selectedSize  = [self sizeForState:SSUIMenuNodeStateSelected atIndex:i];
    node.normalColor   = [self colorForState:SSUIMenuNodeStateNormal atIndex:i];
    node.selectedColor = [self colorForState:SSUIMenuNodeStateSelected atIndex:i];
    node.speedFactor   = self.speedFactor;
    if (self.fontName) {
      node.font = [UIFont fontWithName:self.fontName size:node.selectedSize];
    } else {
      node.font = [UIFont systemFontOfSize:node.selectedSize];
    }
    if ([self.dataSource respondsToSelector:@selector(menuView:initialMenuNode:atIndex:)]) {
      node = [self.dataSource menuView:self initialMenuNode:node atIndex:i];
    }
    if (i == 0) {
      [node setSelected:YES withAnimation:NO];
      self.selNode = node;
    } else {
      [node setSelected:NO withAnimation:NO];
    }
    [self.scrollView addSubview:node];
  }
}

- (void)calculateNodeFrames {
  CGFloat contentWidth = [self nodeMarginAtIndex:0];
  for (int i = 0; i < self.titlesCount; i++) {
    CGFloat nodeW = 60.0;
    if ([self.delegate respondsToSelector:@selector(menuView:widthForNodeAtIndex:)]) {
      nodeW = [self.delegate menuView:self widthForNodeAtIndex:i];
    }
    CGRect frame = CGRectMake(contentWidth, 0, nodeW, self.frame.size.height);
    // 记录frame
    [self.frames addObject:[NSValue valueWithCGRect:frame]];
    contentWidth += nodeW + [self nodeMarginAtIndex:i+1];
  }
  // 如果总宽度小于屏幕宽,重新计算frame,为item间添加间距
  if (contentWidth < self.scrollView.frame.size.width) {
    CGFloat distance = self.scrollView.frame.size.width - contentWidth;
    CGFloat (^shiftDis)(int);
    switch (self.layoutMode) {
      case SSUIMenuViewLayoutModeScatter: {
        CGFloat gap = distance / (self.titlesCount + 1);
        shiftDis = ^CGFloat(int index) { return gap * (index + 1); };
        break;
      }
      case SSUIMenuViewLayoutModeLeft: {
        shiftDis = ^CGFloat(int index) { return 0.0; };
        break;
      }
      case SSUIMenuViewLayoutModeRight: {
        shiftDis = ^CGFloat(int index) { return distance; };
        break;
      }
      case SSUIMenuViewLayoutModeCenter: {
        shiftDis = ^CGFloat(int index) { return distance / 2; };
        break;
      }
    }
    for (int i = 0; i < self.frames.count; i++) {
      CGRect frame = [self.frames[i] CGRectValue];
      frame.origin.x += shiftDis(i);
      self.frames[i] = [NSValue valueWithCGRect:frame];
    }
    contentWidth = self.scrollView.frame.size.width;
  }
  self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

- (CGFloat)nodeMarginAtIndex:(NSInteger)index {
  if ([self.delegate respondsToSelector:@selector(menuView:nodeMarginAtIndex:)]) {
    return [self.delegate menuView:self nodeMarginAtIndex:index];
  }
  return 0.0;
}

- (void)addPointerWithFrame:(CGRect)frame isTriangle:(BOOL)isTriangle hasBorder:(BOOL)hasBorder hollow:(BOOL)isHollow cornerRadius:(CGFloat)cornerRadius {
  SSUIMenuPointer *pView = [[SSUIMenuPointer alloc] initWithFrame:frame];
  pView.itemFrames = [self convertPointerWidthsToFrames];
  pView.color = self.lineColor.CGColor;
  pView.isTriangle = isTriangle;
  pView.hasBorder = hasBorder;
  pView.hollow = isHollow;
  pView.cornerRadius = cornerRadius;
  pView.naughty = self.pointerIsNaughty;
  pView.speedFactor = self.speedFactor;
  pView.backgroundColor = [UIColor clearColor];
  self.pointer = pView;
  [self.scrollView insertSubview:self.pointer atIndex:0];
}

#pragma mark - Menu item delegate
- (void)didPressedMenuNode:(SSUIMenuNode *)menuNode {
  
  if ([self.delegate respondsToSelector:@selector(menuView:shouldSelesctedIndex:)]) {
    BOOL should = [self.delegate menuView:self shouldSelesctedIndex:menuNode.tag - SSUIMenuNodeTagOffset];
    if (!should) {
      return;
    }
  }
  
  CGFloat progress = menuNode.tag - SSUIMenuNodeTagOffset;
  [self.pointer moveToPostion:progress];
  
  NSInteger currentIndex = self.selNode.tag - SSUIMenuNodeTagOffset;
  if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
    [self.delegate menuView:self didSelesctedIndex:menuNode.tag-SSUIMenuNodeTagOffset currentIndex:currentIndex];
  }
  
  [self.selNode setSelected:NO withAnimation:YES];
  [menuNode setSelected:YES withAnimation:YES];
  self.selNode = menuNode;
  
  NSTimeInterval delay = self.style == SSUIMenuViewStyleDefault ? 0 : 0.3f;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // 让选中的item位于中间
    [self refreshContenOffset];
  });
}
@end
