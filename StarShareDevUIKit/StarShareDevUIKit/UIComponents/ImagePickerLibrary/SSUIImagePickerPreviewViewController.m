//
//  SSUIImagePickerPreviewViewController.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIImagePickerPreviewViewController.h"
#import "UICore.h"
#import "SSUIImagePickerViewController.h"
#import "SSUIImagePickerHelper.h"
#import "SSUIAssetsManager.h"
#import "SSUIZoomImageView.h"
#import "SSUIAsset.h"
#import "SSUIButton.h"
#import "SSUIImagePickerHelper.h"
#import "SSUIPieProgressView.h"
#import "SSUIAlertController.h"
#import "UIImage+UI.h"
#import "UIView+UI.h"
#import "UIControl+UI.h"

BeginIgnoreAvailabilityWarning

#pragma mark - SSUIImagePickerPreviewViewController (UIAppearance)

@implementation SSUIImagePickerPreviewViewController (UIAppearance)

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self appearance];
  });
}

static SSUIImagePickerPreviewViewController *imagePickerPreviewViewControllerAppearance;
+ (instancetype)appearance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (!imagePickerPreviewViewControllerAppearance) {
      imagePickerPreviewViewControllerAppearance = [[SSUIImagePickerPreviewViewController alloc] init];
      imagePickerPreviewViewControllerAppearance.toolBarBackgroundColor = UIColorMakeWithRGBA(27, 27, 27, .9f);
      imagePickerPreviewViewControllerAppearance.toolBarTintColor = UIColorWhite;
    }
  });
  return imagePickerPreviewViewControllerAppearance;
}

@end

@implementation SSUIImagePickerPreviewViewController {
  BOOL _singleCheckMode;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.maximumSelectImageCount = INT_MAX;
    self.minimumSelectImageCount = 0;
    
    if (imagePickerPreviewViewControllerAppearance) {
      self.toolBarBackgroundColor = [SSUIImagePickerPreviewViewController appearance].toolBarBackgroundColor;
      self.toolBarTintColor = [SSUIImagePickerPreviewViewController appearance].toolBarTintColor;
    }
  }
  return self;
}

- (void)initSubviews {
  [super initSubviews];
  
  self.imagePreviewView.delegate = self;
  
  _topToolBarView = [[UIView alloc] init];
  self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
  self.topToolBarView.tintColor = self.toolBarTintColor;
  [self.view addSubview:self.topToolBarView];
  
  _backButton = [[SSUIButton alloc] init];
  self.backButton.adjustsImageTintColorAutomatically = YES;
  [self.backButton setImage:NavBarBackIndicatorImage forState:UIControlStateNormal];
  self.backButton.tintColor = self.topToolBarView.tintColor;
  [self.backButton sizeToFit];
  [self.backButton addTarget:self action:@selector(handleCancelPreviewImage:) forControlEvents:UIControlEventTouchUpInside];
  self.backButton.outsideEdge = UIEdgeInsetsMake(-30, -20, -50, -80);
  [self.topToolBarView addSubview:self.backButton];
  
  _checkboxButton = [[SSUIButton alloc] init];
  self.checkboxButton.adjustsImageTintColorAutomatically = YES;
  [self.checkboxButton setImage:[UIHelper imageWithName:@"UI_previewImage_checkbox"] forState:UIControlStateNormal];
  [self.checkboxButton setImage:[UIHelper imageWithName:@"UI_previewImage_checkbox_checked"] forState:UIControlStateSelected];
  [self.checkboxButton setImage:[UIHelper imageWithName:@"UI_previewImage_checkbox_checked"] forState:UIControlStateSelected|UIControlStateHighlighted];
  self.checkboxButton.tintColor = self.topToolBarView.tintColor;
  [self.checkboxButton sizeToFit];
  [self.checkboxButton addTarget:self action:@selector(handleCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
  self.checkboxButton.outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
  [self.topToolBarView addSubview:self.checkboxButton];
  
  _progressView = [[SSUIPieProgressView alloc] init];
  self.progressView.tintColor = self.toolBarTintColor;
  self.progressView.hidden = YES;
  [self.topToolBarView addSubview:self.progressView];
  
  _downloadRetryButton = [[UIButton alloc] init];
  [self.downloadRetryButton setImage:[UIHelper imageWithName:@"UI_icloud_download_fault"] forState:UIControlStateNormal];
  [self.downloadRetryButton sizeToFit];
  [self.downloadRetryButton addTarget:self action:@selector(handleDownloadRetryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
  self.downloadRetryButton.outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
  self.downloadRetryButton.hidden = YES;
  [self.topToolBarView addSubview:self.downloadRetryButton];
}

- (BOOL)preferredNavigationBarHidden
{
  return YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [UIHelper renderStatusBarHidenAnimation:NO];
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  if (!_singleCheckMode) {
    SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
    self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [UIHelper renderStatusBarShowAnimation:NO];
  [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  self.topToolBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), IS_58INCH_SCREEN ? 88 : 64);
  CGFloat topToolbarPaddingTop = [[UIApplication sharedApplication] isStatusBarHidden] ? 0 : IS_58INCH_SCREEN ? 44 : 20;
  CGFloat topToolbarContentHeight = CGRectGetHeight(self.topToolBarView.bounds) - topToolbarPaddingTop;
  self.backButton.frame = CGRectSetXY(self.backButton.frame, 8, topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.backButton.frame)));
  if (!self.checkboxButton.hidden) {
    self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.topToolBarView.frame) - 10 - CGRectGetWidth(self.checkboxButton.frame), topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.checkboxButton.frame)));
  }
  UIImage *downloadRetryImage = [self.downloadRetryButton imageForState:UIControlStateNormal];
  self.downloadRetryButton.frame = CGRectSetXY(self.downloadRetryButton.frame, CGRectGetWidth(self.topToolBarView.frame) - 10 - downloadRetryImage.size.width, topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.downloadRetryButton.frame)));
  /* 理论上 progressView 作为进度按钮，应该需要跟错误重试按钮 downloadRetryButton 的 frame 保持一致，但这里并没有直接使用
   * self.progressView.frame = self.downloadRetryButton.frame，这是因为 self.downloadRetryButton 具有 1pt 的 top
   * contentEdgeInsets，因此最终的 frame 是椭圆型，如果按上面的操作，progressView 内部绘制出的饼状图形就会变成椭圆型，
   * 因此，这里 progressView 直接拿 downloadRetryButton 的 image 图片尺寸作为 frame size
   */
  self.progressView.frame = CGRectFlatMake(CGRectGetMinX(self.downloadRetryButton.frame), CGRectGetMinY(self.downloadRetryButton.frame) + self.downloadRetryButton.contentEdgeInsets.top, downloadRetryImage.size.width, downloadRetryImage.size.height);
}

- (void)setToolBarBackgroundColor:(UIColor *)toolBarBackgroundColor {
  _toolBarBackgroundColor = toolBarBackgroundColor;
  self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
  _toolBarTintColor = toolBarTintColor;
  self.topToolBarView.tintColor = toolBarTintColor;
  self.backButton.tintColor = toolBarTintColor;
  self.checkboxButton.tintColor = toolBarTintColor;
}

- (void)setDownloadStatus:(SSUIAssetDownloadStatus)downloadStatus {
  _downloadStatus = downloadStatus;
  switch (downloadStatus) {
    case SSUIAssetDownloadStatusSucceed:
      if (!_singleCheckMode) {
        self.checkboxButton.hidden = NO;
      }
      self.progressView.hidden = YES;
      self.downloadRetryButton.hidden = YES;
      break;
      
    case SSUIAssetDownloadStatusDownloading:
      self.checkboxButton.hidden = YES;
      self.progressView.hidden = NO;
      self.downloadRetryButton.hidden = YES;
      break;
      
    case SSUIAssetDownloadStatusCanceled:
      self.checkboxButton.hidden = NO;
      self.progressView.hidden = YES;
      self.downloadRetryButton.hidden = YES;
      break;
      
    case SSUIAssetDownloadStatusFailed:
      self.progressView.hidden = YES;
      self.checkboxButton.hidden = YES;
      self.downloadRetryButton.hidden = NO;
      break;
      
    default:
      break;
  }
}

- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSMutableArray<SSUIAsset *> *)imageAssetArray
                                 selectedImageAssetArray:(NSMutableArray<SSUIAsset *> *)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode {
  self.imagesAssetArray = imageAssetArray;
  self.selectedImageAssetArray = selectedImageAssetArray;
  self.imagePreviewView.currentImageIndex = currentImageIndex;
  _singleCheckMode = singleCheckMode;
  if (singleCheckMode) {
    self.checkboxButton.hidden = YES;
  }
}

#pragma mark - <SSUIImagePreviewViewDelegate>

- (NSUInteger)numberOfImagesInImagePreviewView:(SSUIImagePreviewView *)imagePreviewView {
  return [self.imagesAssetArray count];
}

- (SSUIImagePreviewMediaType)imagePreviewView:(SSUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
  SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
  if (imageAsset.assetType == SSUIAssetTypeImage) {
    if (@available(iOS 9.1, *)) {
      if (imageAsset.assetSubType == SSUIAssetSubTypeLivePhoto) {
        return SSUIImagePreviewMediaTypeLivePhoto;
      }
    }
    return SSUIImagePreviewMediaTypeImage;
  } else if (imageAsset.assetType == SSUIAssetTypeVideo) {
    return SSUIImagePreviewMediaTypeVideo;
  } else {
    return SSUIImagePreviewMediaTypeOthers;
  }
}

- (void)imagePreviewView:(SSUIImagePreviewView *)imagePreviewView renderZoomImageView:(SSUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
  [self requestImageForZoomImageView:zoomImageView withIndex:index];
}

- (void)imagePreviewView:(SSUIImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index {
  if (!_singleCheckMode) {
    SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
  }
}

#pragma mark - <SSUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(SSUIZoomImageView *)zoomImageView location:(CGPoint)location {
  self.topToolBarView.hidden = !self.topToolBarView.hidden;
}


- (void)zoomImageView:(SSUIZoomImageView *)imageView didHideVideoToolbar:(BOOL)didHide {
  self.topToolBarView.hidden = didHide;
}

#pragma mark - 按钮点击回调

- (void)handleCancelPreviewImage:(SSUIButton *)button {
  [self.navigationController popViewControllerAnimated:YES];
  if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewControllerDidCancel:)]) {
    [self.delegate imagePickerPreviewViewControllerDidCancel:self];
  }
}

- (void)handleCheckButtonClick:(SSUIButton *)button {
  [SSUIImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:button];
  
  if (button.selected) {
    if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willUncheckImageAtIndex:)]) {
      [self.delegate imagePickerPreviewViewController:self willUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
    }
    
    button.selected = NO;
    SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
    [SSUIImagePickerHelper imageAssetArray:self.selectedImageAssetArray removeImageAsset:imageAsset];
    
    if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didUncheckImageAtIndex:)]) {
      [self.delegate imagePickerPreviewViewController:self didUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
    }
  } else {
    if ([self.selectedImageAssetArray count] >= self.maximumSelectImageCount) {
      if (!self.alertTitleWhenExceedMaxSelectImageCount) {
        self.alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(self.maximumSelectImageCount)];
      }
      if (!self.alertButtonTitleWhenExceedMaxSelectImageCount) {
        self.alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
      }
      
      SSUIAlertController *alertController = [SSUIAlertController alertControllerWithTitle:self.alertTitleWhenExceedMaxSelectImageCount message:nil preferredStyle:SSUIAlertControllerStyleAlert];
      [alertController addAction:[SSUIAlertAction actionWithTitle:self.alertButtonTitleWhenExceedMaxSelectImageCount style:SSUIAlertActionStyleCancel handler:nil]];
      [alertController showWithAnimated:YES];
      return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willCheckImageAtIndex:)]) {
      [self.delegate imagePickerPreviewViewController:self willCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
    }
    
    button.selected = YES;
    [SSUIImagePickerHelper springAnimationOfImageCheckedWithCheckboxButton:button];
    SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
    [self.selectedImageAssetArray addObject:imageAsset];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didCheckImageAtIndex:)]) {
      [self.delegate imagePickerPreviewViewController:self didCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
    }
  }
}

- (void)handleDownloadRetryButtonClick:(id)sender {
  [self requestImageForZoomImageView:nil withIndex:self.imagePreviewView.currentImageIndex];
}

#pragma mark - Request Image

- (void)requestImageForZoomImageView:(SSUIZoomImageView *)zoomImageView withIndex:(NSInteger)index {
  SSUIZoomImageView *imageView = zoomImageView ? : [self.imagePreviewView zoomImageViewAtIndex:index];
  // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
  // 拉取图片的过程中可能会多次返回结果，且图片尺寸越来越大，因此这里调整 contentMode 以防止图片大小跳动
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
  
  // 获取资源图片的预览图，这是一张适合当前设备屏幕大小的图片，最终展示时把图片交给组件控制最终展示出来的大小。
  // 系统相册本质上也是这么处理的，因此无论是系统相册，还是这个系列组件，由始至终都没有显示照片原图，
  // 这也是系统相册能加载这么快的原因。
  // 另外这里采用异步请求获取图片，避免获取图片时 UI 卡顿
  PHAssetImageProgressHandler phProgressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    imageAsset.downloadProgress = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
      // 只有当前显示的预览图才会展示下载进度
      SSUIKitLog(@"Download iCloud image in preview, current progress is: %f", progress);
      
      if (self.downloadStatus != SSUIAssetDownloadStatusDownloading) {
        self.downloadStatus = SSUIAssetDownloadStatusDownloading;
        // 重置 progressView 的显示的进度为 0
        [self.progressView setProgress:0 animated:NO];
      }
      // 拉取资源的初期，会有一段时间没有进度，猜测是发出网络请求以及与 iCloud 建立连接的耗时，这时预先给个 0.02 的进度值，看上去好看些
      float targetProgress = fmax(0.02, progress);
      if ( targetProgress < self.progressView.progress ) {
        [self.progressView setProgress:targetProgress animated:NO];
      } else {
        self.progressView.progress = fmax(0.02, progress);
      }
      if (error) {
        SSUIKitLog(@"Download iCloud image Failed, current progress is: %f", progress);
        self.downloadStatus = SSUIAssetDownloadStatusFailed;
      }
    });
  };
  
  /**
  if (imageAsset.assetType == SSUIAssetTypeLivePhoto) {
    imageView.tag = -1;
    imageAsset.requestID = [imageAsset requestLivePhotoWithCompletion:^void(PHLivePhoto *livePhoto, NSDictionary *info) {
      // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
      // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
      BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
      BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
      BOOL loadICloudImageFault = !livePhoto || info[PHImageErrorKey];
      if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
        // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
        // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
        dispatch_async(dispatch_get_main_queue(), ^{
          imageView.livePhoto = livePhoto;
        });
      }
      
      BOOL downloadSucceed = (livePhoto && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue]);
      
      if (downloadSucceed) {
        // 资源资源已经在本地或下载成功
        [imageAsset updateDownloadStatusWithDownloadResult:YES];
        self.downloadStatus = SSUIAssetDownloadStatusSucceed;
        
      } else if ([info objectForKey:PHLivePhotoInfoErrorKey] ) {
        // 下载错误
        [imageAsset updateDownloadStatusWithDownloadResult:NO];
        self.downloadStatus = SSUIAssetDownloadStatusFailed;
      }
      
    } withProgressHandler:phProgressHandler];
    imageView.tag = imageAsset.requestID;
  } else
    */
  if (imageAsset.assetType == SSUIAssetTypeVideo) {
    imageView.tag = -1;
    imageAsset.requestID = [imageAsset requestPlayerItemWithCompletion:^(AVPlayerItem *playerItem, NSDictionary *info) {
      // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
      // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
      BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
      BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
      BOOL loadICloudImageFault = !playerItem || info[PHImageErrorKey];
      if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
        dispatch_async(dispatch_get_main_queue(), ^{
          imageView.videoPlayerItem = playerItem;
        });
      }
    } withProgressHandler:phProgressHandler];
    imageView.tag = imageAsset.requestID;
  } else {
    if (imageAsset.assetType != SSUIAssetTypeImage) {
      return;
    }
    
    BOOL isLivePhoto = NO;
    if (@available(iOS 9.1, *)) {
      if (imageAsset.assetSubType == SSUIAssetSubTypeLivePhoto) {
        isLivePhoto = YES;
      }
    }
    
    if (isLivePhoto) {
      imageView.tag = -1;
      imageAsset.requestID = [imageAsset requestLivePhotoWithCompletion:^void(PHLivePhoto *livePhoto, NSDictionary *info) {
        // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
        // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
        dispatch_async(dispatch_get_main_queue(), ^{
          BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
          BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
          BOOL loadICloudImageFault = !livePhoto || info[PHImageErrorKey];
          if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
            // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
            // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
            if (@available(iOS 9.1, *)) {
              imageView.livePhoto = livePhoto;
            }
          }
          BOOL downloadSucceed = (livePhoto && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue]);
          if (downloadSucceed) {
            // 资源资源已经在本地或下载成功
            [imageAsset updateDownloadStatusWithDownloadResult:YES];
            self.downloadStatus = SSUIAssetDownloadStatusSucceed;
          } else if ([info objectForKey:PHLivePhotoInfoErrorKey] ) {
            // 下载错误
            [imageAsset updateDownloadStatusWithDownloadResult:NO];
            self.downloadStatus = SSUIAssetDownloadStatusFailed;
          }
        });
      } withProgressHandler:phProgressHandler];
      imageView.tag = imageAsset.requestID;
    } else if (imageAsset.assetSubType == SSUIAssetSubTypeGIF) {
      [imageAsset requestImageData:^(NSData *imageData, NSDictionary<NSString *,id> *info, BOOL isGIF, BOOL isHEIC) {
        UIImage *resultImage = [SSUIImagePickerPreviewViewController animatedGIFWithData:imageData];
        imageView.image = resultImage;
      }];
    } else {
      imageView.tag = -1;
      imageAsset.requestID = [imageAsset requestPreviewImageWithCompletion:^void(UIImage *result, NSDictionary *info) {
        // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
        // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
        dispatch_async(dispatch_get_main_queue(), ^{
          BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
          BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
          BOOL loadICloudImageFault = !result || info[PHImageErrorKey];
          if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
            imageView.image = result;
          }
          BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
          if (downloadSucceed) {
            // 资源资源已经在本地或下载成功
            [imageAsset updateDownloadStatusWithDownloadResult:YES];
            self.downloadStatus = SSUIAssetDownloadStatusSucceed;
          } else if ([info objectForKey:PHImageErrorKey] ) {
            // 下载错误
            [imageAsset updateDownloadStatusWithDownloadResult:NO];
            self.downloadStatus = SSUIAssetDownloadStatusFailed;
          }
        });
      } withProgressHandler:phProgressHandler];
      imageView.tag = imageAsset.requestID;
    }
  }
}

+ (UIImage *)animatedGIFWithData:(NSData *)data {
  // http://www.jianshu.com/p/767af9c690a3
  // https://github.com/rs/SDWebImage
  if (!data) {
    return nil;
  }
  CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  size_t count = CGImageSourceGetCount(source);
  UIImage *animatedImage;
  if (count <= 1) {
    animatedImage = [[UIImage alloc] initWithData:data];
  } else {
    NSMutableArray <UIImage *> *images = [NSMutableArray array];
    NSTimeInterval duration = 0.0f;
    for (size_t i = 0; i < count; i++) {
      CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
      duration += [self frameDurationAtIndex:i source:source];
      [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
      CGImageRelease(image);
    }
    if (!duration) {
      duration = (1.0f / 10.0f) * count;
    }
    animatedImage = [UIImage animatedImageWithImages:images duration:duration];
  }
  CFRelease(source);
  return animatedImage;
}

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
  // http://www.jianshu.com/p/767af9c690a3
  // https://github.com/rs/SDWebImage
  float frameDuration = 0.1f;
  CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
  NSDictionary <NSString *, NSDictionary *> *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
  NSDictionary <NSString *, NSNumber *> *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
  NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
  if (delayTimeUnclampedProp) {
    frameDuration = [delayTimeUnclampedProp floatValue];
  } else {
    NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
    if (delayTimeProp) {
      frameDuration = [delayTimeProp floatValue];
    }
  }
  CFRelease(cfFrameProperties);
  return frameDuration;
}
@end

EndIgnoreAvailabilityWarning
