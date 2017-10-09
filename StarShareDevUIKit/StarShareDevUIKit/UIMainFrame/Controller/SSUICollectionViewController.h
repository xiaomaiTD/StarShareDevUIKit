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
@property(nonatomic, assign) UIEdgeInsets collectionViewInitialContentInset;
@property(nonatomic, assign) UIEdgeInsets collectionViewInitialScrollIndicatorInsets;
@end

@interface SSUICollectionViewController (Hooks)
- (void)initCollectionView;
@end
