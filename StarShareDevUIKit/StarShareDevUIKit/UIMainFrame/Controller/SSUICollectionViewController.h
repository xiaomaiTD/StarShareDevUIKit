//
//  SSUICollectionViewController.h
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIViewController.h"
#import "SSUICollectionView.h"

@interface SSUICollectionViewController : SSUIViewController<SSUICollectionViewDelegate,SSUICollectionViewDataSource>
@property(nonatomic, strong, readonly) SSUICollectionView *collectionView;

/**
 修改 UICollectionView ContentInset ，一旦修改了此属性并且不等于 {-1, -1, -1, -1} 的时候，系统的 automaticallyAdjustsScrollViewInsets 和 iOS 11 下的新属性 contentInsetAdjustmentBehavior 可能会影响到 ContentInset | adjustedContentInset 其实这个时候 UICollectionView ContentInset 并不是等于你设置的 collectionViewInitialContentInset ，所以在这个时候如果想要使用此属性 必须设置 automaticallyAdjustsScrollViewInsets = NO，或者 contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever。
 */
@property(nonatomic, assign) UIEdgeInsets collectionViewInitialContentInset;
@property(nonatomic, assign) UIEdgeInsets collectionViewInitialScrollIndicatorInsets;
@end

@interface SSUICollectionViewController (Hooks)
- (void)initCollectionView NS_REQUIRES_SUPER;
@end
