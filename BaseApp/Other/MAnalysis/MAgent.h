//
//  MAgent.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
    REALTIME=0,
    BATCH=1,
}ReportPolicy;

@interface MAgent : NSObject<UIAlertViewDelegate>
{

}

+(MAgent*)getInstance;

+(void)checkUpdate;
+(void)startWithAppkKey:(NSString*)appKey serverURL:(NSString*)serverURL;
+(void)startWithAppkKey:(NSString *)appKey reportPolicy:(ReportPolicy)policy serverURL:(NSString *)serverURL;

+(void)postEvent:(NSString*)eventId;
+(void)postEvent:(NSString *)eventId label:(NSString*)label;
+(void)postEvent:(NSString *)eventId acc:(NSString *)acc;
+(void)postEvent:(NSString *)eventId label:(NSString *)label acc:(NSString*)acc;

+(void)startTracPage:(NSString*)pageName;
+(void)endTracPage:(NSString*)pageName;

+(BOOL)isJailbroken;
+(void)setOnLineConfig:(BOOL)isOnLineConfig;
+(void)setIsLogEnabled:(BOOL)isLogEnabled;

+(void)pushUUID;

@end
