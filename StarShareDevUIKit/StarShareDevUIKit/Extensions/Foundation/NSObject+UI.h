//
//  NSObject+UI.h
//  Project
//
//  Created by pmo on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (UI)
- (BOOL)hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;
- (id)performSelectorToSuperclass:(SEL)aSelector;
- (id)performSelectorToSuperclass:(SEL)aSelector withObject:(id)object;
- (void)performSelector:(SEL)selector withReturnValue:(void *)returnValue arguments:(void *)firstArgument, ...;
- (void)enumrateInstanceMethodsUsingBlock:(void (^)(SEL selector))block;
+ (void)enumrateInstanceMethodsOfClass:(Class)aClass usingBlock:(void (^)(SEL selector))block;
+ (void)enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL selector))block;
@end
