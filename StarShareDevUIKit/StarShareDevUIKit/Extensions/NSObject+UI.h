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
@end
