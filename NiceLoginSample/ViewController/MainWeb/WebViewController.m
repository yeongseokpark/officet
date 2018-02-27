//
//  ViewController.m
//  WebViewManager
//
//  Created by  111 on 2018. 1. 8..
//  Copyright © 2018년 111. All rights reserved.
//

#import "WebViewController.h"
#import "SettingManager.h"
#import "AppDelegate.h"
#import "PopupViewController.h"
#import "DataManager.h"
#import "TaskManager.h"
@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webview,activityIndicator;

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [activityIndicator startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [activityIndicator stopAnimating];
}
-(void)callWebview:(NSString*)str{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //[mainWebview stringByEvaluatingJavaScriptFromString:str];
    [app.imgdata addObject:str];
    
}



-(void)handleRefresh:(UIRefreshControl *)refresh {
    [webview reload];
    [refresh endRefreshing];
}
   
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [webview.scrollView addSubview:refreshControl];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // NS Log...
   
    NSString *url = app.pageUrl;
    NSString *body = [NSString stringWithFormat:@"data=%@",[[DataManager sharedManager]getParam]];
    NSLog(@"body:%@",body);
    
    // WebView Loading...
    //NSURL *url = [NSURL URLWithString:[SettingManager sharedManager].mainDomain];
   // NSURLRequest *request = [NSURLRequest requestWithURL:url];
    webview.delegate = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
  
    [self.webview loadRequest:request];
    //[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] timeoutInterval:5.0];
}


// All Catch Webview http protocol
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    // 요청한 URL 값을 가져온다.
    NSString *requestStr = [[request URL] absoluteString];
    NSLog(@"req:%@",requestStr);
    // web 에서 app 호출 시 특정 url로 판단하고 이벤트 실행함
    if ([[[request URL] absoluteString] hasPrefix:@"appcustomscheme:"]) {
        
        NSString *requestString = [[request URL] absoluteString];
        NSArray *components = [requestString componentsSeparatedByString:@":?:"];
        NSArray *functionStrArr = [[components objectAtIndex:1] componentsSeparatedByString:@":::"];
        
        // 함수 이름 가져오기
        NSString *functionName = [functionStrArr objectAtIndex:0];
        // 함수 구분
        if([functionName isEqualToString:@"callCamera"]){
            
            
            // 함수로 전달할 인자 가져오기
            NSString *functionParam = [functionStrArr objectAtIndex:1];
            NSString *functionParam2 = [functionStrArr objectAtIndex:2];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.ableImageCount =[functionParam intValue];
            app.maxImageCount = [functionParam2 intValue];
            
            NSLog(@"able%@",functionParam);
            NSLog(@"max%@",functionParam2);
            [self performSelector:@selector(callObjectiveCFromJavascript)];
        }
        
        else if([functionName isEqualToString:@"sendLogout"]){
             [[SettingManager sharedManager] setIsAutoLogin:@"false"];
            [[SettingManager sharedManager] setStateLogout:@"true"];
            [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        }
        
        else if([functionName isEqualToString:@"phoneCall"]){
            NSString *num = [functionStrArr objectAtIndex:1];
            NSString* tel = @"telprompt://";
            tel = [tel stringByAppendingString:num];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:tel]];
        }
        else if([functionName isEqualToString:@"callZipcode"]){
            NSString *url = [functionStrArr objectAtIndex:1];
            NSString *target = [[[DataManager sharedManager]getDomain] stringByAppendingString:url];
              [[DataManager sharedManager]setZipCodeUrl:target];
              [self performSegueWithIdentifier:@"segueSubWeb" sender:nil];
        }
        return NO;

    } else{
        return YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"네트워크 오류"
                                  message:@"페이지 로드 실패!!"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                            exit(0);
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    

}

-(void) viewDidAppear:(BOOL)animated{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // [self.mainWebview stringByEvaluatingJavaScriptFromString:@"callTest()"];
    NSString *script = [NSString stringWithFormat:@"receiveZipcode('%@','%@')",[app.zipCode stringByRemovingPercentEncoding],[app.address stringByRemovingPercentEncoding]];
    [webview stringByEvaluatingJavaScriptFromString:script];

    for (int i=0;i<app.imgdata.count;i++){
        
        [webview stringByEvaluatingJavaScriptFromString:app.imgdata[i]];
    }
}
- (void)callObjectiveCFromJavascript {
    
    
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //
    //    UIViewController *view = [storyboard instantiateViewControllerWithIdentifier:@"ImageVC"];
    //
    //    [self presentViewController:view animated:TRUE completion:nil];
    
    
    PopupViewController *vc = [[PopupViewController alloc]initWithNibName:nil bundle:nil];
    [vc view].backgroundColor = [UIColor clearColor];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    
    
    
}
-(void) loadLoginViewController{
    [self performSegueWithIdentifier:@"segueLogin" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
