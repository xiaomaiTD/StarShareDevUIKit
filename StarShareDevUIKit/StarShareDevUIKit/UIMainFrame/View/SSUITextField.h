//
//  SSUITextField.h
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSUITextField;

@protocol SSUITextFieldDelegate <UITextFieldDelegate>
@optional
- (void)textField:(SSUITextField *)textField didPreventTextChangeInRange:(NSRange)range replacementString:(NSString *)replacementString;
@end

@interface SSUITextField : UITextField
@property(nonatomic, weak) id<SSUITextFieldDelegate> delegate;
@property(nonatomic, strong) IBInspectable UIColor *placeholderColor;
@property(nonatomic, assign) UIEdgeInsets textInsets;
@property(nonatomic, assign) IBInspectable BOOL shouldResponseToProgrammaticallyTextChanges;
@property(nonatomic, assign) IBInspectable NSUInteger maximumTextLength;
@property(nonatomic, assign) IBInspectable BOOL shouldCountingNonASCIICharacterAsTwo;
@end
