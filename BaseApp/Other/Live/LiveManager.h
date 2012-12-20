//
//  LiveManager.h
//  BaseApp
//
//  Created by xujun wu on 12-11-15.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveAuthRequest.h"

@interface LiveManager : NSObject<LiveAuthRequestDelegate>
{
    LiveAuthRequest             *liveRequest;
}
@property (nonatomic,strong)LiveAuthRequest *liveRequest;


+(LiveManager*)getInstance;

-(NSURL*)getAuthCodeUrl;

-(void)retrieveToken;
-(void)getHome;

-(void)getData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo;
-(void)postData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo;


-(void)getUser;
-(void)getAllFiles:(NSString*)aUrl;
-(void)uploadFile:(NSString*)aFilePath fileName:(NSString*)aFileName;
-(void)updateFile:(NSString*)aFileId path:(NSString*)aFilePath fileName:(NSString*)aFileName;
-(void)downloadFile:(NSString*)aId fileName:(NSString*)aFileName userInfo:(NSDictionary*)aUserInfo;


@end
