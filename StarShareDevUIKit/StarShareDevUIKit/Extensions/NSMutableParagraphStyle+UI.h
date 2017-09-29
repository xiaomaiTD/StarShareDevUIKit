//
//  NSMutableParagraphStyle+UI.h
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSMutableParagraphStyle (UI)
+ (instancetype)paragraphStyleWithLineHeight:(CGFloat)lineHeight;
+ (instancetype)paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode;
+ (instancetype)paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment;
@end
