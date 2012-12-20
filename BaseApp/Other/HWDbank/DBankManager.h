//
//  DBankManager.h
//  SAnalysis
//
//  Created by xujun wu on 12-11-8.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBankRequest.h"

#define HWRequestOAuthToken @"HWRequestOAuthToken"
#define HWRequestOAuthAccessToken @"HWRequestOAuthAccessToken"

@interface DBankManager : NSObject<DBankRequestDelegate>
{
    DBankRequest            *dbankRequest;
    NSString            *tokenSecret;
}
@property (nonatomic,strong)DBankRequest        *dbankRequest;
@property (nonatomic,strong)NSString            *tokenSecret;

+(DBankManager*)getInstance;

-(void)getOAuthToken;

-(void)getOAuthAccessToken:(NSString*)aToken verifier:(NSString *)aVerifier;

-(void)getUserInfo;
-(void)getVFSlsDir:(NSString*)folderName;
-(void)createDefaultFolder;

-(void)getData:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;


-(void)uploadFile:(NSString*)aFilePath fileName:(NSString*)aFileName;

-(void)downloadFile:(NSString*)aUrl fileName:(NSString *)aFileName;
-(void)updateFile:(NSString*)aFilePath fileName:(NSString*)aFileName oldFile:(NSString *)aOldFile;

@end
