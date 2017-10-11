//
//  UIStaticTableViewCellData.h
//  StarShareDevUIKit
//
//  Created by jearoc on 2017/10/10.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SSUITableCell;

typedef NS_ENUM(NSInteger,UIStaticTableViewCellAccessoryType) {
  UIStaticTableViewCellAccessoryTypeNone,                     ///<  默认类型
  UIStaticTableViewCellAccessoryTypeDisclosureIndicator,      ///<  箭头类型
  UIStaticTableViewCellAccessoryTypeDetailDisclosureButton,   ///<  按钮带箭头类型
  UIStaticTableViewCellAccessoryTypeCheckmark,                ///<  选项类型
  UIStaticTableViewCellAccessoryTypeDetailButton,             ///<  按钮类型
  UIStaticTableViewCellAccessoryTypeDoneButton,               ///<  完成按钮类型
  UIStaticTableViewCellAccessoryTypeSwitch,                   ///<  开关类型
};

/**
 *  一个 cellData 对象用于存储 static tableView（例如设置界面那种列表） 列表里的一行 cell 的基本信息，包括这个 cell 的 class、text、detailText、accessoryView 等。
 *  @see UIStaticTableViewCellDataSource
 */
@interface UIStaticTableViewCellData : NSObject

/// 当前 cellData 的标志，一般同个 tableView 里的每个 cellData 都会拥有不相同的 identifier
@property(nonatomic, assign) NSInteger identifier;

/// 当前 cellData 所对应的 indexPath
@property(nonatomic, strong, readonly) NSIndexPath *indexPath;

/// cell 要使用的 class，默认为 SSUITableCell，若要改为自定义 class，必须是 SSUITableCell 的子类
@property(nonatomic, assign) Class cellClass;

/// init cell 时要使用的 style
@property(nonatomic, assign) UITableViewCellStyle style;

/// cell 的高度，默认为 TableViewCellNormalHeight
@property(nonatomic, assign) CGFloat height;

/// cell 左边要显示的图片，将会被设置到 cell.imageView.image
@property(nonatomic, strong) UIImage *image;

/// cell 的文字，将会被设置到 cell.textLabel.text
@property(nonatomic, copy) NSString *text;

/// cell 的详细文字，将会被设置到 cell.detailTextLabel.text，所以要求 cellData.style 的值必须是带 detailTextLabel 类型的 style
@property(nonatomic, copy) NSString *detailText;

/// 当 cell 的点击事件被触发时，要由哪个对象来接收
@property(nonatomic, assign) id didSelectTarget;

/// 当 cell 的点击事件被触发时，要向 didSelectTarget 指针发送什么消息以响应事件
/// @warning 这个 selector 接收一个参数，这个参数也即当前的 UIStaticTableViewCellData 对象
@property(nonatomic, assign) SEL didSelectAction;

/// cell 右边的 accessoryView 的类型
@property(nonatomic, assign) UIStaticTableViewCellAccessoryType accessoryType;

/// 配合 accessoryType 使用，不同的 accessoryType 需要配合不同 class 的 accessoryValueObject 使用。例如 UIStaticTableViewCellAccessoryTypeSwitch 要求传 @YES 或 @NO 用于控制 UISwitch.on 属性。
/// @warning 目前也仅支持与 UIStaticTableViewCellAccessoryTypeSwitch 搭配使用。
@property(nonatomic, strong) NSObject *accessoryValueObject;

/// 扩展数据，绑定一些用户自己的自定义数据
@property(nonatomic, strong) id extendObject;

/// 当 accessoryType 是某些带 UIControl 的控件时，可通过这两个属性来为 accessoryView 添加操作事件。
/// 目前支持的类型包括：UIStaticTableViewCellAccessoryTypeDetailDisclosureButton、UIStaticTableViewCellAccessoryTypeDetailButton、UIStaticTableViewCellAccessoryTypeSwitch
/// @warning 这个 selector 接收一个参数，与 didSelectAction 一样，这个参数一般情况下也是当前的 UIStaticTableViewCellData 对象，仅在 Switch 时会传 UISwitch 控件的实例
@property(nonatomic, assign) id accessoryTarget;
@property(nonatomic, assign) SEL accessoryAction;



+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                      didSelectTarget:(id)didSelectTarget
                                      didSelectAction:(SEL)didSelectAction
                                        accessoryType:(UIStaticTableViewCellAccessoryType)accessoryType;

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
                                      accessoryAction:(SEL)accessoryAction;

+ (UITableViewCellAccessoryType)tableViewCellAccessoryTypeWithStaticAccessoryType:(UIStaticTableViewCellAccessoryType)type;

@end
