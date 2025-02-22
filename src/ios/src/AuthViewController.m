/**
 * Copyright (c) 2017, Oracle and/or its affiliates.
 * The Universal Permissive License (UPL), Version 1.0
 */
#import "AuthViewController.h"
#import <WebKit/WebKit.h>

@interface AuthViewController ()
@property (weak, nonatomic) OMMobileSecurityService* ommssInstance;
@property (nonatomic) BOOL isLogin;
@property (strong, nonatomic) WKProcessPool *processPool;
@property (nonatomic) BOOL wkWebViewEnabled;
@end

#ifdef DEBUG
#   define IdmLog(...) NSLog(__VA_ARGS__)
#else
#   define IdmLog(...)
#endif

@implementation AuthViewController

- (IBAction)cancel:(id)sender {
  IdmLog(@"Cancel invoked.");
  [self dismissViewControllerAnimated:YES completion:nil];
  if (self.isLogin) {
    [self.ommssInstance cancelAuthentication];
  }
}

- (void) setAuthenticationInstance: (OMMobileSecurityService*) ommss {
  self.ommssInstance = ommss;
}

- (void) setIsLoginChallenge:(BOOL) isLoginChallenge {
  self.isLogin = isLoginChallenge;
}

- (void) isWkWebViewEnabled: (BOOL) enabled {
  self.wkWebViewEnabled = enabled;
}

- (void) viewDidLoad {
  [super viewDidLoad];

  if (!self.isLogin) {
    [self.cancelButton setEnabled:NO];
  }

  if (self.wkWebViewEnabled && self.wkWebView == nil) {
    [self createWKWebview];
  }
}

- (WKProcessPool*) sharedProcessPool
{
  if (self.processPool == nil) {
    // Loading shared process pool from wkwebview plugin, if it exists.
    Class processPoolFactory = NSClassFromString(@"CDVWKProcessPoolFactory");
    if (processPoolFactory != nil) {
      #pragma clang diagnostic push
      #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      self.processPool =  [[processPoolFactory performSelector:NSSelectorFromString(@"sharedFactory")]
                            performSelector:NSSelectorFromString(@"sharedPool")];
      #pragma clang diagnostic pop
    } else {
      self.processPool = [[WKProcessPool alloc] init];
    }
  }

  return self.processPool;
}

- (void)createWKWebview
{
  WKWebViewConfiguration *webconfig = [[WKWebViewConfiguration alloc] init];
  webconfig.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
  webconfig.processPool = [self sharedProcessPool];

  self.wkWebView = [[WKWebView alloc] initWithFrame:self.authWebView.frame
                                      configuration:webconfig];
  self.wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.authWebView removeFromSuperview];
  [[self view] addSubview: self.wkWebView];
}

@end
