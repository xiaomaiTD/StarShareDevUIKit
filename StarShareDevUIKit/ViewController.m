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
#import "SSUIAlertController.h"

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
  
  SSUIAlertAction *action1 = [SSUIAlertAction actionWithTitle:@"取消" style:SSUIAlertActionStyleCancel handler:^(SSUIAlertAction *action) {
  }];
  SSUIAlertAction *action2 = [SSUIAlertAction actionWithTitle:@"删除" style:SSUIAlertActionStyleDestructive handler:^(SSUIAlertAction *action) {
  }];
  SSUIAlertAction *action3 = [SSUIAlertAction actionWithTitle:@"置灰按钮" style:SSUIAlertActionStyleDefault handler:^(SSUIAlertAction *action) {
  }];
  action3.enabled = NO;
  SSUIAlertController *alertController = [SSUIAlertController alertControllerWithTitle:@"确定删除？" message:@"删除后将无法恢复，请慎重考虑" preferredStyle:SSUIAlertControllerStyleActionSheet];
  [alertController addAction:action1];
  [alertController addAction:action2];
  [alertController addAction:action3];
  [alertController showWithAnimated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
