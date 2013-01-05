//
//  MAgent.m
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MAgent.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>
#import <arpa/inet.h>  //For AF_INET,etc
#import <net/if.h>    //For IFF_LOOPBACK
#import <ifaddrs.h>
#import "MCheckUpdateReturn.h"
#import "MConfigPreference.h"
#import "MEvent.h"
#import "MErrorLog.h"
#import "MActivityLog.h"
#import "MClientData.h"
#import "MGlobal.h"
#import "OpenUDID.h"
#import "MAgentRequest.h"

static MAgent  *instance=nil;

@interface MAgent ()
{
    NSString        *appKey;
    ReportPolicy        policy;
    BOOL                isLogEnabled;
    BOOL                isCrashReportEnabled;
    NSDate              *startDate;
    NSString            *updateOnlyWifi;
    NSString            *sessionMillis;
    BOOL                isOnlineConfig;
    
    MCheckUpdateReturn       *updateRet;
    NSMutableArray          *eventArray;
    NSString                *sessionId;
    NSString                *pageName;
}

@property (nonatomic)ReportPolicy       policy;
@property (nonatomic)BOOL               isLogEnabled;
@property (nonatomic)BOOL               isCrashReportEnabled;
@property (nonatomic,strong)NSString        *appKey;
@property (nonatomic,strong) NSString       *updateOnlyWifi;
@property (nonatomic,strong) NSString       *sessionMillis;
@property (nonatomic) BOOL                  isOnLineConfig;
@property (nonatomic) MCheckUpdateReturn     *updateRet;
@property (nonatomic,strong) NSDate         *startDate;
@property (nonatomic,strong) NSString       *sessionId;
@property (nonatomic,strong) NSString       *pageName;

@end

@implementation MAgent
@synthesize policy,isLogEnabled,isCrashReportEnabled,updateOnlyWifi,sessionMillis,isOnLineConfig;
@synthesize updateRet,appKey,startDate,sessionId,pageName;

+(MAgent*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[[self class]alloc]init];
            instance.isLogEnabled=NO;
            instance.isCrashReportEnabled=YES;
            instance.policy=1;
            instance.sessionMillis=@"30";
            instance.updateOnlyWifi=@"1";
        }
    }
    return instance;
}

+(void)startWithAppkKey:(NSString *)appKey serverURL:(NSString *)serverURL
{
    [[MAgent getInstance] initWithAppKey:appKey reportPolicy:BATCH serverURL:serverURL];
}


+(void)startWithAppkKey:(NSString *)appKey reportPolicy:(ReportPolicy)policy serverURL:(NSString *)serverURL
{
    [[MAgent getInstance] initWithAppKey:appKey reportPolicy:policy serverURL:serverURL];
}

+(void)setIsLogEnabled:(BOOL)isLogEnabled
{
    [MAgent getInstance].isLogEnabled=isLogEnabled;
}

-(void)initWithAppKey:(NSString*)applicationKey reportPolicy:(ReportPolicy)aPolicy serverURL:(NSString*)aServerURL
{
    self.appKey=applicationKey;
    self.policy=aPolicy;
    [MGlobal setBaseURL:aServerURL];
    
    NSNotificationCenter *notifCenter=[NSNotificationCenter defaultCenter];

    [notifCenter addObserver:self selector:@selector(resignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [notifCenter addObserver:self selector:@selector(becomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound ];
     
    self.startDate=[[NSDate date]copy];
     
    NSString *currentTime=[[NSString alloc]initWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString *sessionIdentifier=[[NSString alloc]initWithFormat:@"%@%@",currentTime,@"3"];
    
    self.sessionId=[self md5:sessionIdentifier];
    if (isLogEnabled) {
        NSLog(@"Get Session ID=%@",sessionId);
    }
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [self performSelectorInBackground:@selector(archiveClientData) withObject:nil];
}

+(void)startTracPage:(NSString*)pageName
{
    [[MAgent getInstance] performSelectorInBackground:@selector(recordStartTime:) withObject:pageName];
}

-(void)recordStartTime:(NSString*) pageName
{
    @autoreleasepool {
        if (pageName==nil) {
            return;
        }
        self.pageName = [[NSString alloc] initWithString:pageName];
        NSDate *pageStartDate = [[NSDate date] copy];
        [[NSUserDefaults standardUserDefaults] setObject:pageStartDate forKey:pageName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(void)endTracPage:(NSString*)pageName
{
    if([MAgent getInstance].policy == REALTIME)
    {
        if([MAgent getInstance].isLogEnabled)
        {
            NSLog(@"Commit using Time of page %@",pageName);
        }
    
        [[MAgent getInstance] performSelectorInBackground:@selector(commitUsingTime:) withObject:pageName];
    }
    else
    {
        if([MAgent getInstance].isLogEnabled)
        {
            NSLog(@"Save Activity using time to cache of %@",pageName);
        }
        [[MAgent getInstance] performSelectorInBackground:@selector(saveActivityUsingTime:) withObject:pageName];
    }
    
}

- (void)resignActive:(NSNotification *)sender
{
    [MAgent endTracPage:self.pageName];
}

-(void)becomeActive:(NSNotification*)sender
{
    if (isLogEnabled) {
        NSLog(@"Application become active");
    }
    [MAgent startTracPage:self.pageName];
    
    NSString *pageName=[[NSBundle mainBundle]bundleIdentifier];
    NSDate *pageStartDate=[[NSDate date] copy];
    [[NSUserDefaults standardUserDefaults]setObject:pageStartDate forKey:pageName];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSString *currentTime=[[NSString alloc]initWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    self.sessionId=[self md5:currentTime];
    if (isLogEnabled) {
        NSLog(@"Current session ID=%@",sessionId);
    }
    [self performSelectorInBackground:@selector(archiveClientData) withObject:nil];
    if (isLogEnabled) {
        NSLog(@"Application Resign Active");
    }
}

-(void)commitUsingTime:(NSString*)pageName
{
    @autoreleasepool {
        NSString *sessionMills=self.sessionId;
        NSString *endMils=[self getCurrentTime];
        if (pageName==nil) {
            return;
        }
        NSDate *pageStartDate=[[NSUserDefaults standardUserDefaults]objectForKey:pageName];
        if (pageStartDate!=nil) {
            NSString *startMils=[self getDateStr:pageStartDate];
            NSTimeInterval duration = (-[startDate timeIntervalSinceNow])*1000;
            NSString *durationStr = [[NSString alloc] initWithFormat:@"%f",duration];
            NSString *activities = pageName;
            NSString *appVersion = [self getVersion];
            [MAgentRequest postUsingTime:appKey sessionMills:sessionMills startMils:startMils endMils:endMils duration:durationStr activity:activities version:appVersion];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:pageName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            if (isLogEnabled) {
                 NSLog(@"Page Start time not found. in commitUsingTime pagename = %@",pageName);
            }
        }
    }
}

- (void)saveErrorLog:(NSString*)stackTrace
{
    @autoreleasepool {
        if(isLogEnabled)
        {
            NSLog(@"save error log");
        }
        MErrorLog *errorLog = [[MErrorLog alloc] init];
        errorLog.stackTrace = stackTrace;
        errorLog.appKey = self.appKey;
        errorLog.version = [self getVersion];
        errorLog.time = [self getCurrentTime];
        errorLog.activity = [[NSBundle mainBundle] bundleIdentifier];
        errorLog.osVersion = [[UIDevice currentDevice] systemVersion];
        errorLog.deviceID = [self machineName];
        NSLog(@"Error Log");
        NSData *errorLogData = [[NSUserDefaults standardUserDefaults] objectForKey:@"errorLog"] ;
        NSMutableArray * errorLogArray = [[NSMutableArray alloc] init ];
        if (errorLogData!=nil)
        {
            errorLogArray = [NSKeyedUnarchiver unarchiveObjectWithData:errorLogData];
        }
        else {
            errorLogArray = [[NSMutableArray alloc] init ];
        }
        [errorLogArray addObject:errorLog];
        if(isLogEnabled)
        {
            NSLog(@"Error Log array size = %d",[errorLogArray count]);
        }
        NSData *newErrorData = [NSKeyedArchiver archivedDataWithRootObject:errorLogArray];
        [[NSUserDefaults standardUserDefaults] setObject:newErrorData forKey:@"errorLog"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

- (void)saveActivityUsingTime:(NSString*)pageName
{
    @autoreleasepool
    {
        MActivityLog *acLog = [[MActivityLog alloc] init];
        acLog.sessionMils = self.sessionId;
        NSLog(@"saveActivityUsingTime %@",pageName);
        if (pageName==nil) {
            return;
        }
        NSDate *pageStartDate = [[NSUserDefaults standardUserDefaults] objectForKey:pageName];
        if(pageStartDate!=nil)
        {
            NSString *start_mils = [self getDateStr:pageStartDate];
            acLog.startMils = start_mils;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:pageName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            if(isLogEnabled)
            {
                NSLog(@"Page Start time not found. in saveActivityUsingTime pagename = %@",pageName);
            }
            return;
        }
        acLog.endMils = [self getCurrentTime];
        NSTimeInterval duration = (-[startDate timeIntervalSinceNow])*1000;
        acLog.duration = [[NSString alloc] initWithFormat:@"%f",duration];
        acLog.activity = pageName;
        acLog.version = [self getVersion];
        if(acLog)
        {
            NSLog(@"acLog sessionMils = %@",acLog.sessionMils);
        }
        NSData *activityLogData = [[NSUserDefaults standardUserDefaults] objectForKey:@"activityLog"] ;
        NSMutableArray * activityLogArray = [[NSMutableArray alloc] init ];
        if (activityLogData!=nil)
        {
            activityLogArray = [NSKeyedUnarchiver unarchiveObjectWithData:activityLogData];
        }
        else {
            activityLogArray = [[NSMutableArray alloc] init ];
        }
        [activityLogArray addObject:acLog];
        if(isLogEnabled)
        {
            NSLog(@"Activity Log array size = %d",[activityLogArray count]);
        }
        NSData *newActivityData = [NSKeyedArchiver archivedDataWithRootObject:activityLogArray];
        [[NSUserDefaults standardUserDefaults] setObject:newActivityData forKey:@"activityLog"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(void)checkUpdate
{
    if ([MAgent getInstance].updateOnlyWifi)
    {
        [[MAgent getInstance] getApplicationUpdate];
    }
}

-(void) getApplicationUpdate
{
    MCheckUpdateReturn *retWrapper;
    if(isLogEnabled)
    {
        NSLog(@"Begin get application update");
    }
    retWrapper = [MAgentRequest checkUpdate:appKey version:@"1.0"];
    if (retWrapper.flag>0)
    {
        updateRet = retWrapper;
        NSString *version = [[NSString alloc] initWithFormat:@"New Update %@",retWrapper.version];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: version
                                                        message: retWrapper.description
                                                       delegate: self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Confirm", nil];
        [alert show];
    }
    else
    {
        if(isLogEnabled)
        {
            NSLog(@"Update Return: Flag = %d, Msg = %@",retWrapper.flag,retWrapper.msg);
        }
    }
}

-(void) postDataInBackGround
{
    MCheckUpdateReturn *returnData = [MAgentRequest checkUpdate:appKey version:@"1.0"];
    [self performSelectorOnMainThread:@selector(end_postdataThread:) withObject:returnData waitUntilDone:NO];
}
-(void) end_postdataThread:(id)ret
{
    MCheckUpdateReturn *retObj  =ret;
    if (retObj.flag>0) {
        
    }
}

+(void)postEvent:(NSString *)event_id
{
    MEvent *event =[[MEvent alloc] init];
    event.eventId = event_id;
    event.activity = [[NSBundle mainBundle] bundleIdentifier];
    event.label = @"";
    event.time = [[MAgent getInstance] getCurrentTime];
    event.version = [[MAgent getInstance] getVersion];
    event.acc = 1;
    [[MAgent getInstance] archiveEvent:event];
}

+(void)postEvent:(NSString *)event_id label:(NSString *)label
{
    MEvent *event = [[MEvent alloc] init];
    event.eventId = event_id;
    event.time = [[MAgent getInstance] getCurrentTime];
    event.acc = 1;
    event.version = [[MAgent getInstance] getVersion];
    event.activity = [[NSBundle mainBundle] bundleIdentifier];
    event.label = label;
    [[MAgent getInstance] archiveEvent:event];
    
}

+(void)postEvent:(NSString *)event_id acc:(NSInteger)acc
{
    MEvent *event = [[MEvent alloc] init];
    event.eventId = event_id;
    event.time = [[MAgent getInstance] getCurrentTime];
    event.acc = acc;
    event.version = [[MAgent getInstance] getVersion];
    event.activity =[[NSBundle mainBundle] bundleIdentifier];
    event.label = @"";
    [[MAgent getInstance] archiveEvent:event];
    
}

+(void)postEvent:(NSString *)event_id label:(NSString *)label acc:(NSInteger)acc
{
    MEvent *event = [[MEvent alloc] init];
    event.eventId = event_id;
    event.time = [[MAgent getInstance] getCurrentTime];
    event.acc = acc;
    event.activity = [[NSBundle mainBundle] bundleIdentifier];
    event.version = [[MAgent getInstance] getVersion];
    event.label = label;
    [[MAgent getInstance] archiveEvent:event];
}


-(void) processEvent:(MEvent *)event
{
    [self performSelectorInBackground:@selector(postEventInBackGround:) withObject:event];
}

-(void) processArchivedLogs
{
    @autoreleasepool {
        NSMutableArray *eventArray = [self getArchiveEvent];
        NSMutableArray *activityLogArray = [self getArchiveActivityLog];
        NSMutableArray *errorLogArray = [self getArchiveErrorLog];
        NSMutableArray *clientDataArray = [self getArchiveClientData];
        if([eventArray count]>0 || [activityLogArray count]>0 || [errorLogArray count]>0 || [clientDataArray count]>0)
        {
            NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
            [requestDic setObject:appKey forKey:@"appkey"];
            if([eventArray count]>0)
            {
                [requestDic setObject:eventArray forKey:@"eventInfo"];
            }
            
            if([activityLogArray count] >0)
            {
                [requestDic setObject:activityLogArray forKey:@"activityInfo"];
            }
            
            if([errorLogArray count]>0)
            {
                [requestDic setObject:errorLogArray forKey:@"errorInfo"];
            }
            
            if([clientDataArray count]>0)
            {
                [requestDic setObject:clientDataArray forKey:@"clientData"];
            }
            
            if(isLogEnabled)
            {
                NSLog(@"Post Archive Logs");
            }
            MCommonReturn *ret = [MAgentRequest postArchiveLogs:requestDic];
            if(ret.flag>0)
            {
                if (isLogEnabled)
                {
                    NSLog(@"Arcived log upload success, so remove archived logs in cache");
                }
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"eventArray"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activityLog"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"errorLog"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clientDataArray"];
            }
        }
    }
}

-(NSMutableArray *)getArchiveEvent
{
    NSData *oldData = [[NSUserDefaults standardUserDefaults] objectForKey:@"eventArray"] ;
    NSMutableArray * array = nil;
    if(isLogEnabled)
    {
        NSLog(@"old  data num = %d",[array count]);
    }
    
    if (oldData!=nil)
    {
        array = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
    }
    NSMutableArray *eventArray = [[NSMutableArray alloc] init];
    if ([array count]>0)
    {
        for(MEvent *mEvent in array)
        {
            NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
            [requestDictionary setObject:mEvent.eventId forKey:@"event_identifier"];
            [requestDictionary setObject:mEvent.time forKey:@"time"];
            [requestDictionary setObject:mEvent.activity forKey:@"activity"];
            [requestDictionary setObject:mEvent.label forKey:@"label"];
            [requestDictionary setObject:[NSNumber numberWithInt:mEvent.acc] forKey:@"acc"];
            [requestDictionary setObject:appKey forKey:@"appkey"];
            [requestDictionary setObject:mEvent.version forKey:@"version"];
            [eventArray addObject:requestDictionary];
        }
    }
    return eventArray;
}

-(NSMutableArray *)getArchiveActivityLog
{
    NSData *oldData = [[NSUserDefaults standardUserDefaults] objectForKey:@"activityLog"] ;
    NSMutableArray * array = nil;
    if (oldData!=nil)
    {
        array = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
        if(isLogEnabled)
        {
            NSLog(@"Have activity data num = %d",[array count]);
        }
    }
    NSMutableArray *activityLogArray = [[NSMutableArray alloc] init];
    if ([array count]>0)
    {
        for(MActivityLog *mLog in array)
        {
            NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
            [requestDictionary setObject:mLog.sessionMils forKey:@"session_id"];
            [requestDictionary setObject:mLog.startMils forKey:@"start_millis"];
            [requestDictionary setObject:mLog.endMils forKey:@"end_millis"];
            [requestDictionary setObject:mLog.duration forKey:@"duration"];
            [requestDictionary setObject:mLog.activity forKey:@"activities"];
            [requestDictionary setObject:appKey forKey:@"appkey"];
            [requestDictionary setObject:mLog.version forKey:@"version"];
            [activityLogArray addObject:requestDictionary];
        }
    }
    return activityLogArray;
}

-(NSMutableArray *)getArchiveErrorLog
{
    NSData *oldData = [[NSUserDefaults standardUserDefaults] objectForKey:@"errorLog"] ;
    NSMutableArray * array = nil;
    if (oldData!=nil)
    {
        array = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
        if(isLogEnabled)
        {
            NSLog(@"Have error data num = %d",[array count]);
        }
    }
    NSMutableArray *errorLogArray = [[NSMutableArray alloc] init];
    if ([array count]>0)
    {
        for(MErrorLog *errorLog in array)
        {
            NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
            [requestDictionary setObject:errorLog.time forKey:@"time"];
            [requestDictionary setObject:errorLog.stackTrace forKey:@"stacktrace"];
            [requestDictionary setObject:errorLog.version forKey:@"version"];
            [requestDictionary setObject:errorLog.osVersion forKey:@"os_version"];
            [requestDictionary setObject:errorLog.deviceID forKey:@"deviceid"];
            [requestDictionary setObject:errorLog.appKey forKey:@"appkey"];
            [requestDictionary setObject:errorLog.activity forKey:@"activity"];
            [errorLogArray addObject:requestDictionary];
        }
    }
    return errorLogArray;
}


-(void)postEventInBackGround:(MEvent *)event
{
    @autoreleasepool {
        MCommonReturn *ret ;
        ret = [MAgentRequest postEvent:self.appKey event:event];
        if (ret.flag<0)
        {
            NSData *oldData = [[NSUserDefaults standardUserDefaults] objectForKey:@"eventArray"] ;
            NSMutableArray * array = [[NSMutableArray alloc] init];
            
            if (oldData!=nil)
            {
                array = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
            }
            [array addObject:event];
            NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:array];
            [[NSUserDefaults standardUserDefaults] setObject:newData forKey:@"eventArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}


-(void)postOldEventDataInBackGround:(NSMutableArray *)array
{
    @autoreleasepool {
        for (int i =0; i<[array count]; i++)
        {
            MEvent *event = [array objectAtIndex:i];
            
            MCommonReturn *ret ;
            ret = [MAgentRequest postEvent:appKey event:event];
            if (ret.flag>0)
            {
                [array removeObjectAtIndex:i];
                
            }
            
            NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:array];
            
            [[NSUserDefaults standardUserDefaults] setObject:newData forKey:@"eventArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

-(void)archiveClientData
{
    MClientData *clientData = [self getDeviceInfo];
    NSMutableArray *mClientDataArray;
    if (self.policy == BATCH) {
        NSData *oldData = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientDataArray"] ;
        if (oldData!=nil)
        {
            mClientDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
        }
        else
        {
            mClientDataArray = [[NSMutableArray alloc] init];
        }
        if(isLogEnabled)
        {
            NSLog(@"archive client data because of BATCH mode");
        }
        [mClientDataArray addObject:clientData];
        if(isLogEnabled)
        {
            NSLog(@"Archived client data = %d",[mClientDataArray count]);
        }
        NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:mClientDataArray];
        [[NSUserDefaults standardUserDefaults] setObject:newData forKey:@"clientDataArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        
        [self processClientData:clientData];
    }
    
    //Process archived logs after post ClientData
    [self performSelector:@selector(processArchivedLogs)];
    
}

-(void)processClientData:(MClientData *)clientData
{
    [self performSelector:@selector(postClientDataInBackground:) withObject:clientData];
}

-(NSMutableArray *)getArchiveClientData
{
    NSData *oldData = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientDataArray"] ;
    NSMutableArray * array = nil;
    if (oldData!=nil)
    {
        array = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
        if(isLogEnabled)
        {
            NSLog(@"Have error data num = %d",[array count]);
        }
    }
    NSMutableArray *clientDataArray = [[NSMutableArray alloc] init];
    if ([array count]>0)
    {
        for(MClientData *clientData in array)
        {
            NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
            [requestDictionary setObject:clientData.platform forKey:@"platform"];
            [requestDictionary setObject:clientData.osVersion forKey:@"os_version"];
            [requestDictionary setObject:clientData.language forKey:@"language"];
            [requestDictionary setObject:clientData.resolution forKey:@"resolution"];
            [requestDictionary setObject:clientData.deviceid forKey:@"deviceid"];
            if(clientData.mccmnc!=nil)
            {
                [requestDictionary setObject:clientData.mccmnc forKey:@"mccmnc"];
            }
            else
            {
                [requestDictionary setObject:@"" forKey:@"mccmnc"];
                
            }
            [requestDictionary setObject:clientData.version forKey:@"version"];
            [requestDictionary setObject:clientData.network forKey:@"network"];
            [requestDictionary setObject:clientData.devicename forKey:@"devicename"];
            [requestDictionary setObject:clientData.modulename forKey:@"modulename"];
            [requestDictionary setObject:clientData.time forKey:@"time"];
            [requestDictionary setObject:appKey forKey:@"appkey"];
            [requestDictionary setObject:clientData.isJailbroken forKey:@"isjailbroken"];
            [clientDataArray addObject:requestDictionary];
        }
    }
    return clientDataArray;
}



-(void)archiveEvent:(MEvent *)event
{
    NSMutableArray *mEventArray;
    if (self.policy == BATCH) {
        NSData *oldData = [[NSUserDefaults standardUserDefaults] objectForKey:@"eventArray"] ;
        if (oldData!=nil)
        {
            mEventArray = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
        }
        else
        {
            mEventArray = [[NSMutableArray alloc] init];
        }
        if(isLogEnabled)
        {
            NSLog(@"archive event because of BATCH mode");
        }
        [mEventArray addObject:event];
        if(isLogEnabled)
        {
            NSLog(@"Archived event count = %d",[mEventArray count]);
        }
        NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:mEventArray];
        [[NSUserDefaults standardUserDefaults] setObject:newData forKey:@"eventArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [self processEvent:event];
    }
}

-(NSString *) getVersion
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return appVersion;
}

-(MClientData *)getDeviceInfo
{
    MClientData  *info = [[MClientData alloc] init];
    info.platform = [[UIDevice currentDevice] systemName];
    info.devicename = [self machineName];
    info.modulename = [[UIDevice currentDevice] model];
    info.osVersion = [[UIDevice currentDevice] systemVersion];
    info.time = [self getCurrentTime];
    if([MAgent isJailbroken])
    {
        info.isJailbroken = @"1";
    }
    else {
        info.isJailbroken = @"0";
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat scale = [[UIScreen mainScreen] scale];
    info.resolution = [[NSString alloc] initWithFormat:@"%.fx%.f",rect.size.width*scale,rect.size.height*scale];
    //Using open UDID
    info.deviceid = [OpenUDID value];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    info.language = [languages objectAtIndex:0];
    
    
    CTTelephonyNetworkInfo*netInfo =[[CTTelephonyNetworkInfo alloc] init];
    CTCarrier*carrier =[netInfo subscriberCellularProvider];
    NSString*mcc =[carrier mobileCountryCode];
    NSString*mnc =[carrier mobileNetworkCode];
    info.mccmnc = [mcc stringByAppendingString:mnc];
    
    info.version = [self getVersion];
    BOOL isWifi = [self isWiFiAvailable];
    if(isWifi)
    {
        info.network = @"WIFI";
    }
    else
    {
        info.network = @"2G/3G";
    }
    return info;
}

-(NSString *)getCurrentTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"ABC"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"Current Time 2 = %@",timeStamp);
    return timeStamp;
    
}

-(NSString *)getDateStr:(NSDate *)inputDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"ABC"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:inputDate];
    return timeStamp;
    
}

-(void)postClientDataInBackground:(MClientData *)clientData
{
    @autoreleasepool {
        //[self isWiFiAvailable];
        MCommonReturn *ret ;
        ret = [MAgentRequest postClient:self.appKey deviceInfo:clientData];
        if(ret.flag >0)
        {
            if(isLogEnabled)
            {
                NSLog(@"Post Client Data OK: Flag = %d, Msg = %@",ret.flag,ret.msg);
            }
        }
        else
        {
            if(isLogEnabled)
            {
                NSLog(@"Post Client Data Error: So save to archive. Flag = %d, Msg = %@",ret.flag,ret.msg);
            }
            NSMutableArray *mClientDataArray;
            NSData *oldData = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientDataArray"] ;
            if (oldData!=nil)
            {
                mClientDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
            }
            else
            {
                mClientDataArray = [[NSMutableArray alloc] init];
            }
            if(isLogEnabled)
            {
                NSLog(@"archive client data because of BATCH mode");
            }
            [mClientDataArray addObject:clientData];
            if(isLogEnabled)
            {
                NSLog(@"Archived client data = %d",[mClientDataArray count]);
            }
            NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:mClientDataArray];
            [[NSUserDefaults standardUserDefaults] setObject:newData forKey:@"clientDataArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}


+(MConfigPreference *)updateOnlineConfig
{
    MConfigPreference * ret ;
    ret = [MAgentRequest getOnlineConfig:[self getInstance].appKey];
    if (ret.flag>0) {
    }
    return ret;
    
}

uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    NSString *stackTrace = [[NSString alloc] initWithFormat:@"%@\n%@",exception,[exception callStackSymbols]];
    [[MAgent getInstance] saveErrorLog:stackTrace];
}

-(void)postErrorLog:(NSString*)stackTrace
{
    @autoreleasepool {
        if(isLogEnabled)
        {
            NSLog(@"Post error log realtime");
        }
        MErrorLog *errorLog = [[MErrorLog alloc] init];
        errorLog.stackTrace = stackTrace;
        errorLog.appKey = self.appKey;
        errorLog.version = [self getVersion];
        errorLog.time = [self getCurrentTime];
        errorLog.activity = [[NSBundle mainBundle] bundleIdentifier];
        errorLog.osVersion = [[UIDevice currentDevice] systemVersion];
        errorLog.deviceID = [self machineName];
        MCommonReturn *ret = [MAgentRequest postErrorLog:self.appKey errorLog:errorLog];
        if(ret.flag<0)
        {
            [self saveErrorLog:stackTrace];
        }
    }
}

+(BOOL)isJailbroken
{
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}


+(void)pushUUID
{
    [[MAgent getInstance]pushUuid];
}

-(void)pushUuid
{
    @autoreleasepool {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uuid = [defaults objectForKey:@"uuid"];
        MCommonReturn *ret = [MAgentRequest postUUID:self.appKey uuid:uuid];
        if(ret.flag<0)
        {
            NSLog(@"上传失败");
        }
    }
}

+(void)setOnLineConfig:(BOOL)isOnlineConfig
{
    [MAgent getInstance].isOnLineConfig = isOnlineConfig;
    if ([MAgent getInstance].isOnLineConfig) {
        MConfigPreference *config ;
        
        config = [self updateOnlineConfig];
        [MAgent getInstance].sessionMillis = config.sessionMillis;
        [MAgent getInstance].updateOnlyWifi = config.updateOnlyWifi;
        [MAgent getInstance].policy = [config.reportPolicy intValue];
    }
    else {
        NSLog(@"本地配置");
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateRet.fileUrl]];
    }
}


-(BOOL)isWiFiAvailable
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    if (getifaddrs(&addresses) != 0) return NO;
    
    cursor = addresses;
    while (cursor != NULL) {
        if (cursor -> ifa_addr -> sa_family == AF_INET
            && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    
    freeifaddrs(addresses);
    return wiFiAvailable;
}

-(NSString*) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return  [NSString stringWithCString:systemInfo.machine
                               encoding:NSUTF8StringEncoding];
}

@end
