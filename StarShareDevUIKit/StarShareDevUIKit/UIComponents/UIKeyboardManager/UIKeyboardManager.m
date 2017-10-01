//
//  UIKeyboardManager.m
//  Project
//
//  Created by pmo on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIKeyboardManager.h"
#import "UICore.h"

#define IS_IPAD [UIHelper isIPad]

@interface UIView (KeyboardManager)
- (id)findFirstResponder;
@end

@implementation UIView (KeyboardManager)
- (id)findFirstResponder {
  if (self.isFirstResponder) {
    return self;
  }
  for (UIView *subView in self.subviews) {
    id responder = [subView findFirstResponder];
    if (responder) return responder;
  }
  return nil;
}
@end

@interface UIResponder (KeyboardManager)
@property(nonatomic, assign) BOOL keyboardManager_isFirstResponder;
@end

@implementation UIResponder (KeyboardManager)
+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    ReplaceMethod([self class], @selector(becomeFirstResponder), @selector(keyboardManager_becomeFirstResponder));
    ReplaceMethod([self class], @selector(resignFirstResponder), @selector(keyboardManager_resignFirstResponder));
  });
}

- (BOOL)keyboardManager_becomeFirstResponder {
  self.keyboardManager_isFirstResponder = YES;
  return [self keyboardManager_becomeFirstResponder];
}

- (BOOL)keyboardManager_resignFirstResponder {
  self.keyboardManager_isFirstResponder = NO;
  return [self keyboardManager_resignFirstResponder];
}

- (void)setKeyboardManager_isFirstResponder:(BOOL)keyboardManager_isFirstResponder {
  objc_setAssociatedObject(self, @selector(keyboardManager_isFirstResponder), @(keyboardManager_isFirstResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)keyboardManager_isFirstResponder {
  return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end

@interface UIKeyboardUserInfo ()
@property(nonatomic, weak, readwrite) UIKeyboardManager *keyboardManager;
@property(nonatomic, strong, readwrite) NSNotification *notification;
@property(nonatomic, weak, readwrite) UIResponder *targetResponder;
@property(nonatomic, assign) BOOL isTargetResponderFocused;
@property(nonatomic, assign, readwrite) CGFloat width;
@property(nonatomic, assign, readwrite) CGFloat height;
@property(nonatomic, assign, readwrite) CGRect beginFrame;
@property(nonatomic, assign, readwrite) CGRect endFrame;
@property(nonatomic, assign, readwrite) NSTimeInterval animationDuration;
@property(nonatomic, assign, readwrite) UIViewAnimationCurve animationCurve;
@property(nonatomic, assign, readwrite) UIViewAnimationOptions animationOptions;
@end

@implementation UIKeyboardUserInfo

- (void)setNotification:(NSNotification *)notification {
  _notification = notification;
  if (self.originUserInfo) {
    _animationDuration = [[self.originUserInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _animationCurve = (UIViewAnimationCurve)[[self.originUserInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    _animationOptions = self.animationCurve<<16;
    _beginFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _endFrame = [[self.originUserInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  }
}

- (void)setTargetResponder:(UIResponder *)targetResponder {
  _targetResponder = targetResponder;
  self.isTargetResponderFocused = targetResponder && targetResponder.keyboardManager_isFirstResponder;
}

- (NSDictionary *)originUserInfo {
  return self.notification ? self.notification.userInfo : nil;
}

- (CGFloat)width {
  CGRect keyboardRect = [UIKeyboardManager convertKeyboardRect:_endFrame toView:nil];
  return keyboardRect.size.width;
}

- (CGFloat)height {
  CGRect keyboardRect = [UIKeyboardManager convertKeyboardRect:_endFrame toView:nil];
  return keyboardRect.size.height;
}

- (CGFloat)heightInView:(UIView *)view {
  if (!view) {
    return [self height];
  }
  CGRect keyboardRect = [UIKeyboardManager convertKeyboardRect:_endFrame toView:view];
  CGRect visiableRect = CGRectIntersection(view.bounds, keyboardRect);
  if (CGRectIsNull(visiableRect)) {
    return 0;
  }
  return visiableRect.size.height;
}

- (CGRect)beginFrame {
  return _beginFrame;
}

- (CGRect)endFrame {
  return _endFrame;
}

- (NSTimeInterval)animationDuration {
  return _animationDuration;
}

- (UIViewAnimationCurve)animationCurve {
  return _animationCurve;
}

- (UIViewAnimationOptions)animationOptions {
  return _animationOptions;
}
@end

@interface UIKeyboardViewFrameObserver : NSObject
@property (nonatomic, copy) void (^keyboardViewChangeFrameBlock)(UIView *keyboardView);
- (void)addToKeyboardView:(UIView *)keyboardView;
+ (instancetype)observerForView:(UIView *)keyboardView;
@end

static char kAssociatedObjectKey_KeyboardViewFrameObserver;

@implementation UIKeyboardViewFrameObserver {
  __unsafe_unretained UIView *_keyboardView;
}

- (void)addToKeyboardView:(UIView *)keyboardView {
  if (_keyboardView == keyboardView) {
    return;
  }
  if (_keyboardView) {
    [self removeFrameObserver];
    objc_setAssociatedObject(_keyboardView, &kAssociatedObjectKey_KeyboardViewFrameObserver, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  _keyboardView = keyboardView;
  if (keyboardView) {
    [self addFrameObserver];
  }
  objc_setAssociatedObject(keyboardView, &kAssociatedObjectKey_KeyboardViewFrameObserver, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addFrameObserver {
  if (!_keyboardView) {
    return;
  }
  [_keyboardView addObserver:self forKeyPath:@"frame" options:kNilOptions context:NULL];
  [_keyboardView addObserver:self forKeyPath:@"center" options:kNilOptions context:NULL];
  [_keyboardView addObserver:self forKeyPath:@"bounds" options:kNilOptions context:NULL];
  [_keyboardView addObserver:self forKeyPath:@"transform" options:kNilOptions context:NULL];
}

- (void)removeFrameObserver {
  [_keyboardView removeObserver:self forKeyPath:@"frame"];
  [_keyboardView removeObserver:self forKeyPath:@"center"];
  [_keyboardView removeObserver:self forKeyPath:@"bounds"];
  [_keyboardView removeObserver:self forKeyPath:@"transform"];
  _keyboardView = nil;
}

- (void)dealloc {
  [self removeFrameObserver];
}

+ (instancetype)observerForView:(UIView *)keyboardView {
  if (!keyboardView) {
    return nil;
  }
  return objc_getAssociatedObject(keyboardView, &kAssociatedObjectKey_KeyboardViewFrameObserver);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (![keyPath isEqualToString:@"frame"] &&
      ![keyPath isEqualToString:@"center"] &&
      ![keyPath isEqualToString:@"bounds"] &&
      ![keyPath isEqualToString:@"transform"]) {
    return;
  }
  if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
    return;
  }
  if ([[change objectForKey:NSKeyValueChangeKindKey] integerValue] != NSKeyValueChangeSetting) {
    return;
  }
  id newValue = [change objectForKey:NSKeyValueChangeNewKey];
  if (newValue == [NSNull null]) { newValue = nil; }
  if (self.keyboardViewChangeFrameBlock) {
    self.keyboardViewChangeFrameBlock(_keyboardView);
  }
}

@end

@interface UIKeyboardManager ()
@property(nonatomic, strong) NSMutableArray <NSValue *> *targetResponderValues;
@property(nonatomic, strong) UIKeyboardUserInfo *keyboardMoveUserInfo;
@property(nonatomic, assign) CGRect keyboardMoveBeginRect;
@property(nonatomic, assign) BOOL debug;
@end

static UIResponder *kCurrentResponder = nil;

@implementation UIKeyboardManager

- (instancetype)init {
  NSAssert(NO, @"请使用initWithDelegate:初始化");
  return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  NSAssert(NO, @"请使用initWithDelegate:初始化");
  return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id <UIKeyboardManagerDelegate>)delegate {
  if (self = [super init]) {
    _delegate = delegate;
    _delegateEnabled = YES;
    _targetResponderValues = [[NSMutableArray alloc] init];
    [self addKeyboardNotification];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)addTargetResponder:(UIResponder *)targetResponder {
  if (!targetResponder || ![targetResponder isKindOfClass:[UIResponder class]]) {
    return NO;
  }
  [self.targetResponderValues addObject:[self packageTargetResponder:targetResponder]];
  return YES;
}

- (NSArray<UIResponder *> *)allTargetResponders {
  NSMutableArray *targetResponders = nil;
  for (int i = 0; i < self.targetResponderValues.count; i++) {
    if (!targetResponders) {
      targetResponders = [[NSMutableArray alloc] init];
    }
    id unPackageValue = [self unPackageTargetResponder:self.targetResponderValues[i]];
    if (unPackageValue && [unPackageValue isKindOfClass:[UIResponder class]]) {
      [targetResponders addObject:(UIResponder *)unPackageValue];
    }
  }
  return [targetResponders copy];
}

- (NSValue *)packageTargetResponder:(UIResponder *)targetResponder {
  if (![targetResponder isKindOfClass:[UIResponder class]]) {
    return nil;
  }
  return [NSValue valueWithNonretainedObject:targetResponder];
}

- (UIResponder *)unPackageTargetResponder:(NSValue *)value {
  if (!value) {
    return nil;
  }
  id unPackageValue = [value nonretainedObjectValue];
  if (![unPackageValue isKindOfClass:[UIResponder class]]) {
    return nil;
  }
  return (UIResponder *)unPackageValue;
}

#pragma mark - Notification

- (void)addKeyboardNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShowNotification:)
                                               name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidShowNotification:)
                                               name:UIKeyboardDidShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHideNotification:)
                                               name:UIKeyboardWillHideNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidHideNotification:)
                                               name:UIKeyboardDidHideNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillChangeFrameNotification:)
                                               name:UIKeyboardWillChangeFrameNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidChangeFrameNotification:)
                                               name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
  
  if (self.debug) {
    NSLog(@"keyboardWillShowNotification - %@", self);
    NSLog(@"\n");
  }
  
  if (![self shouldReceiveShowNotification]) {
    return;
  }
  
  UIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
  userInfo.targetResponder = kCurrentResponder ?: nil;
  
  if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillShowWithUserInfo:)]) {
    [self.delegate keyboardWillShowWithUserInfo:userInfo];
  }
  
  // 额外处理iPad浮动键盘
  if (IS_IPAD) {
    self.keyboardMoveUserInfo = userInfo;
    [self keyboardDidChangedFrame:[self.class keyboardView]];
  }
}

- (void)keyboardDidShowNotification:(NSNotification *)notification {
  
  if (self.debug) {
    NSLog(@"keyboardDidShowNotification - %@", self);
    NSLog(@"\n");
  }
  
  UIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
  userInfo.targetResponder = kCurrentResponder ?: nil;
  
  id firstResponder = [[UIApplication sharedApplication].keyWindow findFirstResponder];
  BOOL shouldReceiveDidShowNotification = self.targetResponderValues.count <= 0 || (firstResponder && firstResponder == kCurrentResponder);
  
  if (shouldReceiveDidShowNotification) {
    
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidShowWithUserInfo:)]) {
      [self.delegate keyboardDidShowWithUserInfo:userInfo];
    }
    
    // 额外处理iPad浮动键盘
    if (IS_IPAD) {
      self.keyboardMoveUserInfo = userInfo;
      [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
  }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
  
  if (self.debug) {
    NSLog(@"keyboardWillHideNotification - %@", self);
    NSLog(@"\n");
  }
  
  if (![self shouldReceiveHideNotification]) {
    return;
  }
  
  UIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
  userInfo.targetResponder = kCurrentResponder ?: nil;
  
  if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillHideWithUserInfo:)]) {
    [self.delegate keyboardWillHideWithUserInfo:userInfo];
  }
  
  // 额外处理iPad浮动键盘
  if (IS_IPAD) {
    self.keyboardMoveUserInfo = userInfo;
    [self keyboardDidChangedFrame:[self.class keyboardView]];
  }
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
  
  if (self.debug) {
    NSLog(@"keyboardDidHideNotification - %@", self);
    NSLog(@"\n");
  }
  
  UIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
  userInfo.targetResponder = kCurrentResponder ?: nil;
  
  if ([self shouldReceiveHideNotification]) {
    if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidHideWithUserInfo:)]) {
      [self.delegate keyboardDidHideWithUserInfo:userInfo];
    }
  }
  
  if (kCurrentResponder &&
      !kCurrentResponder.keyboardManager_isFirstResponder &&
      !IS_IPAD) {
    kCurrentResponder = nil;
  }
  
  // 额外处理iPad浮动键盘
  if (IS_IPAD) {
    if (self.targetResponderValues.count <= 0 || kCurrentResponder) {
      self.keyboardMoveUserInfo = userInfo;
      [self keyboardDidChangedFrame:[self.class keyboardView]];
    }
  }
}

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification {
  
  if (self.debug) {
    NSLog(@"keyboardWillChangeFrameNotification - %@", self);
    NSLog(@"\n");
  }
  
  UIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
  
  if ([self shouldReceiveShowNotification]) {
    userInfo.targetResponder = kCurrentResponder ?: nil;
  } else if ([self shouldReceiveHideNotification]) {
    userInfo.targetResponder = kCurrentResponder ?: nil;
  } else {
    return;
  }
  
  if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
    [self.delegate keyboardWillChangeFrameWithUserInfo:userInfo];
  }
  
  // 额外处理iPad浮动键盘
  if (IS_IPAD) {
    self.keyboardMoveUserInfo = userInfo;
    [self addFrameObserverIfNeeded];
  }
}

- (void)keyboardDidChangeFrameNotification:(NSNotification *)notification {
  
  if (self.debug) {
    NSLog(@"keyboardDidChangeFrameNotification - %@", self);
    NSLog(@"\n");
  }
  
  UIKeyboardUserInfo *userInfo = [self newUserInfoWithNotification:notification];
  
  if ([self shouldReceiveShowNotification]) {
    userInfo.targetResponder = kCurrentResponder ?: nil;
  } else if ([self shouldReceiveHideNotification]) {
    userInfo.targetResponder = kCurrentResponder ?: nil;
  } else {
    return;
  }
  
  if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardDidChangeFrameWithUserInfo:)]) {
    [self.delegate keyboardDidChangeFrameWithUserInfo:userInfo];
  }
  
  // 额外处理iPad浮动键盘
  if (IS_IPAD) {
    self.keyboardMoveUserInfo = userInfo;
    [self keyboardDidChangedFrame:[self.class keyboardView]];
  }
}

- (UIKeyboardUserInfo *)newUserInfoWithNotification:(NSNotification *)notification {
  UIKeyboardUserInfo *userInfo = [[UIKeyboardUserInfo alloc] init];
  userInfo.keyboardManager = self;
  userInfo.notification = notification;
  return userInfo;
}

- (BOOL)shouldReceiveShowNotification {
  
  kCurrentResponder = [[UIApplication sharedApplication].keyWindow findFirstResponder];
  
  if (self.targetResponderValues.count <= 0) {
    return YES;
  } else {
    return kCurrentResponder && [self.targetResponderValues containsObject:[self packageTargetResponder:kCurrentResponder]];
  }
}

- (BOOL)shouldReceiveHideNotification {
  if (self.targetResponderValues.count <= 0) {
    return YES;
  } else {
    if (kCurrentResponder) {
      return [self.targetResponderValues containsObject:[self packageTargetResponder:kCurrentResponder]];
    } else {
      return NO;
    }
  }
}

#pragma mark - iPad浮动键盘

- (void)addFrameObserverIfNeeded {
  if (![self.class keyboardView]) {
    return;
  }
  __weak __typeof(self)weakSelf = self;
  UIKeyboardViewFrameObserver *observer = [UIKeyboardViewFrameObserver observerForView:[self.class keyboardView]];
  if (!observer) {
    observer = [[UIKeyboardViewFrameObserver alloc] init];
    observer.keyboardViewChangeFrameBlock = ^(UIView *keyboardView) {
      [weakSelf keyboardDidChangedFrame:keyboardView];
    };
    [observer addToKeyboardView:[self.class keyboardView]];
    // 手动调用第一次
    [self keyboardDidChangedFrame:[self.class keyboardView]];
  }
}

- (void)keyboardDidChangedFrame:(UIView *)keyboardView {
  
  if (keyboardView != [self.class keyboardView]) {
    return;
  }
  
  // 也需要判断targetResponder
  if (![self shouldReceiveShowNotification] && ![self shouldReceiveHideNotification]) {
    return;
  }
  
  if (self.delegateEnabled && [self.delegate respondsToSelector:@selector(keyboardWillChangeFrameWithUserInfo:)]) {
    
    UIWindow *keyboardWindow = keyboardView.window;
    
    if (self.keyboardMoveBeginRect.size.width == 0 && self.keyboardMoveBeginRect.size.height == 0) {
      // 第一次需要初始化
      self.keyboardMoveBeginRect = CGRectMake(0, keyboardWindow.bounds.size.height, keyboardWindow.bounds.size.width, 0);
    }
    
    CGRect endFrame = CGRectZero;
    if (keyboardWindow) {
      endFrame = [keyboardWindow convertRect:keyboardView.frame toWindow:nil];
    } else {
      endFrame = keyboardView.frame;
    }
    
    // 自己构造一个UIKeyboardUserInfo，一些属性使用之前最后一个keyboardUserInfo的值
    UIKeyboardUserInfo *keyboardMoveUserInfo = [[UIKeyboardUserInfo alloc] init];
    keyboardMoveUserInfo.keyboardManager = self;
    keyboardMoveUserInfo.targetResponder = self.keyboardMoveUserInfo ? self.keyboardMoveUserInfo.targetResponder : nil;
    keyboardMoveUserInfo.animationDuration = self.keyboardMoveUserInfo ? self.keyboardMoveUserInfo.animationDuration : 0.25;
    keyboardMoveUserInfo.animationCurve = self.keyboardMoveUserInfo ? self.keyboardMoveUserInfo.animationCurve : 7;
    keyboardMoveUserInfo.animationOptions = self.keyboardMoveUserInfo ? self.keyboardMoveUserInfo.animationOptions : keyboardMoveUserInfo.animationCurve<<16;
    keyboardMoveUserInfo.beginFrame = self.keyboardMoveBeginRect;
    keyboardMoveUserInfo.endFrame = endFrame;
    
    if (self.debug) {
      NSLog(@"keyboardDidMoveNotification - %@", self);
      NSLog(@"\n");
    }
    
    [self.delegate keyboardWillChangeFrameWithUserInfo:keyboardMoveUserInfo];
    
    self.keyboardMoveBeginRect = endFrame;
    
    if (kCurrentResponder) {
      UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow ?: [[UIApplication sharedApplication] windows].firstObject;
      if (mainWindow) {
        CGRect keyboardRect = keyboardMoveUserInfo.endFrame;
        CGFloat distanceFromBottom = [UIKeyboardManager distanceFromMinYToBottomInView:mainWindow keyboardRect:keyboardRect];
        if (distanceFromBottom < keyboardRect.size.height) {
          if (!kCurrentResponder.keyboardManager_isFirstResponder) {
            // willHide
            kCurrentResponder = nil;
          }
        } else if (distanceFromBottom > keyboardRect.size.height && !kCurrentResponder.isFirstResponder) {
          if (!kCurrentResponder.keyboardManager_isFirstResponder) {
            // 浮动
            kCurrentResponder = nil;
          }
        }
      }
    }
    
  }
}

#pragma mark - 工具方法

+ (void)animateWithAnimated:(BOOL)animated keyboardUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
  if (animated) {
    [UIView animateWithDuration:keyboardUserInfo.animationDuration delay:0 options:keyboardUserInfo.animationOptions|UIViewAnimationOptionBeginFromCurrentState animations:^{
      if (animations) {
        animations();
      }
    } completion:^(BOOL finished) {
      if (completion) {
        completion(finished);
      }
    }];
  } else {
    if (animations) {
      animations();
    }
    if (completion) {
      completion(YES);
    }
  }
}

+ (void)handleKeyboardNotificationWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo showBlock:(void (^)(UIKeyboardUserInfo *keyboardUserInfo))showBlock hideBlock:(void (^)(UIKeyboardUserInfo *keyboardUserInfo))hideBlock {
  // 专门处理 iPad Pro 在键盘完全不显示的情况（不会调用willShow，所以通过是否focus来判断）
  if ([UIKeyboardManager visiableKeyboardHeight] <= 0 && !keyboardUserInfo.isTargetResponderFocused) {
    if (hideBlock) {
      hideBlock(keyboardUserInfo);
    }
  } else {
    if (showBlock) {
      showBlock(keyboardUserInfo);
    }
  }
}

+ (UIWindow *)keyboardWindow {
  
  for (UIWindow *window in [UIApplication sharedApplication].windows) {
    if ([self getKeyboardViewFromWindow:window]) {
      return window;
    }
  }
  
  NSMutableArray *kbWindows = nil;
  
  for (UIWindow *window in [UIApplication sharedApplication].windows) {
    NSString *windowName = NSStringFromClass(window.class);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9) {
      // UITextEffectsWindow
      if (windowName.length == 19 &&
          [windowName hasPrefix:@"UI"] &&
          [windowName hasSuffix:[NSString stringWithFormat:@"%@%@", @"TextEffects", @"Window"]]) {
        if (!kbWindows) kbWindows = [NSMutableArray new];
        [kbWindows addObject:window];
      }
    } else {
      // UIRemoteKeyboardWindow
      if (windowName.length == 22 &&
          [windowName hasPrefix:@"UI"] &&
          [windowName hasSuffix:[NSString stringWithFormat:@"%@%@", @"Remote", @"KeyboardWindow"]]) {
        if (!kbWindows) kbWindows = [NSMutableArray new];
        [kbWindows addObject:window];
      }
    }
  }
  
  if (kbWindows.count == 1) {
    return kbWindows.firstObject;
  }
  
  return nil;
}

+ (CGRect)convertKeyboardRect:(CGRect)rect toView:(UIView *)view {
  
  if (CGRectIsNull(rect) || CGRectIsInfinite(rect)) {
    return rect;
  }
  
  UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
  if (!mainWindow) {
    if (view) {
      [view convertRect:rect fromView:nil];
    } else {
      return rect;
    }
  }
  
  rect = [mainWindow convertRect:rect fromWindow:nil];
  if (!view) {
    return [mainWindow convertRect:rect toWindow:nil];
  }
  if (view == mainWindow) {
    return rect;
  }
  
  UIWindow *toWindow = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
  if (!mainWindow || !toWindow) {
    return [mainWindow convertRect:rect toView:view];
  }
  if (mainWindow == toWindow) {
    return [mainWindow convertRect:rect toView:view];
  }
  
  rect = [mainWindow convertRect:rect toView:mainWindow];
  rect = [toWindow convertRect:rect fromWindow:mainWindow];
  rect = [view convertRect:rect fromView:toWindow];
  
  return rect;
}

+ (CGFloat)distanceFromMinYToBottomInView:(UIView *)view keyboardRect:(CGRect)rect {
  rect = [self convertKeyboardRect:rect toView:view];
  CGFloat distance = CGRectGetHeight(view.bounds) - CGRectGetMinY(rect);
  return distance;
}

+ (UIView *)keyboardView {
  for (UIWindow *window in [UIApplication sharedApplication].windows) {
    UIView *view = [self getKeyboardViewFromWindow:window];
    if (view) {
      return view;
    }
  }
  return nil;
}

+ (UIView *)getKeyboardViewFromWindow:(UIWindow *)window {
  
  if (!window) return nil;
  
  NSString *windowName = NSStringFromClass(window.class);
  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9) {
    if (![windowName isEqualToString:@"UITextEffectsWindow"]) {
      return nil;
    }
  } else {
    if (![windowName isEqualToString:@"UIRemoteKeyboardWindow"]) {
      return nil;
    }
  }
  
  for (UIView *view in window.subviews) {
    NSString *viewName = NSStringFromClass(view.class);
    if (![viewName isEqualToString:@"UIInputSetContainerView"]) {
      continue;
    }
    
    for (UIView *subView in view.subviews) {
      NSString *subViewName = NSStringFromClass(subView.class);
      if (![subViewName isEqualToString:@"UIInputSetHostView"]) {
        continue;
      }
      return subView;
    }
  }
  
  return nil;
}

+ (BOOL)isKeyboardVisible {
  UIView *keyboardView = self.keyboardView;
  UIWindow *keyboardWindow = keyboardView.window;
  if (!keyboardView || !keyboardWindow) {
    return NO;
  }
  CGRect rect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
  if (CGRectIsNull(rect) || CGRectIsInfinite(rect)) {
    return NO;
  }
  return rect.size.width > 0 && rect.size.height > 0;
}

+ (CGRect)currentKeyboardFrame {
  UIView *keyboardView = [self keyboardView];
  if (!keyboardView) {
    return CGRectNull;
  }
  UIWindow *keyboardWindow = keyboardView.window;
  if (keyboardWindow) {
    return [keyboardWindow convertRect:keyboardView.frame toWindow:nil];
  } else {
    return keyboardView.frame;
  }
}

+ (CGFloat)visiableKeyboardHeight {
  UIView *keyboardView = [self keyboardView];
  UIWindow *keyboardWindow = keyboardView.window;
  if (!keyboardView || !keyboardWindow) {
    return 0;
  } else {
    CGRect visiableRect = CGRectIntersection(keyboardWindow.bounds, keyboardView.frame);
    if (CGRectIsNull(visiableRect)) {
      return 0;
    }
    return visiableRect.size.height;
  }
}

@end

@implementation UITextField (UIKeyboardManager)

- (void)setKeyboardWillShowNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardWillShowNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardWillShowNotificationBlock), keyboardWillShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardWillShowNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardWillShowNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardDidShowNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardDidShowNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardDidShowNotificationBlock), keyboardDidShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardDidShowNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardDidShowNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardWillHideNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardWillHideNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardWillHideNotificationBlock), keyboardWillHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardWillHideNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardWillHideNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardDidHideNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardDidHideNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardDidHideNotificationBlock), keyboardDidHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardDidHideNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardDidHideNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardWillChangeFrameNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardWillChangeFrameNotificationBlock), keyboardWillChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardWillChangeFrameNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardDidChangeFrameNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardDidChangeFrameNotificationBlock), keyboardDidChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardDidChangeFrameNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardManager:(UIKeyboardManager *)keyboardManager {
  objc_setAssociatedObject(self, @selector(keyboardManager), keyboardManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIKeyboardManager *)keyboardManager {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)initKeyboardManagerIfNeeded {
  if (!self.keyboardManager) {
    self.keyboardManager = [[UIKeyboardManager alloc] initWithDelegate:self];
    [self.keyboardManager addTargetResponder:self];
  }
}

#pragma mark - <UIKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardWillShowNotificationBlock) {
    self.keyboardWillShowNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardWillHideWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardWillHideNotificationBlock) {
    self.keyboardWillHideNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardWillChangeFrameWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardWillChangeFrameNotificationBlock) {
    self.keyboardWillChangeFrameNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardDidShowWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardDidShowNotificationBlock) {
    self.keyboardDidShowNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardDidHideWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardDidHideNotificationBlock) {
    self.keyboardDidHideNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardDidChangeFrameWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardDidChangeFrameNotificationBlock) {
    self.keyboardDidChangeFrameNotificationBlock(keyboardUserInfo);
  }
}

@end

@implementation UITextView (UIKeyboardManager)

- (void)setKeyboardWillShowNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardWillShowNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardWillShowNotificationBlock), keyboardWillShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardWillShowNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardWillShowNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardDidShowNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardDidShowNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardDidShowNotificationBlock), keyboardDidShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardDidShowNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardDidShowNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardWillHideNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardWillHideNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardWillHideNotificationBlock), keyboardWillHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardWillHideNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardWillHideNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardDidHideNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardDidHideNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardDidHideNotificationBlock), keyboardDidHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardDidHideNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardDidHideNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardWillChangeFrameNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardWillChangeFrameNotificationBlock), keyboardWillChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardWillChangeFrameNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardDidChangeFrameNotificationBlock:(void (^)(UIKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
  objc_setAssociatedObject(self, @selector(keyboardDidChangeFrameNotificationBlock), keyboardDidChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  if (keyboardDidChangeFrameNotificationBlock) {
    [self initKeyboardManagerIfNeeded];
  }
}

- (void (^)(UIKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setKeyboardManager:(UIKeyboardManager *)keyboardManager {
  objc_setAssociatedObject(self, @selector(keyboardManager), keyboardManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIKeyboardManager *)keyboardManager {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)initKeyboardManagerIfNeeded {
  if (!self.keyboardManager) {
    self.keyboardManager = [[UIKeyboardManager alloc] initWithDelegate:self];
    [self.keyboardManager addTargetResponder:self];
  }
}

#pragma mark - <UIKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardWillShowNotificationBlock) {
    self.keyboardWillShowNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardWillHideWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardWillHideNotificationBlock) {
    self.keyboardWillHideNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardWillChangeFrameWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardWillChangeFrameNotificationBlock) {
    self.keyboardWillChangeFrameNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardDidShowWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardDidShowNotificationBlock) {
    self.keyboardDidShowNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardDidHideWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardDidHideNotificationBlock) {
    self.keyboardDidHideNotificationBlock(keyboardUserInfo);
  }
}

- (void)keyboardDidChangeFrameWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (self.keyboardDidChangeFrameNotificationBlock) {
    self.keyboardDidChangeFrameNotificationBlock(keyboardUserInfo);
  }
}

@end
