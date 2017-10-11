//
//  UIConfigurationMacros.h
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import "UIConfiguration.h"

#define UICMI [UIConfiguration shareConfiguration]

#pragma mark - Global Color

// 基础颜色
#define UIColorClear                [UICMI clearColor]
#define UIColorWhite                [UICMI whiteColor]
#define UIColorBlack                [UICMI blackColor]
#define UIColorGray                 [UICMI grayColor]
#define UIColorGrayDarken           [UICMI grayDarkenColor]
#define UIColorGrayLighten          [UICMI grayLightenColor]
#define UIColorRed                  [UICMI redColor]
#define UIColorGreen                [UICMI greenColor]
#define UIColorBlue                 [UICMI blueColor]
#define UIColorYellow               [UICMI yellowColor]

// 功能颜色
#define UIColorLink                 [UICMI linkColor]
#define UIColorDisabled             [UICMI disabledColor]
#define UIColorForBackground        [UICMI backgroundColor]
#define UIColorMask                 [UICMI maskDarkColor]
#define UIColorMaskWhite            [UICMI maskLightColor]
#define UIColorSeparator            [UICMI separatorColor]
#define UIColorSeparatorDashed      [UICMI separatorDashedColor]
#define UIColorPlaceholder          [UICMI placeholderColor]

// 测试用的颜色
#define UIColorTestRed              [UICMI testColorRed]
#define UIColorTestGreen            [UICMI testColorGreen]
#define UIColorTestBlue             [UICMI testColorBlue]

// 可操作的控件
#pragma mark - UIControl

#define UIControlHighlightedAlpha       [UICMI controlHighlightedAlpha]
#define UIControlDisabledAlpha          [UICMI controlDisabledAlpha]

// 按钮
#pragma mark - UIButton
#define ButtonHighlightedAlpha          [UICMI buttonHighlightedAlpha]
#define ButtonDisabledAlpha             [UICMI buttonDisabledAlpha]
#define ButtonTintColor                 [UICMI buttonTintColor]

#define GhostButtonColorBlue            [UICMI ghostButtonColorBlue]
#define GhostButtonColorRed             [UICMI ghostButtonColorRed]
#define GhostButtonColorGreen           [UICMI ghostButtonColorGreen]
#define GhostButtonColorGray            [UICMI ghostButtonColorGray]
#define GhostButtonColorWhite           [UICMI ghostButtonColorWhite]

#define FillButtonColorBlue            [UICMI fillButtonColorBlue]
#define FillButtonColorRed             [UICMI fillButtonColorRed]
#define FillButtonColorGreen           [UICMI fillButtonColorGreen]
#define FillButtonColorGray            [UICMI fillButtonColorGray]
#define FillButtonColorWhite           [UICMI fillButtonColorWhite]

// 输入框
#pragma mark - TextField & TextView
#define TextFieldTintColor              [UICMI textFieldTintColor]
#define TextFieldTextInsets             [UICMI textFieldTextInsets]


#pragma mark - NavigationBar

#define NavBarHighlightedAlpha                          [UICMI navBarHighlightedAlpha]
#define NavBarDisabledAlpha                             [UICMI navBarDisabledAlpha]
#define NavBarButtonFont                                [UICMI navBarButtonFont]
#define NavBarButtonFontBold                            [UICMI navBarButtonFontBold]
#define NavBarBackgroundImage                           [UICMI navBarBackgroundImage]
#define NavBarShadowImage                               [UICMI navBarShadowImage]
#define NavBarBarTintColor                              [UICMI navBarBarTintColor]
#define NavBarTintColor                                 [UICMI navBarTintColor]
#define NavBarTitleColor                                [UICMI navBarTitleColor]
#define NavBarTitleFont                                 [UICMI navBarTitleFont]
#define NavBarBarBackButtonTitlePositionAdjustment      [UICMI navBarBackButtonTitlePositionAdjustment]
#define NavBarBackIndicatorImage                        [UICMI navBarBackIndicatorImage]
#define NavBarCloseButtonImage                          [UICMI navBarCloseButtonImage]

#define NavBarLoadingMarginRight                        [UICMI navBarLoadingMarginRight]
#define NavBarAccessoryViewMarginLeft                   [UICMI navBarAccessoryViewMarginLeft]
#define NavBarActivityIndicatorViewStyle                [UICMI navBarActivityIndicatorViewStyle]


#pragma mark - TabBar

#define TabBarBackgroundImage                           [UICMI tabBarBackgroundImage]
#define TabBarBarTintColor                              [UICMI tabBarBarTintColor]
#define TabBarShadowImageColor                          [UICMI tabBarShadowImageColor]
#define TabBarTintColor                                 [UICMI tabBarTintColor]
#define TabBarItemTitleColor                            [UICMI tabBarItemTitleColor]
#define TabBarItemTitleColorSelected                    [UICMI tabBarItemTitleColorSelected]
#define TabBarItemTitleFont                             [UICMI tabBarItemTitleFont]


#pragma mark - Toolbar

#define ToolBarHighlightedAlpha                         [UICMI toolBarHighlightedAlpha]
#define ToolBarDisabledAlpha                            [UICMI toolBarDisabledAlpha]
#define ToolBarTintColor                                [UICMI toolBarTintColor]
#define ToolBarTintColorHighlighted                     [UICMI toolBarTintColorHighlighted]
#define ToolBarTintColorDisabled                        [UICMI toolBarTintColorDisabled]
#define ToolBarBackgroundImage                          [UICMI toolBarBackgroundImage]
#define ToolBarBarTintColor                             [UICMI toolBarBarTintColor]
#define ToolBarShadowImageColor                         [UICMI toolBarShadowImageColor]
#define ToolBarButtonFont                               [UICMI toolBarButtonFont]


#pragma mark - SearchBar

#define SearchBarTextFieldBackground                    [UICMI searchBarTextFieldBackground]
#define SearchBarTextFieldBorderColor                   [UICMI searchBarTextFieldBorderColor]
#define SearchBarBottomBorderColor                      [UICMI searchBarBottomBorderColor]
#define SearchBarBarTintColor                           [UICMI searchBarBarTintColor]
#define SearchBarTintColor                              [UICMI searchBarTintColor]
#define SearchBarTextColor                              [UICMI searchBarTextColor]
#define SearchBarPlaceholderColor                       [UICMI searchBarPlaceholderColor]
#define SearchBarFont                                   [UICMI searchBarFont]
#define SearchBarSearchIconImage                        [UICMI searchBarSearchIconImage]
#define SearchBarClearIconImage                         [UICMI searchBarClearIconImage]
#define SearchBarTextFieldCornerRadius                  [UICMI searchBarTextFieldCornerRadius]


#pragma mark - TableView / TableViewCell

#define TableViewBackgroundColor                   [UICMI tableViewBackgroundColor]
#define TableViewGroupedBackgroundColor            [UICMI tableViewGroupedBackgroundColor]
#define TableSectionIndexColor                     [UICMI tableSectionIndexColor]
#define TableSectionIndexBackgroundColor           [UICMI tableSectionIndexBackgroundColor]
#define TableSectionIndexTrackingBackgroundColor   [UICMI tableSectionIndexTrackingBackgroundColor]
#define TableViewSeparatorColor                    [UICMI tableViewSeparatorColor]
#define TableViewCellBackgroundColor               [UICMI tableViewCellBackgroundColor]
#define TableViewCellSelectedBackgroundColor       [UICMI tableViewCellSelectedBackgroundColor]
#define TableViewCellWarningBackgroundColor        [UICMI tableViewCellWarningBackgroundColor]
#define TableViewCellNormalHeight                  [UICMI tableViewCellNormalHeight]

#define TableViewCellDisclosureIndicatorImage      [UICMI tableViewCellDisclosureIndicatorImage]
#define TableViewCellCheckmarkImage                [UICMI tableViewCellCheckmarkImage]
#define TableViewCellDetailButtonImage             [UICMI tableViewCellDetailButtonImage]
#define TableViewCellDoneButtonImage               [UICMI tableViewCellDoneButtonImage]
#define TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator [UICMI tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator]

#define TableViewSectionHeaderBackgroundColor      [UICMI tableViewSectionHeaderBackgroundColor]
#define TableViewSectionFooterBackgroundColor      [UICMI tableViewSectionFooterBackgroundColor]
#define TableViewSectionHeaderFont                 [UICMI tableViewSectionHeaderFont]
#define TableViewSectionFooterFont                 [UICMI tableViewSectionFooterFont]
#define TableViewSectionHeaderTextColor            [UICMI tableViewSectionHeaderTextColor]
#define TableViewSectionFooterTextColor            [UICMI tableViewSectionFooterTextColor]
#define TableViewSectionHeaderContentInset         [UICMI tableViewSectionHeaderContentInset]
#define TableViewSectionFooterContentInset         [UICMI tableViewSectionFooterContentInset]

#define TableViewGroupedSectionHeaderFont          [UICMI tableViewGroupedSectionHeaderFont]
#define TableViewGroupedSectionFooterFont          [UICMI tableViewGroupedSectionFooterFont]
#define TableViewGroupedSectionHeaderTextColor     [UICMI tableViewGroupedSectionHeaderTextColor]
#define TableViewGroupedSectionFooterTextColor     [UICMI tableViewGroupedSectionFooterTextColor]
#define TableViewGroupedSectionHeaderDefaultHeight [UICMI tableViewGroupedSectionHeaderDefaultHeight]
#define TableViewGroupedSectionFooterDefaultHeight [UICMI tableViewGroupedSectionFooterDefaultHeight]
#define TableViewGroupedSectionHeaderContentInset  [UICMI tableViewGroupedSectionHeaderContentInset]
#define TableViewGroupedSectionFooterContentInset  [UICMI tableViewGroupedSectionFooterContentInset]

#define TableViewCellTitleLabelColor               [UICMI tableViewCellTitleLabelColor]
#define TableViewCellDetailLabelColor              [UICMI tableViewCellDetailLabelColor]

#pragma mark - CollectionView
#define CollectionViewBackgroundColor              [UICMI collectionViewBackgroundColor]

#pragma mark - UIWindowLevel
#define UIWindowLevelUIAlertView                  [UICMI windowLevelUIAlertView]
#define UIWindowLevelUIImagePreviewView           [UICMI windowLevelUIImagePreviewView]

#pragma mark - Others

#define SupportedOrientationMask                        [UICMI supportedOrientationMask]
#define AutomaticallyRotateDeviceOrientation            [UICMI automaticallyRotateDeviceOrientation]
#define StatusbarStyleLightInitially                    [UICMI statusbarStyleLightInitially]
#define NeedsBackBarButtonItemTitle                     [UICMI needsBackBarButtonItemTitle]
#define HidesBottomBarWhenPushedInitially               [UICMI hidesBottomBarWhenPushedInitially]
#define NavigationBarHiddenInitially                    [UICMI navigationBarHiddenInitially]
