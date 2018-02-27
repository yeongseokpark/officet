//
//  MsgPopupViewController.m
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 2. 21..
//  Copyright © 2018년 myname. All rights reserved.
//

#import "MsgPopupViewController.h"
#import "DataManager.h"
@interface MsgPopupViewController ()

@end

@implementation MsgPopupViewController
@synthesize labelMsg;

- (void)viewDidLoad {
    [super viewDidLoad];
    labelMsg.text = [DataManager sharedManager].getLoginMsg;
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

- (IBAction)btnClose2:(id)sender {
    [[self view]removeFromSuperview];
}
@end
