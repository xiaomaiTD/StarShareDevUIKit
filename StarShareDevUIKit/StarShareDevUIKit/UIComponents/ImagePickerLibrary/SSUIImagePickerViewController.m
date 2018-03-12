//
//  SSUIImagePickerViewController.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIImagePickerViewController.h"
#import "UICore.h"
#import "SSUIImagePickerCollectionViewCell.h"
#import "SSUIButton.h"
#import "SSUIPieProgressView.h"
#import "SSUIAssetsManager.h"
#import "SSUIAlertController.h"
#import "SSUIImagePickerHelper.h"
#import "UICollectionView+UI.h"
#import "UIScrollView+UI.h"
#import "CALayer+UI.h"
#import "UIView+UI.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+UI.h"
#import "UIEmptyView.h"
#import "UINavigationButton.h"

#define OperationToolBarViewHeight 44
#define OperationToolBarViewPaddingHorizontal 12
#define ImageCountLabelSize CGSizeMake(18, 18)

#define CollectionViewInsetHorizontal PreferredVarForDevices((PixelOne * 2), 1, 2, 2)
#define CollectionViewInset UIEdgeInsetsMake(CollectionViewInsetHorizontal, CollectionViewInsetHorizontal, CollectionViewInsetHorizontal, CollectionViewInsetHorizontal)
#define CollectionViewCellMargin CollectionViewInsetHorizontal

static NSString * const kVideoCellIdentifier = @"video";
static NSString * const kImageOrUnknownCellIdentifier = @"imageorunknown";

#pragma mark - SSUIImagePickerViewController (UIAppearance)

@implementation SSUIImagePickerViewController (UIAppearance)

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self appearance];
  });
}

static SSUIImagePickerViewController *imagePickerViewControllerAppearance;
+ (instancetype)appearance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if (!imagePickerViewControllerAppearance) {
      imagePickerViewControllerAppearance = [[SSUIImagePickerViewController alloc] init];
      imagePickerViewControllerAppearance.minimumImageWidth = 75;
    }
  });
  return imagePickerViewControllerAppearance;
}
@end

@interface SSUIImagePickerViewController ()

@property(nonatomic, strong, readwrite) UICollectionViewFlowLayout *collectionViewLayout;
@property(nonatomic, strong, readwrite) UICollectionView *collectionView;
@property(nonatomic, strong, readwrite) UIView *operationToolBarView;
@property(nonatomic, strong, readwrite) SSUIButton *previewButton;
@property(nonatomic, strong, readwrite) SSUIButton *sendButton;
@property(nonatomic, strong, readwrite) UILabel *imageCountLabel;

@property(nonatomic, strong, readwrite) NSMutableArray<SSUIAsset *> *imagesAssetArray;
@property(nonatomic, strong, readwrite) SSUIAssetsGroup *assetsGroup;

@property(nonatomic, strong) SSUIImagePickerPreviewViewController *imagePickerPreviewViewController;
@property(nonatomic, assign) BOOL hasScrollToInitialPosition;
@property(nonatomic, assign) BOOL canScrollToInitialPosition;
@end

@implementation SSUIImagePickerViewController

- (void)didInitialized {
  [super didInitialized];
  
  if (imagePickerViewControllerAppearance) {
    self.minimumImageWidth = [SSUIImagePickerViewController appearance].minimumImageWidth;
  }
  
  _allowsMultipleSelection = YES;
  _maximumSelectImageCount = INT_MAX;
  _minimumSelectImageCount = 0;
  _shouldShowDefaultLoadingView = YES;
  
  [self loadViewIfNeeded];
}

- (void)dealloc {
  self.collectionView.dataSource = nil;
  self.collectionView.delegate = nil;
}

- (void)initSubviews {
  [super initSubviews];
  
  self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
  self.collectionViewLayout.sectionInset = CollectionViewInset;
  self.collectionViewLayout.minimumLineSpacing = CollectionViewCellMargin;
  self.collectionViewLayout.minimumInteritemSpacing = CollectionViewCellMargin;
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewLayout];
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  self.collectionView.delaysContentTouches = NO;
  self.collectionView.showsHorizontalScrollIndicator = NO;
  self.collectionView.alwaysBounceHorizontal = NO;
  self.collectionView.backgroundColor = UIColorClear;
  [self.collectionView registerClass:[SSUIImagePickerCollectionViewCell class] forCellWithReuseIdentifier:kVideoCellIdentifier];
  [self.collectionView registerClass:[SSUIImagePickerCollectionViewCell class] forCellWithReuseIdentifier:kImageOrUnknownCellIdentifier];
  [self.view addSubview:self.collectionView];
  
  // 只有允许多选时，才显示底部工具
  if (self.allowsMultipleSelection) {
    self.operationToolBarView = [[UIView alloc] init];
    self.operationToolBarView.backgroundColor = UIColorWhite;
    self.operationToolBarView.borderPosition = SSUIBorderViewPositionTop;
    [self.view addSubview:self.operationToolBarView];
    
    self.sendButton = [[SSUIButton alloc] init];
    self.sendButton.titleLabel.font = UIFontMake(16);
    self.sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.sendButton setTitleColor:UIColorMake(124, 124, 124) forState:UIControlStateNormal];
    [self.sendButton setTitleColor:UIColorGray forState:UIControlStateDisabled];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton sizeToFit];
    self.sendButton.enabled = NO;
    [self.sendButton addTarget:self action:@selector(handleSendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.operationToolBarView addSubview:self.sendButton];
    
    self.previewButton = [[SSUIButton alloc] init];
    self.previewButton.titleLabel.font = self.sendButton.titleLabel.font;
    [self.previewButton setTitleColor:[self.sendButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.previewButton setTitleColor:[self.sendButton titleColorForState:UIControlStateDisabled] forState:UIControlStateDisabled];
    [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.previewButton sizeToFit];
    self.previewButton.enabled = NO;
    [self.previewButton addTarget:self action:@selector(handlePreviewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.operationToolBarView addSubview:self.previewButton];
    
    self.imageCountLabel = [[UILabel alloc] init];
    self.imageCountLabel.backgroundColor = ButtonTintColor;
    self.imageCountLabel.textColor = UIColorWhite;
    self.imageCountLabel.font = UIFontMake(12);
    self.imageCountLabel.textAlignment = NSTextAlignmentCenter;
    self.imageCountLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.imageCountLabel.layer.masksToBounds = YES;
    self.imageCountLabel.layer.cornerRadius = ImageCountLabelSize.width / 2;
    self.imageCountLabel.hidden = YES;
    [self.operationToolBarView addSubview:self.imageCountLabel];
  }
  
  _selectedImageAssetArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColorWhite;
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
  [super setNavigationItemsIsInEditMode:isInEditMode animated:animated];
  self.navigationItem.rightBarButtonItem = [UINavigationButton barButtonItemWithType:UINavigationButtonTypeNormal
                                                                               title:@"取消"
                                                                            position:UINavigationButtonPositionRight
                                                                              target:self
                                                                              action:@selector(handleCancelPickerImage:)];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (self.allowsMultipleSelection) {
    NSInteger selectedImageCount = [_selectedImageAssetArray count];
    if (selectedImageCount > 0) {
      self.previewButton.enabled = YES;
      self.sendButton.enabled = YES;
      self.imageCountLabel.text = [NSString stringWithFormat:@"%@", @(selectedImageCount)];
      self.imageCountLabel.hidden = NO;
    } else {
      self.previewButton.enabled = NO;
      self.sendButton.enabled = NO;
      self.imageCountLabel.hidden = YES;
    }
  }
  [self.collectionView reloadData];
}

- (void)showEmptyView {
  [super showEmptyView];
  self.emptyView.backgroundColor = self.view.backgroundColor;
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  if (!CGSizeEqualToSize(self.collectionView.frame.size, self.view.bounds.size)) {
    self.collectionView.frame = self.view.bounds;
  }
  
  CGFloat operationToolBarViewHeight = 0;
  if (self.allowsMultipleSelection) {
    self.operationToolBarView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - OperationToolBarViewHeight, CGRectGetWidth(self.view.bounds), OperationToolBarViewHeight);
    self.previewButton.frame = CGRectSetXY(self.previewButton.frame, OperationToolBarViewPaddingHorizontal, CGFloatGetCenter(CGRectGetHeight(self.operationToolBarView.frame), CGRectGetHeight(self.previewButton.frame)));
    self.sendButton.frame = CGRectMake(CGRectGetWidth(self.operationToolBarView.frame) - OperationToolBarViewPaddingHorizontal - CGRectGetWidth(self.sendButton.frame), CGFloatGetCenter(CGRectGetHeight(self.operationToolBarView.frame), CGRectGetHeight(self.sendButton.frame)), CGRectGetWidth(self.sendButton.frame), CGRectGetHeight(self.sendButton.frame));
    self.imageCountLabel.frame = CGRectMake(CGRectGetMinX(self.sendButton.frame) - ImageCountLabelSize.width - 5, CGRectGetMinY(self.sendButton.frame) + CGFloatGetCenter(CGRectGetHeight(self.sendButton.frame), ImageCountLabelSize.height), ImageCountLabelSize.width, ImageCountLabelSize.height);
    operationToolBarViewHeight = CGRectGetHeight(self.operationToolBarView.frame);
  }
  
  if (self.collectionView.contentInset.bottom != operationToolBarViewHeight) {
    self.collectionView.contentInset = UIEdgeInsetsSetBottom(self.collectionView.contentInset, operationToolBarViewHeight);
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    [self scrollToInitialPositionIfNeeded];
  }
}

- (void)refreshWithImagesArray:(NSMutableArray<SSUIAsset *> *)imagesArray {
  self.imagesAssetArray = imagesArray;
  [self.collectionView reloadData];
}

- (void)refreshWithAssetsGroup:(SSUIAssetsGroup *)assetsGroup {
  self.assetsGroup = assetsGroup;
  if (!self.imagesAssetArray) {
    self.imagesAssetArray = [[NSMutableArray alloc] init];
  } else {
    [self.imagesAssetArray removeAllObjects];
  }
  SSUIAlbumSortType albumSortType = SSUIAlbumSortTypePositive;
  if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(albumSortTypeForImagePickerViewController:)]) {
    albumSortType = [self.imagePickerViewControllerDelegate albumSortTypeForImagePickerViewController:self];
  }
  
  if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerWillStartLoad:)]) {
    [self.imagePickerViewControllerDelegate imagePickerViewControllerWillStartLoad:self];
  }
  if (self.shouldShowDefaultLoadingView) {
    [self showEmptyViewWithLoading];
  }
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [assetsGroup enumerateAssetsWithOptions:albumSortType usingBlock:^(SSUIAsset *resultAsset) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (resultAsset) {
          [self.imagesAssetArray addObject:resultAsset];
        } else {
          [self.collectionView reloadData];
          [self.collectionView performBatchUpdates:NULL
                                        completion:^(BOOL finished) {
                                          
                                          [self scrollToInitialPositionIfNeeded];
                                          
                                          if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerWillFinishLoad:)]) {
                                            [self.imagePickerViewControllerDelegate imagePickerViewControllerWillFinishLoad:self];
                                          }
                                          if (self.shouldShowDefaultLoadingView) {
                                            [self hideEmptyView];
                                          }
                                        }];
        }
      });
    }];
  });
}

- (void)initPreviewViewControllerIfNeeded {
  if (!self.imagePickerPreviewViewController) {
    self.imagePickerPreviewViewController = [self.imagePickerViewControllerDelegate imagePickerPreviewViewControllerForImagePickerViewController:self];
    self.imagePickerPreviewViewController.maximumSelectImageCount = self.maximumSelectImageCount;
    self.imagePickerPreviewViewController.minimumSelectImageCount = self.minimumSelectImageCount;
  }
}

- (CGSize)referenceImageSize {
  CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
  CGFloat collectionViewContentSpacing = collectionViewWidth - UIEdgeInsetsGetHorizontalValue(self.collectionView.contentInset);
  NSInteger columnCount = floor(collectionViewContentSpacing / self.minimumImageWidth);
  CGFloat referenceImageWidth = self.minimumImageWidth;
  BOOL isSpacingEnoughWhenDisplayInMinImageSize = UIEdgeInsetsGetHorizontalValue(self.collectionViewLayout.sectionInset) + (self.minimumImageWidth + self.collectionViewLayout.minimumInteritemSpacing) * columnCount - self.collectionViewLayout.minimumInteritemSpacing <= collectionViewContentSpacing;
  if (!isSpacingEnoughWhenDisplayInMinImageSize) {
    columnCount -= 1;
  }
  referenceImageWidth = (collectionViewContentSpacing - UIEdgeInsetsGetHorizontalValue(self.collectionViewLayout.sectionInset) - self.collectionViewLayout.minimumInteritemSpacing * (columnCount - 1)) / columnCount;
  return CGSizeMake(referenceImageWidth, referenceImageWidth);
}

- (void)setMinimumImageWidth:(CGFloat)minimumImageWidth {
  _minimumImageWidth = minimumImageWidth;
  [self referenceImageSize];
  [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)scrollToInitialPositionIfNeeded {
  BOOL hasDataLoaded = [self.collectionView numberOfItemsInSection:0] > 0;
  if (self.collectionView.window && hasDataLoaded && !self.hasScrollToInitialPosition) {
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(albumSortTypeForImagePickerViewController:)] && [self.imagePickerViewControllerDelegate albumSortTypeForImagePickerViewController:self] == SSUIAlbumSortTypeReverse) {
      [self.collectionView scrollToTopForce:NO animated:NO];
    } else {
      if ([self.collectionView canScroll]) {
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x,
                                                          self.collectionView.contentSize.height +
                                                          self.collectionView.contentInset.bottom -
                                                          CGRectGetHeight(self.collectionView.bounds))
                                     animated:NO];
      }
    }
    
    self.hasScrollToInitialPosition = YES;
  }
}

- (void)willPopInNavigationControllerWithAnimated:(BOOL)animated {
  self.hasScrollToInitialPosition = NO;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.imagesAssetArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self referenceImageSize];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = kImageOrUnknownCellIdentifier;
  SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
  if (imageAsset.assetType == SSUIAssetTypeVideo) {
    identifier = kVideoCellIdentifier;
  }
  SSUIImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
  
  [imageAsset requestThumbnailImageWithSize:[self referenceImageSize] completion:^(UIImage *result, NSDictionary *info) {
    if (!info || [[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
      cell.contentImageView.image = result;
    } else if ([collectionView itemVisibleAtIndexPath:indexPath]) {
      SSUIImagePickerCollectionViewCell *anotherCell = (SSUIImagePickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
      anotherCell.contentImageView.image = result;
    }
  }];
  
  if (imageAsset.assetType == SSUIAssetTypeVideo) {
    cell.videoDurationLabel.text = [NSString timeStringWithMinsAndSecsFromSecs:imageAsset.duration];
  }
  
  [cell.checkboxButton addTarget:self action:@selector(handleCheckBoxButtonClick:) forControlEvents:UIControlEventTouchUpInside];
  [cell.progressView addTarget:self action:@selector(handleProgressViewClick:) forControlEvents:UIControlEventTouchUpInside];
  [cell.downloadRetryButton addTarget:self action:@selector(handleDownloadRetryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
  
  cell.editing = self.allowsMultipleSelection;
  if (cell.editing) {
    cell.checked = [SSUIImagePickerHelper imageAssetArray:_selectedImageAssetArray containsImageAsset:imageAsset];
  }
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
  if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didSelectImageWithImagesAsset:afterImagePickerPreviewViewControllerUpdate:)]) {
    [self.imagePickerViewControllerDelegate imagePickerViewController:self didSelectImageWithImagesAsset:imageAsset afterImagePickerPreviewViewControllerUpdate:self.imagePickerPreviewViewController];
  }
  
  if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerPreviewViewControllerForImagePickerViewController:)]) {
    [self initPreviewViewControllerIfNeeded];
    if (!self.allowsMultipleSelection) {
      // 单选的情况下
      [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:@[imageAsset]
                                                                      selectedImageAssetArray:nil
                                                                            currentImageIndex:0
                                                                              singleCheckMode:YES];
    } else {
      // cell 处于编辑状态，即图片允许多选
      [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:self.imagesAssetArray
                                                                      selectedImageAssetArray:_selectedImageAssetArray
                                                                            currentImageIndex:indexPath.item
                                                                              singleCheckMode:NO];
    }
    [self.navigationController pushViewController:self.imagePickerPreviewViewController animated:YES];
  }
}

#pragma mark - 按钮点击回调

- (void)handleSendButtonClick:(id)sender {
  if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didFinishPickingImageWithImagesAssetArray:)]) {
    [self.imagePickerViewControllerDelegate imagePickerViewController:self didFinishPickingImageWithImagesAssetArray:_selectedImageAssetArray];
  }
  [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)handlePreviewButtonClick:(id)sender {
  [self initPreviewViewControllerIfNeeded];
  [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:[_selectedImageAssetArray copy]
                                                                  selectedImageAssetArray:_selectedImageAssetArray
                                                                        currentImageIndex:0
                                                                          singleCheckMode:NO];
  [self.navigationController pushViewController:self.imagePickerPreviewViewController animated:YES];
}

- (void)handleCancelPickerImage:(id)sender {
  [self.navigationController dismissViewControllerAnimated:YES completion:^() {
    if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerDidCancel:)]) {
      [self.imagePickerViewControllerDelegate imagePickerViewControllerDidCancel:self];
    }
  }];
}

- (void)handleCheckBoxButtonClick:(id)sender {
  UIButton *checkBoxButton = sender;
  NSIndexPath *indexPath = [self.collectionView indexPathForItemAtView:checkBoxButton];
  
  SSUIImagePickerCollectionViewCell *cell = (SSUIImagePickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
  if (cell.checked) {
    // 移除选中状态
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:willUncheckImageAtIndex:)]) {
      [self.imagePickerViewControllerDelegate imagePickerViewController:self willUncheckImageAtIndex:indexPath.item];
    }
    
    cell.checked = NO;
    [SSUIImagePickerHelper imageAssetArray:_selectedImageAssetArray removeImageAsset:imageAsset];
    
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didUncheckImageAtIndex:)]) {
      [self.imagePickerViewControllerDelegate imagePickerViewController:self didUncheckImageAtIndex:indexPath.item];
    }
    
    // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
    [self updateImageCountAndCheckLimited];
  } else {
    // 选中该资源
    // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
    [self requestImageWithIndexPath:indexPath];
  }
}

- (void)handleProgressViewClick:(id)sender {
  UIControl *progressView = sender;
  NSIndexPath *indexPath = [self.collectionView indexPathForItemAtView:progressView];
  SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
  if (imageAsset.downloadStatus == SSUIAssetDownloadStatusDownloading) {
    // 下载过程中点击，取消下载，理论上能点击 progressView 就肯定是下载中，这里只是做个保护
    SSUIImagePickerCollectionViewCell *cell = (SSUIImagePickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [[SSUIAssetsManager sharedInstance].cachingImageManager cancelImageRequest:(int32_t)imageAsset.requestID];
    SSUIKitLog(@"Cancel download asset image with request ID %@", [NSNumber numberWithInteger:imageAsset.requestID]);
    cell.downloadStatus = SSUIAssetDownloadStatusCanceled;
    [imageAsset updateDownloadStatusWithDownloadResult:NO];
  }
}

- (void)handleDownloadRetryButtonClick:(id)sender {
  UIButton *downloadRetryButton = sender;
  NSIndexPath *indexPath = [self.collectionView indexPathForItemAtView:downloadRetryButton];
  [self requestImageWithIndexPath:indexPath];
}

- (void)updateImageCountAndCheckLimited {
  NSInteger selectedImageCount = [_selectedImageAssetArray count];
  if (selectedImageCount > 0 && selectedImageCount >= _minimumSelectImageCount) {
    self.previewButton.enabled = YES;
    self.sendButton.enabled = YES;
    self.imageCountLabel.text = [NSString stringWithFormat:@"%@", @(selectedImageCount)];
    self.imageCountLabel.hidden = NO;
    [SSUIImagePickerHelper springAnimationOfImageSelectedCountChangeWithCountLabel:self.imageCountLabel];
  } else {
    self.previewButton.enabled = NO;
    self.sendButton.enabled = NO;
    self.imageCountLabel.hidden = YES;
  }
}

#pragma mark - Request Image

- (void)requestImageWithIndexPath:(NSIndexPath *)indexPath {
  // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
  SSUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
  SSUIImagePickerCollectionViewCell *cell = (SSUIImagePickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  imageAsset.requestID = [imageAsset requestPreviewImageWithCompletion:^(UIImage *result, NSDictionary *info) {
    
    BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
    
    if (downloadSucceed) {
      // 资源资源已经在本地或下载成功
      [imageAsset updateDownloadStatusWithDownloadResult:YES];
      cell.downloadStatus = SSUIAssetDownloadStatusSucceed;
      
      if ([_selectedImageAssetArray count] >= _maximumSelectImageCount) {
        if (!_alertTitleWhenExceedMaxSelectImageCount) {
          _alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(_maximumSelectImageCount)];
        }
        if (!_alertButtonTitleWhenExceedMaxSelectImageCount) {
          _alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
        }
        
        SSUIAlertController *alertController = [SSUIAlertController alertControllerWithTitle:_alertTitleWhenExceedMaxSelectImageCount message:nil preferredStyle:SSUIAlertControllerStyleAlert];
        [alertController addAction:[SSUIAlertAction actionWithTitle:_alertButtonTitleWhenExceedMaxSelectImageCount style:SSUIAlertActionStyleCancel handler:nil]];
        [alertController showWithAnimated:YES];
        return;
      }
      
      if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:willCheckImageAtIndex:)]) {
        [self.imagePickerViewControllerDelegate imagePickerViewController:self willCheckImageAtIndex:indexPath.item];
      }
      
      cell.checked = YES;
      [_selectedImageAssetArray addObject:imageAsset];
      
      if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didCheckImageAtIndex:)]) {
        [self.imagePickerViewControllerDelegate imagePickerViewController:self didCheckImageAtIndex:indexPath.item];
      }
      
      // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
      [self updateImageCountAndCheckLimited];
    } else if ([info objectForKey:PHImageErrorKey] ) {
      // 下载错误
      [imageAsset updateDownloadStatusWithDownloadResult:NO];
      cell.downloadStatus = SSUIAssetDownloadStatusFailed;
    }
    
  } withProgressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    imageAsset.downloadProgress = progress;
    
    if ([self.collectionView itemVisibleAtIndexPath:indexPath]) {
      /**
       *  withProgressHandler 不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
       *  为了避免这种情况，这里该 block 主动放到主线程执行。
       */
      dispatch_async(dispatch_get_main_queue(), ^{
        SSUIKitLog(@"Download iCloud image, current progress is : %f", progress);
        
        if (cell.downloadStatus != SSUIAssetDownloadStatusDownloading) {
          cell.downloadStatus = SSUIAssetDownloadStatusDownloading;
          // 重置 progressView 的显示的进度为 0
          [cell.progressView setProgress:0 animated:NO];
          // 预先设置预览界面的下载状态
          self.imagePickerPreviewViewController.downloadStatus = SSUIAssetDownloadStatusDownloading;
        }
        // 拉取资源的初期，会有一段时间没有进度，猜测是发出网络请求以及与 iCloud 建立连接的耗时，这时预先给个 0.02 的进度值，看上去好看些
        float targetProgress = MAX(0.02, progress);
        if ( targetProgress < cell.progressView.progress ) {
          [cell.progressView setProgress:targetProgress animated:NO];
        } else {
          cell.progressView.progress = MAX(0.02, progress);
        }
        if (error) {
          SSUIKitLog(@"Download iCloud image Failed, current progress is: %f", progress);
          cell.downloadStatus = SSUIAssetDownloadStatusFailed;
        }
      });
    }
  }];
}

@end
