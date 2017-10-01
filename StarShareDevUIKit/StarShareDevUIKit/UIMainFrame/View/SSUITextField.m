//
//  SSUITextField.m
//  Project
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUITextField.h"
#import "UICore.h"
#import "UIExtensions.h"

@interface SSUITextField () <SSUITextFieldDelegate, UIScrollViewDelegate>
@property(nonatomic, weak) id <SSUITextFieldDelegate> originalDelegate;
@end

@implementation SSUITextField

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self didInitialized];
    self.tintColor = TextFieldTintColor;
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self didInitialized];
  }
  return self;
}

- (void)didInitialized {
  self.delegate = self;
  self.placeholderColor = UIColorPlaceholder;
  self.textInsets = TextFieldTextInsets;
  self.shouldResponseToProgrammaticallyTextChanges = YES;
  self.maximumTextLength = NSUIntegerMax;
  [self addTarget:self action:@selector(handleTextChangeEvent:) forControlEvents:UIControlEventEditingChanged];
}

- (void)dealloc {
  self.delegate = nil;
  self.originalDelegate = nil;
}

#pragma mark - Placeholder

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
  _placeholderColor = placeholderColor;
  if (self.placeholder) {
    [self updateAttributedPlaceholderIfNeeded];
  }
}

- (void)setPlaceholder:(NSString *)placeholder {
  [super setPlaceholder:placeholder];
  if (self.placeholderColor) {
    [self updateAttributedPlaceholderIfNeeded];
  }
}

- (void)updateAttributedPlaceholderIfNeeded {
  self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
}

#pragma mark - TextInsets

- (CGRect)textRectForBounds:(CGRect)bounds {
  bounds = CGRectInsetEdges(bounds, self.textInsets);
  CGRect resultRect = [super textRectForBounds:bounds];
  return resultRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  bounds = CGRectInsetEdges(bounds, self.textInsets);
  return [super editingRectForBounds:bounds];
}

#pragma mark - TextPosition

- (void)layoutSubviews {
  [super layoutSubviews];
  
  // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug
  // 具体问题描述
  // 这是系统的 UITextField 的 bug，仅在 iOS 10 之后才会。触发条件：
  // 1. UITextField.frame 的高度要比 UITextField.font.lineHeight 或者 UITextField.defaultTextAttributes[NSParagraphStyleAttributeName].minimumLineHeight 的整数值（ceil 运算）大。
  // 2. 输入的文字要超过文本框的宽度，也即出现横向滚动。
  // 3. 在此情况下一个一个字地删除，文字就会往下掉。
  // 4. 或者不用删除文字，而是在文本框里往右上角拖拽，就会看到文字往左下方掉。
  // 5. 与 contentVerticalAlignment 的值无关。
  // 问题根源
  // UITextField 只有一个 subview，是私有的 UIFieldEditor，其父类为 UIScrollView。这个 bug 的直接原因是在那个场景下 scrollView.contentOffset.y 为负值，至于为什么被调整为负值不得而知。
  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
    return;
  }
  
  UIScrollView *scrollView = self.subviews.firstObject;
  if (![scrollView isKindOfClass:[UIScrollView class]]) {
    return;
  }
  
  // 默认 delegate 是为 nil 的，所以我们才利用 delegate 修复这 个 bug，如果哪一天 delegate 不为 nil，就先不处理了。
  if (scrollView.delegate) {
    return;
  }
  
  scrollView.delegate = self;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：如上
  
  if (scrollView != self.subviews.firstObject) {
    return;
  }
  
  CGFloat lineHeight = ((NSParagraphStyle *)self.defaultTextAttributes[NSParagraphStyleAttributeName]).minimumLineHeight;
  lineHeight = lineHeight ?: ((UIFont *)self.defaultTextAttributes[NSFontAttributeName]).lineHeight;
  if (scrollView.contentSize.height > ceil(lineHeight) && scrollView.contentOffset.y < 0) {
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
  }
}

- (void)setText:(NSString *)text {
  NSString *textBeforeChange = self.text;
  [super setText:text];
  
  if (self.shouldResponseToProgrammaticallyTextChanges && ![textBeforeChange isEqualToString:text]) {
    [self fireTextDidChangeEventForTextField:self];
  }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
  NSAttributedString *textBeforeChange = self.attributedText;
  [super setAttributedText:attributedText];
  if (self.shouldResponseToProgrammaticallyTextChanges && ![textBeforeChange isEqualToAttributedString:attributedText]) {
    [self fireTextDidChangeEventForTextField:self];
  }
}

- (void)fireTextDidChangeEventForTextField:(SSUITextField *)textField {
  [textField sendActionsForControlEvents:UIControlEventEditingChanged];
  [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
}

- (NSUInteger)lengthWithString:(NSString *)string {
  return self.shouldCountingNonASCIICharacterAsTwo ? string.lengthWhenCountingNonASCIICharacterAsTwo : string.length;
}

#pragma mark - <SSUITextFieldDelegate>

- (BOOL)textField:(SSUITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (textField.maximumTextLength < NSUIntegerMax) {
    
    // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
    BOOL isDeleting = range.length > 0 && string.length <= 0;
    if (isDeleting || textField.markedTextRange) {
      
      if ([textField.originalDelegate respondsToSelector:_cmd]) {
        return [textField.originalDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
      }
      
      return YES;
    }
    
    NSUInteger rangeLength = self.shouldCountingNonASCIICharacterAsTwo ? [textField.text substringWithRange:range].lengthWhenCountingNonASCIICharacterAsTwo : range.length;
    if ([self lengthWithString:textField.text] - rangeLength + [self lengthWithString:string] > textField.maximumTextLength) {
      // 将要插入的文字裁剪成这么长，就可以让它插入了
      NSInteger substringLength = textField.maximumTextLength - [self lengthWithString:textField.text] + rangeLength;
      if (substringLength > 0 && [self lengthWithString:string] > substringLength) {
        NSString *allowedText = [string substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, substringLength) lessValue:YES countingNonASCIICharacterAsTwo:self.shouldCountingNonASCIICharacterAsTwo];
        if ([self lengthWithString:allowedText] <= substringLength) {
          textField.text = [textField.text stringByReplacingCharactersInRange:range withString:allowedText];
          
          if (!textField.shouldResponseToProgrammaticallyTextChanges) {
            [textField fireTextDidChangeEventForTextField:textField];
          }
        }
      }
      
      if ([self.originalDelegate respondsToSelector:@selector(textField:didPreventTextChangeInRange:replacementString:)]) {
        [self.originalDelegate textField:textField didPreventTextChangeInRange:range replacementString:string];
      }
      return NO;
    }
  }
  
  if ([textField.originalDelegate respondsToSelector:_cmd]) {
    return [textField.originalDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
  }
  
  return YES;
}

#pragma mark - Delegate Proxy

- (void)setDelegate:(id<SSUITextFieldDelegate>)delegate {
  self.originalDelegate = delegate != self ? delegate : nil;
  [super setDelegate:delegate ? self : nil];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
  NSMethodSignature *a = [super methodSignatureForSelector:aSelector];
  NSMethodSignature *b = [(id)self.originalDelegate methodSignatureForSelector:aSelector];
  NSMethodSignature *result = a ? a : b;
  return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
  if ([(id)self.originalDelegate respondsToSelector:anInvocation.selector]) {
    [anInvocation invokeWithTarget:(id)self.originalDelegate];
  }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  BOOL a = [super respondsToSelector:aSelector];
  BOOL c = [self.originalDelegate respondsToSelector:aSelector];
  BOOL result = a || c;
  return result;
}

- (void)handleTextChangeEvent:(SSUITextField *)textField {
  // 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 textField:shouldChangeCharactersInRange:replacementString: 的，所以要在这里截断文字
  // 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
  
  if (!textField.markedTextRange) {
    if ([self lengthWithString:textField.text] > textField.maximumTextLength) {
      textField.text = [textField.text substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, textField.maximumTextLength) lessValue:YES countingNonASCIICharacterAsTwo:self.shouldCountingNonASCIICharacterAsTwo];
      
      if ([self.originalDelegate respondsToSelector:@selector(textField:didPreventTextChangeInRange:replacementString:)]) {
        [self.originalDelegate textField:textField didPreventTextChangeInRange:textField.selectedRange replacementString:nil];
      }
    }
  }
}

@end
