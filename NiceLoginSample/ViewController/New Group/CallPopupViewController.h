//
//  CallPopupViewController.h
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 2. 20..
//  Copyright © 2018년 myname. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallPopupViewController : UIViewController
- (IBAction)btnClose:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bodyview;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletClose;
@property (weak, nonatomic) IBOutlet UIButton *btnOutletCall;
- (IBAction)btnHotline:(id)sender;

@end
