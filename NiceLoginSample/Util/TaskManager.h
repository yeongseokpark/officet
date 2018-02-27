//
//  SettingManager.h
//

#import <Foundation/Foundation.h>

/**
 설정 매니저
 */
@interface TaskManager : NSObject
+ (TaskManager *)sharedManager;
-(void)requestAPIM:(NSString *)param;
-(NSString*)getUriEncode:(NSString *)value;
-(NSString *)getUriDecoding:(NSString *)value;
-(NSString*)getSha256:(NSString *)clear;
-(NSString *)getUUID;
-(NSString*)getToday;
-(NSString*)getHashPwd:(NSString*)tcbid pwd:(NSString*)tcbpwd;
-(NSString*)getParameter:(Boolean)preAddState lgnId:(NSString*)lgnid lgnPwd:(NSString*)lgnpwd lgnUuid:(NSString*)lgnuuid lgnTel:(NSString*)lgntel;
-(NSMutableURLRequest*)getUrlRequest:(NSString*)param;
-(void)saveCheckState:(Boolean)autoLoginState idSaveState:(Boolean)idSaveState;
-(NSString*)getJson:(NSString*)lgncode jsondata:(NSDictionary*)json;
-(NSString*)getDomain:(NSString*)url;
@end



