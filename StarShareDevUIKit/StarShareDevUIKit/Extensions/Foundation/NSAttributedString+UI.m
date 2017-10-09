//
//  NSAttributedString+UI.m
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "NSAttributedString+UI.h"
#import "UICore.h"
#import "NSString+UI.h"
#import "UIColor+UI.h"

@implementation NSAttributedString (UI)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
    ReplaceMethod([[[NSAttributedString alloc] initWithString:@""] class],
                  @selector(initWithString:),
                  @selector(ss_initWithString:));
    ReplaceMethod([[[NSAttributedString alloc] initWithString:@"" attributes:nil] class],
                  @selector(initWithString:attributes:),
                  @selector(ss_initWithString:attributes:));
  });
}

- (instancetype)ss_initWithString:(NSString *)str {
  str = str ?: @"";
  return [self ss_initWithString:str];
}

- (instancetype)ss_initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
  str = str ?: @"";
  return [self ss_initWithString:str attributes:attrs];
}

- (NSUInteger)lengthWhenCountingNonASCIICharacterAsTwo {
  return self.string.lengthWhenCountingNonASCIICharacterAsTwo;
}

+ (instancetype)attributedStringWithImage:(UIImage *)image {
  return [self attributedStringWithImage:image baselineOffset:0 leftMargin:0 rightMargin:0];
}

+ (instancetype)attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
  if (!image) {
    return nil;
  }
  NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
  attachment.image = image;
  attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
  NSMutableAttributedString *string = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
  [string addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:NSMakeRange(0, string.length)];
  if (leftMargin > 0) {
    [string insertAttributedString:[self attributedStringWithFixedSpace:leftMargin] atIndex:0];
  }
  if (rightMargin > 0) {
    [string appendAttributedString:[self attributedStringWithFixedSpace:rightMargin]];
  }
  return string;
}

+ (instancetype)attributedStringWithFixedSpace:(CGFloat)width {
  UIGraphicsBeginImageContext(CGSizeMake(width, 1));
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return [self attributedStringWithImage:image];
}


@end
