//
//  SSUITextView.h
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSUITextView;

@protocol SSUITextViewDelegate <UITextViewDelegate>
@optional
- (void)textView:(SSUITextView *)textView newHeightAfterTextChanged:(CGFloat)height;
- (BOOL)textViewShouldReturn:(SSUITextView *)textView;
- (void)textView:(SSUITextView *)textView didPreventTextChangeInRange:(NSRange)range replacementText:(NSString *)replacementText;
@end

@interface SSUITextView : UITextView<SSUITextViewDelegate>
@property(nonatomic, weak) id<SSUITextViewDelegate> delegate;
@property(nonatomic, assign) IBInspectable BOOL shouldResponseToProgrammaticallyTextChanges;
@property(nonatomic, assign) IBInspectable NSUInteger maximumTextLength;
@property(nonatomic, assign) IBInspectable BOOL shouldCountingNonASCIICharacterAsTwo;
@property(nonatomic, copy) IBInspectable NSString *placeholder;
@property(nonatomic, strong) IBInspectable UIColor *placeholderColor;
@property(nonatomic, assign) UIEdgeInsets placeholderMargins;
@property(nonatomic, assign) BOOL autoResizable;
@end
