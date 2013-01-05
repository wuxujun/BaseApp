//
//  RequestManager.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-27.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "RequestManager.h"
static RequestManager *instance=nil;

@implementation RequestManager
@synthesize oauthRequest,tokenSecret;

-(id)init
{
    self=[super init];
    if (self) {
        oauthRequest=[[OAuthRequest alloc]initWithDelegate:self];
        [oauthRequest start];
    }
    return  self;
}

+(RequestManager*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[RequestManager alloc]init];
        }
    }
    return instance;
}

-(void)getOAuthToken:(enum OAuthId)oauthId
{
    [oauthRequest getOAuthToken:oauthId];
}

-(void)getOAuthAccessToken:(enum OAuthId)oauthId token:(NSString *)aToken verifier:(NSString *)aVerifier
{
    [oauthRequest getOAuthAccessToken:oauthId token:aToken secret:tokenSecret verifier:aVerifier];
}

#pragma mark - 
#pragma mark OAuthRequestDelegate
-(void)getOAuthTokenSuccess:(OAuthRequest *)request result:(NSDictionary *)aResult
{
    if (![aResult isKindOfClass:[NSDictionary class]]) {
        return;
    }
    tokenSecret=[aResult objectForKey:@"oauth_token_secret"];
    NSNotification *notification = [NSNotification notificationWithName:RequestOAuthToken object:[aResult objectForKey:@"oauth_token"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)getOauthTokenFailed:(OAuthRequest *)request
{

}

-(void)getAccessTokenSuccess:(OAuthRequest *)request result:(NSDictionary *)aResult
{
    if (![aResult isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSNotification *notification = [NSNotification notificationWithName:RequestOAuthAccessToken object:[aResult objectForKey:@"oauth_token_secret"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)getAccessTokenFailed:(OAuthRequest *)request
{

}

@end
