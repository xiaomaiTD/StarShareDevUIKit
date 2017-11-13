//
//  UIScrollView+MTRefresh.m
//  MTime_iOS
//
//  Created by BUBUKO on 2017/11/13.
//  Copyright © 2017年 BUBUKO. All rights reserved.
//

#import "UIScrollView+MTRefresh.h"

@implementation UIScrollView (MTRefresh)
- (void)addRefreshHeaderCallback:(void (^ __nullable)(void))callback
{
  MTRefreshHeader *header = [MTRefreshHeader headerWithRefreshingBlock:callback];
  header.stateLabel.hidden = YES;
  header.lastUpdatedTimeLabel.hidden = YES;
  self.mj_header = header;
}
- (void)addRefreshFooterCallback:(void (^ __nullable)(void))callback
{
  MTRefreshFooter *footer = [MTRefreshFooter footerWithRefreshingBlock:callback];
  footer.stateLabel.hidden = YES;
  self.mj_footer = footer;
}
@end
