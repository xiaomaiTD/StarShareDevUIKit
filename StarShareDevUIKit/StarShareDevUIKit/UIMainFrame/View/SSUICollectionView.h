//
//  SSUICollectionView.h
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSUICollectionView;

@protocol SSUICollectionViewDelegate <UICollectionViewDelegate>
@end

@protocol SSUICollectionViewDataSource <UICollectionViewDataSource>
@end

@interface SSUICollectionView : UICollectionView
@property(nonatomic, weak) id<SSUICollectionViewDelegate> delegate;
@property(nonatomic, weak) id<SSUICollectionViewDataSource> dataSource;
@end

NS_ASSUME_NONNULL_END
