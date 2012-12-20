//
//  VDiskManager.m
//  BaseApp
//
//  Created by xujun wu on 12-12-4.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "VDiskManager.h"

static VDiskManager     *instance=nil;
@implementation VDiskManager
@synthesize vdiskRequest;

-(id)init
{
    self=[super init];
    if (self) {
        vdiskRequest=[[VDiskRequest alloc]initWithDelegage:self];
        [vdiskRequest start];
    }
    return self;
}

+(VDiskManager*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[VDiskManager alloc]init];
        }
    }
    return instance;
}

-(void)getToken:(NSString *)uId pwd:(NSString *)aPwd
{
    [vdiskRequest getToken:uId pwd:aPwd];
}

-(void)upload:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    [vdiskRequest upload:aFilePath fileName:aFileName];
}

-(void)getData:(NSString *)aUrl params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [vdiskRequest getData:aUrl params:aParams userInfo:aUserInfo];
}

-(void)postData:(NSString *)aUrl params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [vdiskRequest postData:aUrl params:aParams userInfo:aUserInfo];
}

-(void)didGetDataFalied:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification=[NSNotification notificationWithName:VDiskRequestFailed object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter]postNotification:notification];

}

-(void)didGetDataFinished:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSLog(@"didGetDataFinished %@   %@",aDict,aUserInfo);
    NSNotification *notification=[NSNotification notificationWithName:VDiskRequestDataFinished object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter]postNotification:notification];

}

@end
