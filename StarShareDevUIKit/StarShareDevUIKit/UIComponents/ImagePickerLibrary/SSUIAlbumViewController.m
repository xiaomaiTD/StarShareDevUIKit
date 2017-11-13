//
//  SSUIAlbumViewController.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIAlbumViewController.h"
#import "SSUITableCell.h"
#import "UICore.h"
#import "SSUIButton.h"
#import "UIView+UI.h"
#import "SSUIAssetsManager.h"
#import "SSUIImagePickerViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>

const CGFloat SSUIAlbumCellDefaultCellHeight = 57;
const CGFloat SSUIAlbumCellDefaultNameFontSize = 16;
const CGFloat SSUIAlbumCellDefaultAssetsNumberFontSize = 16;
const UIEdgeInsets SSUIAlbumCellDefaultNameInsets = {0, 8, 0, 4};

@interface SSUIAlbumViewController ()

@end

#pragma mark - SSUIAlbumTableViewCell

@interface SSUIAlbumTableViewCell : SSUITableCell

@property(nonatomic, assign) CGFloat albumNameFontSize UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat albumAssetsNumberFontSize UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets albumNameInsets UI_APPEARANCE_SELECTOR;
@end

@implementation SSUIAlbumTableViewCell {
  CALayer *_bottomLineLayer;
}

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [SSUIAlbumTableViewCell appearance].albumNameFontSize = SSUIAlbumCellDefaultNameFontSize;
    [SSUIAlbumTableViewCell appearance].albumAssetsNumberFontSize = SSUIAlbumCellDefaultAssetsNumberFontSize;
    [SSUIAlbumTableViewCell appearance].albumNameInsets = SSUIAlbumCellDefaultNameInsets;
  });
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.albumNameFontSize = [SSUIAlbumTableViewCell appearance].albumNameFontSize;
    self.albumAssetsNumberFontSize = [SSUIAlbumTableViewCell appearance].albumAssetsNumberFontSize;
    self.albumNameInsets = [SSUIAlbumTableViewCell appearance].albumNameInsets;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.detailTextLabel.textColor = UIColorGrayDarken;
    
    _bottomLineLayer = [[CALayer alloc] init];
    _bottomLineLayer.backgroundColor = UIColorSeparator.CGColor;
    [self.layer insertSublayer:_bottomLineLayer atIndex:0];
  }
  return self;
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
  [super updateCellAppearanceWithIndexPath:indexPath];
  self.textLabel.font = UIFontBoldMake(self.albumNameFontSize);
  self.detailTextLabel.font = UIFontMake(self.albumAssetsNumberFontSize);
}

- (void)layoutSubviews {
  [super layoutSubviews];
  // 避免iOS7下seletedBackgroundView会往上下露出1px（以盖住系统分隔线，但我们的分隔线是自定义的）
  self.selectedBackgroundView.frame = self.bounds;
  
  CGFloat contentViewPaddingRight = 10;
  self.imageView.frame = CGRectMake(0, 0,
                                    CGRectGetHeight(self.contentView.bounds),
                                    CGRectGetHeight(self.contentView.bounds));
  self.textLabel.frame = CGRectSetXY(self.textLabel.frame,
                                     CGRectGetMaxX(self.imageView.frame) + self.albumNameInsets.left,
                                     flat([self.textLabel topWhenCenterInSuperview]));
  CGFloat textLabelMaxWidth = CGRectGetWidth(self.contentView.bounds) - contentViewPaddingRight - CGRectGetWidth(self.detailTextLabel.frame) - self.albumNameInsets.right - CGRectGetMinX(self.textLabel.frame);
  if (CGRectGetWidth(self.textLabel.frame) > textLabelMaxWidth) {
    self.textLabel.frame = CGRectSetWidth(self.textLabel.frame, textLabelMaxWidth);
  }
  
  self.detailTextLabel.frame = CGRectSetXY(self.detailTextLabel.frame, CGRectGetMaxX(self.textLabel.frame) + self.albumNameInsets.right, flat([self.detailTextLabel topWhenCenterInSuperview]));
  _bottomLineLayer.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - PixelOne, CGRectGetWidth(self.bounds), PixelOne);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  _bottomLineLayer.hidden = highlighted;
}

@end

#pragma mark - SSUIAlbumViewController (UIAppearance)

@implementation SSUIAlbumViewController (UIAppearance)

+ (void)initialize {
  static dispatch_once_t onceToken1;
  dispatch_once(&onceToken1, ^{
    [self appearance];
  });
}

static SSUIAlbumViewController *albumViewControllerAppearance;
+ (instancetype)appearance {
  static dispatch_once_t onceToken2;
  dispatch_once(&onceToken2, ^{
    if (!albumViewControllerAppearance) {
      albumViewControllerAppearance = [[SSUIAlbumViewController alloc] init];
      albumViewControllerAppearance.albumTableViewCellHeight = SSUIAlbumCellDefaultCellHeight;
    }
  });
  return albumViewControllerAppearance;
}

@end

@implementation SSUIAlbumViewController {
  SSUIImagePickerViewController *_imagePickerViewController;
  NSMutableArray *_albumsArray;
}

- (void)didInitialized {
  [super didInitialized];
  _shouldShowDefaultLoadingView = YES;
  if (albumViewControllerAppearance) {
    // 避免 albumViewControllerAppearance init 时走到这里来，导致死循环
    self.albumTableViewCellHeight = [SSUIAlbumViewController appearance].albumTableViewCellHeight;
  }
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
  [super setNavigationItemsIsInEditMode:isInEditMode animated:animated];
  if (!self.title) {
    self.title = @"照片";
  }
  self.navigationItem.rightBarButtonItem = [UINavigationButton barButtonItemWithType:UINavigationButtonTypeNormal
                                                                               title:@"取消"
                                                                            position:UINavigationButtonPositionRight
                                                                              target:self
                                                                              action:@selector(handleCancelSelectAlbum:)];
}

- (void)initTableView {
  [super initTableView];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if ([SSUIAssetsManager authorizationStatus] == SSUIAssetAuthorizationStatusNotAuthorized) {
    NSString *tipString = self.tipTextWhenNoPhotosAuthorization;
    if (!tipString) {
      NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
      NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
      if (!appName) {
        appName = [mainInfoDictionary objectForKey:(NSString *)kCFBundleNameKey];
      }
      tipString = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
    }
    [self showEmptyViewWithText:tipString detailText:nil buttonTitle:nil buttonAction:nil];
  } else {
    
    _albumsArray = [[NSMutableArray alloc] init];
    if ([self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerWillStartLoad:)]) {
      [self.albumViewControllerDelegate albumViewControllerWillStartLoad:self];
    }
    if (self.shouldShowDefaultLoadingView) {
      [self showEmptyViewWithLoading];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      [[SSUIAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:self.contentType usingBlock:^(SSUIAssetsGroup *resultAssetsGroup) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (resultAssetsGroup) {
            [_albumsArray addObject:resultAssetsGroup];
          } else {
            [self refreshAlbumAndShowEmptyTipIfNeed];
          }
        });
      }];
    });
  }
}

- (void)refreshAlbumAndShowEmptyTipIfNeed {
  if ([_albumsArray count] > 0) {
    if ([self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerWillFinishLoad:)]) {
      [self.albumViewControllerDelegate albumViewControllerWillFinishLoad:self];
    }
    if (self.shouldShowDefaultLoadingView) {
      [self hideEmptyView];
    }
    [self.tableView reloadData];
  } else {
    NSString *tipString = self.tipTextWhenPhotosEmpty ? : @"空照片";
    [self showEmptyViewWithText:tipString detailText:nil buttonTitle:nil buttonAction:nil];
  }
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_albumsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return self.albumTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifer = @"cell";
  SSUIAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
  if (!cell) {
    cell = [[SSUIAlbumTableViewCell alloc] initForTableView:self.tableView
                                                  withStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:kCellIdentifer];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  SSUIAssetsGroup *assetsGroup = [_albumsArray objectAtIndex:indexPath.row];
  cell.imageView.image = [assetsGroup posterImageWithSize:CGSizeMake(self.albumTableViewCellHeight, self.albumTableViewCellHeight)];
  cell.textLabel.text = [assetsGroup name];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@)", @(assetsGroup.numberOfAssets)];
  
  [cell updateCellAppearanceWithIndexPath:indexPath];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (!_imagePickerViewController) {
    _imagePickerViewController = [self.albumViewControllerDelegate imagePickerViewControllerForAlbumViewController:self];
  }
  SSUIKitLog(@"self.%@ 必须实现 %@ 并返回一个 %@ 对象", NSStringFromSelector(@selector(albumViewControllerDelegate)), NSStringFromSelector(@selector(imagePickerViewControllerForAlbumViewController:)), NSStringFromClass([SSUIImagePickerViewController class]));
  SSUIAssetsGroup *assetsGroup = [_albumsArray objectAtIndex:indexPath.row];
  [_imagePickerViewController refreshWithAssetsGroup:assetsGroup];
  _imagePickerViewController.title = [assetsGroup name];
  [self.navigationController pushViewController:_imagePickerViewController animated:YES];
}

- (void)handleCancelSelectAlbum:(id)sender {
  [self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
    if (self.albumViewControllerDelegate && [self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerDidCancel:)]) {
      [self.albumViewControllerDelegate albumViewControllerDidCancel:self];
    }
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}
@end
