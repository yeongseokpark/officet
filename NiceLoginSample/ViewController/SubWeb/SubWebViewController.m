//
//  SubWebViewController.m
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 2. 18..
//  Copyright © 2018년 myname. All rights reserved.
//

#import "SubWebViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"
@interface SubWebViewController ()

@end

@implementation SubWebViewController
@synthesize subwebview;

- (void)viewDidLoad {
    [super viewDidLoad];
   // NSString *url = @"https://muat.nicetcb.co.kr/cm/CM0100M002GP.nice";
    NSString *url = [DataManager sharedManager].getZipCodeUrl;
    subwebview.delegate = self;
    [subwebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)subwebview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
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
        if([functionName isEqualToString:@"sendZipcode"]){
            
            
            // 함수로 전달할 인자 가져오기
            NSString *zipcode = [functionStrArr objectAtIndex:1];
            NSString *addrStr = [functionStrArr objectAtIndex:2];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.zipCode = zipcode;
            app.address = addrStr;
            [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        }
        else if([functionName isEqualToString:@"closeView"]){
            [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        }
        return NO;
        

        
    }
    
    else{
        return YES;
    }
}

@end
