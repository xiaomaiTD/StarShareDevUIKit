//
//  UIStaticTableViewCellData.m
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "UIStaticTableViewCellData.h"
#import "UICore.h"
#import "SSUITableCell.h"

@implementation UIStaticTableViewCellData

- (void)setIndexPath:(NSIndexPath *)indexPath {
  _indexPath = indexPath;
}

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                      didSelectTarget:(id)didSelectTarget
                                      didSelectAction:(SEL)didSelectAction
                                        accessoryType:(UIStaticTableViewCellAccessoryType)accessoryType {
  return [UIStaticTableViewCellData staticTableViewCellDataWithIdentifier:identifier
                                                                cellClass:[SSUITableCell class]
                                                                    style:UITableViewCellStyleDefault
                                                                   height:TableViewCellNormalHeight
                                                                    image:image
                                                                     text:text
                                                               detailText:detailText
                                                          didSelectTarget:didSelectTarget
                                                          didSelectAction:didSelectAction
                                                            accessoryType:accessoryType
                                                     accessoryValueObject:nil
                                                          accessoryTarget:nil
                                                          accessoryAction:NULL];
}

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                            cellClass:(Class)cellClass
                                                style:(UITableViewCellStyle)style
                                               height:(CGFloat)height
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                      didSelectTarget:(id)didSelectTarget
                                      didSelectAction:(SEL)didSelectAction
                                        accessoryType:(UIStaticTableViewCellAccessoryType)accessoryType
                                 accessoryValueObject:(NSObject *)accessoryValueObject
                                      accessoryTarget:(id)accessoryTarget
                                      accessoryAction:(SEL)accessoryAction {
  UIStaticTableViewCellData *data = [[UIStaticTableViewCellData alloc] init];
  data.identifier = identifier;
  data.cellClass = cellClass;
  data.style = style;
  data.height = height;
  data.image = image;
  data.text = text;
  data.detailText = detailText;
  data.didSelectTarget = didSelectTarget;
  data.didSelectAction = didSelectAction;
  data.accessoryType = accessoryType;
  data.accessoryValueObject = accessoryValueObject;
  data.accessoryTarget = accessoryTarget;
  data.accessoryAction = accessoryAction;
  return data;
}

- (instancetype)init {
  if (self = [super init]) {
    self.cellClass = [SSUITableCell class];
    self.height = TableViewCellNormalHeight;
  }
  return self;
}

- (void)setCellClass:(Class)cellClass {
  NSAssert([cellClass isSubclassOfClass:[SSUITableCell class]], @"%@.cellClass 必须为 SSUITableCell 的子类", NSStringFromClass(self.class));
  _cellClass = cellClass;
}

+ (UITableViewCellAccessoryType)tableViewCellAccessoryTypeWithStaticAccessoryType:(UIStaticTableViewCellAccessoryType)type {
  switch (type) {
    case UIStaticTableViewCellAccessoryTypeDisclosureIndicator:
      return UITableViewCellAccessoryDisclosureIndicator;
    case UIStaticTableViewCellAccessoryTypeDetailDisclosureButton:
      return UITableViewCellAccessoryDetailDisclosureButton;
    case UIStaticTableViewCellAccessoryTypeCheckmark:
      return UITableViewCellAccessoryCheckmark;
    case UIStaticTableViewCellAccessoryTypeDoneButton:
    case UIStaticTableViewCellAccessoryTypeDetailButton:
      return UITableViewCellAccessoryDetailButton;
    case UIStaticTableViewCellAccessoryTypeSwitch:
    default:
      return UITableViewCellAccessoryNone;
  }
}

@end
