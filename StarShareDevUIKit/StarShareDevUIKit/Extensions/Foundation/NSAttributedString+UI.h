//
//  NSAttributedString+UI.h
//  StarShareDevUIKit
//
//  Created by pmo on 2017/10/1.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (UI)
- (NSUInteger)lengthWhenCountingNonASCIICharacterAsTwo;
+ (instancetype)attributedStringWithImage:(UIImage *)image;
+ (instancetype)attributedStringWithImage:(UIImage *)image
                           baselineOffset:(CGFloat)offset
                               leftMargin:(CGFloat)leftMargin
                              rightMargin:(CGFloat)rightMargin;
+ (instancetype)attributedStringWithFixedSpace:(CGFloat)width;
@end
