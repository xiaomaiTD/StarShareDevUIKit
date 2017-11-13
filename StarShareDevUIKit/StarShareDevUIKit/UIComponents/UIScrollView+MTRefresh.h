//
//  UIScrollView+MTRefresh.h
//  MTime_iOS
//
//  Created by BUBUKO on 2017/11/13.
//  Copyright © 2017年 BUBUKO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTRefreshHeader.h"
#import "MTRefreshFooter.h"

@interface UIScrollView (MTRefresh)
- (void)addRefreshHeaderCallback:(void (^ __nullable)(void))callback;
- (void)addRefreshFooterCallback:(void (^ __nullable)(void))callback;
@end
