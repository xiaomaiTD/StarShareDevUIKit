//
//  UINavigationTitleView.m
//  Project
//
//  Created by jearoc on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UINavigationTitleView.h"
#import "UIExtensions.h"
#import "UICore.h"

@interface UINavigationBar (TitleView)
@end

@implementation UINavigationBar (TitleView)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod([self class], @selector(layoutSubviews), @selector(titleView_navigationBarLayoutSubviews));
  });
}

- (void)titleView_navigationBarLayoutSubviews {
  UINavigationTitleView *titleView = (UINavigationTitleView *)self.topItem.titleView;
  
  if ([titleView isKindOfClass:[UINavigationTitleView class]]) {
    CGFloat titleViewMaximumWidth = CGRectGetWidth(titleView.bounds);
    CGSize titleViewSize = [titleView sizeThatFits:CGSizeMake(titleViewMaximumWidth, CGFLOAT_MAX)];
    titleViewSize.height = ceil(titleViewSize.height);
    
    if (CGRectGetHeight(titleView.bounds) != titleViewSize.height) {
      CGFloat titleViewMinY = flat(CGRectGetMinY(titleView.frame) - ((titleViewSize.height - CGRectGetHeight(titleView.bounds)) / 2.0));
      titleView.frame = CGRectMake(CGRectGetMinX(titleView.frame), titleViewMinY, fmin(titleViewMaximumWidth, titleViewSize.width), titleViewSize.height);
    }
    
    // iOS 11 之后（iOS 11 Beta 5 测试过） titleView 的布局发生了一些变化，如果不主动设置宽度，titleView 里的内容就可能无法完整展示
    if (@available(iOS 11,*)) {
      if (CGRectGetWidth(titleView.bounds) != titleViewSize.width) {
        titleView.frame = CGRectSetWidth(titleView.frame, titleViewSize.width);
      }
    }
  } else {
    titleView = nil;
  }
  [self titleView_navigationBarLayoutSubviews];
  
  if (titleView) {
    //NSLog(@"【%@】系统布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView);
  }
}

@end

@interface UINavigationTitleView ()
@property(nonatomic, assign) CGSize titleLabelSize;
@property(nonatomic, assign) CGSize subtitleLabelSize;
@end

@implementation UINavigationTitleView

-(instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self addTarget:self action:@selector(handleTouchTitleViewEvent) forControlEvents:UIControlEventTouchUpInside];
    _titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.titleLabel];
    
    _subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.subtitleLabel];
    
    self.userInteractionEnabled = NO;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.needsLoadingView = NO;
    self.loadingViewHidden = YES;
    self.needsLoadingPlaceholderSpace = YES;
    
    UINavigationTitleView *appearance = [UINavigationTitleView appearance];
    self.loadingViewSize = appearance.loadingViewSize;
    self.loadingViewMarginRight = appearance.loadingViewMarginRight;
    self.titleFont = appearance.titleFont;
    self.subtitleFont = appearance.subtitleFont;
    self.tintColor = NavBarTitleColor;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@, title = %@, subtitle = %@", [super description], self.title, self.subtitle];
}

#pragma mark - 布局

- (void)refreshLayout {
  UINavigationBar *navigationBar = [self navigationBarSuperviewForSubview:self];
  if (navigationBar) {
    [navigationBar setNeedsLayout];
  }
  [self setNeedsLayout];
}

// 找到 titleView 所在的 navigationBar（iOS 11 及以后，titleView.superview.superview == navigationBar，iOS 10 及以前，titleView.superview == navigationBar）
- (UINavigationBar *)navigationBarSuperviewForSubview:(UIView *)subview {
  if (!subview.superview) {
    return nil;
  }
  
  if ([subview.superview isKindOfClass:[UINavigationBar class]]) {
    return (UINavigationBar *)subview.superview;
  }
  
  return [self navigationBarSuperviewForSubview:subview.superview];
}

- (void)updateTitleLabelSize {
  if (self.titleLabel.text.length > 0) {
    self.titleLabelSize = CGSizeCeil([self.titleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)]);
  } else {
    self.titleLabelSize = CGSizeZero;
  }
}

- (void)updateSubtitleLabelSize {
  if (self.subtitleLabel.text.length > 0) {
    self.subtitleLabelSize = CGSizeCeil([self.subtitleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)]);
  } else {
    self.subtitleLabelSize = CGSizeZero;
  }
}

- (CGSize)loadingViewSpacingSize {
  if (self.needsLoadingView) {
    return CGSizeMake(self.loadingViewSize.width + self.loadingViewMarginRight, self.loadingViewSize.height);
  }
  return CGSizeZero;
}

- (CGSize)loadingViewSpacingSizeIfNeedsPlaceholder {
  return CGSizeMake([self loadingViewSpacingSize].width * (self.needsLoadingPlaceholderSpace ? 2 : 1), [self loadingViewSpacingSize].height);
}

- (UIEdgeInsets)titleEdgeInsetsIfShowingTitleLabel {
  return CGSizeIsEmpty(self.titleLabelSize) ? UIEdgeInsetsZero : self.titleEdgeInsets;
}

- (UIEdgeInsets)subtitleEdgeInsetsIfShowingSubtitleLabel {
  return CGSizeIsEmpty(self.subtitleLabelSize) ? UIEdgeInsetsZero : self.subtitleEdgeInsets;
}

- (CGSize)contentSize {
  CGSize size = CGSizeZero;
  CGFloat firstLineWidth = self.titleLabelSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsetsIfShowingTitleLabel);
  firstLineWidth += [self loadingViewSpacingSizeIfNeedsPlaceholder].width;
  CGFloat secondLineWidth = self.subtitleLabelSize.width + UIEdgeInsetsGetHorizontalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel);
  size.width = fmax(firstLineWidth, secondLineWidth);
  size.height = self.titleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsetsIfShowingTitleLabel) + self.subtitleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel);
  return CGSizeFlatted(size);
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize resultSize = [self contentSize];
  return resultSize;
}

- (void)layoutSubviews {
  
  if (CGSizeIsEmpty(self.bounds.size)) {
    NSLog(@"%@, layoutSubviews, size = %@", NSStringFromClass([self class]), NSStringFromCGSize(self.bounds.size));
    return;
  }
  
  [super layoutSubviews];
  
  BOOL alignLeft = self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft;
  BOOL alignRight = self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight;
  
  // 通过sizeThatFit计算出来的size，如果大于可使用的最大宽度，则会被系统改为最大限制的最大宽度
  CGSize maxSize = self.bounds.size;
  
  // 实际内容的size，小于等于maxSize
  CGSize contentSize = [self contentSize];
  contentSize.width = fmin(maxSize.width, contentSize.width);
  contentSize.height = fmin(maxSize.height, contentSize.height);
  
  // 计算左右两边的偏移值
  CGFloat offsetLeft = 0;
  CGFloat offsetRight = 0;
  if (alignLeft) {
    offsetLeft = 0;
    offsetRight = maxSize.width - contentSize.width;
  } else if (alignRight) {
    offsetLeft = maxSize.width - contentSize.width;
    offsetRight = 0;
  } else {
    offsetLeft = offsetRight = floorInPixel((maxSize.width - contentSize.width) / 2.0);
  }
  
  // 计算loading占的单边宽度
  CGFloat loadingViewSpace = [self loadingViewSpacingSize].width;
  
  BOOL isTitleLabelShowing = self.titleLabel.text.length > 0;
  BOOL isSubtitleLabelShowing = self.subtitleLabel.text.length > 0;
  UIEdgeInsets titleEdgeInsets = self.titleEdgeInsetsIfShowingTitleLabel;
  UIEdgeInsets subtitleEdgeInsets = self.subtitleEdgeInsetsIfShowingSubtitleLabel;
  
  CGFloat minX = offsetLeft;
  CGFloat maxX = maxSize.width - offsetRight - (self.needsLoadingPlaceholderSpace ? loadingViewSpace : 0);
  
  if (self.loadingView) {
    self.loadingView.frame = CGRectSetXY(self.loadingView.frame, minX, CGFloatGetCenter(self.titleLabelSize.height, self.loadingViewSize.height) + titleEdgeInsets.top);
    minX = CGRectGetMaxX(self.loadingView.frame) + self.loadingViewMarginRight;
  }
  if (isTitleLabelShowing) {
    minX += titleEdgeInsets.left;
    maxX -= titleEdgeInsets.right;
    self.titleLabel.frame = CGRectFlatMake(minX, titleEdgeInsets.top, maxX - minX, self.titleLabelSize.height);
  } else {
    self.titleLabel.frame = CGRectZero;
  }
  if (isSubtitleLabelShowing) {
    self.subtitleLabel.frame = CGRectFlatMake(subtitleEdgeInsets.left, (isTitleLabelShowing ? CGRectGetMaxY(self.titleLabel.frame) + titleEdgeInsets.bottom : 0) + subtitleEdgeInsets.top, maxSize.width - UIEdgeInsetsGetHorizontalValue(subtitleEdgeInsets), self.subtitleLabelSize.height);
  } else {
    self.subtitleLabel.frame = CGRectZero;
  }
}

#pragma mark - setter / getter
- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
  [super setContentHorizontalAlignment:contentHorizontalAlignment];
  [self refreshLayout];
  
}
- (void)setNeedsLoadingPlaceholderSpace:(BOOL)needsLoadingPlaceholderSpace {
  _needsLoadingPlaceholderSpace = needsLoadingPlaceholderSpace;
  [self refreshLayout];
  
}
- (void)setLoadingViewMarginRight:(CGFloat)loadingViewMarginRight {
  _loadingViewMarginRight = loadingViewMarginRight;
  [self refreshLayout];
  
}
- (void)setTitleFont:(UIFont *)titleFont {
  _titleFont = titleFont;
  self.titleLabel.font = titleFont;
  [self updateTitleLabelSize];
  [self refreshLayout];
}
- (void)setSubtitleFont:(UIFont *)subtitleFont {
  _subtitleFont = subtitleFont;
  self.subtitleLabel.font = subtitleFont;
  [self updateSubtitleLabelSize];
  [self refreshLayout];
}
- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
  _titleEdgeInsets = titleEdgeInsets;
  [self refreshLayout];
}
- (void)setSubtitleEdgeInsets:(UIEdgeInsets)subtitleEdgeInsets {
  _subtitleEdgeInsets = subtitleEdgeInsets;
  [self refreshLayout];
}
- (void)setTitle:(NSString *)title {
  _title = title;
  self.titleLabel.text = title;
  [self updateTitleLabelSize];
  [self refreshLayout];
}
- (void)setSubtitle:(NSString *)subtitle {
  _subtitle = subtitle;
  self.subtitleLabel.text = subtitle;
  [self updateSubtitleLabelSize];
  [self refreshLayout];
}
- (void)setNeedsLoadingView:(BOOL)needsLoadingView {
  _needsLoadingView = needsLoadingView;
  if (needsLoadingView) {
    if (!self.loadingView) {
      _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:NavBarActivityIndicatorViewStyle];
      CGSize initialSize = _loadingView.bounds.size;
      CGFloat scale = self.loadingViewSize.width / initialSize.width;
      _loadingView.transform = CGAffineTransformMakeScale(scale, scale);
      self.loadingView.color = self.tintColor;
      [self.loadingView stopAnimating];
      [self addSubview:self.loadingView];
    }
  } else {
    if (self.loadingView) {
      [self.loadingView stopAnimating];
      [self.loadingView removeFromSuperview];
      _loadingView = nil;
    }
  }
  [self refreshLayout];
}
- (void)setLoadingViewHidden:(BOOL)loadingViewHidden {
  _loadingViewHidden = loadingViewHidden;
  if (self.needsLoadingView) {
    loadingViewHidden ? [self.loadingView stopAnimating] : [self.loadingView startAnimating];
  }
  [self refreshLayout];
}

#pragma mark - Style & Type

- (void)tintColorDidChange {
  [super tintColorDidChange];
  
  UIColor *color = self.tintColor;
  self.titleLabel.textColor = color;
  self.subtitleLabel.textColor = color;
  self.loadingView.color = color;
}

#pragma mark - Events

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  self.alpha = highlighted ? UIControlHighlightedAlpha : 1;
}

- (void)handleTouchTitleViewEvent {
  if ([self.delegate respondsToSelector:@selector(didTouchTitleView:)]) {
    [self.delegate didTouchTitleView:self];
  }
  [self refreshLayout];
}
@end

@interface UINavigationTitleView (UIAppearance)
@end

@implementation UINavigationTitleView (UIAppearance)

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self setDefaultAppearance];
  });
}

+ (void)setDefaultAppearance {
  UINavigationTitleView *appearance = [UINavigationTitleView appearance];
  appearance.loadingViewSize = CGSizeMake(18, 18);
  appearance.loadingViewMarginRight = 3;
  appearance.titleFont = NavBarTitleFont;
  appearance.subtitleFont = NavBarTitleFont;
  appearance.titleEdgeInsets = UIEdgeInsetsZero;
  appearance.subtitleEdgeInsets = UIEdgeInsetsZero;
}

@end
