//
//  UIConfiguration.m
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import "UIConfiguration.h"
#import "UICommonDefines.h"
#import "UIConfiguration.h"
#import "UIHelper.h"

@implementation UIConfiguration

+ (instancetype)shareConfiguration
{
  static id shareConfiguration = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shareConfiguration = [[self alloc] init];
  });
  return shareConfiguration;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self initDefaultConfiguration];
  }
  return self;
}

- (void)initDefaultConfiguration
{
#pragma mark - Global Color
  
  self.clearColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
  self.whiteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
  self.blackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
  self.grayColor = UIColorMake(179, 179, 179);
  self.grayDarkenColor = UIColorMake(163, 163, 163);
  self.grayLightenColor = UIColorMake(198, 198, 198);
  self.redColor = UIColorMake(250, 58, 58);
  self.greenColor = UIColorMake(159, 214, 97);
  self.blueColor = UIColorMake(49, 189, 243);
  self.yellowColor = UIColorMake(255, 207, 71);
  
  self.linkColor = UIColorMake(56, 116, 171);
  self.disabledColor = self.grayColor;
  self.backgroundColor = UIColorMake(255, 255, 255);
  self.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);
  self.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);
  self.separatorColor = UIColorMake(222, 224, 226);
  self.separatorDashedColor = UIColorMake(17, 17, 17);
  self.placeholderColor = UIColorMake(196, 200, 208);
  
  self.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
  self.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
  self.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);
  
#pragma mark - UIControl
  
  self.controlHighlightedAlpha = 0.5f;
  self.controlDisabledAlpha = 0.5f;
  
#pragma mark - UIButton
  
  self.buttonHighlightedAlpha = self.controlHighlightedAlpha;
  self.buttonDisabledAlpha = self.controlDisabledAlpha;
  self.buttonTintColor = self.blueColor;
  
  self.ghostButtonColorBlue = self.blueColor;
  self.ghostButtonColorRed = self.redColor;
  self.ghostButtonColorGreen = self.greenColor;
  self.ghostButtonColorGray = self.grayColor;
  self.ghostButtonColorWhite = self.whiteColor;
  
  self.fillButtonColorBlue = self.blueColor;
  self.fillButtonColorRed = self.redColor;
  self.fillButtonColorGreen = self.greenColor;
  self.fillButtonColorGray = self.grayColor;
  self.fillButtonColorWhite = self.whiteColor;
  
#pragma mark - UITextField & UITextView
  
  self.textFieldTintColor = nil;
  self.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);
  
#pragma mark - NavigationBar
  
  self.navBarHighlightedAlpha = 0.2f;
  self.navBarDisabledAlpha = 0.2f;
  self.navBarButtonFont = nil;
  self.navBarButtonFontBold = nil;
  self.navBarBackgroundImage = nil;
  self.navBarShadowImage = nil;
  self.navBarBarTintColor = nil;
  self.navBarTintColor = nil;
  self.navBarTitleColor = self.blackColor;
  self.navBarTitleFont = nil;
  self.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;
  self.navBarBackIndicatorImage = nil;
  self.navBarCloseButtonImage = nil;
  
  self.navBarLoadingMarginRight = 3;
  self.navBarAccessoryViewMarginLeft = 5;
  self.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
  
#pragma mark - TabBar
  
  self.tabBarBackgroundImage = nil;
  self.tabBarBarTintColor = nil;
  self.tabBarShadowImageColor = nil;
  self.tabBarTintColor = nil;
  self.tabBarItemTitleColor = nil;
  self.tabBarItemTitleColorSelected = self.tabBarTintColor;
  self.tabBarItemTitleFont = nil;
  
#pragma mark - Toolbar
  
  self.toolBarHighlightedAlpha = 0.4f;
  self.toolBarDisabledAlpha = 0.4f;
  self.toolBarTintColor = nil;
  self.toolBarTintColorHighlighted = [self.toolBarTintColor colorWithAlphaComponent:self.toolBarHighlightedAlpha];
  self.toolBarTintColorDisabled = [self.toolBarTintColor colorWithAlphaComponent:self.toolBarDisabledAlpha];
  self.toolBarBackgroundImage = nil;
  self.toolBarBarTintColor = nil;
  self.toolBarShadowImageColor = nil;
  self.toolBarButtonFont = nil;
  
#pragma mark - SearchBar
  
  self.searchBarTextFieldBackground = nil;
  self.searchBarTextFieldBorderColor = nil;
  self.searchBarBottomBorderColor = nil;
  self.searchBarBarTintColor = nil;
  self.searchBarTintColor = nil;
  self.searchBarTextColor = nil;
  self.searchBarPlaceholderColor = self.placeholderColor;
  self.searchBarFont = nil;
  self.searchBarSearchIconImage = nil;
  self.searchBarClearIconImage = nil;
  self.searchBarTextFieldCornerRadius = 2.0;
  
#pragma mark - TableView / TableViewCell
  
  self.tableViewBackgroundColor = nil;
  self.tableViewGroupedBackgroundColor = nil;
  self.tableSectionIndexColor = nil;
  self.tableSectionIndexBackgroundColor = nil;
  self.tableSectionIndexTrackingBackgroundColor = nil;
  self.tableViewSeparatorColor = self.separatorColor;
  
  self.tableViewCellNormalHeight = 44;
  self.tableViewCellTitleLabelColor = nil;
  self.tableViewCellDetailLabelColor = nil;
  self.tableViewCellBackgroundColor = self.whiteColor;
  self.tableViewCellSelectedBackgroundColor = UIColorMake(238, 239, 241);
  self.tableViewCellWarningBackgroundColor = self.yellowColor;
  self.tableViewCellDisclosureIndicatorImage = nil;
  self.tableViewCellCheckmarkImage = nil;
  self.tableViewCellDetailButtonImage = nil;
  self.tableViewCellDoneButtonImage = nil;
  self.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = 12;
  
  self.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);
  self.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);
  self.tableViewSectionHeaderFont = UIFontBoldMake(12);
  self.tableViewSectionFooterFont = UIFontBoldMake(12);
  self.tableViewSectionHeaderTextColor = self.grayDarkenColor;
  self.tableViewSectionFooterTextColor = self.grayColor;
  self.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
  self.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
  
  self.tableViewGroupedSectionHeaderFont = UIFontMake(12);
  self.tableViewGroupedSectionFooterFont = UIFontMake(12);
  self.tableViewGroupedSectionHeaderTextColor = self.grayDarkenColor;
  self.tableViewGroupedSectionFooterTextColor = self.grayColor;
  self.tableViewGroupedSectionHeaderDefaultHeight = UITableViewAutomaticDimension;
  self.tableViewGroupedSectionFooterDefaultHeight = UITableViewAutomaticDimension;
  self.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);
  self.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);
  
#pragma mark - CollectionView
  self.collectionViewBackgroundColor = nil;
  
#pragma mark - UIWindowLevel
  self.windowLevelUIAlertView = UIWindowLevelAlert - 4.0;
  self.windowLevelUIImagePreviewView = UIWindowLevelStatusBar + 1;
  
#pragma mark - Others
  
  self.supportedOrientationMask = UIInterfaceOrientationMaskPortrait;
  self.automaticallyRotateDeviceOrientation = NO;
  self.statusbarStyleLightInitially = NO;
  self.needsBackBarButtonItemTitle = NO;
  self.hidesBottomBarWhenPushedInitially = NO;
  self.navigationBarHiddenInitially = NO;
}

#pragma mark setter

/**
 设置导航栏按钮字体
 @param navBarButtonFont font
 */
- (void)setNavBarButtonFont:(UIFont *)navBarButtonFont {
  _navBarButtonFont = navBarButtonFont;
}

/**
 设置导航栏 tintcolor
 @param navBarTintColor color
 */
- (void)setNavBarTintColor:(UIColor *)navBarTintColor {
  _navBarTintColor = navBarTintColor;
  if (navBarTintColor) {
    [UIHelper visibleViewController].navigationController.navigationBar.tintColor = _navBarTintColor;
  }
}

/**
 设置导航栏 bartintcolor
 @param navBarBarTintColor color
 */
- (void)setNavBarBarTintColor:(UIColor *)navBarBarTintColor {
  _navBarBarTintColor = navBarBarTintColor;
  if (navBarBarTintColor) {
    [UINavigationBar appearance].barTintColor = _navBarBarTintColor;
    [UIHelper visibleViewController].navigationController.navigationBar.barTintColor = _navBarBarTintColor;
  }
}

/**
 设置导航栏分割线图片
 @param navBarShadowImage image
 */
- (void)setNavBarShadowImage:(UIImage *)navBarShadowImage {
  _navBarShadowImage = navBarShadowImage;
  if (navBarShadowImage) {
    [UINavigationBar appearance].shadowImage = _navBarShadowImage;
    [UIHelper visibleViewController].navigationController.navigationBar.shadowImage = _navBarShadowImage;
  }
}

/**
 设置导航栏背景图片
 @param navBarBackgroundImage image
 */
- (void)setNavBarBackgroundImage:(UIImage *)navBarBackgroundImage {
  _navBarBackgroundImage = navBarBackgroundImage;
  if (navBarBackgroundImage) {
    [[UINavigationBar appearance] setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [[UIHelper visibleViewController].navigationController.navigationBar setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
  }
}

/**
 设置导航栏 title 字体
 @param navBarTitleFont font
 */
- (void)setNavBarTitleFont:(UIFont *)navBarTitleFont {
  _navBarTitleFont = navBarTitleFont;
  if (self.navBarTitleFont || self.navBarTitleColor) {
    NSMutableDictionary<NSString *, id> *titleTextAttributes = [[NSMutableDictionary alloc] init];
    if (self.navBarTitleFont) {
      [titleTextAttributes setValue:self.navBarTitleFont forKey:NSFontAttributeName];
    }
    if (self.navBarTitleColor) {
      [titleTextAttributes setValue:self.navBarTitleColor forKey:NSForegroundColorAttributeName];
    }
    [UINavigationBar appearance].titleTextAttributes = titleTextAttributes;
    [UIHelper visibleViewController].navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
  }
}

/**
 设置导航栏 title 颜色
 @param navBarTitleColor color
 */
- (void)setNavBarTitleColor:(UIColor *)navBarTitleColor {
  _navBarTitleColor = navBarTitleColor;
  if (self.navBarTitleFont || self.navBarTitleColor) {
    NSMutableDictionary<NSString *, id> *titleTextAttributes = [[NSMutableDictionary alloc] init];
    if (self.navBarTitleFont) {
      [titleTextAttributes setValue:self.navBarTitleFont forKey:NSFontAttributeName];
    }
    if (self.navBarTitleColor) {
      [titleTextAttributes setValue:self.navBarTitleColor forKey:NSForegroundColorAttributeName];
    }
    [UINavigationBar appearance].titleTextAttributes = titleTextAttributes;
    [UIHelper visibleViewController].navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
  }
}

/**
 设置导航栏返回按钮图片
 @param navBarBackIndicatorImage image
 */
- (void)setNavBarBackIndicatorImage:(UIImage *)navBarBackIndicatorImage {
  _navBarBackIndicatorImage = navBarBackIndicatorImage;
  
  if (_navBarBackIndicatorImage) {
    UINavigationBar *navBarAppearance = [UINavigationBar appearance];
    UINavigationBar *navigationBar = [UIHelper visibleViewController].navigationController.navigationBar;
    
    CGSize systemBackIndicatorImageSize = CGSizeMake(13, 21); // 在iOS 8-11 上实际测量得到
    CGSize customBackIndicatorImageSize = _navBarBackIndicatorImage.size;
    if (!CGSizeEqualToSize(customBackIndicatorImageSize, systemBackIndicatorImageSize)) {
      CGFloat imageExtensionVerticalFloat = CGFloatGetCenter(systemBackIndicatorImageSize.height, customBackIndicatorImageSize.height);
      UIEdgeInsets insets = UIEdgeInsetsMake(imageExtensionVerticalFloat,
                                             0,
                                             imageExtensionVerticalFloat,
                                             systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width);
      
      CGSize contextSize = CGSizeMake(_navBarBackIndicatorImage.size.width + UIEdgeInsetsGetHorizontalValue(insets),
                                      _navBarBackIndicatorImage.size.height + UIEdgeInsetsGetVerticalValue(insets));
      UIGraphicsBeginImageContextWithOptions(contextSize, NO, _navBarBackIndicatorImage.scale);
      [_navBarBackIndicatorImage drawAtPoint:CGPointMake(insets.left, insets.top)];
      UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
      _navBarBackIndicatorImage = finalImage;
    }
    
    navBarAppearance.backIndicatorImage = _navBarBackIndicatorImage;
    navBarAppearance.backIndicatorTransitionMaskImage = navBarAppearance.backIndicatorImage;
    navigationBar.backIndicatorImage = _navBarBackIndicatorImage;
    navigationBar.backIndicatorTransitionMaskImage = navigationBar.backIndicatorImage;
  }
}

/**
 设置导航栏按钮标题偏移
 @param navBarBackButtonTitlePositionAdjustment adjust
 */
- (void)setNavBarBackButtonTitlePositionAdjustment:(UIOffset)navBarBackButtonTitlePositionAdjustment {
  _navBarBackButtonTitlePositionAdjustment = navBarBackButtonTitlePositionAdjustment;
  
  if (!UIOffsetEqualToOffset(UIOffsetZero, _navBarBackButtonTitlePositionAdjustment)) {
    UIBarButtonItem *backBarButtonItem = [UIBarButtonItem appearance];
    [backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
    [[UIHelper visibleViewController].navigationController.navigationItem.backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
  }
}

/**
 设置 ToolBar tintcolor
 @param toolBarTintColor color
 */
- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
  _toolBarTintColor = toolBarTintColor;
  if (toolBarTintColor) {
    [UIHelper visibleViewController].navigationController.toolbar.tintColor = _toolBarTintColor;
  }
}

/**
 设置 ToolBar bartintcolor
 @param toolBarBarTintColor color
 */
- (void)setToolBarBarTintColor:(UIColor *)toolBarBarTintColor {
  _toolBarBarTintColor = toolBarBarTintColor;
  if (toolBarBarTintColor) {
    [UIToolbar appearance].barTintColor = _toolBarBarTintColor;
    [UIHelper visibleViewController].navigationController.toolbar.barTintColor = _toolBarBarTintColor;
  }
}

/**
 设置 ToolBar 背景图片
 @param toolBarBackgroundImage image
 */
- (void)setToolBarBackgroundImage:(UIImage *)toolBarBackgroundImage {
  _toolBarBackgroundImage = toolBarBackgroundImage;
  if (toolBarBackgroundImage) {
    [[UIToolbar appearance] setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIHelper visibleViewController].navigationController.toolbar setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
  }
}

/**
 设置 ToolBar 分割线颜色
 @param toolBarShadowImageColor color
 */
- (void)setToolBarShadowImageColor:(UIColor *)toolBarShadowImageColor {
  _toolBarShadowImageColor = toolBarShadowImageColor;
  if (_toolBarShadowImageColor) {
    UIImage *shadowImage = __UIImageMake(CGSizeMake(1, PixelOne),_toolBarShadowImageColor);
    [[UIToolbar appearance] setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
    [[UIHelper visibleViewController].navigationController.toolbar setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
  }
}

/**
 设置 TabBar tintcolor
 @param tabBarTintColor color
 */
- (void)setTabBarTintColor:(UIColor *)tabBarTintColor {
  _tabBarTintColor = tabBarTintColor;
  if (tabBarTintColor) {
    [UIHelper visibleViewController].tabBarController.tabBar.tintColor = _tabBarTintColor;
  }
}

/**
 设置 TabBar bartintcolor
 @param tabBarBarTintColor color
 */
- (void)setTabBarBarTintColor:(UIColor *)tabBarBarTintColor {
  _tabBarBarTintColor = tabBarBarTintColor;
  if (tabBarBarTintColor) {
    [UITabBar appearance].barTintColor = _tabBarBarTintColor;
    [UIHelper visibleViewController].tabBarController.tabBar.barTintColor = _tabBarBarTintColor;
  }
}

/**
 设置 TabBar 背景图片
 @param tabBarBackgroundImage image
 */
- (void)setTabBarBackgroundImage:(UIImage *)tabBarBackgroundImage {
  _tabBarBackgroundImage = tabBarBackgroundImage;
  if (tabBarBackgroundImage) {
    [UITabBar appearance].backgroundImage = _tabBarBackgroundImage;
    [UIHelper visibleViewController].tabBarController.tabBar.backgroundImage = _tabBarBackgroundImage;
  }
}

/**
 设置 TabBar 分割线颜色
 @param tabBarShadowImageColor color
 */
- (void)setTabBarShadowImageColor:(UIColor *)tabBarShadowImageColor {
  _tabBarShadowImageColor = tabBarShadowImageColor;
  if (_tabBarShadowImageColor) {
    UIImage *shadowImage = __UIImageMake(CGSizeMake(1, PixelOne),_tabBarShadowImageColor);
    [[UITabBar appearance] setShadowImage:shadowImage];
    [UIHelper visibleViewController].tabBarController.tabBar.shadowImage = shadowImage;
  }
}

/**
 设置 TabBar 按钮标题颜色
 @param tabBarItemTitleColor color
 */
- (void)setTabBarItemTitleColor:(UIColor *)tabBarItemTitleColor {
  _tabBarItemTitleColor = tabBarItemTitleColor;
  if (_tabBarItemTitleColor) {
    NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColor;
    [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [[UIHelper visibleViewController].tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    }];
  }
}

/**
 设置 TabBar 按钮标题字体
 @param tabBarItemTitleFont font
 */
- (void)setTabBarItemTitleFont:(UIFont *)tabBarItemTitleFont {
  _tabBarItemTitleFont = tabBarItemTitleFont;
  if (_tabBarItemTitleFont) {
    NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
    textAttributes[NSFontAttributeName] = _tabBarItemTitleFont;
    [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [[UIHelper visibleViewController].tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    }];
  }
}

/**
 设置 TabBar 按钮标题选种颜色
 @param tabBarItemTitleColorSelected color
 */
- (void)setTabBarItemTitleColorSelected:(UIColor *)tabBarItemTitleColorSelected {
  _tabBarItemTitleColorSelected = tabBarItemTitleColorSelected;
  if (_tabBarItemTitleColorSelected) {
    NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateSelected]];
    textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColorSelected;
    [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
    [[UIHelper visibleViewController].tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      [obj setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
    }];
  }
}

@end
