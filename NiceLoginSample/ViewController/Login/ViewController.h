//
//  ViewController.h
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 1. 10..
//  Copyright © 2018년 myname. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"
#import "MASConstraintMaker.h"
@protocol BEMCheckBoxDelegate;
@interface ViewController : UIViewController  <UIWebViewDelegate> {
    BEMCheckBox *autoLoginCheckBox;
    BEMCheckBox *idSaveCheckBox;
    BEMCheckBox *preAddCheckBox;
  
}
@property BOOL preAddState;      //사전 등록 체크 상태
@property BOOL autoLoginState;
@property BOOL idSaveState;
@property BOOL layoutState;
@property BOOL autoLoginAction;   // 자동 로그인 실행 확인
@property NSString *deviceType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* logImgTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* preAddLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* autoLoginLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* logImgBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* logImgLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* logImgRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *preAddLabel;
@property (weak, nonatomic) IBOutlet UILabel *autoLoginLabel;
@property (weak, nonatomic) IBOutlet UILabel *idSaveLabel;

@property (weak, nonatomic) IBOutlet UITextField *sampleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* sampleLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (nonatomic, strong) MASConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIButton *loginOutlet;
@property (nonatomic, retain) IBOutlet UITextField *txtLoginId;
@property (nonatomic, retain) IBOutlet UITextField *txtLoginPwd;
@property (nonatomic, retain) IBOutlet UITextField *txtPreRegistedPhone;
- (IBAction)DelegateLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *activityImage;
@property (weak, nonatomic) IBOutlet UILabel *txtHotline;
-(void) initDeviceLayout;
-(void)preAddCheck;
-(void)autoLoginCheck;
-(NSString*)getHashValue;
-(void)requestLogin:(NSString *)param;
-(void)makeParameter:(NSString *)tcbid pwd:(NSString*)tcbpwd uuid:(NSString*) tcbuuid num:(NSString*) tcbnum;
@end

