//
//  NSString+UI.h
//  Project
//
//  Created by jearoc on 2017/9/27.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (UI)
- (BOOL)includesString:(NSString *)string;
- (NSString *)trim;
- (NSString *)trimAllWhiteSpace;
- (NSString *)trimLineBreakCharacter;
- (NSString *)md5;
+ (NSString *)hexStringWithInteger:(NSInteger)integer;
+ (NSString *)stringByConcat:(id)firstArgv, ...;
+ (NSString *)timeStringWithMinsAndSecsFromSecs:(double)seconds;
- (NSString *)removeMagicalChar;
- (NSUInteger)lengthWhenCountingNonASCIICharacterAsTwo;
- (NSString *)substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index
                                                        lessValue:(BOOL)lessValue
                                   countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;
- (NSString *)substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index;
- (NSString *)substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index
                                                      lessValue:(BOOL)lessValue
                                 countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;
- (NSString *)substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index;
- (NSString *)substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range
                                                        lessValue:(BOOL)lessValue
                                   countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;
- (NSString *)substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range;
- (NSString *)stringByRemoveCharacterAtIndex:(NSUInteger)index;
- (NSString *)stringByRemoveLastCharacter;
@end

@interface NSString (StringFormat)
+ (instancetype)stringWithNSInteger:(NSInteger)integerValue;
+ (instancetype)stringWithCGFloat:(CGFloat)floatValue;
+ (instancetype)stringWithCGFloat:(CGFloat)floatValue decimal:(NSUInteger)decimal;
@end
