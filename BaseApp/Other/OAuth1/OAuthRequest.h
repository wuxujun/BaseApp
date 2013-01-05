//
//  OAuthRequest.h
//  SAnalysis
//  OAuth 1.0  request
//  Created by xujun wu on 12-10-26.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

enum OAuthId{
    DBANK_HW = 1,
    BOX = 2,
    DROPBOX = 3,
    Weibo_Sohu = 8,
    Weibo_Max
};

typedef enum{
    GET_OAUTH_CODE=0,
    GET_OAUTH_ACCESS_TOKEN,
}RequestType;



#define  USER_REQUEST_TYPE     @"requestType"
#define  NeedToReLogin         @"NeedToReLogin"
#define  RequestFailed         @"RequestFailed"

@class  ASINetworkQueue;
@protocol OAuthRequestDelegate;

@interface OAuthRequest : NSObject
{
    ASINetworkQueue             *requestQueue;
    __unsafe_unretained id<OAuthRequestDelegate>         delegate;
    
}
@property (nonatomic,strong)ASINetworkQueue         *requestQueue;
@property (nonatomic,assign)id<OAuthRequestDelegate>   delegate;

-(id)initWithDelegate:(id)aDelegate;
-(BOOL)isRunning;
-(void)start;
-(void)pause;
-(void)resume;
-(void)cancel;

-(NSString*)getOAuthUrl:(NSString*)aUrl
             httpMethod:(NSString *)aHttpMethod
            consumerKey:(NSString *)aConsumerKey
         consumerSecret:(NSString *)aConsumerSecret
               tokenKey:(NSString *)aTokenKey
            tokenSecret:(NSString *)aTokenSecret
                 verify:(NSString *)aVerify
            callbackUrl:(NSString *)aCallbackUrl
             parameters:(NSDictionary *)aParameters
            queryString:(NSString **)aQueryString ;

-(void)getOAuthToken:(enum OAuthId)oauthId;
-(void)getOAuthAccessToken:(enum OAuthId)oauthId token:(NSString*)aToken secret:(NSString*)aSecret verifier:(NSString*)aVerifier;

@end

@protocol OAuthRequestDelegate <NSObject>

@optional
-(void)getOAuthTokenSuccess:(OAuthRequest*)request result:(NSDictionary*)aResult;
-(void)getOauthTokenFailed:(OAuthRequest*)request;
-(void)getAccessTokenSuccess:(OAuthRequest*)request result:(NSDictionary*)aResult;
-(void)getAccessTokenFailed:(OAuthRequest *)request;

@end
