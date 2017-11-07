//
//  ViewController.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/9/29.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "ViewController.h"
#import "SSUISwitch.h"
#import "SSUIButton.h"


@interface ViewController ()
@property (nonatomic, strong) SSUILoadingButton *b;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  SSUISwitch *s = [[SSUISwitch alloc] initWithFrame:CGRectMake(100, 100, 41, 23)];
  [self.view addSubview:s];
  [s addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
  
  self.b = [[SSUILoadingButton alloc] init];
  self.b.backgroundColor = [UIColor darkTextColor];
  self.b.frame = CGRectMake(100, 200, 170, 35);
  [self.b setTitle:@"2333333" forState:UIControlStateNormal];
  [self.b setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
  [self.view addSubview:self.b];
  
  self.b.shouldProhibitUserInteractionWhenLoading = NO;
  self.b.activityIndicatorAlignment = SSUILoadingButtonAlignmentCenter;
  self.b.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}

- (void)switchAction:(SSUISwitch *)sender
{
  //self.b.activityIndicatorAlignment = SSUILoadingButtonAlignmentCenter;
  //self.b.spacingWithImageOrTitle = 20;
  //self.b.activityIndicatorAlignment = SSUILoadingButtonAlignmentRight;
  self.b.loading = sender.isOn;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
