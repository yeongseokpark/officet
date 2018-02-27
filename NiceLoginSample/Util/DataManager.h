//
//  DataManager.h
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 2. 23..
//  Copyright © 2018년 myname. All rights reserved.
//

@interface DataManager : NSObject

@property (nonatomic, strong) NSString *lgnId;             // 로그인 아이디
@property (nonatomic, strong) NSString *lgnHash;           // 로그인 해시값
@property (nonatomic, strong) NSString *lgnPwd;            // 로그인 패스워드
@property (nonatomic, strong) NSString *pageUrl;            // TargetUrl
@property (nonatomic, strong) NSString *zipCodeUrl;         // 우편번호Url
@property (nonatomic, strong) NSString *param;            // 파라미터
@property (nonatomic, strong) NSString *domain;            // 도메인
@property (nonatomic, strong) NSString *loginMsg;            // apim 응답 메세지

+ (DataManager *)sharedManager;

-(void) setLoginId:(NSString *)value;
-(void) setLoginHash:(NSString *)value;
-(NSString*) getLoginId;
-(NSString*) getLoginHash;
-(void) setLoginPwd:(NSString *)value;
-(NSString*) getLoginPwd;
-(void) setPageUrl:(NSString *)value;
-(NSString*) getPageUrl;
-(void) setParam:(NSString *)value;
-(NSString*) getParam;
-(void) setDomain:(NSString *)value;
-(NSString*) getDomain;
-(void) setZipCodeUrl:(NSString *)url;
-(NSString*)getZipCodeUrl;
-(void) setLoginMsg:(NSString *)value;
-(NSString*) getLoginMsg;
@end
