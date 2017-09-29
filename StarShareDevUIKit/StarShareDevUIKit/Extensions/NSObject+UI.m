//
//  NSObject+UI.m
//  Project
//
//  Created by pmo on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "NSObject+UI.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (UI)
- (BOOL)hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
  if (![[self class] isSubclassOfClass:superclass]) {
    return NO;
  }
  
  if (![superclass instancesRespondToSelector:selector]) {
    return NO;
  }
  
  Method superclassMethod = class_getInstanceMethod(superclass, selector);
  Method instanceMethod = class_getInstanceMethod([self class], selector);
  if (!instanceMethod || instanceMethod == superclassMethod) {
    return NO;
  }
  return YES;
}
@end
