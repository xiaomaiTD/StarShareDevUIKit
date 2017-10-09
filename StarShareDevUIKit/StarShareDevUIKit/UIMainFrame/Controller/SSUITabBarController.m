//
//  SSUITabBarController.m
//  XX_iOS_APP
//
//  Created by pmo on 2017/8/16.
//  Copyright © 2017年 pmo. All rights reserved.
//

#import "SSUITabBarController.h"
#import "UIExtensions.h"
#import "UICore.h"

@interface SSUITabBarController ()

@end

@implementation SSUITabBarController

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
  self.tabBar.tintColor = TabBarTintColor;
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
  return [self.selectedViewController hasOverrideUIKitMethod:_cmd] ? [self.selectedViewController shouldAutorotate] : YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return [self.selectedViewController hasOverrideUIKitMethod:_cmd] ? [self.selectedViewController supportedInterfaceOrientations] : SupportedOrientationMask;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
