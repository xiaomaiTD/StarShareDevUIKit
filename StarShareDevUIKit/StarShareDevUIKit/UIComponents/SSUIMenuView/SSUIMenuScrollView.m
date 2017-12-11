//
//  SSUIMenuScrollView.m
//  StarShare_iOS
//
//  Created by BUBUKO on 2017/12/10.
//  Copyright © 2017年 Rui Wang. All rights reserved.
//

#import "SSUIMenuScrollView.h"

@implementation SSUIMenuScrollView

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  //MARK: UITableViewCell 删除手势
  if ([NSStringFromClass(otherGestureRecognizer.view.class) isEqualToString:@"UITableViewWrapperView"] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
    return YES;
  }
  return NO;
}
@end
