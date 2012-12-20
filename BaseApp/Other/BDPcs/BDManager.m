//
//  BDManager.m
//  BaseApp
//
//  Created by xujun wu on 12-11-26.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "BDManager.h"

static BDManager        *instance=nil;

@implementation BDManager
@synthesize bdRequest;

-(id)init
{
    self=[super init];
    if (self) {
        bdRequest=[[BDRequest alloc]initWithDelegate:self];
        [bdRequest start];
    }
    return self;
}

+(BDManager*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[BDManager alloc]init];
        }
    }
    return instance;
}

-(NSURL*)getOAuthCodeUrl
{
    return [bdRequest getOAuthCodeUrl];
}

-(void)createDefaultFolder
{
    [bdRequest createDefaultFolder];
}

-(void)upload:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    [bdRequest upload:aFilePath fileName:aFileName];
}

-(void)updateFile:(NSString*)aFilePath fileName:(NSString*)aFileName oldFile:(NSString *)aOldFile
{
    [bdRequest updateFile:aFilePath fileName:aFileName oldFile:aOldFile];
}


-(void)getData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [bdRequest getData:aMethod params:aParams userInfo:aUserInfo];
}

-(void)postData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [bdRequest postData:aMethod params:aParams userInfo:aUserInfo];
}
-(void)didGetUserInfo
{

}

-(void)didGetDataFalied:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification=[NSNotification notificationWithName:BDRequestFailed object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

-(void)didGetDataFinished:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification=[NSNotification notificationWithName:BDRequestDataFinished object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

@end
