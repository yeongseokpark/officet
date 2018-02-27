//
//  HttpManager.m
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 2. 22..
//  Copyright © 2018년 myname. All rights reserved.
//
#import "TaskManager.h"
#import "KeychainItemWrapper.h"
#import <CommonCrypto/CommonHMAC.h>
#import <Foundation/Foundation.h>
#import "SettingManager.h"
#import "DataManager.h"

@implementation TaskManager

- (id)init
{
    self = [super init];
    if (self) {
       
    }
    
    return self;
}

#pragma mark - Singleton
+ (TaskManager *)sharedManager {
    static TaskManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [TaskManager new];
    });
    return _instance;
}

-(void)requestAPIM:(NSString *)param{
    
}
/**
 Uri 인코딩
 */
-(NSString*)getUriEncode:(NSString *)value{
    NSString *encodeKey = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                (CFStringRef)value,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8));
    return encodeKey;
}
/**
 Uri 디코딩
 */
-(NSString *)getUriDecoding:(NSString *)value {
    return CFBridgingRelease(
                             CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                                     kCFAllocatorDefault,
                                                                                     (__bridge CFStringRef)value,
                                                                                     CFSTR(""),
                                                                                     kCFStringEncodingUTF8)
                             );
}

/**
 Sha256 해시 만들기
 */

-(NSString*) getSha256:(NSString *)clear{
    
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest
                               length:CC_SHA256_DIGEST_LENGTH];
    
    // Convert to Base64 data
    NSData *base64Data = [out base64EncodedDataWithOptions:0];
    NSString *str =  [NSString stringWithUTF8String:[base64Data bytes]];
    return str;
}

/**
 UUID 가져오기
 */
- (NSString *)getUUID {
    
//    static NSString *KEYCHAIN_IDENTIFIER = @"UUID";
//    NSString *KEYCHAIN_ACCESSGROUP = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"KEYCHAIN_ACCESSGROUP"];
//    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_IDENTIFIER accessGroup:KEYCHAIN_ACCESSGROUP];
//    NSString *UUID = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
//    //NSLogI(@"KEYCHAIN get UUID : %@", UUID);
//    if(UUID == nil || UUID.length == 0) {
//        UUID = [[NSUUID UUID] UUIDString];
//        [keychainItem setObject:UUID forKey:(__bridge id)kSecAttrAccount];
//        //NSLogI(@"KEYCHAIN set UUID : %@", UUID);
//    }
//    return UUID;

    
    
//       NSString *UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//     return UUID;
      return @"4ecbbc3a8abc3eb1";
}

/**
 오늘 날짜 구하기
 */

-(NSString*)getToday{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *strDate = [formatter stringFromDate:[NSDate date]];
    return strDate;
}

/**
 해시 패스워드 만들기
 */

-(NSString*)getHashPwd:(NSString*)tcbid pwd:(NSString*)tcbpwd{
    NSString *temp = [self getSha256:tcbpwd];
    NSString *hashPwd = @"";
    hashPwd = [hashPwd stringByAppendingString:tcbid];
    hashPwd = [hashPwd stringByAppendingString:temp];
    hashPwd = [hashPwd stringByAppendingString:[self getToday]];
    
    NSString *unencodedString = [self getSha256:hashPwd];
    NSString *encodeKey = [self getUriEncode:unencodedString];
    return encodeKey;
}

/**
 요청 파라미터 만들기
 */
-(NSString*)getParameter:(Boolean)preAddState lgnId:(NSString*)lgnid lgnPwd:(NSString*)lgnpwd lgnUuid:(NSString*)lgnuuid lgnTel:(NSString*)lgntel{
    NSString *param = @"";
    if(preAddState == true){
        param = [[param stringByAppendingString:@"lgn_usrid="] stringByAppendingString:lgnid];
        param = [[param stringByAppendingString:@"&hashpwd="] stringByAppendingString:lgnpwd];
        param = [[param stringByAppendingString:@"&hptel="] stringByAppendingString:lgntel];
        param = [[param stringByAppendingString:@"&modevno="] stringByAppendingString:lgnuuid];
    }
    else{
        param = [[param stringByAppendingString:@"lgn_usrid="] stringByAppendingString:lgnid];
        param = [[param stringByAppendingString:@"&hashpwd="] stringByAppendingString:lgnpwd];
        param = [[param stringByAppendingString:@"&hptel="] stringByAppendingString:@""];
        param = [[param stringByAppendingString:@"&modevno="] stringByAppendingString:lgnuuid];
    }
    return param;
}


/**
 JSON 만들기
 */
-(NSString*)getJson:(NSString*)lgncode jsondata:(NSDictionary*)json {
    NSMutableDictionary* jsondata = [NSMutableDictionary new];
    if([lgncode isEqualToString:@"01"]){
        [jsondata setValue:[DataManager sharedManager].getLoginId forKey:@"lgn_usrid"];
        [jsondata setValue:[DataManager sharedManager].getLoginHash forKey:@"hashpwd"];
        [jsondata setValue:lgncode forKey:@"loginCode"];
        [jsondata setValue:[[TaskManager sharedManager]getUUID] forKey:@"modevno"];
        [jsondata setValue:[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"tcbmbrpsidtid"] forKey:@"hptel"];
        [jsondata setValue:[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"hash_val"] forKey:@"hash_val"];
        NSData* tempdata = [NSJSONSerialization dataWithJSONObject:jsondata options:NSJSONWritingPrettyPrinted error:nil];
        NSString* jsonstr = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
        jsonstr = [jsonstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return jsonstr;
    }
    
    else if([lgncode isEqualToString:@"04"]||[lgncode isEqualToString:@"05"]){
        
        [jsondata setValue:[DataManager sharedManager].getLoginId forKey:@"lgn_usrid"];
        [jsondata setValue:[DataManager sharedManager].getLoginHash forKey:@"hashpwd"];
        [jsondata setValue:[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"hash_val"] forKey:@"hash_val"];
        [jsondata setValue:lgncode forKey:@"loginCode"];
        [jsondata setValue:[[TaskManager sharedManager]getUUID] forKey:@"modevno"];
        [jsondata setValue:[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"tcb_inunm"] forKey:@"tcb_inunm"];
        [jsondata setValue:[[[json valueForKey:@"items"]valueForKey:@"item"][0] valueForKey:@"tcborgcd"] forKey:@"tcborgcd"];
        NSData* tempdata = [NSJSONSerialization dataWithJSONObject:jsondata options:NSJSONWritingPrettyPrinted error:nil];
        NSString* jsonstr = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
        jsonstr = [jsonstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return jsonstr;
    }
    return @"error";
}

/**
 요청 URl 만들기
 */
-(NSMutableURLRequest*)getUrlRequest:(NSString*)param{
    
    NSURL * url = [NSURL URLWithString:@"https://api.kisline.com/nice/sb/api/nicetcb/mobile/login"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"G0iN8pC1qW3bQ3rJ4jT4yQ2jL0jN4pJ2cU8uA4fX8nG5wB0wB8" forHTTPHeaderField:@"x-ibm-client-secret"];
    [urlRequest addValue:@"1bef1d8a-bb06-4ad6-9ec1-7e4b2f051f16" forHTTPHeaderField:@"x-ibm-client-id"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    return urlRequest;
}

/**
 자동로그인,아이디저장 상태 저장
 */

-(void)saveCheckState:(Boolean)autoLoginState idSaveState:(Boolean)idSaveState{
    if(autoLoginState){
        [[SettingManager sharedManager] setIsAutoLogin:@"true"];
        [[SettingManager sharedManager] setLoginId:[DataManager sharedManager].getLoginId];
        [[SettingManager sharedManager] setKeychainPwd:[DataManager sharedManager].getLoginPwd];
    }
    else if(idSaveState){
        [[SettingManager sharedManager] setIsSaveId:@"true"];
        [[SettingManager sharedManager] setLoginId:[DataManager sharedManager].getLoginId];
    }
}

/**
 도메인 가져오기
 */

-(NSString*)getDomain:(NSString*)url{
    
    NSArray *arrString= [url componentsSeparatedByString: @"/"];
    NSString *string1 = [arrString objectAtIndex:0];
    NSString *string2 = [arrString objectAtIndex:1];
    NSString *string3 = [arrString objectAtIndex:2];
    NSString *result = @"";
    result = [result stringByAppendingString:string1];
    result = [[result stringByAppendingString:@"/"] stringByAppendingString:string2];
    result = [[result stringByAppendingString:@"/"] stringByAppendingString:string3];
    return result;
}

/**
 오늘 날짜 구하기
 */

//
//-(NSString*)getHashValue{
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    
//    NSString *strDate = [formatter stringFromDate:[NSDate date]];
//    NSLog(@"date%@", strDate);
//    
//    NSString *hash = @"";
//    
//    hash = [hash stringByAppendingString:txtLoginId.text];
//    hash = [hash stringByAppendingString:txtLoginPwd.text];
//    hash = [hash stringByAppendingString:@"uuid"];
//    hash = [hash stringByAppendingString:strDate];
//    return [[TaskManager sharedManager] getSha256:hash];
//}


@end

