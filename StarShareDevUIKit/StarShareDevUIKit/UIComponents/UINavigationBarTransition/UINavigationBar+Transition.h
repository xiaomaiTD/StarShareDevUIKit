//
//  UINavigationBar+Transition.h
//  Project
//
//  Created by jearoc on 2017/9/25.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Transition)

/// 用来模仿真的navBar，配合 UINavigationController+NavigationBarTransition 在转场过程中存在的一条假navBar
@property (nonatomic, strong) UINavigationBar *transitionNavigationBar;

@end
