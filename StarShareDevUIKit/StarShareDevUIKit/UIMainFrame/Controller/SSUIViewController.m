//
//  SSUIViewController.m
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import "SSUIViewController.h"
#import "UIExtensions.h"
#import "SSUINavigationController.h"
#import "UIComponents.h"
#import "UICore.h"

@interface SSUIViewControllerHideKeyboardDelegateObject : NSObject <UIGestureRecognizerDelegate, UIKeyboardManagerDelegate>
@property(nonatomic, weak) SSUIViewController *viewController;
- (instancetype)initWithViewController:(SSUIViewController *)viewController;
@end

@interface SSUIViewController (){
  UITapGestureRecognizer *_hideKeyboardTapGestureRecognizer;
  UIKeyboardManager *_hideKeyboardManager;
  SSUIViewControllerHideKeyboardDelegateObject *_hideKeyboadDelegateObject;
}
@property(nonatomic,strong,readwrite) UINavigationTitleView *titleView;
@end

@implementation SSUIViewController
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - 生命周期

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    [self didInitialized];
  }
  return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  if (self = [super initWithCoder:aDecoder]) {
    [self didInitialized];
  }
  return self;
}
- (void)didInitialized
{
  self.titleView = [[UINavigationTitleView alloc] init];
  self.titleView.title = self.title;
  
  self.hidesBottomBarWhenPushed = HidesBottomBarWhenPushedInitially;
  self.extendedLayoutIncludesOpaqueBars = YES;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(contentSizeCategoryDidChanged:)
                                               name:UIContentSizeCategoryDidChangeNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(significantTimeChange:)
                                               name:UIApplicationSignificantTimeChangeNotification
                                             object:nil];
  self.supportedOrientationMask = SupportedOrientationMask;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self setNavigationItemsIsInEditMode:NO animated:NO];
  [self setToolbarItemsIsInEditMode:NO animated:NO];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self needLayoutSubviews];
}

- (void)setTitle:(NSString *)title {
  [super setTitle:title];
  self.titleView.title = title;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  if (!self.view.backgroundColor) {
    UIColor *backgroundColor = UIColorForBackground;
    if (backgroundColor) {
      self.view.backgroundColor = backgroundColor;
    }
  }
  
  _hideKeyboadDelegateObject = [[SSUIViewControllerHideKeyboardDelegateObject alloc] initWithViewController:self];
  _hideKeyboardTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
  self.hideKeyboardTapGestureRecognizer.delegate = _hideKeyboadDelegateObject;
  self.hideKeyboardTapGestureRecognizer.enabled = NO;
  [self.view addGestureRecognizer:self.hideKeyboardTapGestureRecognizer];
  _hideKeyboardManager = [[UIKeyboardManager alloc] initWithDelegate:_hideKeyboadDelegateObject];
  
  [self initSubviews];
}

#pragma mark - 空列表视图 UIEmptyView

- (void)showEmptyView {
  if (!self.emptyView) {
    self.emptyView = [[UIEmptyView alloc] initWithFrame:self.view.bounds];
  }
  [self.view addSubview:self.emptyView];
}

- (void)hideEmptyView {
  [self.emptyView removeFromSuperview];
}

- (BOOL)isEmptyViewShowing {
  return self.emptyView && self.emptyView.superview;
}

- (void)showEmptyViewWithLoading {
  [self showEmptyView];
  [self.emptyView setImage:nil];
  [self.emptyView setLoadingViewHidden:NO];
  [self.emptyView setTextLabelText:nil];
  [self.emptyView setDetailTextLabelText:nil];
  [self.emptyView setActionButtonTitle:nil];
}

- (void)showEmptyViewWithText:(NSString * _Nullable)text
                   detailText:(NSString * _Nullable)detailText
                  buttonTitle:(NSString * _Nullable)buttonTitle
                 buttonAction:(SEL)action {
  [self showEmptyViewWithLoading:NO
                           image:nil
                            text:text
                      detailText:detailText
                     buttonTitle:buttonTitle
                    buttonAction:action];
}

- (void)showEmptyViewWithImage:(UIImage * _Nullable)image
                          text:(NSString * _Nullable)text
                    detailText:(NSString * _Nullable)detailText
                   buttonTitle:(NSString * _Nullable)buttonTitle
                  buttonAction:(SEL)action {
  [self showEmptyViewWithLoading:NO
                           image:image
                            text:text
                      detailText:detailText
                     buttonTitle:buttonTitle
                    buttonAction:action];
}

- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage * _Nullable)image
                            text:(NSString * _Nullable)text
                      detailText:(NSString * _Nullable)detailText
                     buttonTitle:(NSString * _Nullable)buttonTitle
                    buttonAction:(SEL)action {
  [self showEmptyView];
  [self.emptyView setLoadingViewHidden:!showLoading];
  [self.emptyView setImage:image];
  [self.emptyView setTextLabelText:text];
  [self.emptyView setDetailTextLabelText:detailText];
  [self.emptyView setActionButtonTitle:buttonTitle];
  [self.emptyView.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
  [self.emptyView.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)layoutEmptyView {
  if (self.emptyView) {
    // 由于为self.emptyView设置frame时会调用到self.view，为了避免导致viewDidLoad提前触发，这里需要判断一下self.view是否已经被初始化
    BOOL viewDidLoad = self.emptyView.superview || [self isViewLoaded];
    if (viewDidLoad) {
      CGSize newEmptyViewSize = self.emptyView.superview.bounds.size;
      CGSize oldEmptyViewSize = self.emptyView.frame.size;
      if (!CGSizeEqualToSize(newEmptyViewSize, oldEmptyViewSize)) {
        self.emptyView.frame = CGRectMake(CGRectGetMinX(self.emptyView.frame), CGRectGetMinY(self.emptyView.frame), newEmptyViewSize.width, newEmptyViewSize.height);
      }
      return YES;
    }
  }
  
  return NO;
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
  return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return self.supportedOrientationMask;
}

#pragma mark - <UINavigationControllerDelegate>

- (BOOL)shouldSetStatusBarStyleLight {
  return StatusbarStyleLightInitially;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return StatusbarStyleLightInitially ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)preferredNavigationBarHidden {
  return NavigationBarHiddenInitially;
}

- (void)viewControllerKeepingAppearWhenSetViewControllersWithAnimated:(BOOL)animated {
  [self setNavigationItemsIsInEditMode:NO animated:NO];
  [self setToolbarItemsIsInEditMode:NO animated:NO];
}

#pragma clang diagnostic pop
@end

@implementation SSUIViewController (UIKeyboard)
- (UITapGestureRecognizer *)hideKeyboardTapGestureRecognizer {
  return _hideKeyboardTapGestureRecognizer;
}
- (UIKeyboardManager *)hideKeyboardManager {
  return _hideKeyboardManager;
}
- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
  return NO;
}
@end

@implementation SSUIViewControllerHideKeyboardDelegateObject

- (instancetype)initWithViewController:(SSUIViewController *)viewController {
  if (self = [super init]) {
    self.viewController = viewController;
  }
  return self;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer != self.viewController.hideKeyboardTapGestureRecognizer) {
    return YES;
  }
  
  if (![UIKeyboardManager isKeyboardVisible]) {
    return NO;
  }
  
  UIView *targetView = nil;
  CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
  targetView = [gestureRecognizer.view hitTest:location withEvent:nil];
  
  // 点击了本身就是输入框的 view，就不要降下键盘了
  if ([targetView isKindOfClass:[UITextField class]] || [targetView isKindOfClass:[UITextView class]]) {
    return NO;
  }
  
  if ([self.viewController shouldHideKeyboardWhenTouchInView:targetView]) {
    [self.viewController.view endEditing:YES];
  }
  return NO;
}

#pragma mark - <UIKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  if (![self.viewController isViewLoadedAndVisible]) return;
  BOOL hasOverrideMethod = [self.viewController hasOverrideMethod:@selector(shouldHideKeyboardWhenTouchInView:) ofSuperclass:[SSUIViewController class]];
  self.viewController.hideKeyboardTapGestureRecognizer.enabled = hasOverrideMethod;
}

- (void)keyboardWillHideWithUserInfo:(UIKeyboardUserInfo *)keyboardUserInfo {
  self.viewController.hideKeyboardTapGestureRecognizer.enabled = NO;
}

@end

@implementation SSUIViewController (Hooks)
- (void)initSubviews {}
- (void)needLayoutSubviews {
  [self layoutEmptyView];
}
- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
  self.navigationItem.titleView = self.titleView;
}
- (void)setToolbarItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {}
- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {}
- (void)significantTimeChange:(NSNotification *)notification{}
@end
