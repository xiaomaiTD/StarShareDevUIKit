//
//  UITextView+UI.h
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (UI)
- (NSRange)convertNSRangeFromUITextRange:(UITextRange *)textRange;
- (void)setTextKeepingSelectedRange:(NSString *)text;
- (void)setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText;
- (void)scrollCaretVisibleAnimated:(BOOL)animated;
@end
