//
//  ViewController.h
//  WebViewManager
//
//  Created by  111 on 2018. 1. 8..
//  Copyright © 2018년 111. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>
{
    UIWebView *webview;
}

@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (strong, nonatomic) NSString *loginId;
@property (strong, nonatomic) NSString *loginPwd;
@property (strong, nonatomic) NSString *autoLogin;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
-(void)callObjectiveCFromJavascript;
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
-(void)callWebview:(NSString*)str;

/** 현재 메인페이지 컨트롤러 */
/*- (IBAction)LoginMove:(id)sender;*/

@end

