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
#import <AVFoundation/AVFoundation.h>
#import "UIConfigurationMacros.h"
#import "UICommonDefines.h"

NSString *const UIResourcesMainBundleName = @"StarShareUIResources.bundle";

@implementation UIHelper (Bundle)

+ (NSBundle *)resourcesBundle {
  return [UIHelper resourcesBundleWithName:UIResourcesMainBundleName];
}

+ (NSBundle *)resourcesBundleWithName:(NSString *)bundleName {
  NSBundle *bundle = [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundleName]];
  if (!bundle) {
    // 动态framework的bundle资源是打包在framework里面的，所以无法通过mainBundle拿到资源，只能通过其他方法来获取bundle资源。
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSDictionary *bundleData = [self parseBundleName:bundleName];
    if (bundleData) {
      bundle = [NSBundle bundleWithPath:[frameworkBundle pathForResource:[bundleData objectForKey:@"name"] ofType:[bundleData objectForKey:@"type"]]];
    }
  }
  return bundle;
}

+ (UIImage *)imageWithName:(NSString *)name {
  NSBundle *bundle = [UIHelper resourcesBundle];
  return [UIHelper imageInBundle:bundle withName:name];
}

+ (UIImage *)imageInBundle:(NSBundle *)bundle withName:(NSString *)name {
  if (bundle && name) {
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
      return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
      NSString *imagePath = [[bundle resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
      return [UIImage imageWithContentsOfFile:imagePath];
    }
  }
  return nil;
}

+ (NSDictionary *)parseBundleName:(NSString *)bundleName {
  NSArray *bundleData = [bundleName componentsSeparatedByString:@"."];
  if (bundleData.count == 2) {
    return @{@"name":bundleData[0], @"type":bundleData[1]};
  }
  return nil;
}

@end

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

@implementation UIHelper (AudioSession)

+ (void)redirectAudioRouteWithSpeaker:(BOOL)speaker temporary:(BOOL)temporary {
  if (![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
    return;
  }
  if (temporary) {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:speaker ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone error:nil];
  } else {
    [[AVAudioSession sharedInstance] setCategory:[AVAudioSession sharedInstance].category withOptions:speaker ? AVAudioSessionCategoryOptionDefaultToSpeaker : 0 error:nil];
  }
}

+ (void)setAudioSessionCategory:(nullable NSString *)category {
  
  // 如果不属于系统category，返回
  if (category != AVAudioSessionCategoryAmbient &&
      category != AVAudioSessionCategorySoloAmbient &&
      category != AVAudioSessionCategoryPlayback &&
      category != AVAudioSessionCategoryRecord &&
      category != AVAudioSessionCategoryPlayAndRecord &&
      BeginIgnoreDeprecatedWarning
      category != AVAudioSessionCategoryAudioProcessing)
      EndIgnoreDeprecatedWarning
  {
    return;
  }
  
  [[AVAudioSession sharedInstance] setCategory:category error:nil];
}

+ (UInt32)categoryForLowVersionWithCategory:(NSString *)category {
  if ([category isEqualToString:AVAudioSessionCategoryAmbient]) {
    return kAudioSessionCategory_AmbientSound;
  }
  if ([category isEqualToString:AVAudioSessionCategorySoloAmbient]) {
    return kAudioSessionCategory_SoloAmbientSound;
  }
  if ([category isEqualToString:AVAudioSessionCategoryPlayback]) {
    return kAudioSessionCategory_MediaPlayback;
  }
  if ([category isEqualToString:AVAudioSessionCategoryRecord]) {
    return kAudioSessionCategory_RecordAudio;
  }
  if ([category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
    return kAudioSessionCategory_PlayAndRecord;
  }
  BeginIgnoreDeprecatedWarning
  if ([category isEqualToString:AVAudioSessionCategoryAudioProcessing]) {
    return kAudioSessionCategory_AudioProcessing;
  }
  EndIgnoreDeprecatedWarning
  return kAudioSessionCategory_AmbientSound;
}

@end

@implementation UIHelper (Orientation)

- (void)handleDeviceOrientationNotification:(NSNotification *)notification {
  [UIHelper sharedInstance].orientationBeforeChangingByHelper = UIDeviceOrientationUnknown;
}

+ (BOOL)rotateToDeviceOrientation:(UIDeviceOrientation)orientation {
  if ([UIDevice currentDevice].orientation == orientation) {
    [UIViewController attemptRotationToDeviceOrientation];
    return NO;
  }
  
  [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
  return YES;
}

static char kAssociatedObjectKey_orientationBeforeChangedByHelper;
- (void)setOrientationBeforeChangingByHelper:(UIDeviceOrientation)orientationBeforeChangedByHelper {
  objc_setAssociatedObject(self,
                           &kAssociatedObjectKey_orientationBeforeChangedByHelper,
                           @(orientationBeforeChangedByHelper),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIDeviceOrientation)orientationBeforeChangingByHelper {
  return [((NSNumber *)objc_getAssociatedObject(self,
                                                &kAssociatedObjectKey_orientationBeforeChangedByHelper)) integerValue];
}

+ (CGFloat)angleForTransformWithInterfaceOrientation:(UIInterfaceOrientation)orientation {
  CGFloat angle;
  switch (orientation)
  {
    case UIInterfaceOrientationPortraitUpsideDown:
      angle = M_PI;
      break;
    case UIInterfaceOrientationLandscapeLeft:
      angle = -M_PI_2;
      break;
    case UIInterfaceOrientationLandscapeRight:
      angle = M_PI_2;
      break;
    default:
      angle = 0.0;
      break;
  }
  return angle;
}

+ (CGAffineTransform)transformForCurrentInterfaceOrientation {
  return [UIHelper transformWithInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

+ (CGAffineTransform)transformWithInterfaceOrientation:(UIInterfaceOrientation)orientation {
  CGFloat angle = [UIHelper angleForTransformWithInterfaceOrientation:orientation];
  return CGAffineTransformMakeRotation(angle);
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

NSString *const UISpringAnimationKey = @"UISpringAnimationKey";
@implementation UIHelper (Animation)

+ (void)actionSpringAnimationForView:(UIView *)view {
  NSTimeInterval duration = 0.6;
  CAKeyframeAnimation *springAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  springAnimation.values = @[@.85, @1.15, @.9, @1.0,];
  springAnimation.keyTimes = @[@(0.0 / duration), @(0.15 / duration) , @(0.3 / duration), @(0.45 / duration),];
  springAnimation.duration = duration;
  [view.layer addAnimation:springAnimation forKey:UISpringAnimationKey];
}

@end

@implementation UIHelper (Log)

- (void)printLogWithCalledFunction:(nonnull const char *)func log:(nonnull NSString *)log, ... {
  va_list args;
  va_start(args, log);
  NSString *logString = [[NSString alloc] initWithFormat:log arguments:args];
  if ([self.helperDelegate respondsToSelector:@selector(UIHelperPrintLog:)]) {
    [self.helperDelegate UIHelperPrintLog:[NSString stringWithFormat:@"StarShareDevUIKit - %@. Called By %s", logString, func]];
  } else {
    NSLog(@"StarShareDevUIKit - %@. Called By %s", logString, func);
  }
  va_end(args);
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
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(handleDeviceOrientationNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
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

