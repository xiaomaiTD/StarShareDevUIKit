//
//  UINavigationTitleView.h
//  Project
//
//  Created by jearoc on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UINavigationTitleView;

@protocol UINavigationTitleViewDelegate <NSObject>
@optional
- (void)didTouchTitleView:(UINavigationTitleView *)titleView;
@end

@interface UINavigationTitleView : UIControl
@property(nonatomic, weak) id<UINavigationTitleViewDelegate> delegate;
#pragma mark - Titles
@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong, readonly) UILabel *subtitleLabel;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont *subtitleFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets titleEdgeInsets UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets subtitleEdgeInsets UI_APPEARANCE_SELECTOR;
#pragma mark - Loading
@property(nonatomic, strong, readonly) UIActivityIndicatorView *loadingView;
@property(nonatomic, assign) BOOL needsLoadingView;
@property(nonatomic, assign) BOOL loadingViewHidden;
@property(nonatomic, assign) BOOL needsLoadingPlaceholderSpace;
@property(nonatomic, assign) CGSize loadingViewSize UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat loadingViewMarginRight UI_APPEARANCE_SELECTOR;
@end
