//
//  MTRefreshHeader.h
//  MTime_iOS
//
//  Created by BUBUKO on 2017/11/13.
//  Copyright © 2017年 BUBUKO. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

@class MTLoading;

@interface MTRefreshHeader : MJRefreshStateHeader

@property (strong, nonatomic, readonly) MTLoading *loading;
@property (strong, nonatomic, readonly) UIImageView *arrowView;
@end
