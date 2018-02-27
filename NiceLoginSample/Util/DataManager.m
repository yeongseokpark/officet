//
//  DataManager.m
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 2. 23..
//  Copyright © 2018년 myname. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DataManager.h"

@implementation DataManager
@synthesize lgnId,lgnHash,lgnPwd,pageUrl,param,domain,zipCodeUrl,loginMsg;
- (id)init
{
    self = [super init];
    if (self) {
      
    }
    
    return self;
}

#pragma mark - Singleton
+ (DataManager *)sharedManager {
    static DataManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [DataManager new];
    });
    return _instance;
}

-(void) setLoginId:(NSString *)value{
    lgnId = value;
}

-(void) setLoginHash:(NSString *)value{
    lgnHash = value;
}

-(NSString*) getLoginId{
    return lgnId;
}

-(NSString*) getLoginHash{
    return lgnHash;
}
-(void) setLoginPwd:(NSString *)value{
    lgnPwd = value;
}
-(NSString*) getLoginPwd{
    return lgnPwd;
}
-(void) setPageUrl:(NSString *)value{
    pageUrl = value;
}
-(NSString*) getPageUrl{
    return pageUrl;
}
-(void) setParam:(NSString *)value{
    param = value;
}
-(NSString*) getParam{
    return param;
}
-(void) setDomain:(NSString *)value{
    domain = value;
}
-(NSString*) getDomain{
    return domain;
}
-(void) setZipCodeUrl:(NSString *)url{
    zipCodeUrl = url;
}
-(NSString*)getZipCodeUrl{
    return zipCodeUrl;
}
-(void) setLoginMsg:(NSString *)value{
    loginMsg = value;
}
-(NSString*) getLoginMsg{
    return loginMsg;
}
@end
