//
//  SSUIAlertController.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIAlertController.h"
#import "UICore.h"
#import "UIModalPresentationViewController.h"
#import "SSUIButton.h"
#import "SSUITextField.h"
#import "UIView+UI.h"
#import "UIControl+UI.h"
#import "NSMutableParagraphStyle+UI.h"
#import "UIImage+UI.h"

static NSUInteger alertControllerCount = 0;

#pragma mark - SSUIBUttonWrapView

@interface SSUIAlertButtonWrapView : UIView

@property(nonatomic, strong) SSUIButton *button;
@end

@implementation SSUIAlertButtonWrapView

- (instancetype)init {
  self = [super init];
  if (self) {
    self.button = [[SSUIButton alloc] init];
    self.button.adjustsButtonWhenDisabled = NO;
    self.button.adjustsButtonWhenHighlighted = NO;
    [self addSubview:self.button];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.button.frame = self.bounds;
}

@end

#pragma mark - SSUIAlertAction

@protocol SSUIAlertActionDelegate <NSObject>

- (void)didClickAlertAction:(SSUIAlertAction *)alertAction;

@end

@interface SSUIAlertAction ()

@property(nonatomic, strong) SSUIAlertButtonWrapView *buttonWrapView;
@property(nonatomic, copy, readwrite) NSString *title;
@property(nonatomic, assign, readwrite) SSUIAlertActionStyle style;
@property(nonatomic, copy) void (^handler)(SSUIAlertAction *action);
@property(nonatomic, weak) id<SSUIAlertActionDelegate> delegate;

@end

@implementation SSUIAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(SSUIAlertActionStyle)style handler:(void (^)(SSUIAlertAction *action))handler {
  SSUIAlertAction *alertAction = [[SSUIAlertAction alloc] init];
  alertAction.title = title;
  alertAction.style = style;
  alertAction.handler = handler;
  return alertAction;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.buttonWrapView = [[SSUIAlertButtonWrapView alloc] init];
    self.button.automaticallyAdjustTouchHighlightedInScrollView = YES;
    [self.button addTarget:self action:@selector(handleAlertActionEvent:) forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (SSUIButton *)button {
  return self.buttonWrapView.button;
}

- (void)setEnabled:(BOOL)enabled {
  _enabled = enabled;
  self.button.enabled = enabled;
}

- (void)handleAlertActionEvent:(id)sender {
  // 需要先调delegate，里面会先恢复keywindow
  if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAlertAction:)]) {
    [self.delegate didClickAlertAction:self];
  }
}

@end

@implementation SSUIAlertController (UIAppearance)

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self appearance];
  });
}

static SSUIAlertController *alertControllerAppearance;
+ (instancetype)appearance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self resetAppearance];
  });
  return alertControllerAppearance;
}

+ (void)resetAppearance {
  if (!alertControllerAppearance) {
    
    alertControllerAppearance = [[SSUIAlertController alloc] init];
    
    alertControllerAppearance.alertContentMargin = UIEdgeInsetsMake(0, 0, 0, 0);
    alertControllerAppearance.alertContentMaximumWidth = 270;
    alertControllerAppearance.alertSeperatorColor = UIColorMake(211, 211, 219);
    alertControllerAppearance.alertTitleAttributes = @{NSForegroundColorAttributeName:UIColorBlack,NSFontAttributeName:UIFontBoldMake(17),NSParagraphStyleAttributeName:[NSMutableParagraphStyle paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail]};
    alertControllerAppearance.alertMessageAttributes = @{NSForegroundColorAttributeName:UIColorBlack,NSFontAttributeName:UIFontMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail]};
    alertControllerAppearance.alertButtonAttributes = @{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)};
    alertControllerAppearance.alertButtonDisabledAttributes = @{NSForegroundColorAttributeName:UIColorMake(129, 129, 129),NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)};
    alertControllerAppearance.alertCancelButtonAttributes = @{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontBoldMake(17),NSKernAttributeName:@(0)};
    alertControllerAppearance.alertDestructiveButtonAttributes = @{NSForegroundColorAttributeName:UIColorRed,NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)};
    alertControllerAppearance.alertContentCornerRadius = (IOS_VERSION >= 9.0 ? 13 : 6);
    alertControllerAppearance.alertButtonHeight = 44;
    alertControllerAppearance.alertHeaderBackgroundColor = UIColorMakeWithRGBA(247, 247, 247, 1);
    alertControllerAppearance.alertButtonBackgroundColor = alertControllerAppearance.alertHeaderBackgroundColor;
    alertControllerAppearance.alertButtonHighlightBackgroundColor = UIColorMake(232, 232, 232);
    alertControllerAppearance.alertHeaderInsets = UIEdgeInsetsMake(20, 16, 20, 16);
    alertControllerAppearance.alertTitleMessageSpacing = 3;
    
    alertControllerAppearance.sheetContentMargin = UIEdgeInsetsMake(10, 10, 10, 10);
    alertControllerAppearance.sheetContentMaximumWidth = [UIHelper screenSizeFor55Inch].width - UIEdgeInsetsGetHorizontalValue(alertControllerAppearance.sheetContentMargin);
    alertControllerAppearance.sheetSeperatorColor = UIColorMake(211, 211, 219);
    alertControllerAppearance.sheetTitleAttributes = @{NSForegroundColorAttributeName:UIColorMake(143, 143, 143),NSFontAttributeName:UIFontBoldMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail]};
    alertControllerAppearance.sheetMessageAttributes = @{NSForegroundColorAttributeName:UIColorMake(143, 143, 143),NSFontAttributeName:UIFontMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail]};
    alertControllerAppearance.sheetButtonAttributes = @{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)};
    alertControllerAppearance.sheetButtonDisabledAttributes = @{NSForegroundColorAttributeName:UIColorMake(129, 129, 129),NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)};
    alertControllerAppearance.sheetCancelButtonAttributes = @{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontBoldMake(20),NSKernAttributeName:@(0)};
    alertControllerAppearance.sheetDestructiveButtonAttributes = @{NSForegroundColorAttributeName:UIColorRed,NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)};
    alertControllerAppearance.sheetCancelButtonMarginTop = 8;
    alertControllerAppearance.sheetContentCornerRadius = (IOS_VERSION >= 9.0 ? 13 : 6);
    alertControllerAppearance.sheetButtonHeight = (IOS_VERSION >= 9.0 ? 57 : 44);
    alertControllerAppearance.sheetHeaderBackgroundColor = UIColorMakeWithRGBA(247, 247, 247, 1);
    alertControllerAppearance.sheetButtonBackgroundColor = alertControllerAppearance.sheetHeaderBackgroundColor;
    alertControllerAppearance.sheetButtonHighlightBackgroundColor = UIColorMake(232, 232, 232);
    alertControllerAppearance.sheetHeaderInsets = UIEdgeInsetsMake(16, 16, 16, 16);
    alertControllerAppearance.sheetTitleMessageSpacing = 8;
  }
}

@end

@interface SSUIAlertController () <SSUIAlertActionDelegate, UIModalPresentationContentViewControllerProtocol, UIModalPresentationViewControllerDelegate>

@property(nonatomic, assign, readwrite) SSUIAlertControllerStyle preferredStyle;
@property(nonatomic, strong, readwrite) UIModalPresentationViewController *modalPresentationViewController;

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIControl *maskView;

@property(nonatomic, strong) UIView *scrollWrapView;
@property(nonatomic, strong) UIScrollView *headerScrollView;
@property(nonatomic, strong) UIScrollView *buttonScrollView;

@property(nonatomic, strong) UIView *headerEffectView;
@property(nonatomic, strong) UIView *cancelButtoneEffectView;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageLabel;
@property(nonatomic, strong) SSUIAlertAction *cancelAction;

@property(nonatomic, strong) NSMutableArray<SSUIAlertAction *> *alertActions;
@property(nonatomic, strong) NSMutableArray<SSUIAlertAction *> *destructiveActions;
@property(nonatomic, strong) NSMutableArray<UITextField *> *alertTextFields;

@property(nonatomic, assign) CGFloat keyboardHeight;
@property(nonatomic, assign) BOOL isShowing;

// 保护 showing 的过程中调用 hide 无效
@property(nonatomic, assign) BOOL isNeedsHideAfterAlertShowed;
@property(nonatomic, assign) BOOL isAnimatedForHideAfterAlertShowed;
@end

@implementation SSUIAlertController{
  NSString            *_title;
  BOOL _needsUpdateAction;
  BOOL _needsUpdateTitle;
  BOOL _needsUpdateMessage;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    [self didInitialized];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self didInitialized];
  }
  return self;
}

- (void)didInitialized {
  if (alertControllerAppearance) {
    self.alertContentMargin = [SSUIAlertController appearance].alertContentMargin;
    self.alertContentMaximumWidth = [SSUIAlertController appearance].alertContentMaximumWidth;
    self.alertSeperatorColor = [SSUIAlertController appearance].alertSeperatorColor;
    self.alertContentCornerRadius = [SSUIAlertController appearance].alertContentCornerRadius;
    self.alertTitleAttributes = [SSUIAlertController appearance].alertTitleAttributes;
    self.alertMessageAttributes = [SSUIAlertController appearance].alertMessageAttributes;
    self.alertButtonAttributes = [SSUIAlertController appearance].alertButtonAttributes;
    self.alertButtonDisabledAttributes = [SSUIAlertController appearance].alertButtonDisabledAttributes;
    self.alertCancelButtonAttributes = [SSUIAlertController appearance].alertCancelButtonAttributes;
    self.alertDestructiveButtonAttributes = [SSUIAlertController appearance].alertDestructiveButtonAttributes;
    self.alertButtonHeight = [SSUIAlertController appearance].alertButtonHeight;
    self.alertHeaderBackgroundColor = [SSUIAlertController appearance].alertHeaderBackgroundColor;
    self.alertButtonBackgroundColor = [SSUIAlertController appearance].alertButtonBackgroundColor;
    self.alertButtonHighlightBackgroundColor = [SSUIAlertController appearance].alertButtonHighlightBackgroundColor;
    self.alertHeaderInsets = [SSUIAlertController appearance].alertHeaderInsets;
    self.alertTitleMessageSpacing = [SSUIAlertController appearance].alertTitleMessageSpacing;
    
    self.sheetContentMargin = [SSUIAlertController appearance].sheetContentMargin;
    self.sheetContentMaximumWidth = [SSUIAlertController appearance].sheetContentMaximumWidth;
    self.sheetSeperatorColor = [SSUIAlertController appearance].sheetSeperatorColor;
    self.sheetTitleAttributes = [SSUIAlertController appearance].sheetTitleAttributes;
    self.sheetMessageAttributes = [SSUIAlertController appearance].sheetMessageAttributes;
    self.sheetButtonAttributes = [SSUIAlertController appearance].sheetButtonAttributes;
    self.sheetButtonDisabledAttributes = [SSUIAlertController appearance].sheetButtonDisabledAttributes;
    self.sheetCancelButtonAttributes = [SSUIAlertController appearance].sheetCancelButtonAttributes;
    self.sheetDestructiveButtonAttributes = [SSUIAlertController appearance].sheetDestructiveButtonAttributes;
    self.sheetCancelButtonMarginTop = [SSUIAlertController appearance].sheetCancelButtonMarginTop;
    self.sheetContentCornerRadius = [SSUIAlertController appearance].sheetContentCornerRadius;
    self.sheetButtonHeight = [SSUIAlertController appearance].sheetButtonHeight;
    self.sheetHeaderBackgroundColor = [SSUIAlertController appearance].sheetHeaderBackgroundColor;
    self.sheetButtonBackgroundColor = [SSUIAlertController appearance].sheetButtonBackgroundColor;
    self.sheetButtonHighlightBackgroundColor = [SSUIAlertController appearance].sheetButtonHighlightBackgroundColor;
    self.sheetHeaderInsets = [SSUIAlertController appearance].sheetHeaderInsets;
    self.sheetTitleMessageSpacing = [SSUIAlertController appearance].sheetTitleMessageSpacing;
  }
}

- (void)setAlertButtonAttributes:(NSDictionary<NSString *,id> *)alertButtonAttributes {
  _alertButtonAttributes = alertButtonAttributes;
  _needsUpdateAction = YES;
}

- (void)setSheetButtonAttributes:(NSDictionary<NSString *,id> *)sheetButtonAttributes {
  _sheetButtonAttributes = sheetButtonAttributes;
  _needsUpdateAction = YES;
}

- (void)setAlertButtonDisabledAttributes:(NSDictionary<NSString *,id> *)alertButtonDisabledAttributes {
  _alertButtonDisabledAttributes = alertButtonDisabledAttributes;
  _needsUpdateAction = YES;
}

- (void)setSheetButtonDisabledAttributes:(NSDictionary<NSString *,id> *)sheetButtonDisabledAttributes {
  _sheetButtonDisabledAttributes = sheetButtonDisabledAttributes;
  _needsUpdateAction = YES;
}

- (void)setAlertCancelButtonAttributes:(NSDictionary<NSString *,id> *)alertCancelButtonAttributes {
  _alertCancelButtonAttributes = alertCancelButtonAttributes;
  _needsUpdateAction = YES;
}

- (void)setSheetCancelButtonAttributes:(NSDictionary<NSString *,id> *)sheetCancelButtonAttributes {
  _sheetCancelButtonAttributes = sheetCancelButtonAttributes;
  _needsUpdateAction = YES;
}

- (void)setAlertDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)alertDestructiveButtonAttributes {
  _alertDestructiveButtonAttributes = alertDestructiveButtonAttributes;
  _needsUpdateAction = YES;
}

- (void)setSheetDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)sheetDestructiveButtonAttributes {
  _sheetDestructiveButtonAttributes = sheetDestructiveButtonAttributes;
  _needsUpdateAction = YES;
}

- (void)setAlertButtonBackgroundColor:(UIColor *)alertButtonBackgroundColor {
  _alertButtonBackgroundColor = alertButtonBackgroundColor;
  _needsUpdateAction = YES;
}

- (void)setSheetButtonBackgroundColor:(UIColor *)sheetButtonBackgroundColor {
  _sheetButtonBackgroundColor = sheetButtonBackgroundColor;
  _needsUpdateAction = YES;
}

- (void)setAlertButtonHighlightBackgroundColor:(UIColor *)alertButtonHighlightBackgroundColor {
  _alertButtonHighlightBackgroundColor = alertButtonHighlightBackgroundColor;
  _needsUpdateAction = YES;
}

- (void)setSheetButtonHighlightBackgroundColor:(UIColor *)sheetButtonHighlightBackgroundColor {
  _sheetButtonHighlightBackgroundColor = sheetButtonHighlightBackgroundColor;
  _needsUpdateAction = YES;
}

- (void)setAlertTitleAttributes:(NSDictionary<NSString *,id> *)alertTitleAttributes {
  _alertTitleAttributes = alertTitleAttributes;
  _needsUpdateTitle = YES;
}

- (void)setAlertMessageAttributes:(NSDictionary<NSString *,id> *)alertMessageAttributes {
  _alertMessageAttributes = alertMessageAttributes;
  _needsUpdateMessage = YES;
}

- (void)setSheetTitleAttributes:(NSDictionary<NSString *,id> *)sheetTitleAttributes {
  _sheetTitleAttributes = sheetTitleAttributes;
  _needsUpdateTitle = YES;
}

- (void)setSheetMessageAttributes:(NSDictionary<NSString *,id> *)sheetMessageAttributes {
  _sheetMessageAttributes = sheetMessageAttributes;
  _needsUpdateMessage = YES;
}

- (void)setAlertHeaderBackgroundColor:(UIColor *)alertHeaderBackgroundColor {
  _alertHeaderBackgroundColor = alertHeaderBackgroundColor;
  [self updateHeaderBackgrondColor];
}

- (void)setSheetHeaderBackgroundColor:(UIColor *)sheetHeaderBackgroundColor {
  _sheetHeaderBackgroundColor = sheetHeaderBackgroundColor;
  [self updateHeaderBackgrondColor];
}

- (void)updateHeaderBackgrondColor {
  if (self.preferredStyle == SSUIAlertControllerStyleActionSheet) {
    if (self.headerScrollView) { self.headerScrollView.backgroundColor = self.sheetHeaderBackgroundColor; }
  } else if (self.preferredStyle == SSUIAlertControllerStyleAlert) {
    if (self.headerScrollView) { self.headerScrollView.backgroundColor = self.alertHeaderBackgroundColor; }
  }
}

- (void)setAlertSeperatorColor:(UIColor *)alertSeperatorColor {
  _alertSeperatorColor = alertSeperatorColor;
  [self updateEffectBackgroundColor];
}

- (void)setSheetSeperatorColor:(UIColor *)sheetSeperatorColor {
  _sheetSeperatorColor = sheetSeperatorColor;
  [self updateEffectBackgroundColor];
}

- (void)updateEffectBackgroundColor {
  if (self.preferredStyle == SSUIAlertControllerStyleAlert && self.alertSeperatorColor) {
    if (self.headerEffectView) { self.headerEffectView.backgroundColor = self.alertSeperatorColor; }
    if (self.cancelButtoneEffectView) { self.cancelButtoneEffectView.backgroundColor = self.alertSeperatorColor; }
  } else if (self.preferredStyle == SSUIAlertControllerStyleActionSheet && self.sheetSeperatorColor) {
    if (self.headerEffectView) { self.headerEffectView.backgroundColor = self.sheetSeperatorColor; }
    if (self.cancelButtoneEffectView) { self.cancelButtoneEffectView.backgroundColor = self.sheetSeperatorColor; }
  }
}

- (void)setAlertContentCornerRadius:(CGFloat)alertContentCornerRadius {
  _alertContentCornerRadius = alertContentCornerRadius;
  [self updateCornerRadius];
}

- (void)setSheetContentCornerRadius:(CGFloat)sheetContentCornerRadius {
  _sheetContentCornerRadius = sheetContentCornerRadius;
  [self updateCornerRadius];
}

- (void)updateCornerRadius {
  if (self.preferredStyle == SSUIAlertControllerStyleAlert) {
    if (self.containerView) { self.containerView.layer.cornerRadius = self.alertContentCornerRadius; self.containerView.clipsToBounds = YES; }
    if (self.cancelButtoneEffectView) { self.cancelButtoneEffectView.layer.cornerRadius = 0; self.cancelButtoneEffectView.clipsToBounds = NO;}
    if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = 0; self.scrollWrapView.clipsToBounds = NO; }
  } else {
    if (self.containerView) { self.containerView.layer.cornerRadius = 0; self.containerView.clipsToBounds = NO; }
    if (self.cancelButtoneEffectView) { self.cancelButtoneEffectView.layer.cornerRadius = self.sheetContentCornerRadius; self.cancelButtoneEffectView.clipsToBounds = YES; }
    if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = self.sheetContentCornerRadius; self.scrollWrapView.clipsToBounds = YES; }
  }
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SSUIAlertControllerStyle)preferredStyle {
  SSUIAlertController *alertController = [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
  if (alertController) {
    return alertController;
  }
  return nil;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SSUIAlertControllerStyle)preferredStyle {
  self = [self init];
  if (self) {
    
    self.isShowing = NO;
    self.shouldRespondMaskViewTouch = preferredStyle == SSUIAlertControllerStyleActionSheet;
    
    self.alertActions = [[NSMutableArray alloc] init];
    self.alertTextFields = [[NSMutableArray alloc] init];
    self.destructiveActions = [[NSMutableArray alloc] init];
    
    self.containerView = [[UIView alloc] init];
    
    self.maskView = [[UIControl alloc] init];
    self.maskView.alpha = 0;
    self.maskView.backgroundColor = UIColorMask;
    [self.maskView addTarget:self action:@selector(handleMaskViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    self.scrollWrapView = [[UIView alloc] init];
    self.headerEffectView = [[UIView alloc] init];
    self.cancelButtoneEffectView = [[UIView alloc] init];
    self.headerScrollView = [[UIScrollView alloc] init];
    self.buttonScrollView = [[UIScrollView alloc] init];
    
    self.title = title;
    self.message = message;
    self.preferredStyle = preferredStyle;
    
    [self updateHeaderBackgrondColor];
    [self updateEffectBackgroundColor];
    [self updateCornerRadius];
    
  }
  return self;
}

- (void)setPreferredStyle:(SSUIAlertControllerStyle)preferredStyle {
  _preferredStyle = IS_IPAD ? SSUIAlertControllerStyleAlert : preferredStyle;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.view addSubview:self.maskView];
  [self.view addSubview:self.containerView];
  [self.containerView addSubview:self.scrollWrapView];
  [self.scrollWrapView addSubview:self.headerEffectView];
  [self.scrollWrapView addSubview:self.headerScrollView];
  [self.scrollWrapView addSubview:self.buttonScrollView];
}

- (void)viewDidLayoutSubviews {
  
  [super viewDidLayoutSubviews];
  
  BOOL hasTitle = (self.titleLabel.text && ![self.titleLabel.text isEqualToString:@""] && !self.titleLabel.hidden);
  BOOL hasMessage = (self.messageLabel.text && ![self.messageLabel.text isEqualToString:@""] && !self.messageLabel.hidden);
  BOOL hasTextField = self.alertTextFields.count > 0;
  BOOL hasCustomView = !!_customView;
  CGFloat contentOriginY = 0;
  
  self.maskView.frame = self.view.bounds;
  
  if (self.preferredStyle == SSUIAlertControllerStyleAlert) {
    
    CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
    CGFloat contentPaddingRight = self.alertHeaderInsets.right;
    
    CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.top : 0;
    CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.bottom : 0;
    self.containerView.width = fmin(self.alertContentMaximumWidth, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.alertContentMargin));
    self.scrollWrapView.width = CGRectGetWidth(self.containerView.bounds);
    self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), 0);
    contentOriginY = contentPaddingTop;
    // 标题和副标题布局
    if (hasTitle) {
      CGFloat titleLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
      CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelLimitWidth, CGFLOAT_MAX)];
      self.titleLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, titleLabelLimitWidth, titleLabelSize.height));
      contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
    }
    if (hasMessage) {
      CGFloat messageLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
      CGSize messageLabelSize = [self.messageLabel sizeThatFits:CGSizeMake(messageLabelLimitWidth, CGFLOAT_MAX)];
      self.messageLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, messageLabelLimitWidth, messageLabelSize.height));
      contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
    }
    // 输入框布局
    if (hasTextField) {
      for (int i = 0; i < self.alertTextFields.count; i++) {
        UITextField *textField = self.alertTextFields[i];
        textField.frame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, 25);
        contentOriginY = CGRectGetMaxY(textField.frame) - 1;
      }
      contentOriginY += 16;
    }
    // 自定义view的布局 - 自动居中
    if (hasCustomView) {
      CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
      _customView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height));
      contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
    }
    // 内容scrollView的布局
    self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
    self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
    contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
    // 按钮布局
    self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
    contentOriginY = 0;
    NSArray *newOrderActions = [self orderedAlertActions:self.alertActions];
    if (self.alertActions.count > 0) {
      BOOL verticalLayout = YES;
      if (self.alertActions.count == 2) {
        CGFloat halfWidth = CGRectGetWidth(self.buttonScrollView.bounds) / 2;
        SSUIAlertAction *action1 = newOrderActions[0];
        SSUIAlertAction *action2 = newOrderActions[1];
        CGSize actionSize1 = [action1.button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        CGSize actionSize2 = [action2.button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        if (actionSize1.width < halfWidth && actionSize2.width < halfWidth) {
          verticalLayout = NO;
        }
      }
      if (!verticalLayout) {
        SSUIAlertAction *action1 = newOrderActions[1];
        action1.buttonWrapView.frame = CGRectMake(0, contentOriginY + PixelOne, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
        SSUIAlertAction *action2 = newOrderActions[0];
        action2.buttonWrapView.frame = CGRectMake(CGRectGetMaxX(action1.buttonWrapView.frame) + PixelOne, contentOriginY + PixelOne, CGRectGetWidth(self.buttonScrollView.bounds) / 2 - PixelOne, self.alertButtonHeight);
        contentOriginY = CGRectGetMaxY(action1.buttonWrapView.frame);
      }
      else {
        for (int i = 0; i < newOrderActions.count; i++) {
          SSUIAlertAction *action = newOrderActions[i];
          action.buttonWrapView.frame = CGRectMake(0, contentOriginY + PixelOne, CGRectGetWidth(self.containerView.bounds), self.alertButtonHeight - PixelOne);
          contentOriginY = CGRectGetMaxY(action.buttonWrapView.frame);
        }
      }
    }
    // 按钮scrollView的布局
    self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
    self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
    // 容器最后布局
    CGFloat contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
    CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
    if (contentHeight > screenSpaceHeight - 20) {
      screenSpaceHeight -= 20;
      CGFloat contentH = fmin(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
      CGFloat buttonH = fmin(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
      if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
        self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
      } else if (contentH < screenSpaceHeight / 2) {
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
        self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
      } else if (buttonH < screenSpaceHeight / 2) {
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
        self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
      }
      contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
      screenSpaceHeight += 20;
    }
    self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), contentHeight);
    self.headerEffectView.frame = self.scrollWrapView.bounds;
    
    CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, (screenSpaceHeight - contentHeight - self.keyboardHeight) / 2, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.scrollWrapView.bounds));
    self.containerView.frame = CGRectFlatted(CGRectApplyAffineTransform(containerRect, self.containerView.transform));
  }
  
  else if (self.preferredStyle == SSUIAlertControllerStyleActionSheet) {
    
    CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
    CGFloat contentPaddingRight = self.alertHeaderInsets.right;
    
    CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.top : 0;
    CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.bottom : 0;
    self.containerView.width = fmin(self.sheetContentMaximumWidth, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.sheetContentMargin));
    self.scrollWrapView.width = CGRectGetWidth(self.containerView.bounds);
    self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), 0);
    contentOriginY = contentPaddingTop;
    // 标题和副标题布局
    if (hasTitle) {
      CGFloat titleLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
      CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelLimitWidth, CGFLOAT_MAX)];
      self.titleLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, titleLabelLimitWidth, titleLabelSize.height));
      contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.sheetTitleMessageSpacing : contentPaddingBottom);
    }
    if (hasMessage) {
      CGFloat messageLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
      CGSize messageLabelSize = [self.messageLabel sizeThatFits:CGSizeMake(messageLabelLimitWidth, CGFLOAT_MAX)];
      self.messageLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, messageLabelLimitWidth, messageLabelSize.height));
      contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
    }
    // 自定义view的布局 - 自动居中
    if (hasCustomView) {
      CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
      _customView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height));
      contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
    }
    // 内容scrollView布局
    self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
    self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
    contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
    // 按钮的布局
    self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
    contentOriginY = 0;
    NSArray *newOrderActions = [self orderedAlertActions:self.alertActions];
    if (self.alertActions.count > 0) {
      contentOriginY = (hasTitle || hasMessage || hasCustomView) ? contentOriginY + PixelOne : contentOriginY;
      for (int i = 0; i < newOrderActions.count; i++) {
        SSUIAlertAction *action = newOrderActions[i];
        if (action.style == SSUIAlertActionStyleCancel && i == newOrderActions.count - 1) {
          continue;
        } else {
          action.buttonWrapView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds), self.sheetButtonHeight - PixelOne);
          contentOriginY = CGRectGetMaxY(action.buttonWrapView.frame) + PixelOne;
        }
      }
      contentOriginY -= PixelOne;
    }
    // 按钮scrollView布局
    self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
    self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
    // 容器最终布局
    self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), CGRectGetMaxY(self.buttonScrollView.frame));
    self.headerEffectView.frame = self.scrollWrapView.bounds;
    contentOriginY = CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop;
    if (self.cancelAction) {
      self.cancelButtoneEffectView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.sheetButtonHeight);
      self.cancelAction.buttonWrapView.frame = self.cancelButtoneEffectView.bounds;
      contentOriginY = CGRectGetMaxY(self.cancelButtoneEffectView.frame);
    }
    // 把上下的margin都加上用于跟整个屏幕的高度做比较
    CGFloat contentHeight = contentOriginY + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
    CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
    if (contentHeight > screenSpaceHeight) {
      CGFloat cancelButtonAreaHeight = (self.cancelAction ? (CGRectGetHeight(self.cancelAction.buttonWrapView.bounds) + self.sheetCancelButtonMarginTop) : 0);
      screenSpaceHeight = screenSpaceHeight - cancelButtonAreaHeight - UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
      CGFloat contentH = MIN(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
      CGFloat buttonH = MIN(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
      if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
        self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
      } else if (contentH < screenSpaceHeight / 2) {
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
        self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
      } else if (buttonH < screenSpaceHeight / 2) {
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
        self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
      }
      self.scrollWrapView.frame =  CGRectSetHeight(self.scrollWrapView.frame, CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds));
      if (self.cancelAction) {
        self.cancelButtoneEffectView.frame = CGRectSetY(self.cancelButtoneEffectView.frame, CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop);
      }
      contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds) + cancelButtonAreaHeight + self.sheetContentMargin.bottom;
      screenSpaceHeight += (cancelButtonAreaHeight + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin));
    } else {
      // 如果小于屏幕高度，则把顶部的top减掉
      contentHeight -= self.sheetContentMargin.top;
    }
    
    CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, screenSpaceHeight - contentHeight, CGRectGetWidth(self.containerView.bounds), contentHeight);
    self.containerView.frame = CGRectFlatted(CGRectApplyAffineTransform(containerRect, self.containerView.transform));
  }
}

- (NSArray *)orderedAlertActions:(NSArray *)actions {
  NSMutableArray<SSUIAlertAction *> *newActions = [[NSMutableArray alloc] init];
  // 按照用户addAction的先后顺序来排序
  if (self.orderActionsByAddedOrdered) {
    [newActions addObjectsFromArray:self.alertActions];
    // 取消按钮不参与排序，所以先移除，在最后再重新添加
    if (self.cancelAction) {
      [newActions removeObject:self.cancelAction];
    }
  } else {
    for (SSUIAlertAction *action in self.alertActions) {
      if (action.style != SSUIAlertActionStyleCancel && action.style != SSUIAlertActionStyleDestructive) {
        [newActions addObject:action];
      }
    }
    for (SSUIAlertAction *action in self.destructiveActions) {
      [newActions addObject:action];
    }
  }
  if (self.cancelAction) {
    [newActions addObject:self.cancelAction];
  }
  return newActions;
}

- (void)initModalPresentationController {
  _modalPresentationViewController = [[UIModalPresentationViewController alloc] init];
  self.modalPresentationViewController.delegate = self;
  self.modalPresentationViewController.maximumContentViewWidth = CGFLOAT_MAX;
  self.modalPresentationViewController.contentViewMargins = UIEdgeInsetsZero;
  self.modalPresentationViewController.dimmingView = nil;
  self.modalPresentationViewController.contentViewController = self;
  [self customModalPresentationControllerAnimation];
}

- (void)customModalPresentationControllerAnimation {
  
  __weak __typeof(self)weakSelf = self;
  
  self.modalPresentationViewController.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
    weakSelf.view.frame = CGRectMake(0, 0, CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
    weakSelf.keyboardHeight = keyboardHeight;
    [weakSelf.view setNeedsLayout];
  };
  
  self.modalPresentationViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
    if (self.preferredStyle == SSUIAlertControllerStyleAlert) {
      weakSelf.containerView.alpha = 0;
      weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
      [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionsCurveOut animations:^{
        weakSelf.maskView.alpha = 1;
        weakSelf.containerView.alpha = 1;
        weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
      } completion:^(BOOL finished) {
        if (completion) {
          completion(finished);
        }
      }];
    } else if (self.preferredStyle == SSUIAlertControllerStyleActionSheet) {
      weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.containerView.bounds), 0);
      [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionsCurveOut animations:^{
        weakSelf.maskView.alpha = 1;
        weakSelf.containerView.layer.transform = CATransform3DIdentity;
      } completion:^(BOOL finished) {
        if (completion) {
          completion(finished);
        }
      }];
    }
  };
  
  self.modalPresentationViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
    if (self.preferredStyle == SSUIAlertControllerStyleAlert) {
      [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionsCurveOut animations:^{
        weakSelf.maskView.alpha = 0;
        weakSelf.containerView.alpha = 0;
      } completion:^(BOOL finished) {
        weakSelf.containerView.alpha = 1;
        if (completion) {
          completion(finished);
        }
      }];
    } else if (self.preferredStyle == SSUIAlertControllerStyleActionSheet) {
      [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionsCurveOut animations:^{
        weakSelf.maskView.alpha = 0;
        weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.containerView.bounds), 0);
      } completion:^(BOOL finished) {
        if (completion) {
          completion(finished);
        }
      }];
    }
  };
}

- (void)showWithAnimated:(BOOL)animated {
  if (self.isShowing) {
    return;
  }
  if (self.alertTextFields.count > 0) {
    [self.alertTextFields.firstObject becomeFirstResponder];
  }
  if (_needsUpdateAction) {
    [self updateAction];
  }
  if (_needsUpdateTitle) {
    [self updateTitleLabel];
  }
  if (_needsUpdateMessage) {
    [self updateMessageLabel];
  }
  
  [self initModalPresentationController];
  
  if ([self.delegate respondsToSelector:@selector(willShowAlertController:)]) {
    [self.delegate willShowAlertController:self];
  }
  
  __weak __typeof(self)weakSelf = self;
  
  [self.modalPresentationViewController showWithAnimated:animated completion:^(BOOL finished) {
    weakSelf.maskView.alpha = 1;
    weakSelf.isShowing = YES;
    if (self.isNeedsHideAfterAlertShowed) {
      [self hideWithAnimated:self.isAnimatedForHideAfterAlertShowed];
      self.isNeedsHideAfterAlertShowed = NO;
      self.isAnimatedForHideAfterAlertShowed = NO;
    }
    if ([weakSelf.delegate respondsToSelector:@selector(didShowAlertController:)]) {
      [weakSelf.delegate didShowAlertController:weakSelf];
    }
  }];
  
  // 增加alertController计数
  alertControllerCount++;
}

- (void)hideWithAnimated:(BOOL)animated {
  [self hideWithAnimated:animated completion:NULL];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
  if (!self.isShowing) {
    self.isNeedsHideAfterAlertShowed = YES;
    self.isAnimatedForHideAfterAlertShowed = animated;
    return;
  }
  
  if ([self.delegate respondsToSelector:@selector(willHideAlertController:)]) {
    [self.delegate willHideAlertController:self];
  }
  
  __weak __typeof(self)weakSelf = self;
  
  [self.modalPresentationViewController hideWithAnimated:animated completion:^(BOOL finished) {
    weakSelf.modalPresentationViewController = nil;
    weakSelf.isShowing = NO;
    weakSelf.maskView.alpha = 0;
    if (self.preferredStyle == SSUIAlertControllerStyleAlert) {
      weakSelf.containerView.alpha = 0;
    } else {
      weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.containerView.bounds), 0);
    }
    if ([weakSelf.delegate respondsToSelector:@selector(didHideAlertController:)]) {
      [weakSelf.delegate didHideAlertController:weakSelf];
    }
    if (completion) {
      completion();
    }
  }];
  
  // 减少alertController计数
  alertControllerCount--;
}

- (void)addAction:(SSUIAlertAction *)action {
  if (action.style == SSUIAlertActionStyleCancel && self.cancelAction) {
    [NSException raise:@"SSUIAlertController使用错误" format:@"同一个alertController不可以同时添加两个cancel按钮"];
  }
  if (action.style == SSUIAlertActionStyleCancel) {
    self.cancelAction = action;
  }
  if (action.style == SSUIAlertActionStyleDestructive) {
    [self.destructiveActions addObject:action];
  }
  // 只有ActionSheet的取消按钮不参与滚动
  if (self.preferredStyle == SSUIAlertControllerStyleActionSheet && action.style == SSUIAlertActionStyleCancel && !IS_IPAD) {
    if (!self.cancelButtoneEffectView.superview) {
      [self.containerView addSubview:self.cancelButtoneEffectView];
    }
    [self.cancelButtoneEffectView addSubview:action.buttonWrapView];
  } else {
    [self.buttonScrollView addSubview:action.buttonWrapView];
  }
  action.delegate = self;
  [self.alertActions addObject:action];
}

- (void)addCancelAction {
  SSUIAlertAction *action = [SSUIAlertAction actionWithTitle:@"取消" style:SSUIAlertActionStyleCancel handler:nil];
  [self addAction:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
  if (_customView) {
    [NSException raise:@"SSUIAlertController使用错误" format:@"UITextField和CustomView不能共存"];
  }
  if (self.preferredStyle == SSUIAlertControllerStyleActionSheet) {
    [NSException raise:@"SSUIAlertController使用错误" format:@"Sheet类型不运行添加UITextField"];
  }
  SSUITextField *textField = [[SSUITextField alloc] init];
  textField.borderStyle = UITextBorderStyleNone;
  textField.backgroundColor = UIColorWhite;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
  textField.font = UIFontMake(14);
  textField.textColor = UIColorBlack;
  textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  textField.clearButtonMode = UITextFieldViewModeWhileEditing;
  textField.layer.borderColor = UIColorMake(210, 210, 210).CGColor;
  textField.layer.borderWidth = PixelOne;
  [self.headerScrollView addSubview:textField];
  [self.alertTextFields addObject:textField];
  if (configurationHandler) {
    configurationHandler(textField);
  }
}

- (void)addCustomView:(UIView *)view {
  if (self.alertTextFields.count > 0) {
    [NSException raise:@"SSUIAlertController使用错误" format:@"UITextField和CustomView不能共存"];
  }
  _customView = view;
  [self.headerScrollView addSubview:_customView];
}

- (void)setTitle:(NSString *)title {
  _title = title;
  if (!self.titleLabel) {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    [self.headerScrollView addSubview:self.titleLabel];
  }
  if (!_title || [_title isEqualToString:@""]) {
    self.titleLabel.hidden = YES;
  } else {
    self.titleLabel.hidden = NO;
    [self updateTitleLabel];
  }
}

- (NSString *)title {
  return _title;
}

- (void)updateTitleLabel {
  if (self.titleLabel && !self.titleLabel.hidden) {
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.title attributes:self.preferredStyle == SSUIAlertControllerStyleAlert ? self.alertTitleAttributes : self.sheetTitleAttributes];
    self.titleLabel.attributedText = attributeString;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
  }
}

- (void)setMessage:(NSString *)message {
  _message = message;
  if (!self.messageLabel) {
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 0;
    [self.headerScrollView addSubview:self.messageLabel];
  }
  if (!_message || [_message isEqualToString:@""]) {
    self.messageLabel.hidden = YES;
  } else {
    self.messageLabel.hidden = NO;
    [self updateMessageLabel];
  }
}

- (void)updateMessageLabel {
  if (self.messageLabel && !self.messageLabel.hidden) {
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.message attributes:self.preferredStyle == SSUIAlertControllerStyleAlert ? self.alertMessageAttributes : self.sheetMessageAttributes];
    self.messageLabel.attributedText = attributeString;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
  }
}

- (NSArray *)actions {
  return self.alertActions;
}

- (void)updateAction {
  
  for (SSUIAlertAction *alertAction in self.alertActions) {
    
    UIColor *backgroundColor = self.preferredStyle == SSUIAlertControllerStyleAlert ? self.alertButtonBackgroundColor : self.sheetButtonBackgroundColor;
    UIColor *highlightBackgroundColor = self.preferredStyle == SSUIAlertControllerStyleAlert ? self.alertButtonHighlightBackgroundColor : self.sheetButtonHighlightBackgroundColor;
    
    alertAction.buttonWrapView.clipsToBounds = alertAction.style == SSUIAlertActionStyleCancel;
    alertAction.button.backgroundColor = backgroundColor;
    alertAction.button.highlightedBackgroundColor = highlightBackgroundColor;
    
    NSAttributedString *attributeString = nil;
    if (alertAction.style == SSUIAlertActionStyleCancel) {
      
      NSDictionary *attributes = (self.preferredStyle == SSUIAlertControllerStyleAlert) ? self.alertCancelButtonAttributes : self.sheetCancelButtonAttributes;
      if (alertAction.buttonAttributes) {
        attributes = alertAction.buttonAttributes;
      }
      
      attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
      
    } else if (alertAction.style == SSUIAlertActionStyleDestructive) {
      
      NSDictionary *attributes = (self.preferredStyle == SSUIAlertControllerStyleAlert) ? self.alertDestructiveButtonAttributes : self.sheetDestructiveButtonAttributes;
      if (alertAction.buttonAttributes) {
        attributes = alertAction.buttonAttributes;
      }
      
      attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
      
    } else {
      
      NSDictionary *attributes = (self.preferredStyle == SSUIAlertControllerStyleAlert) ? self.alertButtonAttributes : self.sheetButtonAttributes;
      if (alertAction.buttonAttributes) {
        attributes = alertAction.buttonAttributes;
      }
      
      attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
    }
    
    [alertAction.button setAttributedTitle:attributeString forState:UIControlStateNormal];
    
    NSDictionary *attributes = (self.preferredStyle == SSUIAlertControllerStyleAlert) ? self.alertButtonDisabledAttributes : self.sheetButtonDisabledAttributes;
    if (alertAction.buttonDisabledAttributes) {
      attributes = alertAction.buttonDisabledAttributes;
    }
    
    attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
    [alertAction.button setAttributedTitle:attributeString forState:UIControlStateDisabled];
    
    if ([alertAction.button imageForState:UIControlStateNormal]) {
      NSRange range = NSMakeRange(0, attributeString.length);
      UIColor *disabledColor = [attributeString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
      [alertAction.button setImage:[[alertAction.button imageForState:UIControlStateNormal] imageWithTintColor:disabledColor] forState:UIControlStateDisabled];
    }
  }
}

- (NSArray *)textFields {
  return self.alertTextFields;
}

- (void)handleMaskViewEvent:(id)sender {
  if (_shouldRespondMaskViewTouch) {
    [self hideWithAnimated:YES completion:NULL];
  }
}

#pragma mark - <SSUIAlertActionDelegate>

- (void)didClickAlertAction:(SSUIAlertAction *)alertAction {
  [self hideWithAnimated:YES completion:^{
    if (alertAction.handler) {
      alertAction.handler(alertAction);
      alertAction.handler = nil;
    }
  }];
}

#pragma mark - <SSUIModalPresentationViewControllerDelegate>

- (void)requestHideAllModalPresentationViewController {
  [self hideWithAnimated:NO completion:NULL];
}


@end

@implementation SSUIAlertController (Manager)

+ (BOOL)isAnyAlertControllerVisible {
  return alertControllerCount > 0;
}

@end
