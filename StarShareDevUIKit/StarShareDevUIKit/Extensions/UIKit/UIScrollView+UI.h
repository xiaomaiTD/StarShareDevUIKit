//
//  UIScrollView+UI.h
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (UI)
@property(nonatomic, assign, readonly) BOOL alreadyAtTop;
@property(nonatomic, assign, readonly) BOOL alreadyAtBottom;
- (BOOL)canScroll;
- (void)scrollToTopForce:(BOOL)force animated:(BOOL)animated;
- (void)scrollToTopAnimated:(BOOL)animated;
- (void)scrollToTop;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)scrollToBottom;
- (void)stopDeceleratingIfNeeded;
@end
