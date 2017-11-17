//
//  SSUIWebViewController.m
//  StarShareDevUIKit
//
//  Created by BUBUKO on 2017/11/16.
//  Copyright © 2017年 jearoc. All rights reserved.
//

#import "SSUIWebViewController.h"
#import <objc/runtime.h>
#import <StoreKit/StoreKit.h>
#import "SSUIAlertController.h"
#import "UINavigationButton.h"
#import "UICore.h"

@interface SSUIWebViewController ()
{
  BOOL _loading;
  NSString *_HTMLString;
  NSURL *_baseURL;
  WKWebViewConfiguration *_configuration;
  SSUIWebViewDidReceiveAuthenticationChallengeHandler _challengeHandler;
  SSWebSecurityPolicy *_securityPolicy;
  NSURLRequest *_request;
}
@property(strong, nonatomic) UILabel *backgroundLabel;
@end

@interface _SSWebContainerView: UIView { dispatch_block_t _hitBlock; } @end
@interface _SSWebContainerView (HitTests)
@property(copy, nonatomic) dispatch_block_t hitBlock;
@end
@implementation _SSWebContainerView
- (dispatch_block_t)hitBlock { return _hitBlock; }
- (void)setHitBlock:(dispatch_block_t)hitBlock { _hitBlock = [hitBlock copy]; }
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  return [super hitTest:point withEvent:event];
}
@end

static NSString *const kSS404NotFoundURLKey = @"404_NOT_FOUND";
static NSString *const kSSNetworkErrorURLKey = @"NETWORK_ERROR";

@interface SSUIWebViewController ()

@property(strong, nonatomic) WKNavigation *navigation;
@property(strong, nonatomic) UIProgressView *progressView;
@property(strong, nonatomic) _SSWebContainerView *containerView;
@end

@implementation SSUIWebViewController

- (instancetype)initWithURLString:(NSString *)urlString {
  return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (instancetype)initWithURL:(NSURL*)URL {
  if(self = [self init]) {
    _URL = URL;
  }
  return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
  if (self = [self init]) {
    _request = request;
  }
  return self;
}

- (instancetype)initWithURL:(NSURL *)URL configuration:(WKWebViewConfiguration *)configuration {
  if (self = [self initWithURL:URL]) {
    _configuration = configuration;
  }
  return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request configuration:(WKWebViewConfiguration *)configuration {
  if (self = [self initWithRequest:request]) {
    _request = request;
    _configuration = configuration;
  }
  return self;
}

- (instancetype)initWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL {
  if (self = [self init]) {
    _HTMLString = HTMLString;
    _baseURL = baseURL;
  }
  return self;
}

- (void)didInitialized
{
  [super didInitialized];
  
  _showsBackgroundLabel = YES;
  _enableCookie = YES;
  _timeoutInternal = 30.0;
  _cachePolicy = NSURLRequestReloadRevalidatingCacheData;
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated
{
  [super setNavigationItemsIsInEditMode:isInEditMode animated:YES];
  UIBarButtonItem *back = [UINavigationButton barButtonItemWithImage:NavBarBackIndicatorImage
                                                            position:UINavigationButtonPositionLeft
                                                              target:self
                                                              action:@selector(goBack)];
  self.navigationItem.leftBarButtonItems = @[back];
}

- (void)initSubviews
{
  [super initSubviews];
  
  _containerView = [[_SSWebContainerView alloc] init];
  _containerView.backgroundColor = UIColorClear;
  _containerView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_containerView];
  
  _backgroundLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  _backgroundLabel.textColor = [UIColor colorWithRed:0.180 green:0.192 blue:0.196 alpha:1.00];
  _backgroundLabel.font = [UIFont systemFontOfSize:12];
  _backgroundLabel.numberOfLines = 0;
  _backgroundLabel.textAlignment = NSTextAlignmentCenter;
  _backgroundLabel.backgroundColor = [UIColor clearColor];
  _backgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _backgroundLabel.hidden = !self.showsBackgroundLabel;
  
  WKWebViewConfiguration *config = _configuration;
  if (!config) {
    config = [[WKWebViewConfiguration alloc] init];
    config.preferences.minimumFontSize = 9.0;
    if ([config respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
      [config setAllowsInlineMediaPlayback:YES];
    }
    if (@available(iOS 9.0, *)) {
      if ([config respondsToSelector:@selector(setApplicationNameForUserAgent:)]) {
        [config setApplicationNameForUserAgent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
      }
    }
    
    if (@available(iOS 10.0, *)) {
      if ([config respondsToSelector:@selector(setMediaTypesRequiringUserActionForPlayback:)]){
        [config setMediaTypesRequiringUserActionForPlayback:WKAudiovisualMediaTypeNone];
      }
    } else if (@available(iOS 9.0, *)) {
      if ( [config respondsToSelector:@selector(setRequiresUserActionForMediaPlayback:)]) {
        [config setRequiresUserActionForMediaPlayback:NO];
      }
    } else {
      BeginIgnoreDeprecatedWarning
      if ( [config respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
        [config setMediaPlaybackRequiresUserAction:NO];
      }
      EndIgnoreDeprecatedWarning
    }
  }
  _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
  _webView.allowsBackForwardNavigationGestures = NO;
  _webView.backgroundColor = [UIColor clearColor];
  _webView.scrollView.backgroundColor = [UIColor clearColor];
  _webView.translatesAutoresizingMaskIntoConstraints = NO;
  if (_enabledWebViewUIDelegate) _webView.UIDelegate = self;
  _webView.navigationDelegate = self;
  [_webView addObserver:self forKeyPath:@"scrollView.contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
  [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
  [self.containerView addSubview:self.webView];
}

- (void)dealloc
{
  [_webView stopLoading];
  [self.class clearWebCacheCompletion:^{
    ///< Clear cache!
  }];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  _webView.UIDelegate = nil;
  _webView.navigationDelegate = nil;
  [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
  [_webView removeObserver:self forKeyPath:@"scrollView.contentOffset"];
  [_webView removeObserver:self forKeyPath:@"title"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
  if ([keyPath isEqualToString:@"estimatedProgress"]) {
    
  } else if ([keyPath isEqualToString:@"scrollView.contentOffset"]) {
    
  } else if ([keyPath isEqualToString:@"title"]) {
    NSString *title = self.titleView.title;
    title = title.length>0 ? title: [_webView title];
    self.titleView.title = title;
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (void)needLayoutSubviews
{
  [super needLayoutSubviews];
  
  self.containerView.frame = self.view.bounds;
  self.webView.frame = self.containerView.bounds;
  self.backgroundLabel.top = self.navigationBarMaxYInViewCoordinator+20;
  self.backgroundLabel.left = 20;
  self.backgroundLabel.width = self.containerView.width - 40;
  self.backgroundLabel.height = self.containerView.height - self.backgroundLabel.top - 20;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (_request) {
    [self loadURLRequest:_request];
  } else if (_URL) {
    [self loadURL:_URL];
  } else if (_baseURL && _HTMLString) {
    [self loadHTMLString:_HTMLString baseURL:_baseURL];
  } else {
    [self loadURL:[NSURL fileURLWithPath:@"404"]];
  }
  [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Public

- (void)loadURL:(NSURL *)URL {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
  request.timeoutInterval = _timeoutInternal;
  request.cachePolicy = _cachePolicy;
  if (_enableCookie) {
    NSMutableArray * cookies = @[].mutableCopy;
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
      NSString * cookieValue = [NSString stringWithFormat:@"%@=%@",cookie.name,cookie.value];
      [cookies addObject:cookieValue];
    }
    NSString *cookieString = [cookies componentsJoinedByString:@";"];
    [request addValue:cookieString forHTTPHeaderField:@"Cookie"];
  } else {
    [request addValue:@"" forHTTPHeaderField:@"Cookie"];
  }
  _navigation = [_webView loadRequest:request];
}

- (void)loadURLRequest:(NSURLRequest *)request {
  NSMutableURLRequest *__request = [request mutableCopy];
  _navigation = [_webView loadRequest:__request];
}

- (void)loadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL {
  _baseURL = baseURL;
  _HTMLString = HTMLString;
  _navigation = [_webView loadHTMLString:HTMLString baseURL:baseURL];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma  mark - some action

- (void)willGoBack{
  if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillGoBack:)]) {
    [_delegate webViewControllerWillGoBack:self];
  }
}

- (void)willGoForward{
  if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillGoForward:)]) {
    [_delegate webViewControllerWillGoForward:self];
  }
}

- (void)willReload{
  if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillReload:)]) {
    [_delegate webViewControllerWillReload:self];
  }
}

- (void)willStop{
  if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerWillStop:)]) {
    [_delegate webViewControllerWillStop:self];
  }
}

- (void)didStartLoad{
  self.navigationItem.title = @"加载中...";
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerDidStartLoad:)]) {
    [_delegate webViewControllerDidStartLoad:self];
  }
  _loading = YES;
}

- (void)didStartLoadWithNavigation:(WKNavigation *)navigation {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [self didStartLoad];
#pragma clang diagnostic pop
}

- (void)didFinishLoad {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
  if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)]) {
    [_delegate webViewControllerDidFinishLoad:self];
  }
  _loading = NO;
  
  NSString *title = self.titleView.title;
  title = title.length>0 ? title: [_webView title];
  self.titleView.title = title?:@"内容浏览";
}

- (void)didFailLoadWithError:(NSError *)error{
  if (error.code == NSURLErrorCannotFindHost) {// 404
    //[self loadURL:[NSURL fileURLWithPath:kAX404NotFoundHTMLPath]];
  } else {
    //[self loadURL:[NSURL fileURLWithPath:kAXNetworkErrorHTMLPath]];
  }
  self.titleView.title = @"加载失败...";
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  if (_delegate && [_delegate respondsToSelector:@selector(webViewController:didFailLoadWithError:)]) {
    [_delegate webViewController:self didFailLoadWithError:error];
  }
}

#pragma mark - Actions

- (void)goBack {
  [self willGoBack];
  if ([_webView canGoBack]) {
    _navigation = [_webView goBack];
  }else{
    if (self.isPresented) {
      [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
      }];
    }else{
      [self.navigationController popViewControllerAnimated:YES];
    }
  }
}

- (void)goForward {
  [self willGoForward];
  if ([_webView canGoForward]) {
    _navigation = [_webView goForward];
  }
}

- (void)reload {
  [self willReload];
  _navigation = [_webView reload];
}

- (void)stop {
  [self willStop];
  [_webView stopLoading];
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
  WKFrameInfo *frameInfo = navigationAction.targetFrame;
  if (![frameInfo isMainFrame]) {
    if (navigationAction.request) {
      [webView loadRequest:navigationAction.request];
    }
  }
  return nil;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (void)webViewDidClose:(WKWebView *)webView {
}
#endif

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
  
  NSString *host = webView.URL.host;
  
  SSUIAlertController *alert = [[SSUIAlertController alloc] initWithTitle:host?:@"来自网页的消息"
                                                                  message:message
                                                           preferredStyle:SSUIAlertControllerStyleAlert];
  SSUIAlertAction *action1 = [SSUIAlertAction actionWithTitle:@"取消"
                                                        style:SSUIAlertActionStyleCancel
                                                      handler:^(SSUIAlertAction *action) {
                                                        if (completionHandler != NULL) {
                                                          completionHandler();
                                                        }
  }];
  SSUIAlertAction *action2 = [SSUIAlertAction actionWithTitle:@"确认"
                                                        style:SSUIAlertActionStyleDefault
                                                      handler:^(SSUIAlertAction *action) {
                                                        if (completionHandler != NULL) {
                                                          completionHandler();
                                                        }
  }];
  [alert addAction:action1];
  [alert addAction:action2];
  [alert showWithAnimated:YES];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
  
  NSString *host = webView.URL.host;
  
  SSUIAlertController *alert = [[SSUIAlertController alloc] initWithTitle:host?:@"来自网页的消息"
                                                                  message:message
                                                           preferredStyle:SSUIAlertControllerStyleAlert];
  SSUIAlertAction *action1 = [SSUIAlertAction actionWithTitle:@"取消"
                                                        style:SSUIAlertActionStyleCancel
                                                      handler:^(SSUIAlertAction *action) {
                                                        if (completionHandler != NULL) {
                                                          completionHandler(NO);
                                                        }
                                                      }];
  SSUIAlertAction *action2 = [SSUIAlertAction actionWithTitle:@"确认"
                                                        style:SSUIAlertActionStyleDefault
                                                      handler:^(SSUIAlertAction *action) {
                                                        if (completionHandler != NULL) {
                                                          completionHandler(YES);
                                                        }
                                                      }];
  [alert addAction:action1];
  [alert addAction:action2];
  [alert showWithAnimated:YES];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
  
  NSString *host = webView.URL.host;
  
  SSUIAlertController *alert = [[SSUIAlertController alloc] initWithTitle:prompt?:@"来自网页的消息"
                                                                  message:host
                                                           preferredStyle:SSUIAlertControllerStyleAlert];
  [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    textField.placeholder = defaultText ? defaultText : @"";
    textField.font = [UIFont systemFontOfSize:12];
  }];
  SSUIAlertAction *action1 = [SSUIAlertAction actionWithTitle:@"取消"
                                                        style:SSUIAlertActionStyleCancel
                                                      handler:^(SSUIAlertAction *action) {
                                                        NSString *string = ((UITextField *)[alert.textFields firstObject]).text;
                                                        if (completionHandler != NULL) {
                                                          completionHandler(string?:defaultText);
                                                        }
                                                      }];
  SSUIAlertAction *action2 = [SSUIAlertAction actionWithTitle:@"确认"
                                                        style:SSUIAlertActionStyleDefault
                                                      handler:^(SSUIAlertAction *action) {
                                                        NSString *string = ((UITextField *)[alert.textFields firstObject]).text;
                                                        if (completionHandler != NULL) {
                                                          completionHandler(string?:defaultText);
                                                        }
                                                      }];
  [alert addAction:action1];
  [alert addAction:action2];
  [alert showWithAnimated:YES];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  
  // Disable all the '_blank' target in page's target.
  if (!navigationAction.targetFrame.isMainFrame) {
    [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
  }
  
  NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
  if (![[NSPredicate predicateWithFormat:@"SELF MATCHES[cd] 'https' OR SELF MATCHES[cd] 'http' OR SELF MATCHES[cd] 'file' OR SELF MATCHES[cd] 'about'"] evaluateWithObject:components.scheme]) {
    
    if (@available(iOS 8.0, *)) {
      if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
        if (@available(iOS 10.0, *)) {
          [UIApplication.sharedApplication openURL:components.URL options:@{} completionHandler:NULL];
        }else{
          [[UIApplication sharedApplication] openURL:components.URL];
        }
      }
    }
    
    decisionHandler(WKNavigationActionPolicyCancel);
    return;
  }
  
  decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
  NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
  NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
  for (NSHTTPCookie *cookie in cookies) {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
  }
  decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
  [self didStartLoadWithNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
  [self didFinishLoad];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
  if (error.code == NSURLErrorCancelled) {
    return;
  }
  [self didFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
  if (error.code == NSURLErrorCancelled) {
    return;
  }
  [self didFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
  
  NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
  __block NSURLCredential *credential = nil;
  
  if (self.challengeHandler) {
    disposition = self.challengeHandler(webView, challenge, &credential);
  } else {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
      if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        if (credential) {
          disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
          disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
      } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
      }
    } else {
      disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
  }
  
  if (completionHandler) {
    completionHandler(disposition, credential);
  }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
  NSString *host = webView.URL.host;
  
  SSUIAlertController *alert = [[SSUIAlertController alloc] initWithTitle:host?:@"来自网页的消息"
                                                                  message:@"网页进程终止"
                                                           preferredStyle:SSUIAlertControllerStyleAlert];
  SSUIAlertAction *action1 = [SSUIAlertAction actionWithTitle:@"取消"
                                                        style:SSUIAlertActionStyleCancel
                                                      handler:^(SSUIAlertAction *action) {
                                                      }];
  SSUIAlertAction *action2 = [SSUIAlertAction actionWithTitle:@"确认"
                                                        style:SSUIAlertActionStyleDefault
                                                      handler:^(SSUIAlertAction *action) {
                                                      }];
  [alert addAction:action1];
  [alert addAction:action2];
  [alert showWithAnimated:YES];
}
#endif

#pragma mark - Setter

- (void)setEnabledWebViewUIDelegate:(BOOL)enabledWebViewUIDelegate {
  _enabledWebViewUIDelegate = enabledWebViewUIDelegate;
  if (_enabledWebViewUIDelegate) {
    _webView.UIDelegate = self;
  } else {
    _webView.UIDelegate = nil;
  }
}

- (void)setEnableCookie:(BOOL)enableCookie
{
  _enableCookie = enableCookie;
  NSMutableURLRequest *request = [_request mutableCopy];
  if (_enableCookie) {
    NSMutableArray * cookies = @[].mutableCopy;
    for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
      NSString * cookieValue = [NSString stringWithFormat:@"%@=%@",cookie.name,cookie.value];
      [cookies addObject:cookieValue];
    }
    NSString *cookieString = [cookies componentsJoinedByString:@";"];
    [request addValue:cookieString forHTTPHeaderField:@"Cookie"];
  } else {
    [request addValue:@"" forHTTPHeaderField:@"Cookie"];
  }
  _navigation = [_webView loadRequest:request];
  _request = [request copy];
}

- (void)setTimeoutInternal:(NSTimeInterval)timeoutInternal {
  _timeoutInternal = timeoutInternal;
  NSMutableURLRequest *request = [_request mutableCopy];
  request.timeoutInterval = _timeoutInternal;
  _navigation = [_webView loadRequest:request];
  _request = [request copy];
}

- (void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy {
  _cachePolicy = cachePolicy;
  NSMutableURLRequest *request = [_request mutableCopy];
  request.cachePolicy = _cachePolicy;
  _navigation = [_webView loadRequest:request];
  _request = [request copy];
}

- (void)setShowsBackgroundLabel:(BOOL)showsBackgroundLabel{
  _backgroundLabel.hidden = !showsBackgroundLabel;
  _showsBackgroundLabel = showsBackgroundLabel;
}

@end

@implementation SSUIWebViewController (WebCache)

+ (void)clearWebCacheCompletion:(dispatch_block_t)completion {
  if (@available(iOS 9.0, *)) {
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:completion];
  } else {
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
    NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
    
    NSError *error;
    /* iOS8.0 WebView Cache path */
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
    
    /* iOS7.0 WebView Cache path */
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
    if (completion) {
      completion();
    }
  }
}
@end

@implementation SSUIWebViewController (Security)
- (SSUIWebViewDidReceiveAuthenticationChallengeHandler)challengeHandler {
  return _challengeHandler;
}

- (SSWebSecurityPolicy *)securityPolicy {
  return _securityPolicy;
}

- (void)setChallengeHandler:(SSUIWebViewDidReceiveAuthenticationChallengeHandler)challengeHandler {
  _challengeHandler = [challengeHandler copy];
}

- (void)setSecurityPolicy:(SSWebSecurityPolicy *)securityPolicy {
  _securityPolicy = securityPolicy;
}
@end
