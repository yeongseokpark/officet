//
//  CallPopupViewController.m
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 2. 20..
//  Copyright © 2018년 myname. All rights reserved.
//

#import "CallPopupViewController.h"

@interface CallPopupViewController ()

@end

@implementation CallPopupViewController
@synthesize bodyview,btnOutletCall,btnOutletClose;

- (void)viewDidLoad {
    [super viewDidLoad];
    bodyview.layer.borderWidth = 1.0;
    bodyview.layer.borderColor = [UIColor blackColor].CGColor;
    
    btnOutletCall.layer.borderWidth = 1.0;
    btnOutletCall.layer.borderColor = [UIColor blackColor].CGColor;
    
    btnOutletClose.layer.borderWidth = 1.0;
    btnOutletClose.layer.borderColor = [UIColor blackColor].CGColor;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnClose:(id)sender {
       [[self view]removeFromSuperview];
}
- (IBAction)btnHotline:(id)sender {
    NSString *num = @"02.2124.6948";
    NSString* tel = @"telprompt://";
    tel = [tel stringByAppendingString:num];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:tel]];
    
}
@end
