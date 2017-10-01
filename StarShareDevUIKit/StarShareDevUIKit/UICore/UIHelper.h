//
//  UIHelper.h
//  Project
//
//  Created by pmo on 2017/9/24.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UIHelperDelegate <NSObject>
@required
- (void)UIHelperPrintLog:(nonnull NSString *)log;
@end

@interface UIHelper : NSObject
+ (instancetype _Nonnull)sharedInstance;
@property(nullable, nonatomic, weak) id<UIHelperDelegate> helperDelegate;
@end

@interface UIHelper (Theme)
+ (UIImage *)navigationBarBackgroundImageWithThemeColor:(UIColor *)color;
@end

@interface UIHelper (ViewController)
+ (nullable UIViewController *)visibleViewController;
@end

@interface UIHelper (UIApplication)
+ (void)renderStatusBarStyleDark;
+ (void)renderStatusBarStyleLight;
+ (void)dimmedApplicationWindow;
+ (void)resetDimmedApplicationWindow;
@end

@interface UIHelper (Keyboard)
+ (BOOL)isKeyboardVisible;
+ (CGFloat)lastKeyboardHeightInApplicationWindowWhenVisible;
+ (CGRect)keyboardRectWithNotification:(nullable NSNotification *)notification;
+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification;
+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification inView:(nullable UIView *)view;
+ (NSTimeInterval)keyboardAnimationDurationWithNotification:(nullable NSNotification *)notification;
+ (UIViewAnimationCurve)keyboardAnimationCurveWithNotification:(nullable NSNotification *)notification;
+ (UIViewAnimationOptions)keyboardAnimationOptionsWithNotification:(nullable NSNotification *)notification;
@end

@interface UIHelper (UITabBarItem)
+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag;
@end

@interface UIHelper (Device)
+ (BOOL)isIPad;
+ (BOOL)isIPadPro;
+ (BOOL)isIPod;
+ (BOOL)isIPhone;
+ (BOOL)isSimulator;

+ (BOOL)is58InchScreen;
+ (BOOL)is55InchScreen;
+ (BOOL)is47InchScreen;
+ (BOOL)is40InchScreen;
+ (BOOL)is35InchScreen;

+ (CGSize)screenSizeFor58Inch;
+ (CGSize)screenSizeFor55Inch;
+ (CGSize)screenSizeFor47Inch;
+ (CGSize)screenSizeFor40Inch;
+ (CGSize)screenSizeFor35Inch;
@end

@interface UIHelper (UIGraphic)
+ (CGFloat)pixelOne;
+ (void)inspectContextSize:(CGSize)size;
+ (void)inspectContextIfInvalidatedInDebugMode:(CGContextRef _Nonnull)context;
+ (BOOL)inspectContextIfInvalidatedInReleaseMode:(CGContextRef _Nonnull)context;
@end

@interface UIHelper (AudioSession)
+ (void)redirectAudioRouteWithSpeaker:(BOOL)speaker temporary:(BOOL)temporary;
+ (void)setAudioSessionCategory:(nullable NSString *)category;
@end

extern NSString * __nonnull const UISpringAnimationKey;
@interface UIHelper (Animation)
+ (void)actionSpringAnimationForView:(nonnull UIView *)view;
@end

@interface UIHelper (Orientation)
+ (BOOL)rotateToDeviceOrientation:(UIDeviceOrientation)orientation;
@property(nonatomic, assign) UIDeviceOrientation orientationBeforeChangingByHelper;
+ (CGFloat)angleForTransformWithInterfaceOrientation:(UIInterfaceOrientation)orientation;
+ (CGAffineTransform)transformForCurrentInterfaceOrientation;
+ (CGAffineTransform)transformWithInterfaceOrientation:(UIInterfaceOrientation)orientation;
@end

@interface UIHelper (Log)
- (void)printLogWithCalledFunction:(nonnull const char *)func log:(nonnull NSString *)log, ... NS_FORMAT_FUNCTION(2,3);
@end

NS_ASSUME_NONNULL_END
