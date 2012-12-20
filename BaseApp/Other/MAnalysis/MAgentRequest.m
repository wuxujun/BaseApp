//
//  MAgentRequest.m
//  BaseApp
//
//  Created by xujun wu on 12-11-20.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MAgentRequest.h"
#import "SBJson.h"
#import "MGlobal.h"

@implementation MAgentRequest

+(NSString*)sendData:(NSString*)URLString data:(NSMutableDictionary*)content
{
    @autoreleasepool {
        NSURL *url = [NSURL URLWithString:URLString];
        NSError *error=nil;
        NSData *djson=[NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];
        NSString *params=[[NSString alloc]initWithData:djson encoding:NSUTF8StringEncoding];
        NSLog(@"login request params= %@",params);

        params = [NSString stringWithFormat:@"content=%@",params];
        NSLog(@"URL=%@;Send Data = %@",url,params);
        NSData *requestData = [params dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        NSURLResponse  *response = nil;
        
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error ];
        if (response == nil) {
            if (error != nil) {
                NSLog(@"Connection to server failed.");
                //NSLog(@"Connection failed! Error - %@ %@ - [%@]",
                //	  [error localizedDescription],
                //	  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey],
                //      @"error");
            }
            
            return @"{\"flag\":-9,\"msg\":\"network connection error\"}";
        }
        else {
            NSString *jsonString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"RET JSON STR = %@",jsonString);		
            jsonString = [jsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            return jsonString;
        }
    }
	
}

#pragma mark - 版本检测
+(MCheckUpdateReturn*)checkUpdate:(NSString *)appKey version:(NSString *)versionCode
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[MGlobal getBaseURL],@"/ums/getApplicationUpdate"];
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setObject:@"1.0" forKey:@"version_code"];
    [requestDictionary setObject:appKey forKey:@"appkey"];
    NSString *ret = [self sendData:url data:requestDictionary];
    MCheckUpdateReturn *result = [[MCheckUpdateReturn alloc] init];
    if (ret==nil) {
        result.flag = -4;
        result.msg = [[NSString alloc] initWithFormat:@"%@",@"error"];
        return result;
    }
    SBJsonParser    *parser     = [[SBJsonParser alloc] init];
    id  returnObject = [parser objectWithString:ret];
    NSDictionary * retDictionary= nil;
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        retDictionary=(NSDictionary*)returnObject;
    }
    result.flag = [[retDictionary objectForKey:@"flag"] intValue];
    result.msg = [retDictionary objectForKey:@"msg"];
    result.description = [retDictionary objectForKey:@"description"];
    result.version = [retDictionary objectForKey:@"version"];
    result.fileUrl = [retDictionary objectForKey:@"fileurl"];
    result.forceUpdate = [retDictionary objectForKey:@"forceupdate"];
    result.time= [retDictionary objectForKey:@"time"];
    return result;
}

+(MCommonReturn*)postClient:(NSString *)appKey deviceInfo:(MClientData *)deviceInfo
{
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",[MGlobal getBaseURL],@"/ums/postClientData"];
        MCommonReturn *ret = [[MCommonReturn alloc] init];
        NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
        [requestDictionary setObject:deviceInfo.platform forKey:@"platform"];
        [requestDictionary setObject:deviceInfo.osVersion forKey:@"os_version"];
        [requestDictionary setObject:deviceInfo.language forKey:@"language"];
        [requestDictionary setObject:deviceInfo.resolution forKey:@"resolution"];
        [requestDictionary setObject:deviceInfo.deviceid forKey:@"deviceid"];
        [requestDictionary setObject:appKey forKey:@"appkey"];
        if(deviceInfo.mccmnc!=nil)
        {
            [requestDictionary setObject:deviceInfo.mccmnc forKey:@"mccmnc"];
        }
        else
        {
            [requestDictionary setObject:@"" forKey:@"mccmnc"];
            
        }
        [requestDictionary setObject:deviceInfo.version forKey:@"version"];
        [requestDictionary setObject:deviceInfo.network forKey:@"network"];
        [requestDictionary setObject:deviceInfo.devicename forKey:@"devicename"];
        [requestDictionary setObject:deviceInfo.modulename forKey:@"modulename"];
        [requestDictionary setObject:deviceInfo.time forKey:@"time"];
        [requestDictionary setObject:deviceInfo.isJailbroken forKey:@"isjailbroken"];
        NSString *retString = [self sendData:url data:requestDictionary];
        SBJsonParser    *parser     = [[SBJsonParser alloc] init];
        id  returnObject = [parser objectWithString:retString];
        NSDictionary * retDictionary= nil;
        if ([returnObject isKindOfClass:[NSDictionary class]]) {
            retDictionary=(NSDictionary*)returnObject;
        }
        ret.flag = [[retDictionary objectForKey:@"flag" ] intValue];
        ret.msg = [retDictionary objectForKey:@"msg"];
        return ret;
    }
}

+(MCommonReturn*)postUsingTime:(NSString *)appKey sessionMills:(NSString *)sessionMills startMils:(NSString *)startMils endMils:(NSString *)endMils duration:(NSString *)duration activity:(NSString *)activity version:(NSString *)version
{
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",[MGlobal getBaseURL],@"/ums/postActivityLog"];
        MCommonReturn *ret = [[MCommonReturn alloc] init];
        NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
        [requestDictionary setObject:sessionMills forKey:@"session_id"];
        [requestDictionary setObject:startMils forKey:@"start_millis"];
        [requestDictionary setObject:endMils forKey:@"end_millis"];
        [requestDictionary setObject:duration forKey:@"duration"];
        [requestDictionary setObject:activity forKey:@"activities"];
        [requestDictionary setObject:appKey forKey:@"appkey"];
        [requestDictionary setObject:version forKey:@"version"];
        NSString *retString = [self sendData:url data:requestDictionary];
        SBJsonParser    *parser     = [[SBJsonParser alloc] init];
        id  returnObject = [parser objectWithString:retString];
        NSDictionary * retDictionary= nil;
        if ([returnObject isKindOfClass:[NSDictionary class]]) {
            retDictionary=(NSDictionary*)returnObject;
        }
        ret.flag = [[retDictionary objectForKey:@"flag" ] intValue];
        ret.msg = [retDictionary objectForKey:@"msg"];
        return ret;
    }
}

+(MCommonReturn*)postArchiveLogs:(NSMutableDictionary *)archiveLogs
{
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",[MGlobal getBaseURL],@"/ums/uploadLog"];
        MCommonReturn *ret = [[MCommonReturn alloc] init];
        NSString *retString = [self sendData:url data:archiveLogs];
        SBJsonParser    *parser     = [[SBJsonParser alloc] init];
        id  returnObject = [parser objectWithString:retString];
        NSDictionary * retDictionary= nil;
        if ([returnObject isKindOfClass:[NSDictionary class]]) {
            retDictionary=(NSDictionary*)returnObject;
        }
        ret.flag = [[retDictionary objectForKey:@"flag" ] intValue];
        ret.msg = [retDictionary objectForKey:@"msg"];
        return ret;        
    }
}

+(MCommonReturn*)postErrorLog:(NSString *)appKey errorLog:(MErrorLog *)errorLog
{
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",[MGlobal getBaseURL],@"/ums/postErrorLog"];
        MCommonReturn *ret = [[MCommonReturn alloc] init];
        NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
        [requestDictionary setObject:errorLog.time forKey:@"time"];
        [requestDictionary setObject:errorLog.stackTrace forKey:@"stacktrace"];
        [requestDictionary setObject:errorLog.version forKey:@"version"];
        [requestDictionary setObject:errorLog.osVersion forKey:@"os_version"];
        [requestDictionary setObject:errorLog.deviceID forKey:@"deviceid"];
        [requestDictionary setObject:appKey forKey:@"appkey"];
        [requestDictionary setObject:errorLog.activity forKey:@"activity"];
        NSString *retString = [self sendData:url data:requestDictionary];
        SBJsonParser    *parser     = [[SBJsonParser alloc] init];
        id  returnObject = [parser objectWithString:retString];
        NSDictionary * retDictionary= nil;
        if ([returnObject isKindOfClass:[NSDictionary class]]) {
            retDictionary=(NSDictionary*)returnObject;
        }
        ret.flag = [[retDictionary objectForKey:@"flag" ] intValue];
        ret.msg = [retDictionary objectForKey:@"msg"];
        return ret;
    }
}


+(MCommonReturn*)postEvent:(NSString *)appKey event:(MEvent *)mEvent
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[MGlobal getBaseURL],@"/ums/postEvent"];
    
    MCommonReturn *ret = [[MCommonReturn alloc] init];
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    [requestDictionary setObject:mEvent.eventId forKey:@"event_identifier"];
    [requestDictionary setObject:mEvent.time forKey:@"time"];
    [requestDictionary setObject:mEvent.activity forKey:@"activity"];
    [requestDictionary setObject:mEvent.label forKey:@"label"];
    [requestDictionary setObject:mEvent.version forKey:@"version"];
    [requestDictionary setObject:[NSNumber numberWithInt:mEvent.acc] forKey:@"acc"];
    [requestDictionary setObject:appKey forKey:@"appkey"];
    
    NSString *retString = [self sendData:url data:requestDictionary];
    SBJsonParser    *parser     = [[SBJsonParser alloc] init];
    id  returnObject = [parser objectWithString:retString];
    NSDictionary * retDictionary= nil;
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        retDictionary=(NSDictionary*)returnObject;
    }
    ret.flag = [[retDictionary objectForKey:@"flag" ] intValue];
    ret.msg = [retDictionary objectForKey:@"msg"];
    return ret;
}

+(MConfigPreference*)getOnlineConfig:(NSString *)appKey
{
    NSString* url = [NSString stringWithFormat:@"%@%@",[MGlobal getBaseURL],@"/ums/getOnlineConfiguration"];
    
    MConfigPreference *ret = [[MConfigPreference alloc] init];
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    
    [requestDictionary setObject:appKey forKey:@"appkey"];
    
    NSString *retString = [self sendData:url data:requestDictionary];
    
    SBJsonParser    *parser     = [[SBJsonParser alloc] init];
    id  returnObject = [parser objectWithString:retString];
    NSDictionary * retDictionary= nil;
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        retDictionary=(NSDictionary*)returnObject;
    }
    
    ret.flag = [[retDictionary objectForKey:@"flag" ] intValue];
    ret.msg = [retDictionary objectForKey:@"msg"];
    
    ret.autoGetLocation = [retDictionary objectForKey:@"autogetlocation"];
    ret.updateOnlyWifi = [retDictionary objectForKey:@"updateonlywifi"];
    ret.sessionMillis = [retDictionary objectForKey:@"sessionmillis"];
    ret.reportPolicy = [retDictionary objectForKey:@"reportpolicy"];
    return ret;
}

@end
