//
//  UITextView+UI.h
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (UI)

/**
 *  convert UITextRange to NSRange, for example, [self convertNSRangeFromUITextRange:self.markedTextRange]
 */
- (NSRange)convertNSRangeFromUITextRange:(UITextRange *)textRange;

/**
 *  设置 text 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)setTextKeepingSelectedRange:(NSString *)text;

/**
 *  设置 attributedText 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText;

/**
 *  [UITextView scrollRangeToVisible:] 并不会考虑 textContainerInset.bottom，所以使用这个方法来代替
 */
- (void)scrollCaretVisibleAnimated:(BOOL)animated;

@end
