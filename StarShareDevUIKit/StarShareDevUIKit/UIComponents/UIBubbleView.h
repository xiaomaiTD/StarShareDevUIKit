//
//  UIBubbleView.h
//  Project
//
//  Created by jearoc on 2017/10/9.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGSize UIBubbleViewAutomaticalMaximumItemSize;

@interface UIBubbleView : UIView
@property(nonatomic, assign) UIEdgeInsets padding;
@property(nonatomic, assign) IBInspectable CGSize minimumItemSize;
@property(nonatomic, assign) IBInspectable CGSize maximumItemSize;
@property(nonatomic, assign) UIEdgeInsets itemMargins;
@end
