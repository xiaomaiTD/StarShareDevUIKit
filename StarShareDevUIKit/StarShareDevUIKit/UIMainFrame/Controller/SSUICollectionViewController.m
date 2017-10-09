//
//  SSUICollectionViewController.m
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUICollectionViewController.h"
#import "UIExtensions.h"
#import "UICore.h"

const UIEdgeInsets SSUICollectionViewControllerInitialContentInsetNotSet = {-1, -1, -1, -1};

@interface SSUICollectionViewController ()
@property(nonatomic, assign, readwrite) UICollectionViewLayout *layout;
@property(nonatomic, strong, readwrite) SSUICollectionView *collectionView;
@property(nonatomic, assign) BOOL hasSetInitialContentInset;
@end

@implementation SSUICollectionViewController

#pragma mark - 生命周期

- (void)didInitialized{
  [super didInitialized];
  self.collectionViewInitialContentInset = SSUICollectionViewControllerInitialContentInsetNotSet;
  self.collectionViewInitialScrollIndicatorInsets = SSUICollectionViewControllerInitialContentInsetNotSet;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIColor *backgroundColor = CollectionViewBackgroundColor;
  if (backgroundColor) {
    self.view.backgroundColor = backgroundColor;
  }
}

- (void)initSubviews {
  [super initSubviews];
  [self initCollectionView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.collectionView clearsSelection];
}

- (void)needLayoutSubviews
{
  BOOL shouldChangeCollectionViewFrame = !CGRectEqualToRect(self.view.bounds, self.collectionView.frame);
  if (shouldChangeCollectionViewFrame) {
    self.collectionView.frame = self.view.bounds;
  }
  
  if ([self shouldAdjustCollectionViewContentInsetsInitially] && !self.hasSetInitialContentInset) {
    self.collectionView.contentInset = self.collectionViewInitialContentInset;
    if ([self shouldAdjustCollectionViewScrollIndicatorInsetsInitially]) {
      self.collectionView.scrollIndicatorInsets = self.collectionViewInitialScrollIndicatorInsets;
    } else {
      // 默认和tableView.contentInset一致
      self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    }
    [self.collectionView scrollToTopAnimated:NO];
    self.hasSetInitialContentInset = YES;
  }
  
  [super needLayoutSubviews];
}

#pragma mark - 工具方法

- (SSUICollectionView *)collectionView {
  if (!_collectionView) {
    [self loadViewIfNeeded];
  }
  return _collectionView;
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
  [super contentSizeCategoryDidChanged:notification];
  [self.collectionView reloadData];
}

- (void)setCollectionViewInitialContentInset:(UIEdgeInsets)collectionViewInitialContentInset {
  _collectionViewInitialContentInset = collectionViewInitialContentInset;
  
  
//   if (UIEdgeInsetsEqualToEdgeInsets(collectionViewInitialContentInset, SSUICollectionViewControllerInitialContentInsetNotSet)) {
//   self.automaticallyAdjustsScrollViewInsets = YES;
//   } else {
//   self.automaticallyAdjustsScrollViewInsets = NO;
//   }
  
}

- (BOOL)shouldAdjustCollectionViewContentInsetsInitially {
  BOOL shouldAdjust = !UIEdgeInsetsEqualToEdgeInsets(self.collectionViewInitialContentInset, SSUICollectionViewControllerInitialContentInsetNotSet);
  return shouldAdjust;
}

- (BOOL)shouldAdjustCollectionViewScrollIndicatorInsetsInitially {
  BOOL shouldAdjust = !UIEdgeInsetsEqualToEdgeInsets(self.collectionViewInitialScrollIndicatorInsets, SSUICollectionViewControllerInitialContentInsetNotSet);
  return shouldAdjust;
}

#pragma mark - 空列表视图

- (void)showEmptyView {
  if (!self.emptyView) {
    self.emptyView = [[UIEmptyView alloc] init];
  }
  [self.collectionView addSubview:self.emptyView];
  [self layoutEmptyView];
}

- (void)hideEmptyView {
  [self.emptyView removeFromSuperview];
}

- (BOOL)layoutEmptyView {
  if (!self.emptyView || !self.emptyView.superview) {
    return NO;
  }
  
  UIEdgeInsets insets = self.collectionView.contentInset;
  if (@available(ios 11, *)) {
    if (self.collectionView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
      insets = self.collectionView.adjustedContentInset;
    }
  }
  
  self.emptyView.frame = CGRectMake(0,
                                    0,
                                    CGRectGetWidth(self.collectionView.bounds) - UIEdgeInsetsGetHorizontalValue(insets),
                                    CGRectGetHeight(self.collectionView.bounds) - UIEdgeInsetsGetVerticalValue(insets));
  return YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - getter

#pragma mark - <SSUICollectionViewDelegate, SSUICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return nil;
}

@end

@implementation SSUICollectionViewController (Hooks)
- (void)initCollectionView
{
  if (!_collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[SSUICollectionView alloc] initWithFrame:self.view.bounds
                                           collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
  }
}
@end
