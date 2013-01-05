//
//  TBaoRequest.h
//  SAnalysis
//
//  Created by xujun wu on 12-11-2.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TB_DOMAIN                           @""
#define TB_API_AUTHORIZE                    @"https://oauth.taobao.com/authorize"
#define TB_API_ACCESS_TOKEN                 @"https://oauth.taobao.com/token"
#define TB_APP_KEY                          @"12589076"
#define TB_APP_SCERET                       @"571d4aac2a3572b9a313460865195ee1"

#define TB_REQUEST_TYPE                     @"requestType"
#define TB_STORE_USER_ID                    @"TBUserID"
#define TB_STORE_ACCESS_TOKEN               @"TBAccessToken"
#define TB_STORE_EXPIRATION_DATE            @"TBExpirationDate"


typedef enum{
    GET_OAUTH_CODE=0,
    GET_OAUTH_ACCESS_TOKEN,
    
} RequestType;


@class ASINetworkQueue;

@protocol TBaoRequestDelegate <NSObject>

@optional
-(void)didGetUserInfo:(NSString*)userId;


@end

@interface TBaoRequest : NSObject
{
    ASINetworkQueue         *requestQueue;
 
    __unsafe_unretained     id<TBaoRequestDelegate>     delegate;
}
@property (nonatomic,strong)ASINetworkQueue     *requestQueue;
@property (nonatomic,assign)id<TBaoRequestDelegate>     delegate;


-(id)initWithDelegate:(id)aDelegate;

-(BOOL)isRunning;
-(void)start;
-(void)pause;
-(void)resume;
-(void)cancel;

-(NSURL*)getOAuthCodeUrl;

-(void)getUserInfo;


@end
