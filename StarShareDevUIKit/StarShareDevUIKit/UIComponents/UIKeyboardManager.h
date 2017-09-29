//
//  UIKeyboardManager.h
//  Project
//
//  Created by pmo on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UIKeyboardManagerDelegate;
@class UIKeyboardUserInfo;

@interface UIKeyboardManager : NSObject
- (instancetype)initWithDelegate:(id<UIKeyboardManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;
@property(nonatomic, weak, readonly) id<UIKeyboardManagerDelegate> delegate;
@property(nonatomic, assign) BOOL delegateEnabled;///< Default is YES, Not call the delegate if is NO.
- (BOOL)addTargetResponder:(UIResponder *)targetResponder;
- (NSArray<UIResponder *> *)allTargetResponders;
+ (CGRect)convertKeyboardRect:(CGRect)rect
                       toView:(UIView *)view;
+ (CGFloat)distanceFromMinYToBottomInView:(UIView *)view
                             keyboardRect:(CGRect)rect;
+ (void)animateWithAnimated:(BOOL)animated
           keyboardUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion;
+ (void)handleKeyboardNotificationWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo
                                     showBlock:(void (^)(UIKeyboardUserInfo *keyboardUserInfo))showBlock
                                     hideBlock:(void (^)(UIKeyboardUserInfo *keyboardUserInfo))hideBlock;
+ (UIView *)keyboardView;
+ (UIWindow *)keyboardWindow;
+ (BOOL)isKeyboardVisible;
+ (CGRect)currentKeyboardFrame;
+ (CGFloat)visiableKeyboardHeight;
@end

@interface UIKeyboardUserInfo : NSObject
@property(nonatomic, weak, readonly) UIKeyboardManager *keyboardManager;
@property(nonatomic, strong, readonly) NSNotification *notification;
@property(nonatomic, strong, readonly) NSDictionary *originUserInfo;
@property(nonatomic, weak, readonly) UIResponder *targetResponder;
@property(nonatomic, assign, readonly) CGFloat width;
@property(nonatomic, assign, readonly) CGFloat height;
- (CGFloat)heightInView:(UIView *)view;
@property(nonatomic, assign, readonly) CGRect beginFrame;
@property(nonatomic, assign, readonly) CGRect endFrame;
@property(nonatomic, assign, readonly) NSTimeInterval animationDuration;
@property(nonatomic, assign, readonly) UIViewAnimationCurve animationCurve;
@property(nonatomic, assign, readonly) UIViewAnimationOptions animationOptions;
@end

@protocol UIKeyboardManagerDelegate <NSObject>
@optional
- (void)keyboardWillShowWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo;
- (void)keyboardWillHideWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo;
- (void)keyboardWillChangeFrameWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo;
- (void)keyboardDidShowWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo;
- (void)keyboardDidHideWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo;
- (void)keyboardDidChangeFrameWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo;
@end

@interface UITextField (UIKeyboardManager)<UIKeyboardManagerDelegate>
@property(nonatomic, copy) void (^keyboardWillShowNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardWillHideNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardWillChangeFrameNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardDidShowNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardDidHideNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardDidChangeFrameNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, strong, readonly) UIKeyboardManager *keyboardManager;
@end


@interface UITextView (UIKeyboardManager)<UIKeyboardManagerDelegate>
@property(nonatomic, copy) void (^keyboardWillShowNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardWillHideNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardWillChangeFrameNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardDidShowNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardDidHideNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^keyboardDidChangeFrameNotificationBlock)(UIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, strong, readonly) UIKeyboardManager *keyboardManager;
@end
