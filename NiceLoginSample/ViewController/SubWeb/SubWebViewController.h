//
//  SubWebViewController.h
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 2. 18..
//  Copyright © 2018년 myname. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubWebViewController : UIViewController<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *subwebview;

@end
