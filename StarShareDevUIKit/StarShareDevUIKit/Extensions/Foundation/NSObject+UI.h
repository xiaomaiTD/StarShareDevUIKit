//
//  NSObject+UI.h
//  Project
//
//  Created by pmo on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (UI)

/**
 判断当前类是否有重写某个父类的指定方法
 
 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
- (BOOL)hasOverrideMethod:(SEL)selector
             ofSuperclass:(Class)superclass;

/**
 对 super 发送消息
 
 @param aSelector 要发送的消息
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method
 */
- (id)performSelectorToSuperclass:(SEL)aSelector;

/**
 对 super 发送消息
 
 @param aSelector 要发送的消息
 @param object 作为参数传过去
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method
 */
- (id)performSelectorToSuperclass:(SEL)aSelector
                       withObject:(id)object;

/**
 *  系统的 performSelector 不支持参数或返回值为非对象的 selector 的调用，所以增加了对应的方法，支持对象和非对象的 selector。
 *
 *  使用示例：
 *  CGFloat result;
 *  CGFloat arg1, arg2;
 *  [self performSelector:xxx withReturnValue:&result arguments:&arg1, &arg2, nil];
 *  // 到这里 result 已经被赋值为 selector 的 return 值
 *
 *  @param selector 要被调用的方法名
 *  @param returnValue selector 的返回值的指针地址
 *  @param firstArgument 调用 selector 时要传的第一个参数的指针地址
 */
- (void)performSelector:(SEL)selector
        withReturnValue:(void *)returnValue
              arguments:(void *)firstArgument, ...;

/**
 使用 block 遍历当前实例的所有方法，父类的方法不包含在内
 */
- (void)enumrateInstanceMethodsUsingBlock:(void (^)(SEL selector))block;

/**
 使用 block 遍历指定的某个类的实例方法，该类的父类方法不包含在内
 *  @param aClass   要遍历的某个类
 *  @param block    遍历时使用的 block，参数为某一个方法
 */
+ (void)enumrateInstanceMethodsOfClass:(Class)aClass
                            usingBlock:(void (^)(SEL selector))block;

/**
 遍历某个 protocol 里的所有方法
 
 @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
 @param block 遍历过程中调用的 block
 */
+ (void)enumerateProtocolMethods:(Protocol *)protocol
                      usingBlock:(void (^)(SEL selector))block;

@end
