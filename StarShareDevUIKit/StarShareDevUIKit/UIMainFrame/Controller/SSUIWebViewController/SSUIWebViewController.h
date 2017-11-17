//
//  SSUIWebViewController.h
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/16.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "SSUIViewController.h"
#import "SSWebSecurityPolicy.h"

NS_ASSUME_NONNULL_BEGIN
@class SSUIWebViewController;

@protocol SSUIWebViewControllerDelegate <NSObject>
@optional
- (void)webViewControllerWillGoBack:(SSUIWebViewController *)webViewController;
- (void)webViewControllerWillGoForward:(SSUIWebViewController *)webViewController;
- (void)webViewControllerWillReload:(SSUIWebViewController *)webViewController;
- (void)webViewControllerWillStop:(SSUIWebViewController *)webViewController;
- (void)webViewControllerDidStartLoad:(SSUIWebViewController *)webViewController;
- (void)webViewControllerDidFinishLoad:(SSUIWebViewController *)webViewController;
- (void)webViewController:(SSUIWebViewController *)webViewController didFailLoadWithError:(NSError *)error;
@end

typedef NSURLSessionAuthChallengeDisposition (^SSUIWebViewDidReceiveAuthenticationChallengeHandler)(WKWebView *webView, NSURLAuthenticationChallenge *challenge, NSURLCredential * _Nullable __autoreleasing * _Nullable credential);

@interface SSUIWebViewController : SSUIViewController<WKUIDelegate, WKNavigationDelegate>
{
@protected
  WKWebView *_webView;
  NSURL *_URL;
}

@property(assign, nonatomic) id<SSUIWebViewControllerDelegate>delegate;
@property(readonly, nonatomic) WKWebView *webView;
@property(assign, nonatomic) BOOL enabledWebViewUIDelegate;/// Default is NO.
@property(assign, nonatomic) BOOL enableCookie;/// Default is YES.
@property(assign, nonatomic) NSTimeInterval timeoutInternal;
@property(assign, nonatomic) NSURLRequestCachePolicy cachePolicy;
@property(readonly, nonatomic) NSURL *URL;
@property(assign, nonatomic) BOOL showsBackgroundLabel;/// Default is YES.

- (instancetype)initWithURLString:(NSString*)urlString;
- (instancetype)initWithURL:(NSURL*)URL;
- (instancetype)initWithRequest:(NSURLRequest *)request;
- (instancetype)initWithURL:(NSURL *)URL configuration:(WKWebViewConfiguration *)configuration;
- (instancetype)initWithRequest:(NSURLRequest *)request configuration:(WKWebViewConfiguration *)configuration;
- (instancetype)initWithHTMLString:(NSString*)HTMLString baseURL:(NSURL*)baseURL;
- (void)loadURL:(NSURL*)URL;
- (void)loadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL;
@end

@interface SSUIWebViewController (WebCache)

+ (void)clearWebCacheCompletion:(dispatch_block_t _Nullable)completion;
@end

@interface SSUIWebViewController (Security)

@property(copy, nonatomic, nullable) SSUIWebViewDidReceiveAuthenticationChallengeHandler challengeHandler;
@property(readwrite, nonatomic, nullable) SSWebSecurityPolicy *securityPolicy;
@end

NS_ASSUME_NONNULL_END
