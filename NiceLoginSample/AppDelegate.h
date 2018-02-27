//
//  AppDelegate.h
//  NiceLoginSample
//
//  Created by 박영석 on 2018. 1. 10..
//  Copyright © 2018년 myname. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong) NSMutableArray *imgdata;
@property NSUInteger ableImageCount;
@property NSUInteger maxImageCount;
@property NSString* pageUrl;
@property NSString* zipCode;
@property NSString* address;
@end

