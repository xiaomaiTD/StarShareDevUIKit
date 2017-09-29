//
//  UITextView+UI.m
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UITextView+UI.h"

@implementation UITextView (UI)
- (NSRange)convertNSRangeFromUITextRange:(UITextRange *)textRange {
  NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
  NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
  return NSMakeRange(location, length);
}

- (void)setTextKeepingSelectedRange:(NSString *)text {
  UITextRange *selectedTextRange = self.selectedTextRange;
  self.text = text;
  self.selectedTextRange = selectedTextRange;
}

- (void)setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText {
  UITextRange *selectedTextRange = self.selectedTextRange;
  self.attributedText = attributedText;
  self.selectedTextRange = selectedTextRange;
}

- (void)scrollCaretVisibleAnimated:(BOOL)animated {
  if (CGRectIsEmpty(self.bounds)) {
    return;
  }
  
  CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
  
  // scrollEnabled 为 NO 时可能产生不合法的 rect 值 https://github.com/QMUI/QMUI_iOS/issues/205
  if (isinf(CGRectGetMinX(caretRect)) || isinf(CGRectGetMinY(caretRect))) {
    return;
  }
  
  CGFloat contentOffsetY = self.contentOffset.y;
  
  if (CGRectGetMinY(caretRect) == self.contentOffset.y + self.textContainerInset.top) {
    // 命中这个条件说明已经不用调整了，直接 return，避免继续走下面的判断，会重复调整，导致光标跳动
    return;
  }
  
  if (CGRectGetMinY(caretRect) < self.contentOffset.y + self.textContainerInset.top) {
    // 光标在可视区域上方，往下滚动
    contentOffsetY = CGRectGetMinY(caretRect) - self.textContainerInset.top - self.contentInset.top;
  } else if (CGRectGetMaxY(caretRect) > self.contentOffset.y + CGRectGetHeight(self.bounds) - self.textContainerInset.bottom - self.contentInset.bottom) {
    // 光标在可视区域下方，往上滚动
    contentOffsetY = CGRectGetMaxY(caretRect) - CGRectGetHeight(self.bounds) + self.textContainerInset.bottom + self.contentInset.bottom;
  } else {
    // 光标在可视区域内，不用调整
    return;
  }
  [self setContentOffset:CGPointMake(self.contentOffset.x, contentOffsetY) animated:animated];
}
@end
