//
//  UIButton+UI.m
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIButton+UI.h"
#import "UICore.h"

@implementation UIButton (UI)
+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ExchangeImplementations([self class], @selector(setTitle:forState:), @selector(ss_setTitle:forState:));
    ExchangeImplementations([self class], @selector(setTitleColor:forState:), @selector(ss_setTitleColor:forState:));
  });
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
  if (self = [super init]) {
    [self setImage:image forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateNormal];
  }
  return self;
}

- (void)calculateHeightAfterSetAppearance {
  [self setTitle:@"测" forState:UIControlStateNormal];
  [self sizeToFit];
  [self setTitle:nil forState:UIControlStateNormal];
}

#pragma mark - Title Attributes

- (void)setTitleAttributes:(NSDictionary<NSString *,id> *)attributes forState:(UIControlState)state {
  if (!attributes) {
    [self.titleAttributes removeObjectForKey:@(state)];
    [self setAttributedTitle:nil forState:state];
    return;
  }
  
  if (!self.titleAttributes) {
    self.titleAttributes = [NSMutableDictionary dictionary];
  }
  
  // 如果传入的 attributes 没有包含文字颜色，则使用用户之前通过 setTitleColor:forState: 方法设置的颜色
  if (![attributes objectForKey:NSForegroundColorAttributeName]) {
    NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    newAttributes[NSForegroundColorAttributeName] = [self titleColorForState:state];
    attributes = [NSDictionary dictionaryWithDictionary:newAttributes];
  }
  self.titleAttributes[@(state)] = attributes;
  
  // 确保调用此方法设置 attributes 之前已经通过 setTitle:forState: 设置的文字也能应用上新的 attributes
  NSString *originalText = [self titleForState:state];
  [self setTitle:originalText forState:state];
  
  // 一个系统的不好的特性（bug?）：如果你给 UIControlStateHighlighted（或者 normal 之外的任何 state）设置了包含 NSFont/NSKern/NSUnderlineAttributeName 之类的 attributedString ，但又仅用 setTitle:forState: 给 UIControlStateNormal 设置了普通的 string ，则按钮从 highlighted 切换回 normal 状态时，font 之类的属性依然会停留在 highlighted 时的状态
  // 为了解决这个问题，我们要确保一旦有 normal 之外的 state 通过设置 titleAttributes 属性而导致使用了 attributedString，则 normal 也必须使用 attributedString
  if (self.titleAttributes.count && !self.titleAttributes[@(UIControlStateNormal)]) {
    [self setTitleAttributes:@{} forState:UIControlStateNormal];
  }
}

- (void)ss_setTitle:(NSString *)title forState:(UIControlState)state {
  [self ss_setTitle:title forState:state];
  if (!title || !self.titleAttributes.count) {
    return;
  }
  
  if (state == UIControlStateNormal) {
    [self.titleAttributes enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
      UIControlState state = [key unsignedIntegerValue];
      NSString *titleForState = [self titleForState:state];
      NSAttributedString *string = [[NSAttributedString alloc] initWithString:titleForState attributes:obj];
      [self setAttributedTitle:[self attributedStringWithEndKernRemoved:string] forState:state];
    }];
    return;
  }
  
  if ([self.titleAttributes objectForKey:@(state)]) {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:self.titleAttributes[@(state)]];
    [self setAttributedTitle:[self attributedStringWithEndKernRemoved:string] forState:state];
    return;
  }
}

// 如果之前已经设置了此 state 下的文字颜色，则覆盖掉之前的颜色
- (void)ss_setTitleColor:(UIColor *)color forState:(UIControlState)state {
  [self ss_setTitleColor:color forState:state];
  NSDictionary *attributes = self.titleAttributes[@(state)];
  if (attributes) {
    NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    newAttributes[NSForegroundColorAttributeName] = color;
    [self setTitleAttributes:[NSDictionary dictionaryWithDictionary:newAttributes] forState:state];
  }
}

// 去除最后一个字的 kern 效果
- (NSAttributedString *)attributedStringWithEndKernRemoved:(NSAttributedString *)string {
  if (!string || !string.length) {
    return string;
  }
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  [attributedString removeAttribute:NSKernAttributeName range:NSMakeRange(string.length - 1, 1)];
  return [[NSAttributedString alloc] initWithAttributedString:attributedString];
}

static char kAssociatedObjectKey_titleAttributes;
- (void)setTitleAttributes:(NSMutableDictionary<NSString *, id> *)titleAttributes {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_titleAttributes, titleAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSNumber *, NSDictionary *> *)titleAttributes {
  return (NSMutableDictionary *)objc_getAssociatedObject(self, &kAssociatedObjectKey_titleAttributes);
}
@end
