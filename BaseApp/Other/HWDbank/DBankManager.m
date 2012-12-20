//
//  DBankManager.m
//  SAnalysis
//
//  Created by xujun wu on 12-11-8.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "DBankManager.h"

static DBankManager     *instance=nil;

@implementation DBankManager
@synthesize dbankRequest,tokenSecret;

-(id)init
{
    self=[super init];
    if (self) {
        dbankRequest=[[DBankRequest alloc]initWithDelegate:self];
        [dbankRequest start];
    }
    return self;
}

+(DBankManager*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[DBankManager alloc]init];
        }
    }
    return instance;
}

#pragma mark - 授权认证
-(void)getOAuthToken
{
    [dbankRequest getOAuthToken];
}

-(void)getOAuthAccessToken:(NSString *)aToken verifier:(NSString *)aVerifier
{
    [dbankRequest getOAuthAccessToken:aToken secret:tokenSecret verifier:aVerifier];
}

-(void)getOAuthTokenSuccess:(DBankRequest *)request result:(NSDictionary *)aResult
{
    if (![aResult isKindOfClass:[NSDictionary class]]) {
        return;
    }
    tokenSecret=[aResult objectForKey:@"oauth_token_secret"];
    NSNotification *notification = [NSNotification notificationWithName:HWRequestOAuthToken object:[aResult objectForKey:@"oauth_token"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)getOauthTokenFailed:(DBankRequest *)request
{
    
}

-(void)getAccessTokenSuccess:(DBankRequest *)request result:(NSDictionary *)aResult
{
    if (![aResult isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSNotification *notification = [NSNotification notificationWithName:HWRequestOAuthAccessToken object:[aResult objectForKey:@"oauth_token_secret"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)getAccessTokenFailed:(DBankRequest *)request
{

}

#pragma mark - 网盘接口

-(void)getUserInfo
{
    [dbankRequest getUserInfo];
}

-(void)downloadFile:(NSString *)aUrl fileName:(NSString *)aFileName
{
    [dbankRequest downloadFile:aUrl fileName:aFileName];
}

-(void)updateFile:(NSString *)aFilePath fileName:(NSString *)aFileName oldFile:(NSString *)aOldFile
{
    [dbankRequest updateFile:aFileName fileName:aFileName oldFile:aOldFile];
}

-(void)createDefaultFolder
{
    [dbankRequest createDefaultFolder];
}

-(void)getVFSlsDir:(NSString*)folderName
{
    [dbankRequest getVFSlsDir:folderName];
}

-(void)uploadFile:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    [dbankRequest uploadFile:aFilePath fileName:aFileName];
}

-(void)didGetVFSlsDir:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification=[NSNotification notificationWithName:@"RequestFinished" object:aDict];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}


-(void)getData:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [dbankRequest getData:aParams userInfo:aUserInfo];
}

-(void)postData:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [dbankRequest postData:aParams userInfo:aUserInfo];
}

-(void)didGetDataFalied:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification=[NSNotification notificationWithName:HWRequestFailed object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

-(void)didGetDataFinished:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification=[NSNotification notificationWithName:HWRequestDataFinished object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}


@end
