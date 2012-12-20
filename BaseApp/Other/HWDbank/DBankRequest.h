//
//  DBankRequest.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-27.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    HW_OAUTH_CODE=0,
    HW_OAUTH_ACCESS_TOKEN,
    HW_USER_GETINFO,
    HW_USER_UPDATE,
    HW_USER_GETACCOUNTS,
    HW_VFS_LSDIR_ROOT,
    HW_VFS_LSDIR,
    HW_VFS_MKDIR_DEF,
    HW_VFS_MKFILE,
    HW_VFS_UPLOAD_FILE,
    HW_VFS_COPYFILE,
    HW_VFS_RMFILE,
    HW_VFS_UPAUTH,
    HW_VFS_DOWNLOAD,
    HW_VFS_DELFILE,
}HWRequestType;

#define  HW_APP_KEY             @"55942"
#define  HW_APP_SECRET          @"72P3oTsbFPBRnXkfOUPFTgMCEvacvdz3"


#define  HW_API_REQUEST_TOKEN     @"http://login.dbank.com/oauth1/request_token"
#define  HW_API_AUTHORIZE         @"http://login.dbank.com/oauth1/authorize"
#define  HW_API_ACCESS_TOKEN      @"http://login.dbank.com/oauth1/access_token"

#define  HW_NSP_APP               @"nsp_app"
#define  HW_NSP_SID               @"nsp_sid"
#define  HW_NSP_KEY               @"nsp_key"
#define  HW_NSP_SVC               @"nsp_svc"
#define  HW_NSP_TS                @"nsp_ts"
#define  HW_NSP_PARAMS            @"nsp_params"
#define  HW_NSP_FMT               @"nsp_fmt"
#define  HW_NSP_TSTR              @"nsp_tstr"

#define  HW_NSP_URL               @"http://api.dbank.com/rest.php"

#define  HW_USER_AUTH_TOKEN            @"DBankHW_OAuthToken"
#define  HW_USER_AUTH_TOKEN_SECRET     @"DBankHW_OAuthTokenSecret"
#define  HW_USER_INIT             @"HWUserInit"

#define  HW_USER_REQUEST_TYPE     @"HWRequestType"

#define HWRequestFailed                 @"RequestFailed"
#define HWRequestDataFinished           @"RequestDataFinished"


@class ASINetworkQueue;
@protocol DBankRequestDelegate;

@interface DBankRequest : NSObject
{
    ASINetworkQueue         *requestQueue;
    
    __unsafe_unretained id<DBankRequestDelegate>    delegate;
    NSString            *token;
    NSString            *tokenSecret;
}
@property (nonatomic,assign)id<DBankRequestDelegate>    delegate;
@property (nonatomic,strong)ASINetworkQueue     *requestQueue;

-(id)initWithDelegate:(id)aDelegate;

-(BOOL)isRunning;
-(void)start;
-(void)pause;
-(void)resume;
-(void)cancel;

#pragma mark - Auth
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

-(void)getOAuthToken;
-(void)getOAuthAccessToken:(NSString*)aToken secret:(NSString*)aSecret verifier:(NSString*)aVerifier;


#pragma mark - 网盘
-(void)getUserInfo;
-(void)getUserAccounts;
-(void)getVFSlsDir:(NSString*)folderName;
-(void)createDefaultFolder;

-(void)getData:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;


-(void)uploadFile:(NSString*)aFilePath fileName:(NSString*)aFileName;
-(void)downloadFile:(NSString*)aUrl fileName:(NSString *)aFileName;
//更新，先删除后上传
-(void)updateFile:(NSString*)aFilePath fileName:(NSString*)aFileName oldFile:(NSString*)aOldFile;

@end


@protocol DBankRequestDelegate <NSObject>

@optional

-(void)getOAuthTokenSuccess:(DBankRequest*)request result:(NSDictionary*)aResult;
-(void)getOauthTokenFailed:(DBankRequest*)request;
-(void)getAccessTokenSuccess:(DBankRequest*)request result:(NSDictionary*)aResult;
-(void)getAccessTokenFailed:(DBankRequest *)request;


-(void)didGetDataFalied:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;
-(void)didGetDataFinished:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;

-(void)didGetUserInfo;
-(void)didGetVFSlsDir:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;


@end