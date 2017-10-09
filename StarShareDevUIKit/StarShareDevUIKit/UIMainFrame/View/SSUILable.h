//
//  SSUILable.h
//  Project
//
//  Created by jearoc on 2017/9/26.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSUILable : UILabel
@property(nonatomic,assign) UIEdgeInsets contentEdgeInsets;
@property(nonatomic,assign) IBInspectable BOOL canPerformCopyAction;
@property(nonatomic,strong) IBInspectable UIColor *highlightedBackgroundColor;
@end
