//
//  SSUISingleImagePickerPreviewViewController.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2018/2/2.
//  Copyright © 2018年 jearoc. All rights reserved.
//

#import "SSUISingleImagePickerPreviewViewController.h"
#import "SSUIButton.h"

@implementation SSUISingleImagePickerPreviewViewController {
  SSUIButton *_confirmButton;
}
@dynamic delegate;

- (void)initSubviews {
  [super initSubviews];
  _confirmButton = [[SSUIButton alloc] init];
  _confirmButton.outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
  [_confirmButton setTitleColor:self.toolBarTintColor forState:UIControlStateNormal];
  [_confirmButton setTitle:@"使用" forState:UIControlStateNormal];
  [_confirmButton addTarget:self action:@selector(handleConfirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
  [_confirmButton sizeToFit];
  [self.topToolBarView addSubview:_confirmButton];
}

- (void)setDownloadStatus:(SSUIAssetDownloadStatus)downloadStatus {
  [super setDownloadStatus:downloadStatus];
  switch (downloadStatus) {
    case SSUIAssetDownloadStatusSucceed:
      _confirmButton.hidden = NO;
      break;
      
    case SSUIAssetDownloadStatusDownloading:
      _confirmButton.hidden = YES;
      break;
      
    case SSUIAssetDownloadStatusCanceled:
      _confirmButton.hidden = NO;
      break;
      
    case SSUIAssetDownloadStatusFailed:
      _confirmButton.hidden = YES;
      break;
      
    default:
      break;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  _confirmButton.frame = CGRectSetXY(_confirmButton.frame,
                                     CGRectGetWidth(self.topToolBarView.frame) - CGRectGetWidth(_confirmButton.frame) - 10,
                                     CGRectGetMinY(self.backButton.frame) + CGFloatGetCenter(CGRectGetHeight(self.backButton.frame),
                                                                                             CGRectGetHeight(_confirmButton.frame)));
}

- (void)handleConfirmButtonClick:(id)sender {
  [self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didSelectImageWithImagesAsset:)]) {
      SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
      [self.delegate imagePickerPreviewViewController:self didSelectImageWithImagesAsset:imageAsset];
    }
  }];
}
@end
