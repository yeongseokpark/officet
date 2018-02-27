//
//  SettingManager.m
//

#import "SettingManager.h"
#import "KeychainItemWrapper.h"
#define KEY_SETTINGMANAGER_LOGINID  @"KEY_SETTINGMANAGER_LOGINID"                   // 아이디
#define KEY_SETTINGMANAGER_LOGINPWD  @"KEY_SETTINGMANAGER_LOGINPWD"                 // 비번
#define KEY_SETTINGMANAGER_UUID  @"KEY_SETTINGMANAGER_UUID"                         // 디바이스 키
#define KEY_SETTINGMANAGER_ISPREREGISTED  @"KEY_SETTINGMANAGER_ISPREREGISTED"       // 사전등록여부
#define KEY_SETTINGMANAGER_PREREGISTEDPHONE  @"KEY_SETTINGMANAGER_PREREGISTEDPHONE" // 사전등록전화번호
#define KEY_SETTINGMANAGER_ISAUTOLOGIN  @"KEY_SETTINGMANAGER_ISAUTOLOGIN"           // 자동 로그인
#define KEY_SETTINGMANAGER_ISSAVEID  @"KEY_SETTINGMANAGER_ISSAVEID"                 // 아이디저장

@implementation SettingManager
@synthesize isAutoLogin,isSaveId,isPreRegisted,stateLogout,defaults;
#pragma mark - lifecycle
- (id)init
{
    self = [super init];
    if (self) {
       defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

#pragma mark - Singleton
+ (SettingManager *)sharedManager {
    static SettingManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [SettingManager new];
    });
    return _instance;
}

#pragma mark - setter / getter

-(void) setLoginId:(NSString *)value{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"tcbId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)getLoginId{
    return [defaults objectForKey:@"tcbId"];
}
-(NSString*)getLoginPwd{
    return [defaults objectForKey:@"tcbPwd"];
}


-(void) setLoginPwd:(NSString *)value{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"tcbPwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setUuid:(NSString *)value{
    _uuid = value;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:KEY_SETTINGMANAGER_UUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setIsPreRegisted:(NSString*)value{
    isPreRegisted = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:KEY_SETTINGMANAGER_ISPREREGISTED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setPreRegistedPhone:(NSString *)value{
    _preRegistedPhone = value;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:KEY_SETTINGMANAGER_PREREGISTEDPHONE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setIsAutoLogin:(NSString*)value{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"autoLoginState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setIsSaveId:(NSString*)value{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"idSaveState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) setStateLogout:(NSString*)value{
    stateLogout = value;

}
-(NSString*)isAutoLogin{
    return [defaults objectForKey:@"autoLoginState"];
}
-(NSString*)isIdSave{
    return [defaults objectForKey:@"idSaveState"];
}
- (NSString *)getKeychainPwd {
    
    static NSString *KEYCHAIN_IDENTIFIER = @"tcbpwd";
    //NSString *KEYCHAIN_ACCESSGROUP = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NICE"];
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_IDENTIFIER accessGroup:nil];
    NSString *pwd = [keychainItem objectForKey:(id)kSecAttrAccount];
//    if(UUID == nil || UUID.length == 0) {
//        UUID = [[NSUUID UUID] UUIDString];
//        [keychainItem setObject:UUID forKey:(__bridge id)kSecAttrAccount];
//        //NSLogI(@"KEYCHAIN set UUID : %@", UUID);
//    }
    return pwd;
    
    
    
    //   NSString *UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    // return UUID;
    //  return @"3b504a0198ae3366";
}

- (void)setKeychainPwd:(NSString*)value {
    
    static NSString *KEYCHAIN_IDENTIFIER = @"tcbpwd";
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_IDENTIFIER accessGroup:nil];
    [keychainItem setObject:value forKey:(id)kSecAttrAccount];

}

#pragma mark - Methods
- (void)printAll{
    NSLog(@"==================================================");
    NSLog(@"= %@", self.class);
    NSLog(@"==================================================");
    
}

@end
