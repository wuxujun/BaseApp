//
//  LiveManager.m
//  BaseApp
//
//  Created by xujun wu on 12-11-15.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "LiveManager.h"

static LiveManager      *instance=nil;
@implementation LiveManager
@synthesize liveRequest;

-(id)init
{
    self=[super init];
    if (self) {
        liveRequest=[[LiveAuthRequest alloc]initWithDelegate:self];
        [liveRequest start];
    }
    return self;
}

+(LiveManager*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[LiveManager alloc]init];
        }
    }
    return instance;
}

-(NSURL*)getAuthCodeUrl
{
   return [liveRequest getAuthCodeUrl];
}

-(void)getUser
{
    [liveRequest getUser];
}

-(void)retrieveToken
{
    [liveRequest retrieveToken];
}

-(void)getHome
{
    [liveRequest getHome];
}

-(void)getAllFiles:(NSString *)aUrl
{
    [liveRequest getAllFiles:aUrl];
}

-(void)uploadFile:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    [liveRequest uploadFile:aFilePath fileName:aFileName];
}

-(void)updateFile:(NSString *)aFileId path:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    [liveRequest updateFile:aFileId path:aFilePath fileName:aFileName];
}

-(void)downloadFile:(NSString *)aId fileName:(NSString *)aFileName userInfo:(NSDictionary *)aUserInfo
{
    [liveRequest downloadFile:aId fileName:aFileName userInfo:aUserInfo];
}


-(void)getData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [liveRequest getData:aMethod params:aParams userInfo:aUserInfo];
}

-(void)postData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [liveRequest postData:aMethod params:aParams userInfo:aUserInfo];
}

-(void)didGetAllFiles:(NSDictionary *)aDict
{
    NSNotification *notification =[NSNotification notificationWithName:LIVERequestDataFinished object:aDict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)didGetUserInfo
{

}

#pragma mark -LiveAuthRequestDelegate
-(void)didGetDataFalied:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo
{
    NSNotification *notification =[NSNotification notificationWithName:LIVERequestDataFinished object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
-(void)didGetDataFinished:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo
{
    NSNotification *notification =[NSNotification notificationWithName:LIVERequestDataFinished object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
@end
