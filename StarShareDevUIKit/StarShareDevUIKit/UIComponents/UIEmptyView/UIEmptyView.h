//
//  UIEmptyView.h
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIEmptyViewLoadingViewProtocol <NSObject>
@optional
- (void)startAnimating; // 当调用 setLoadingViewHidden:NO 时，系统将自动调用此处的 startAnimating
@end

@interface UIEmptyView : UIView
@property(nonatomic, strong) UIView<UIEmptyViewLoadingViewProtocol> *loadingView;
@property(nonatomic, strong, readonly) UIImageView *imageView;
@property(nonatomic, strong, readonly) UILabel *textLabel;
@property(nonatomic, strong, readonly) UILabel *detailTextLabel;
@property(nonatomic, strong, readonly) UIButton *actionButton;
// 可通过调整这些insets来控制间距
@property(nonatomic, assign) UIEdgeInsets imageViewInsets UI_APPEARANCE_SELECTOR;   // 默认为(0, 0, 36, 0)
@property(nonatomic, assign) UIEdgeInsets loadingViewInsets UI_APPEARANCE_SELECTOR;     // 默认为(0, 0, 36, 0)
@property(nonatomic, assign) UIEdgeInsets textLabelInsets UI_APPEARANCE_SELECTOR;   // 默认为(0, 0, 10, 0)
@property(nonatomic, assign) UIEdgeInsets detailTextLabelInsets UI_APPEARANCE_SELECTOR; // 默认为(0, 0, 10, 0)
@property(nonatomic, assign) UIEdgeInsets actionButtonInsets UI_APPEARANCE_SELECTOR;    // 默认为(0, 0, 0, 0)
@property(nonatomic, assign) CGFloat verticalOffset UI_APPEARANCE_SELECTOR; // 如果不想要内容整体垂直居中，则可通过调整此属性来进行垂直偏移。默认为-30，即内容比中间略微偏上

// 字体
@property(nonatomic, strong) UIFont *textLabelFont UI_APPEARANCE_SELECTOR;  // 默认为15pt系统字体
@property(nonatomic, strong) UIFont *detailTextLabelFont UI_APPEARANCE_SELECTOR;    // 默认为14pt系统字体
@property(nonatomic, strong) UIFont *actionButtonFont UI_APPEARANCE_SELECTOR;   // 默认为15pt系统字体

// 颜色
@property(nonatomic, strong) UIColor *textLabelTextColor UI_APPEARANCE_SELECTOR;    // 默认为(93, 100, 110)
@property(nonatomic, strong) UIColor *detailTextLabelTextColor UI_APPEARANCE_SELECTOR;  // 默认为(133, 140, 150)
@property(nonatomic, strong) UIColor *actionButtonTitleColor UI_APPEARANCE_SELECTOR;    // 默认为 ButtonTintColor

- (void)setLoadingViewHidden:(BOOL)hidden;
- (void)setImage:(UIImage *)image;
- (void)setTextLabelText:(NSString *)text;
- (void)setDetailTextLabelText:(NSString *)text;
- (void)setActionButtonTitle:(NSString *)title;
@property(nonatomic, strong, readonly) UIView *contentView;
- (CGSize)sizeThatContentViewFits;  // 返回一个恰好容纳所有子 view 的大小
@end
