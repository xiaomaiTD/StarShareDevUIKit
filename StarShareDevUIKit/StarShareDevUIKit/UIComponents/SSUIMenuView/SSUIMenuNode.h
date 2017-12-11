//
//  SSUIMenuNode.h
//  StarShare_iOS
//
//  Created by BUBUKO on 2017/12/10.
//  Copyright © 2017年 Rui Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SSUIMenuNodeState) {
  SSUIMenuNodeStateSelected,
  SSUIMenuNodeStateNormal,
};

NS_ASSUME_NONNULL_BEGIN

@class SSUIMenuNode;

@protocol SSUIMenuNodeDelegate <NSObject>
@optional
- (void)didPressedMenuNode:(SSUIMenuNode *)menuNode;
@end

@interface SSUIMenuNode : UILabel

@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) CGFloat normalSize;
@property (nonatomic, assign) CGFloat selectedSize;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign) CGFloat speedFactor;
@property (nonatomic, nullable, weak) id<SSUIMenuNodeDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL selected;

- (void)setSelected:(BOOL)selected withAnimation:(BOOL)animation;
@end

NS_ASSUME_NONNULL_END
