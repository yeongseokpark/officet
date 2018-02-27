//
//  SettingManager.h
//

#import <Foundation/Foundation.h>

/**
 설정 매니저
 */
@interface SettingManager : NSObject

@property (nonatomic, strong) NSString *protocalDomain;             // 프로토콜 도메인
@property (nonatomic, strong) NSString *mainDomain;                 // 메인 도메인
@property (nonatomic, strong) NSString *stateLogout;                // 로그아웃 상태
@property (nonatomic, strong) NSString *loginId;                    // 로그인 아이디
@property (nonatomic, strong) NSString *loginPwd;                   // 로그인 비번
@property (nonatomic, strong) NSString *uuid;                       // uuid

@property (nonatomic, strong) NSString *preRegistedPhone;           // 사전 사용자 전번
@property (nonatomic, strong) NSString* isAutoLogin;                             // 자동 로그인
@property (nonatomic, strong) NSString* isPreRegisted;                           // 사전 등록 여부
@property (nonatomic, strong) NSString* isSaveId;                                // 아이디 저장
@property (nonatomic, strong) NSUserDefaults *defaults;
+ (SettingManager *)sharedManager;

- (void)printAll;
-(NSString*)getLoginId;
-(NSString*)getLoginPwd;
- (void)setKeychainPwd:(NSString*)value;
- (NSString *)getKeychainPwd;
@end

