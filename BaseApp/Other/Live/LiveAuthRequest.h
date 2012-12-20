//
//  LiveAuthRequest.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-30.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LIVE_DOMAIN     @"https://apis.live.net/v5.0"

#define LIVE_API_AUTHORIZE        @"https://login.live.com/oauth20_authorize.srf"
#define LIVE_API_ACCESS_TOKEN     @"https://login.live.com/oauth20_token.srf"

#define CALL_BACK_URL             @"http://d.xujun.local/callback.php"

#define APP_KEY         @"00000000440DBC1D"
#define APP_SECRET      @"8id21qcY44yoQukiTrm4Mih8jxpK61Db"

#define LIVE_REQUEST_TYPE         @"LIVERequestType"
#define LIVE_TOKEN_CODE      @"LiveTokenCode"

#define LIVA_AUTH_TOKEN_REQUEST_SUCCEED    @"RequestAccessTokenSucceed"
#define LIVE_GET_USER_REQUEST_SUCCEED      @"RequestGetUserSucceed"
#define LIVE_GET_ALLFILES_SUCCEED          @"RequestGetAllFilesSucceed"


#define LIVE_AUTH_ACCESS_TOKEN              @"access_token"
#define LIVE_AUTH_AUTHENTICATION_TOKEN      @"authentication_token"
#define LIVE_AUTH_CODE                      @"code"
#define LIVE_AUTH_CLIENTID                  @"client_id"
#define LIVE_AUTH_DISPLAY                   @"display"
#define LIVE_AUTH_GRANT_TYPE                @"grant_type"
#define LIVE_AUTH_GRANT_TYPE_AUTHCODE       @"authorization_code"
#define LIVE_AUTH_LOCALE                    @"locale"
#define LIVE_AUTH_REDIRECT_URI              @"redirect_uri"
#define LIVE_AUTH_REFRESH_TOKEN             @"refresh_token"
#define LIVE_AUTH_RESPONSE_TYPE             @"response_type"
#define LIVE_AUTH_SCOPE                     @"scope"
#define LIVE_AUTH_EXPIRES_IN                @"expires_in"


#define LIVE_USER_ACCESS_TOKEN              @"LiveAccessToken"
#define LIVE_USER_INIT                      @"LiveUserInit"



#define LIVE_AUTH_POST_CONTENT_TYPE         @"application/x-www-form-urlencoded;charset=UTF-8"
#define LIVE_API_HEADER_CONTENTTYPE_JSON    @"application/json;charset=UTF-8"

#define LIVE_NOTE_FOLDER                    @"我的记事本"


#define LIVERequestFailed                 @"RequestFailed"
#define LIVERequestDataFinished           @"RequestDataFinished"

typedef enum{
    LIVE_GET_AUTH_CODE,   //get code
    LIVE_RETRIEVE_TOKEN,  //刷新token
    LIVE_QUERY_QUOTA,
    LIVE_GET_USER,
    LIVE_GET_HOME,
    LIVE_GET_FILES,
    LIVE_CREATE_FOLDER,
    LIVE_UPLOAD_FILE,
    LIVE_DOWNLOAD_FILE,
    LIVE_GET_ALLFILES,
}LIVERequestType;

@class ASINetworkQueue;
@class LiveConnSession;


@protocol LiveAuthRequestDelegate <NSObject>

@optional
-(void)didGetUserInfo;
-(void)didGetAllFiles:(NSDictionary*)aDict;


-(void)didGetDataFalied:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;
-(void)didGetDataFinished:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;


@end

@interface LiveAuthRequest : NSObject
{
    ASINetworkQueue         *requestQueue;
    
    NSString                *authCode;
    NSString                *authToken;
    
    NSString                *accessToken;
    
    __unsafe_unretained     id<LiveAuthRequestDelegate>     delegate;
}

@property (nonatomic,strong)ASINetworkQueue             *requestQueue;
@property (nonatomic,assign)id<LiveAuthRequestDelegate> delegate;
@property (nonatomic,strong)NSString                    *authCode;
@property (nonatomic,strong)NSString                    *authToken;
@property (nonatomic,strong)NSString                    *accessToken;

-(id)initWithDelegate:(id)aDelegate;

-(BOOL)isRunning;
-(void)start;
-(void)pause;
-(void)resume;
-(void)cancel;

-(NSURL*)getAuthCodeUrl;
-(NSURL*)getRetrieveTokenUrl;
-(void)retrieveToken;
-(void)refreshToken;

//aMethod 为文件路径
-(void)getData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;

-(void)queryQuota;
-(void)getUser;
-(void)getHome;
-(void)getAllFiles:(NSString*)aUrl;
-(void)uploadFile:(NSString*)aFilePath fileName:(NSString*)aFileName;
-(void)updateFile:(NSString*)aFileId path:(NSString*)aFilePath fileName:(NSString*)aFileName;
-(void)downloadFile:(NSString*)aId fileName:(NSString*)aFileName userInfo:(NSDictionary*)aUserInfo;

@end
