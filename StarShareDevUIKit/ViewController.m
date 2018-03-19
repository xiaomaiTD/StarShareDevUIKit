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
#import "StarShareDevUIKit.h"
#import "SSUIWebViewController.h"
#import "SSUINavigationController.h"
#import "NSString+UI.h"

@interface ViewController ()<SSUIAlbumViewControllerDelegate,SSUIImagePickerViewControllerDelegate,SSUIImagePickerPreviewViewControllerDelegate,SSUISingleImagePickerPreviewViewControllerDelegate>
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
  
  NSLog(@"%li",[@"一" lengthWhenCountingNonASCIICharacterAsTwo]);
}

- (void)switchAction:(SSUISwitch *)sender
{
  //self.b.activityIndicatorAlignment = SSUILoadingButtonAlignmentCenter;
  //self.b.spacingWithImageOrTitle = 20;
  //self.b.activityIndicatorAlignment = SSUILoadingButtonAlignmentRight;
  self.b.loading = sender.isOn;
  
  /**
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
   */
  
  
  [self presentAlbumViewControllerWithTitle:@"相册"];
  
  /**
  SSUIWebViewController *web = [[SSUIWebViewController alloc] initWithURLString:@"https://www.baidu.com"];
  SSUINavigationController *nav = [[SSUINavigationController alloc] initWithRootViewController:web];
  [self presentViewController:nav animated:YES completion:^{
    
  }];
   */
}

- (void)presentAlbumViewControllerWithTitle:(NSString *)title {
  
  // 创建一个 SSUIAlbumViewController 实例用于呈现相簿列表
  SSUIAlbumViewController *albumViewController = [[SSUIAlbumViewController alloc] init];
  albumViewController.albumViewControllerDelegate = self;
  albumViewController.contentType = SSUIAlbumContentTypeOnlyPhoto;
  albumViewController.title = title;
  
  SSUINavigationController *navigationController = [[SSUINavigationController alloc] initWithRootViewController:albumViewController];
  
  // 获取最近发送图片时使用过的相簿，如果有则直接进入该相簿
  SSUIAssetsGroup *assetsGroup = [SSUIImagePickerHelper assetsGroupOfLastestPickerAlbumWithUserIdentify:nil];
  if (assetsGroup) {
    SSUIImagePickerViewController *imagePickerViewController = [self imagePickerViewControllerForAlbumViewController:albumViewController];
    imagePickerViewController.allowsMultipleSelection = NO;
    [imagePickerViewController refreshWithAssetsGroup:assetsGroup];
    imagePickerViewController.title = [assetsGroup name];
    [navigationController pushViewController:imagePickerViewController animated:NO];
  }
  
  [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - <SSUIAlbumViewControllerDelegate>

- (SSUIImagePickerViewController *)imagePickerViewControllerForAlbumViewController:(SSUIAlbumViewController *)albumViewController {
  SSUIImagePickerViewController *imagePickerViewController = [[SSUIImagePickerViewController alloc] init];
  imagePickerViewController.imagePickerViewControllerDelegate = self;
  imagePickerViewController.maximumSelectImageCount = 1;
  imagePickerViewController.minimumSelectImageCount = 1;
  return imagePickerViewController;
}

#pragma mark - <SSUIImagePickerViewControllerDelegate>

- (void)imagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController didFinishPickingImageWithImagesAssetArray:(NSMutableArray<SSUIAsset *> *)imagesAssetArray {
  [SSUIImagePickerHelper updateLastestAlbumWithAssetsGroup:imagePickerViewController.assetsGroup
                                          ablumContentType:SSUIAlbumContentTypeOnlyPhoto
                                              userIdentify:nil];
}

- (SSUIImagePickerPreviewViewController *)imagePickerPreviewViewControllerForImagePickerViewController:(SSUIImagePickerViewController *)imagePickerViewController {
  SSUISingleImagePickerPreviewViewController *imagePickerPreviewViewController = [[SSUISingleImagePickerPreviewViewController alloc] init];
  imagePickerPreviewViewController.delegate = self;
  return imagePickerPreviewViewController;
}

#pragma mark - <SSUISingleImagePickerPreviewViewControllerDelegate>
- (void)imagePickerPreviewViewController:(SSUISingleImagePickerPreviewViewController *)imagePickerPreviewViewController didSelectImageWithImagesAsset:(SSUIAsset *)imageAsset {
  
}

@end
