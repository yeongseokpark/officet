//
//  ViewController.m
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 1. 10..
//  Copyright © 2018년 myname. All rights reserved.
//

#import "TaskManager.h"
#import "DataManager.h"
#import "KeychainItemWrapper.h"
#import "CallPopupViewController.h"
#import "MsgPopupViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "BEMCheckBox.h"
#import "NSLayoutConstraint+MASDebugAdditions.h"
#import "MASConstraintMaker.h"
#import "MASConstraint.h"
#import "NSLayoutConstraint+MASDebugAdditions.h"
#import "NSArray+MASAdditions.h"
#import "SettingManager.h"
#import <CommonCrypto/CommonHMAC.h>
#import <AFNetworking.h>
#import <UIView+Toast.h>
@interface ViewController ()


@end

@implementation ViewController
@synthesize
preAddState,passwordLabel,loginOutlet,logImgTopConstraint,preAddLeftConstraint,autoLoginLeftConstraint,txtLoginId,txtLoginPwd,txtPreRegistedPhone,logImgBottomConstraint,logImgLeftConstraint,logImgRightConstraint,preAddLabel,layoutState,deviceType,autoLoginState,autoLoginLabel,idSaveLabel,activityImage,txtHotline,autoLoginAction,idSaveState;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.idSaveState = false;
    self.preAddState = false;
    self.autoLoginState = false;
    self.layoutState = false;
    
    [self initDeviceLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    UITapGestureRecognizer *hotlineTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotlineTapDetected)];
    hotlineTap.numberOfTapsRequired = 1;
    [txtHotline setUserInteractionEnabled:YES];
    [txtHotline addGestureRecognizer:hotlineTap];
    
    if(![[SettingManager sharedManager].isAutoLogin length]){
        autoLoginCheckBox.on = YES;
        self.autoLoginState = true;
    }
    else if([[SettingManager sharedManager].isAutoLogin isEqualToString:@"true"]){
        [self executeAutoLogin];
    }
    if(![[SettingManager sharedManager].isSaveId length]){
        self.idSaveState = true;
        idSaveCheckBox.on = YES;
    }
    else if([[SettingManager sharedManager].isSaveId isEqualToString:@"true"])
    { idSaveCheckBox.on = YES;
        self.idSaveState = true;
        txtLoginId.text = [SettingManager sharedManager].getLoginId;
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    if( [[SettingManager sharedManager].stateLogout isEqualToString:@"true"]){
        [[SettingManager sharedManager] setIsAutoLogin:@"false"];
        [[SettingManager sharedManager] setIsSaveId:@"false"];
        txtLoginId.text=@"";
        txtLoginPwd.text=@"";
        txtPreRegistedPhone.text=@"";
        [self hideTextField];
        preAddState = false;
        idSaveCheckBox.on = NO;
        autoLoginCheckBox.on = NO;
        preAddCheckBox.on = NO;
        [[SettingManager sharedManager] setStateLogout:@"false"];
    }
}
/**
 배경화면 터치
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
}
/**
 사전 등록 클릭 이벤트 처리
 */
- (void)preAddCheck{
    
    if(self.preAddState==true){
        [self hideTextField];
        preAddCheckBox.on = NO;
        self.preAddState = false;
        self.txtPreRegistedPhone.text = @"";
    }
    else{
        [self showTextField];
        self.preAddState = true;
        preAddCheckBox.on = YES;
    }
}

/**
 아이디저장 클릭 이벤트 처리
 */
- (void)idSaveCheck{
    
    if(self.idSaveState==true){
        idSaveCheckBox.on = NO;
        self.idSaveState = false;
    }
    else{
        self.idSaveState = true;
        idSaveCheckBox.on = YES;
    }
}

/**
 자동로그인 클릭 이벤트 처리
 */

- (void)autoLoginCheck{
    if(self.autoLoginState==true){
        autoLoginCheckBox.on = NO;
        self.autoLoginState = false;
    }
    else{
        autoLoginCheckBox.on = YES;
        self.autoLoginState = true;
    }
}

/**
 체크 박스 이벤트 처리
 */

- (void)didTapCheckBox:(BEMCheckBox*)checkBox{
    if(checkBox == preAddCheckBox){
        [self preAddCheck];
    }
    else if(checkBox == autoLoginCheckBox){
        [self autoLoginCheck];
    }
    else if(checkBox == idSaveCheckBox){
        [self idSaveCheck];
    }
    
}

/**
 휴대폰 번호 입력창 보이기
 */

- (void)showTextField {
    
    if(self.preAddState==false){
        self.sampleLabelHeightConstraint.constant = 50;
    }
}

/**
 휴대폰 번호 입력창 숨기기
 */

- (void)hideTextField {
    
    if(self.preAddState==true){
        self.sampleLabelHeightConstraint.constant = 0;
    }
}


/**
 사전 등록 텍스트 클릭
 */
-(void)preAddTapDetected{
    
    [self preAddCheck];
}
/**
 자동 로그인 텍스트 클릭
 */
-(void)autoLoginTapDetected{
    
    [self autoLoginCheck];
}
/**
 아이디 저장 텍스트 클릭
 */
-(void)idSaveTapDetected{
    
    [self idSaveCheck];
}

/**
 디바이스별 오토레이아웃 설정
 */

-(void) initDeviceLayout{
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    int deviceWidth =(int)screenRect.size.width;
    int deviceHeight = (int)screenRect.size.height;
    UIView *superview = self.view;
    
    // 아이폰5
    if(deviceWidth ==320){
        logImgTopConstraint.constant = 80;
        preAddLeftConstraint.constant = 70;
        autoLoginLeftConstraint.constant = 80;
        logImgBottomConstraint.constant = 60;
        logImgLeftConstraint.constant = 90;
        logImgRightConstraint.constant = 90;
        
    }
    
    // 아이폰6 Plue
    else if(deviceWidth ==414){
        logImgTopConstraint.constant = 150;
        preAddLeftConstraint.constant = 120;
        autoLoginLeftConstraint.constant = 130;
        logImgBottomConstraint.constant = 65;
        logImgLeftConstraint.constant = 130;
        logImgRightConstraint.constant = 130;
    }
    
    // 아이폰X
    else if(deviceHeight ==812){
        logImgTopConstraint.constant = 150;
        preAddLeftConstraint.constant = 99;
        autoLoginLeftConstraint.constant = 113;
        logImgBottomConstraint.constant = 80;
    }
    
    // 아이폰6
    else if(deviceWidth ==375){
        logImgTopConstraint.constant = 120;
        preAddLeftConstraint.constant = 110;
        autoLoginLeftConstraint.constant = 120;
        logImgBottomConstraint.constant = 60;
    }
    
    // 자동로그인 체크 박스 생성
    autoLoginCheckBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [autoLoginCheckBox setLineWidth:0.5];
    [autoLoginCheckBox setBoxType:BEMBoxTypeSquare];
    [autoLoginCheckBox setTintColor:[UIColor whiteColor]];
    [autoLoginCheckBox setOnFillColor:[UIColor whiteColor]];
    [autoLoginCheckBox setOnCheckColor:[UIColor blackColor]];
    [autoLoginCheckBox setOnTintColor:[UIColor whiteColor]];
    [autoLoginCheckBox setOnAnimationType:BEMAnimationTypeFill];
    [autoLoginCheckBox setOffAnimationType:BEMAnimationTypeFill];
    autoLoginCheckBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:autoLoginCheckBox];
    autoLoginCheckBox.delegate = self;
    // 아이디저장 체크 박스 생성
    idSaveCheckBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [idSaveCheckBox setLineWidth:0.5];
    [idSaveCheckBox setBoxType:BEMBoxTypeSquare];
    [idSaveCheckBox setTintColor:[UIColor whiteColor]];
    [idSaveCheckBox setOnFillColor:[UIColor whiteColor]];
    [idSaveCheckBox setOnCheckColor:[UIColor blackColor]];
    [idSaveCheckBox setOnTintColor:[UIColor whiteColor]];
    [idSaveCheckBox setOnAnimationType:BEMAnimationTypeFill];
    [idSaveCheckBox setOffAnimationType:BEMAnimationTypeFill];
    idSaveCheckBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:idSaveCheckBox];
    idSaveCheckBox.delegate = self;
    // 사전 등록 체크 박스 생성
    preAddCheckBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [preAddCheckBox setLineWidth:0.5];
    [preAddCheckBox setBoxType:BEMBoxTypeSquare];
    [preAddCheckBox setTintColor:[UIColor whiteColor]];
    [preAddCheckBox setOnFillColor:[UIColor whiteColor]];
    [preAddCheckBox setOnCheckColor:[UIColor blackColor]];
    [preAddCheckBox setOnTintColor:[UIColor whiteColor]];
    [preAddCheckBox setOnAnimationType:BEMAnimationTypeFill];
    [preAddCheckBox setOffAnimationType:BEMAnimationTypeFill];
    preAddCheckBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:preAddCheckBox];
    preAddCheckBox.delegate = self;
    
    // 체크 박스 오토레이아웃 설정 top,left,right,bottom
    UIEdgeInsets autoLoginPadding;
    UIEdgeInsets idSavePadding;
    UIEdgeInsets preAddPadding;
    
    if(deviceWidth == 320){
        autoLoginPadding = UIEdgeInsetsMake(63, 60, 375, 0);
        idSavePadding = UIEdgeInsetsMake(63, 167, 375, 0);
        preAddPadding = UIEdgeInsetsMake(32, 50, 375, 0);
    }
    else if(deviceHeight == 812){
        autoLoginPadding = UIEdgeInsetsMake(63, 94, 375, 0);
        idSavePadding = UIEdgeInsetsMake(63, 200, 375, 0);
        preAddPadding = UIEdgeInsetsMake(31, 80, 375, 0);
    }
    else if(deviceWidth == 414){
        autoLoginPadding = UIEdgeInsetsMake(63, 109, 375, 0);
        idSavePadding = UIEdgeInsetsMake(63, 216, 375, 0);
        preAddPadding = UIEdgeInsetsMake(31, 100, 375, 0);
    }
    else{
        autoLoginPadding = UIEdgeInsetsMake(64, 98, 375, 0);
        idSavePadding = UIEdgeInsetsMake(64, 197, 375, 0);
        preAddPadding = UIEdgeInsetsMake(33, 89, 375, 0);
    }
    
    [superview addConstraints:@[
                                //autoLogin constraints
                                [NSLayoutConstraint constraintWithItem:autoLoginCheckBox
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:loginOutlet
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:autoLoginPadding.top],
                                
                                [NSLayoutConstraint constraintWithItem:autoLoginCheckBox
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:autoLoginPadding.left],
                                
                                ]];
    
    [superview addConstraints:@[
                                //idSave constraints
                                [NSLayoutConstraint constraintWithItem:idSaveCheckBox
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:loginOutlet
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:idSavePadding.top],
                                
                                [NSLayoutConstraint constraintWithItem:idSaveCheckBox
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:idSavePadding.left],
                                ]];
    
    [superview addConstraints:@[
                                
                                //preAdd constraints
                                [NSLayoutConstraint constraintWithItem:preAddCheckBox
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:passwordLabel
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:preAddPadding.top],
                                
                                [NSLayoutConstraint constraintWithItem:preAddCheckBox
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:preAddPadding.left],
                                ]];
    
    
    //체크 박스 텍스트 클릭 이벤트 등록
    
    UITapGestureRecognizer *preAddTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preAddTapDetected)];
    preAddTap.numberOfTapsRequired = 1;
    [preAddLabel setUserInteractionEnabled:YES];
    [preAddLabel addGestureRecognizer:preAddTap];
    
    UITapGestureRecognizer *autoLoginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoLoginTapDetected)];
    autoLoginTap.numberOfTapsRequired = 1;
    [autoLoginLabel setUserInteractionEnabled:YES];
    [autoLoginLabel addGestureRecognizer:autoLoginTap];
    
    UITapGestureRecognizer *idSaveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(idSaveTapDetected)];
    idSaveTap.numberOfTapsRequired = 1;
    [idSaveLabel setUserInteractionEnabled:YES];
    [idSaveLabel addGestureRecognizer:idSaveTap];
}


/**
 문의 전화번호 클릭
 */

-(void)hotlineTapDetected{
    NSString *num = @"02.2124.6928";
    NSString* tel = @"telprompt://";
    tel = [tel stringByAppendingString:num];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:tel]];
    
}

/**
 키보드 보이기
 */

- (void) keyboardWasShown:(NSNotification *)notification{
    
    if(self.layoutState == false && self.preAddState == true){
        
        CGRect rectView; // 이 View에 대한 위치와 크기의 사각 영역을 나타낼 CGRect 구조체
        CGRect rectKeyboard; // 키보드에 대한 위치와 크기의 사각 영역을 나타낼 CGRect 구조체
        
        // 애니메이션 효과
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // View 자체에 대한 사각 영역을 추출
        rectView = [self.view frame];
        
        // 하단에서 떠오른 키보드의 사각 영역 추출
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&rectKeyboard];
        
        // View를 전체적으로 키보드 높이만큼 위로 올림
        if([deviceType isEqualToString:@"iphone5"]){
            logImgTopConstraint.constant -= 80;
        }
        
        else if([deviceType isEqualToString:@"iphone6p"]){
            logImgTopConstraint.constant -= 30;
        }
        
        else if([deviceType isEqualToString:@"iphoneX"]){
            logImgTopConstraint.constant -= 30;
        }
        
        else if([deviceType isEqualToString:@"iphone6"]){
            logImgTopConstraint.constant -= 30;
        }
        
        else{
            logImgTopConstraint.constant -= 30;
        }
        
        // View의 변경된 사각 영역을 자기 자신에게 적용
        [self.view setFrame:rectView];
        
        // 변경된 사각 영역을 애니메이션을 적용하면서 보여줌
        [UIView commitAnimations];
        self.layoutState = true;
    }
}

/**
 키보드 숨기기
 */
- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    if(self.layoutState == true){
        CGRect rectView; // 이 View에 대한 위치와 크기의 사각 영역을 나타낼 CGRect 구조체
        CGRect rectKeyboard; // 키보드에 대한 위치와 크기의 사각 영역을 나타낼 CGRect 구조체
        
        // 애니메이션 효과를 지정
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // 이 View 자체에 대한 사각 영역을 추출
        rectView = [self.view frame];
        // 하단으로 잠길 키보드의 사각 영역을 추출
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&rectKeyboard];
        
        // View를 전체적으로 키보드 높이만큼 아래로 내림
        
        if([deviceType isEqualToString:@"iphone5"]){
            logImgTopConstraint.constant += 80;
        }
        
        else if([deviceType isEqualToString:@"iphone6p"]){
            logImgTopConstraint.constant += 30;
        }
        
        else if([deviceType isEqualToString:@"iphoneX"]){
            logImgTopConstraint.constant += 30;
        }
        
        else if([deviceType isEqualToString:@"iphone6"]){
            logImgTopConstraint.constant += 30;
        }
        
        else{
            logImgTopConstraint.constant += 30;
        }
        
        // View의 변경된 사각 영역을 자기 자신에게 적용합니다.
        [self.view setFrame:rectView];
        
        // 변경된 사각 영역을 애니메이션을 적용하면서 보여줍니다.
        [UIView commitAnimations];
        self.layoutState = false;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}






/**
 자동로그인 실행
 */

-(void)executeAutoLogin{
    autoLoginAction = true;
    [self.activityImage setHidden:false];
    NSString * lgnId =[SettingManager sharedManager].getLoginId;
    NSString *encodeKey = [[TaskManager sharedManager] getHashPwd:lgnId pwd:[SettingManager sharedManager].getKeychainPwd];
    [[DataManager sharedManager]setLoginId:lgnId];
    [[DataManager sharedManager]setLoginHash:encodeKey];
    NSString *param = [[TaskManager sharedManager]getParameter:false lgnId:lgnId lgnPwd:encodeKey
                                                       lgnUuid:[[TaskManager sharedManager]getUUID] lgnTel:@""];
    [self requestLogin:param];
    
}

/**
 로그인 요청
 */

-(void)requestLogin:(NSString *)param{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask * dataTask =
    [defaultSession dataTaskWithRequest:[[TaskManager sharedManager]getUrlRequest:param]
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                          [self.activityImage setHidden:true];
                          
                          if(error == nil)
                          {
                              NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                              NSData *jsondata = [text dataUsingEncoding:NSUTF8StringEncoding];
                              NSError *e;
                              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsondata options:nil error:&e];
                              NSString *lgnCode =[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"loginCode"];
                       
                              // 로그인 코드 01
                              if([lgnCode isEqualToString:@"01"]){
                                  
                                  if(!autoLoginAction){
                                      [[TaskManager sharedManager]saveCheckState:autoLoginState idSaveState:idSaveState];
                                  }
                                  NSString *pageUrl =[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"pageUrl"];
                                  [[DataManager sharedManager] setParam:[[TaskManager sharedManager] getJson:lgnCode jsondata:json]];
                                  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                  [[DataManager sharedManager] setDomain:[[TaskManager sharedManager]getDomain:pageUrl]];
                                  
                                  //검증
                                   pageUrl =@"https://muat.nicetcb.co.kr/cm/CM0100M601GE.nice";
                                  //
                                  app.pageUrl = pageUrl;
                                  [self performSegueWithIdentifier:@"segueWebView" sender:nil];
                              }
                              // 로그인 코드 04,05
                              else if([lgnCode isEqualToString:@"04"] || [lgnCode isEqualToString:@"05"]){
             
                                  NSString *pageUrl =[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"pageUrl"];
                                  [[DataManager sharedManager] setParam:[[TaskManager sharedManager] getJson:lgnCode jsondata:json]];
                                  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                  app.pageUrl =pageUrl;
                                  [self performSegueWithIdentifier:@"segueWebView" sender:nil];
                                  
                              }
                              
                              // 로그인 코드 06
                              else if([lgnCode isEqualToString:@"06"]){
                                  NSString *pageUrl =[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"pageUrl"];
                                  [[DataManager sharedManager] setParam:[[TaskManager sharedManager] getJson:lgnCode jsondata:json]];
                                  AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                  app.pageUrl =pageUrl;
                                  [self performSegueWithIdentifier:@"segueWebView" sender:nil];
                              }
                              
                              // 로그인 코드 07
                              else if([lgnCode isEqualToString:@"07"]){
                             
                                  CallPopupViewController *vc = [[CallPopupViewController alloc]initWithNibName:nil bundle:nil];
                                  [vc view].backgroundColor = [UIColor clearColor];
                                  [self addChildViewController:vc];
                                  [self.view addSubview:vc.view];
                              }
                              else if([lgnCode isEqualToString:@"02"] || [lgnCode isEqualToString:@"03"]){
                                  NSString *msg =[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"name"];
                                  [[DataManager sharedManager]setLoginMsg:msg];
                                  MsgPopupViewController *vc = [[MsgPopupViewController alloc]initWithNibName:nil bundle:nil];
                                  [vc view].backgroundColor = [UIColor clearColor];
                                  CGRect screenRect=[[UIScreen mainScreen]bounds];
                                  CGFloat deviceWidth=screenRect.size.width;
                                  CGFloat deviceHeight=screenRect.size.height;
                                  [vc.view setFrame:CGRectMake(0, 0, deviceWidth, deviceHeight)];
                    
                                  [self addChildViewController:vc];
                                  [self.view addSubview:vc.view];
                                  
                              }
                              else{
                                  
                                  [self.view makeToast:@"요청 오류"];
                              }
                          }
                      }];
    [dataTask resume];
    
}


/**
 로그인 버튼 클릭
 */
- (IBAction)DelegateLogin:(id)sender {
    autoLoginAction = false;
    [self.activityImage setHidden:false];
    NSString *encodeKey = [[TaskManager sharedManager]getHashPwd:txtLoginId.text pwd:txtLoginPwd.text];
    [[DataManager sharedManager]setLoginId:txtLoginId.text];
    [[DataManager sharedManager]setLoginPwd:txtLoginPwd.text];
    [[DataManager sharedManager]setLoginHash:encodeKey];
    NSString *param = [[TaskManager sharedManager]getParameter:preAddState lgnId:txtLoginId.text lgnPwd:encodeKey lgnUuid:[[TaskManager sharedManager]getUUID] lgnTel:txtPreRegistedPhone.text];
    
    [self requestLogin:param];
    
}

@end
