//
//  SSWebSecurityPolicy.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/16.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WEBSSLPinningMode) {
  WEBSSLPinningModeNone,
  WEBSSLPinningModePublicKey,
  WEBSSLPinningModeCertificate,
};

@interface SSWebSecurityPolicy : NSObject<NSSecureCoding, NSCopying>

@property (readonly, nonatomic, assign) WEBSSLPinningMode SSLPinningMode;
@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;
@property (nonatomic, assign) BOOL allowInvalidCertificates;
@property (nonatomic, assign) BOOL validatesDomainName;

+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;
+ (instancetype)defaultPolicy;
+ (instancetype)policyWithPinningMode:(WEBSSLPinningMode)pinningMode;
+ (instancetype)policyWithPinningMode:(WEBSSLPinningMode)pinningMode withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(nullable NSString *)domain;
@end

NS_ASSUME_NONNULL_END
