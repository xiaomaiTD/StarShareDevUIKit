//
//  SSWebSecurityPolicy.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/16.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSWebSecurityPolicy.h"
#import <AssertMacros.h>

#if !TARGET_OS_IOS && !TARGET_OS_WATCH && !TARGET_OS_TV
static NSData * SecKeyGetData(SecKeyRef key) {
  CFDataRef data = NULL;
  
  __Require_noErr_Quiet(SecItemExport(key, kSecFormatUnknown, kSecItemPemArmour, NULL, &data), _out);
  
  return (__bridge_transfer NSData *)data;
  
_out:
  if (data) {
    CFRelease(data);
  }
  
  return nil;
}
#endif

static BOOL SecKeyIsEqualToKey(SecKeyRef key1, SecKeyRef key2) {
#if TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV
  return [(__bridge id)key1 isEqual:(__bridge id)key2];
#else
  return [SecKeyGetData(key1) isEqual:SecKeyGetData(key2)];
#endif
}

static id PublicKeyForCertificate(NSData *certificate) {
  id allowedPublicKey = nil;
  SecCertificateRef allowedCertificate;
  SecCertificateRef allowedCertificates[1];
  CFArrayRef tempCertificates = nil;
  SecPolicyRef policy = nil;
  SecTrustRef allowedTrust = nil;
  SecTrustResultType result;
  
  allowedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificate);
  __Require_Quiet(allowedCertificate != NULL, _out);
  
  allowedCertificates[0] = allowedCertificate;
  tempCertificates = CFArrayCreate(NULL, (const void **)allowedCertificates, 1, NULL);
  
  policy = SecPolicyCreateBasicX509();
  __Require_noErr_Quiet(SecTrustCreateWithCertificates(tempCertificates, policy, &allowedTrust), _out);
  __Require_noErr_Quiet(SecTrustEvaluate(allowedTrust, &result), _out);
  
  allowedPublicKey = (__bridge_transfer id)SecTrustCopyPublicKey(allowedTrust);
  
_out:
  if (allowedTrust) {
    CFRelease(allowedTrust);
  }
  
  if (policy) {
    CFRelease(policy);
  }
  
  if (tempCertificates) {
    CFRelease(tempCertificates);
  }
  
  if (allowedCertificate) {
    CFRelease(allowedCertificate);
  }
  
  return allowedPublicKey;
}

static BOOL ServerTrustIsValid(SecTrustRef serverTrust) {
  BOOL isValid = NO;
  SecTrustResultType result;
  __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
  
  isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
  
_out:
  return isValid;
}

static NSArray * CertificateTrustChainForServerTrust(SecTrustRef serverTrust) {
  CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
  NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
  
  for (CFIndex i = 0; i < certificateCount; i++) {
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
    [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
  }
  
  return [NSArray arrayWithArray:trustChain];
}

static NSArray * PublicKeyTrustChainForServerTrust(SecTrustRef serverTrust) {
  SecPolicyRef policy = SecPolicyCreateBasicX509();
  CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
  NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
  for (CFIndex i = 0; i < certificateCount; i++) {
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
    
    SecCertificateRef someCertificates[] = {certificate};
    CFArrayRef certificates = CFArrayCreate(NULL, (const void **)someCertificates, 1, NULL);
    
    SecTrustRef trust;
    __Require_noErr_Quiet(SecTrustCreateWithCertificates(certificates, policy, &trust), _out);
    
    SecTrustResultType result;
    __Require_noErr_Quiet(SecTrustEvaluate(trust, &result), _out);
    
    [trustChain addObject:(__bridge_transfer id)SecTrustCopyPublicKey(trust)];
    
  _out:
    if (trust) {
      CFRelease(trust);
    }
    
    if (certificates) {
      CFRelease(certificates);
    }
    
    continue;
  }
  CFRelease(policy);
  
  return [NSArray arrayWithArray:trustChain];
}

#pragma mark -

@interface SSWebSecurityPolicy()
@property (readwrite, nonatomic, assign) WEBSSLPinningMode SSLPinningMode;
@property (readwrite, nonatomic, strong) NSSet *pinnedPublicKeys;
@end

@implementation SSWebSecurityPolicy

+ (NSSet *)certificatesInBundle:(NSBundle *)bundle {
  NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
  
  NSMutableSet *certificates = [NSMutableSet setWithCapacity:[paths count]];
  for (NSString *path in paths) {
    NSData *certificateData = [NSData dataWithContentsOfFile:path];
    [certificates addObject:certificateData];
  }
  
  return [NSSet setWithSet:certificates];
}

+ (NSSet *)defaultPinnedCertificates {
  static NSSet *_defaultPinnedCertificates = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    _defaultPinnedCertificates = [self certificatesInBundle:bundle];
  });
  
  return _defaultPinnedCertificates;
}

+ (instancetype)defaultPolicy {
  SSWebSecurityPolicy *securityPolicy = [[self alloc] init];
  securityPolicy.SSLPinningMode = WEBSSLPinningModeNone;
  
  return securityPolicy;
}

+ (instancetype)policyWithPinningMode:(WEBSSLPinningMode)pinningMode {
  return [self policyWithPinningMode:pinningMode withPinnedCertificates:[self defaultPinnedCertificates]];
}

+ (instancetype)policyWithPinningMode:(WEBSSLPinningMode)pinningMode withPinnedCertificates:(NSSet *)pinnedCertificates {
  SSWebSecurityPolicy *securityPolicy = [[self alloc] init];
  securityPolicy.SSLPinningMode = pinningMode;
  
  [securityPolicy setPinnedCertificates:pinnedCertificates];
  
  return securityPolicy;
}

- (instancetype)init {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  self.validatesDomainName = YES;
  
  return self;
}

- (void)setPinnedCertificates:(NSSet *)pinnedCertificates {
  _pinnedCertificates = pinnedCertificates;
  
  if (self.pinnedCertificates) {
    NSMutableSet *mutablePinnedPublicKeys = [NSMutableSet setWithCapacity:[self.pinnedCertificates count]];
    for (NSData *certificate in self.pinnedCertificates) {
      id publicKey = PublicKeyForCertificate(certificate);
      if (!publicKey) {
        continue;
      }
      [mutablePinnedPublicKeys addObject:publicKey];
    }
    self.pinnedPublicKeys = [NSSet setWithSet:mutablePinnedPublicKeys];
  } else {
    self.pinnedPublicKeys = nil;
  }
}

#pragma mark -

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain
{
  if (domain && self.allowInvalidCertificates && self.validatesDomainName && (self.SSLPinningMode == WEBSSLPinningModeNone || [self.pinnedCertificates count] == 0)) {
    // https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/OverridingSSLChainValidationCorrectly.html
    //  According to the docs, you should only trust your provided certs for evaluation.
    //  Pinned certificates are added to the trust. Without pinned certificates,
    //  there is nothing to evaluate against.
    //
    //  From Apple Docs:
    //          "Do not implicitly trust self-signed certificates as anchors (kSecTrustOptionImplicitAnchors).
    //           Instead, add your own (self-signed) CA certificate to the list of trusted anchors."
    NSLog(@"In order to validate a domain name for self signed certificates, you MUST use pinning.");
    return NO;
  }
  
  NSMutableArray *policies = [NSMutableArray array];
  if (self.validatesDomainName) {
    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
  } else {
    [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
  }
  
  SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
  
  if (self.SSLPinningMode == WEBSSLPinningModeNone) {
    return self.allowInvalidCertificates || ServerTrustIsValid(serverTrust);
  } else if (!ServerTrustIsValid(serverTrust) && !self.allowInvalidCertificates) {
    return NO;
  }
  
  switch (self.SSLPinningMode) {
    case WEBSSLPinningModeNone:
    default:
      return NO;
    case WEBSSLPinningModeCertificate: {
      NSMutableArray *pinnedCertificates = [NSMutableArray array];
      for (NSData *certificateData in self.pinnedCertificates) {
        [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
      }
      SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);
      
      if (!ServerTrustIsValid(serverTrust)) {
        return NO;
      }
      
      // obtain the chain AXter being validated, which *should* contain the pinned certificate in the last position (if it's the Root CA)
      NSArray *serverCertificates = CertificateTrustChainForServerTrust(serverTrust);
      
      for (NSData *trustChainCertificate in [serverCertificates reverseObjectEnumerator]) {
        if ([self.pinnedCertificates containsObject:trustChainCertificate]) {
          return YES;
        }
      }
      
      return NO;
    }
    case WEBSSLPinningModePublicKey: {
      NSUInteger trustedPublicKeyCount = 0;
      NSArray *publicKeys = PublicKeyTrustChainForServerTrust(serverTrust);
      
      for (id trustChainPublicKey in publicKeys) {
        for (id pinnedPublicKey in self.pinnedPublicKeys) {
          if (SecKeyIsEqualToKey((__bridge SecKeyRef)trustChainPublicKey, (__bridge SecKeyRef)pinnedPublicKey)) {
            trustedPublicKeyCount += 1;
          }
        }
      }
      return trustedPublicKeyCount > 0;
    }
  }
  
  return NO;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAXfectingPinnedPublicKeys {
  return [NSSet setWithObject:@"pinnedCertificates"];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
  
  self = [self init];
  if (!self) {
    return nil;
  }
  
  self.SSLPinningMode = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(SSLPinningMode))] unsignedIntegerValue];
  self.allowInvalidCertificates = [decoder decodeBoolForKey:NSStringFromSelector(@selector(allowInvalidCertificates))];
  self.validatesDomainName = [decoder decodeBoolForKey:NSStringFromSelector(@selector(validatesDomainName))];
  self.pinnedCertificates = [decoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(pinnedCertificates))];
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.SSLPinningMode] forKey:NSStringFromSelector(@selector(SSLPinningMode))];
  [coder encodeBool:self.allowInvalidCertificates forKey:NSStringFromSelector(@selector(allowInvalidCertificates))];
  [coder encodeBool:self.validatesDomainName forKey:NSStringFromSelector(@selector(validatesDomainName))];
  [coder encodeObject:self.pinnedCertificates forKey:NSStringFromSelector(@selector(pinnedCertificates))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
  SSWebSecurityPolicy *securityPolicy = [[[self class] allocWithZone:zone] init];
  securityPolicy.SSLPinningMode = self.SSLPinningMode;
  securityPolicy.allowInvalidCertificates = self.allowInvalidCertificates;
  securityPolicy.validatesDomainName = self.validatesDomainName;
  securityPolicy.pinnedCertificates = [self.pinnedCertificates copyWithZone:zone];
  
  return securityPolicy;
}

@end
