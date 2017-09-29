//
//  UIHelper.m
//  Project
//
//  Created by pmo on 2017/9/24.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIHelper.h"
#import "UIExtensions.h"
#import <objc/runtime.h>
#import "UIConfigurationMacros.h"
#import "UICommonDefines.h"

@implementation UIHelper (Theme)

+ (UIImage *)navigationBarBackgroundImageWithThemeColor:(UIColor *)color {
  CGSize size = CGSizeMake(4, 88);// 适配 iPhone X
  UIImage *resultImage = nil;
  color = color ? color : UIColorClear;
  
  UIGraphicsBeginImageContextWithOptions(size, YES, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (CFArrayRef)@[(id)color.CGColor, (id)[color colorWithAlphaAddedToWhite:.86].CGColor], NULL);
  CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, size.height), kCGGradientDrawsBeforeStartLocation);
  
  resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  CGGradientRelease(gradient);
  return [resultImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
}

@end

@implementation UIHelper (ViewController)
+ (nullable UIViewController *)visibleViewController {
  UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
  UIViewController *visibleViewController = [rootViewController visibleViewControllerIfExist];
  return visibleViewController;
}
@end

@implementation UIHelper (UIApplication)
+ (void)renderStatusBarStyleDark {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
#pragma clang diagnostic pop
}

+ (void)renderStatusBarStyleLight {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#pragma clang diagnostic pop
}

+ (void)dimmedApplicationWindow {
  UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
  window.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
  [window tintColorDidChange];
}

+ (void)resetDimmedApplicationWindow {
  UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
  window.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
  [window tintColorDidChange];
}
@end

@implementation UIHelper (Keyboard)

- (void)handleKeyboardWillShow:(NSNotification *)notification {
  self.keyboardVisible = YES;
  self.lastKeyboardHeight = [UIHelper keyboardHeightWithNotification:notification];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
  self.keyboardVisible = NO;
}

static char kAssociatedObjectKey_KeyboardVisible;
- (void)setKeyboardVisible:(BOOL)argv {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_KeyboardVisible, @(argv), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isKeyboardVisible {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_KeyboardVisible)) boolValue];
}

+ (BOOL)isKeyboardVisible {
  BOOL visible = [[UIHelper sharedInstance] isKeyboardVisible];
  return visible;
}

static char kAssociatedObjectKey_LastKeyboardHeight;
- (void)setLastKeyboardHeight:(CGFloat)argv {
  objc_setAssociatedObject(self, &kAssociatedObjectKey_LastKeyboardHeight, @(argv), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)lastKeyboardHeight {
  return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_LastKeyboardHeight)) floatValue];
}

+ (CGFloat)lastKeyboardHeightInApplicationWindowWhenVisible {
  return [[UIHelper sharedInstance] lastKeyboardHeight];
}

+ (CGRect)keyboardRectWithNotification:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  return keyboardRect;
}

+ (CGFloat)keyboardHeightWithNotification:(NSNotification *)notification {
  return [UIHelper keyboardHeightWithNotification:notification inView:nil];
}

+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification inView:(nullable UIView *)view {
  CGRect keyboardRect = [self keyboardRectWithNotification:notification];
  if (!view) {
    return CGRectGetHeight(keyboardRect);
  }
  CGRect keyboardRectInView = [view convertRect:keyboardRect fromView:view.window];
  CGRect keyboardVisibleRectInView = CGRectIntersection(view.bounds, keyboardRectInView);
  CGFloat resultHeight = CGRectIsNull(keyboardVisibleRectInView) ? 0.0f : CGRectGetHeight(keyboardVisibleRectInView);
  return resultHeight;
}

+ (NSTimeInterval)keyboardAnimationDurationWithNotification:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  return animationDuration;
}

+ (UIViewAnimationCurve)keyboardAnimationCurveWithNotification:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  UIViewAnimationCurve curve = (UIViewAnimationCurve)[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
  return curve;
}

+ (UIViewAnimationOptions)keyboardAnimationOptionsWithNotification:(NSNotification *)notification {
  UIViewAnimationOptions options = [UIHelper keyboardAnimationCurveWithNotification:notification]<<16;
  return options;
}

@end

@implementation UIHelper (UITabBarItem)
+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag {
  UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:tag];
  tabBarItem.selectedImage = selectedImage;
  return tabBarItem;
}
@end

@implementation UIHelper
+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static UIHelper *instance = nil;
  dispatch_once(&onceToken,^{
    instance = [[super allocWithZone:NULL] init];
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  });
  return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
  return [self sharedInstance];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

@implementation UIHelper (Device)

static NSInteger isIPad = -1;
+ (BOOL)isIPad {
  if (isIPad < 0) {
    // [[[UIDevice currentDevice] model] isEqualToString:@"iPad"] 无法判断模拟器，改为以下方式
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : 0;
  }
  return isIPad > 0;
}

static NSInteger isIPadPro = -1;
+ (BOOL)isIPadPro {
  if (isIPadPro < 0) {
    isIPadPro = [UIHelper isIPad] ? (DEVICE_WIDTH == 1024 && DEVICE_HEIGHT == 1366 ? 1 : 0) : 0;
  }
  return isIPadPro > 0;
}

static NSInteger isIPod = -1;
+ (BOOL)isIPod {
  if (isIPod < 0) {
    NSString *string = [[UIDevice currentDevice] model];
    isIPod = [string rangeOfString:@"iPod touch"].location != NSNotFound ? 1 : 0;
  }
  return isIPod > 0;
}

static NSInteger isIPhone = -1;
+ (BOOL)isIPhone {
  if (isIPhone < 0) {
    NSString *string = [[UIDevice currentDevice] model];
    isIPhone = [string rangeOfString:@"iPhone"].location != NSNotFound ? 1 : 0;
  }
  return isIPhone > 0;
}

static NSInteger isSimulator = -1;
+ (BOOL)isSimulator {
  if (isSimulator < 0) {
#if TARGET_OS_SIMULATOR
    isSimulator = 1;
#else
    isSimulator = 0;
#endif
  }
  return isSimulator > 0;
}

static NSInteger is58InchScreen = -1;
+ (BOOL)is58InchScreen {
  if (is58InchScreen < 0) {
    is58InchScreen = (DEVICE_WIDTH == self.screenSizeFor58Inch.width && DEVICE_HEIGHT == self.screenSizeFor58Inch.height) ? 1 : 0;
  }
  return is58InchScreen > 0;
}

static NSInteger is55InchScreen = -1;
+ (BOOL)is55InchScreen {
  if (is55InchScreen < 0) {
    is55InchScreen = (DEVICE_WIDTH == self.screenSizeFor55Inch.width && DEVICE_HEIGHT == self.screenSizeFor55Inch.height) ? 1 : 0;
  }
  return is55InchScreen > 0;
}

static NSInteger is47InchScreen = -1;
+ (BOOL)is47InchScreen {
  if (is47InchScreen < 0) {
    is47InchScreen = (DEVICE_WIDTH == self.screenSizeFor47Inch.width && DEVICE_HEIGHT == self.screenSizeFor47Inch.height) ? 1 : 0;
  }
  return is47InchScreen > 0;
}

static NSInteger is40InchScreen = -1;
+ (BOOL)is40InchScreen {
  if (is40InchScreen < 0) {
    is40InchScreen = (DEVICE_WIDTH == self.screenSizeFor40Inch.width && DEVICE_HEIGHT == self.screenSizeFor40Inch.height) ? 1 : 0;
  }
  return is40InchScreen > 0;
}

static NSInteger is35InchScreen = -1;
+ (BOOL)is35InchScreen {
  if (is35InchScreen < 0) {
    is35InchScreen = (DEVICE_WIDTH == self.screenSizeFor35Inch.width && DEVICE_HEIGHT == self.screenSizeFor35Inch.height) ? 1 : 0;
  }
  return is35InchScreen > 0;
}

+ (CGSize)screenSizeFor58Inch {
  return CGSizeMake(375, 812);
}

+ (CGSize)screenSizeFor55Inch {
  return CGSizeMake(414, 736);
}

+ (CGSize)screenSizeFor47Inch {
  return CGSizeMake(375, 667);
}

+ (CGSize)screenSizeFor40Inch {
  return CGSizeMake(320, 568);
}

+ (CGSize)screenSizeFor35Inch {
  return CGSizeMake(320, 480);
}
@end

@implementation UIHelper (UIGraphic)

static CGFloat pixelOne = -1.0f;
+ (CGFloat)pixelOne {
  if (pixelOne < 0) {
    pixelOne = 1 / [[UIScreen mainScreen] scale];
  }
  return pixelOne;
}

+ (void)inspectContextSize:(CGSize)size {
  if (size.width < 0 || size.height < 0) {
    NSAssert(NO, @"CGPostError, %@:%d %s, 非法的size：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, NSStringFromCGSize(size), [NSThread callStackSymbols]);
  }
}

+ (void)inspectContextIfInvalidatedInDebugMode:(CGContextRef)context {
  if (!context) {
    // crash了就找zhoon或者molice
    NSAssert(NO, @"CGPostError, %@:%d %s, 非法的context：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, context, [NSThread callStackSymbols]);
  }
}

+ (BOOL)inspectContextIfInvalidatedInReleaseMode:(CGContextRef)context {
  if (context) {
    return YES;
  }
  return NO;
}

@end

