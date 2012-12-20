//
//  BDRequest.h
//  BaseApp
//
//  Created by xujun wu on 12-11-26.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BD_FOLDER_NAME      @"/apps/微记"
#define BD_APP_KEY         @"DjjGfbiShQv7auE8G4bgGKEB"
#define BD_APP_SECRET      @"7cLIbE5jAjxk4liENu8kU7otomsVGytZ"
#define BD_API_AUTHORIZE        @"https://openapi.baidu.com/oauth/2.0/authorize"
#define BD_API_ACCESS_TOKEN     @"https://openapi.baidu.com/oauth/2.0/token"

#define BD_API_DOMAIN           @"https://pcs.baidu.com/rest/2.0/pcs"

#define BD_USER_INFO_REQUEST_TYPE       @"BDRequestType"
#define BD_USER_STORE_ACCESS_TOKEN      @"BDAccessToken"
#define BD_USER_STORE_EXPIRATION_DATE   @"BDExpirationDate"
#define BD_USER_STORE_SESSION_KEY       @"BDSessionKey"
#define BD_USER_STORE_SESSION_SECRET    @"BDSessionSecret"


#define BD_USER_SPACE_AMOUNT            @"NetbankQuota"
#define BD_USER_SPACE_USED              @"NetbankAvailable"

#define BD_DEFAULT_FOLDER_ID            @"BDDefaultFolderID"
#define BD_DEFAULT_FOLDER_PATH          @"BDDefaultFolderPath"

#define BD_USER_STORE_USER_ID           @"BDUserId"
#define BD_USER_INIT                    @"BDUserInit"

#define BDRequestFailed                 @"RequestFailed"
#define BDRequestDataFinished           @"RequestDataFinished"

typedef enum {
    BDGetOAuthCode=0,
    BDGetOAuthToken,
    BDGetRefreshToken,
    BDGetUserQuota,
    BDGetAllFiles,
    BDCreateFolder,
    BDUploadFile,
    BDDownloadFile,
    BDDeleteFile,
}BDRequestType;

@class ASINetworkQueue;

@protocol BDRequestDelegate <NSObject>


@optional

-(void)didGetUserInfo;

-(void)didGetDataFalied:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;
-(void)didGetDataFinished:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;

@end

@interface BDRequest : NSObject
{
    ASINetworkQueue         *requestQueue;
    __unsafe_unretained id<BDRequestDelegate>           delegate;

}

@property (nonatomic,strong)    ASINetworkQueue         *requestQueue;
@property (nonatomic,assign)id<BDRequestDelegate>           delegate;

-(id)initWithDelegate:(id<BDRequestDelegate>)aDelegate;


-(BOOL)isRunning;
-(void)start;
-(void)pause;
-(void)resume;
-(void)cancel;

-(NSURL*)getOAuthCodeUrl;

-(void)createDefaultFolder;

-(void)upload:(NSString *)aFilePath fileName:(NSString *)aFileName;
-(void)updateFile:(NSString*)aFilePath fileName:(NSString*)aFileName oldFile:(NSString *)aOldFile;


-(void)getData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;


@end
