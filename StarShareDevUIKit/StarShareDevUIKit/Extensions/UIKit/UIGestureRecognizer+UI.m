//
//  UIGestureRecognizer+UI.m
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIGestureRecognizer+UI.h"

@implementation UIGestureRecognizer (UI)
- (nullable UIView *)targetView {
  CGPoint location = [self locationInView:self.view];
  UIView *targetView = [self.view hitTest:location withEvent:nil];
  return targetView;
}
@end
