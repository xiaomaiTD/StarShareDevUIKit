//
//  UITextField+UI.m
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UITextField+UI.h"

@implementation UITextField (UI)
- (NSRange)selectedRange {
  NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
  NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
  return NSMakeRange(location, length);
}
@end
