//
//  MAgentRequest.h
//  BaseApp
//
//  Created by xujun wu on 12-11-20.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCommonReturn.h"
#import "MEvent.h"
#import "MErrorLog.h"
#import "MClientData.h"
#import "MCheckUpdateReturn.h"
#import "MConfigPreference.h"

@interface MAgentRequest : NSObject


+(MCheckUpdateReturn*)checkUpdate:(NSString*)appKey version:(NSString*)versionCode;


+(MCommonReturn*)postClient:(NSString*)appKey deviceInfo:(MClientData*)deviceInfo;
+(MCommonReturn *) postUsingTime:(NSString *) appKey sessionMills:(NSString *)sessionMills startMils:(NSString*)startMils endMils:(NSString*)endMils duration:(NSString*)duration activity:(NSString *) activity version:(NSString *) version;

+(MCommonReturn *) postArchiveLogs:(NSMutableDictionary *) archiveLogs;

+(MCommonReturn *) postErrorLog:(NSString *) appKey errorLog:(MErrorLog *) errorLog;


+(MCommonReturn*)postEvent:(NSString*)appKey event:(MEvent*)mEvent;

+(MConfigPreference*)getOnlineConfig:(NSString*)appKey;

+(MCommonReturn*)postUUID:(NSString*)appKey uuid:(NSString*)uuid;


@end
