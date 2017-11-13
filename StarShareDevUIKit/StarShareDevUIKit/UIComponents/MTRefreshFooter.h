//
//  MTRefreshFooter.h
//  MTime_iOS
//
//  Created by BUBUKO on 2017/11/13.
//  Copyright © 2017年 BUBUKO. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

@class MTLoading;

@interface MTRefreshFooter : MJRefreshBackStateFooter

@property (weak, nonatomic, readonly) MTLoading *loading;
@property (weak, nonatomic, readonly) UIImageView *arrowView;
@end
