//
//  VDiskManager.h
//  BaseApp
//
//  Created by xujun wu on 12-12-4.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDiskRequest.h"

@interface VDiskManager : NSObject<VDiskRequestDelegate>
{
    VDiskRequest                *vdiskRequest;
}
@property (nonatomic,strong)VDiskRequest        *vdiskRequest;

+(VDiskManager*)getInstance;

-(void)getToken:(NSString*)uId pwd:(NSString*)aPwd;

-(void)createDefaultFolder;
-(void)upload:(NSString *)aFilePath fileName:(NSString *)aFileName;

-(void)getData:(NSString*)aUrl params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSString*)aUrl params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;

@end
