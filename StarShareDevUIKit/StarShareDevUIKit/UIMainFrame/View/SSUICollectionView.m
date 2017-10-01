//
//  SSUICollectionView.m
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUICollectionView.h"
#import "UIExtensions.h"

@implementation SSUICollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
  if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
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

- (void)setCollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout
{
  [super setCollectionViewLayout:collectionViewLayout];
  [self updateBounceDirectionWithLayout:collectionViewLayout];
}

- (void)setCollectionViewLayout:(UICollectionViewLayout *)layout animated:(BOOL)animated
{
  [super setCollectionViewLayout:layout animated:animated];
  [self updateBounceDirectionWithLayout:layout];
}

- (void)setCollectionViewLayout:(UICollectionViewLayout *)layout animated:(BOOL)animated completion:(void (^)(BOOL))completion
{
  [super setCollectionViewLayout:layout animated:animated completion:completion];
  [self updateBounceDirectionWithLayout:layout];
}

- (void)updateBounceDirectionWithLayout:(UICollectionViewLayout *)layout
{
  if ([layout isKindOfClass:[UICollectionViewFlowLayout class]]) {
    if (((UICollectionViewFlowLayout *)layout).scrollDirection == UICollectionViewScrollDirectionVertical) {
      self.alwaysBounceVertical = YES;
      self.alwaysBounceHorizontal = NO;
    }
    if (((UICollectionViewFlowLayout *)layout).scrollDirection == UICollectionViewScrollDirectionHorizontal) {
      self.alwaysBounceVertical = NO;
      self.alwaysBounceHorizontal = YES;
    }
  }else{
    self.alwaysBounceVertical = YES;
  }
}

@end
