//
//  SSUIVisualEffectView.h
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/16.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SSUIVisualEffectViewStyle) {
  SSUIVisualEffectViewStyleExtraLight,
  SSUIVisualEffectViewStyleLight,
  SSUIVisualEffectViewStyleDark
};

@interface SSUIVisualEffectView : UIView

@property(nonatomic,assign,readonly) SSUIVisualEffectViewStyle style;
- (instancetype)initWithStyle:(SSUIVisualEffectViewStyle)style;
@end
