//
//  ViewController.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "ViewController.h"
#import "SSUISwitch.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  SSUISwitch *s = [[SSUISwitch alloc] initWithFrame:CGRectMake(100, 100, 41, 23)];
  [self.view addSubview:s];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
