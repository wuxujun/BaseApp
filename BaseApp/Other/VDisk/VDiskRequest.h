//
//  VDiskRequest.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-27.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  APP_KEY                    @"2600941871"
#define  APP_SECRET                 @"f8ab4a1835339e664839c236a4a509c9"

#define  VDISK_URL_GET_TOKEN              @"http://openapi.vdisk.me/?m=auth&a=get_token"
#define  VDISK_URL_KEEP_TOKEN             @"http://openapi.vdisk.me/?m=user&a=keep_token"
#define  VDISK_URL_UPLOAD_FILE            @"http://openapi.vdisk.me/?m=file&a=upload_file"
#define  VDISK_URL_UPLOAD_SHARE_FILE      @"http://openapi.vdisk.me/?m=file&a=upload_share_file"
#define  VDISK_URL_CREATE_DIR             @"http://openapi.vdisk.me/?m=dir&a=create_dir"
#define  VDISK_URL_GET_LIST               @"http://openapi.vdisk.me/?m=dir&a=get_list"
#define  VDISK_URL_GET_QUOTA              @"http://openapi.vdisk.me/?m=file&a=get_quota"
#define  VDISK_URL_UPLOAD_WITH_SHA1       @"http://openapi.vdisk.me/?m=file&a=upload_with_sha1"
#define  VDISK_URL_GET_FILE_INFO          @"http://openapi.vdisk.me/?m=file&a=get_file_info"
#define  VDISK_URL_DELETE_DIR             @"http://openapi.vdisk.me/?m=dir&a=delete_dir"
#define  VDISK_URL_DELETE_FILE            @"http://openapi.vdisk.me/?m=file&a=delete_file"
#define  VDISK_URL_COPY_FILE              @"http://openapi.vdisk.me/?m=file&a=copy_file"
#define  VDISK_URL_MOVE_FILE              @"http://openapi.vdisk.me/?m=file&a=move_file"
#define  VDISK_URL_RENAME_FILE            @"http://openapi.vdisk.me/?m=file&a=rename_file"
#define  VDISK_URL_RENAME_DIR             @"http://openapi.vdisk.me/?m=dir&a=rename_dir"
#define  VDISK_URL_MOVE_DIR               @"http://openapi.vdisk.me/?m=dir&a=move_dir"
#define  VDISK_URL_SHARE_FILE             @"http://openapi.vdisk.me/?m=file&a=share_file"
#define  VDISK_URL_CANCEL_SHARE_FILE      @"http://openapi.vdisk.me/?m=file&a=cancel_share_file"
#define  VDISK_URL_RECYCLE_GET_LIST       @"http://openapi.vdisk.me/?m=recycle&a=get_list"
#define  VDISK_URL_TRUNCATE_RECYCLE_GET   @"http://openapi.vdisk.me/?m=recycle&a=truncate_recycle"
#define  VDISK_URL_RECYCLE_DELETE_FILE    @"http://openapi.vdisk.me/?m=recycle&a=delete_file"
#define  VDISK_URL_RECYCLE_DELETE_DIR     @"http://openapi.vdisk.me/?m=recycle&a=delete_dir"
#define  VDISK_URL_RECYCLE_RESTORE_FILE   @"http://openapi.vdisk.me/?m=recycle&a=restore_file"
#define  VDISK_URL_RECYCLE_RESTORE_DIR    @"http://openapi.vdisk.me/?m=recycle&a=restore_dir"
#define  VDISK_URL_GET_DIRID_WITH_PATH    @"http://openapi.vdisk.me/?m=dir&a=get_dirid_with_path"
#define  VDISK_URL_EMAIL_SHARE_FILE       @"http://openapi.vdisk.me/?m=file&a=email_share_file"


#define  TokenRequestSuccess            @"TokenRequestSuccess"

#define VDISK_USER_SPACE_AMOUNT         @"NetbankQuota"
#define VDISK_USER_SPACE_USED           @"NetbankAvailable"

#define VDISK_USER_STORE_ACCESS_TOKEN   @"VDiskAccessToken"
#define VDISK_USER_INIT                 @"VDiskUserInit"
#define VDISK_USER_STORE_USERNAME       @"VDiskUserName"
#define VDISK_USER_STORE_PASSWORD       @"VDiskUserPassword"
#define VDISK_USER_DEFAULT_FOLDER_ID    @"VDiskUserFolderId"


#define  VDiskRequestDataFinished       @"RequestDataFinished"
#define  VDiskRequestFailed             @"RequestFailed"

typedef enum{
    VD_GET_TOKEN=0,
    VD_KEEP_TOKEN,
    VD_GET_ROOT_LIST,
    VD_GET_LIST,
    VD_CREATE_DIR,
    VD_GET_FILE_INFO,
    VD_VFS_COPYFILE,
    VD_VFS_RMFILE,
    VD_UPLOAD_FILE,
    VD_DOWNLOAD_FILE,
}VDiskRequestType;

#define  VDISK_USER_REQUEST_TYPE     @"VDiskRequestType"


@class ASINetworkQueue;

@protocol VDiskRequestDelegate <NSObject>

@optional

-(void)didGetDataFalied:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;
-(void)didGetDataFinished:(NSDictionary*)aDict userInfo:(NSDictionary*)aUserInfo;

@end


@interface VDiskRequest : NSObject
{
    ASINetworkQueue         *requestQueue;
    
    NSString                *token;
    
    __unsafe_unretained id<VDiskRequestDelegate>        delegate;
}
@property (nonatomic,assign)id<VDiskRequestDelegate>    delegate;
@property (nonatomic,strong)ASINetworkQueue     *requestQueue;
@property (nonatomic,strong)NSString            *token;

-(id)initWithDelegage:(id<VDiskRequestDelegate>)aDelegate;

-(BOOL)isRunning;
-(void)start;
-(void)pause;
-(void)resume;
-(void)cancel;

-(void)getToken:(NSString*)uId pwd:(NSString*)aPwd;
-(void)keepToken;
-(void)getList;

-(void)getFileInfo:(NSString*)fid pageView:(NSString*)aPageView;
-(void)createDefaultFolder;

-(void)upload:(NSString *)aFilePath fileName:(NSString *)aFileName;

-(void)getData:(NSString*)aUrl params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSString*)aUrl params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;

@end

