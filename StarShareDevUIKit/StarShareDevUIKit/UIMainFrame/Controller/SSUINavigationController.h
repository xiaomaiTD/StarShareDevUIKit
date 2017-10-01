//
//  SSUINavigationController.h
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSUINavigationController : UINavigationController<UINavigationControllerDelegate>
- (void)didInitialized NS_REQUIRES_SUPER;
@end

NS_ASSUME_NONNULL_END
