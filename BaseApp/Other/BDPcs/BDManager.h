//
//  BDManager.h
//  BaseApp
//
//  Created by xujun wu on 12-11-26.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDRequest.h"

@interface BDManager : NSObject<BDRequestDelegate>
{
    BDRequest           *bdRequest;
}
@property (nonatomic,strong)BDRequest       *bdRequest;

+(BDManager*)getInstance;

-(NSURL*)getOAuthCodeUrl;

-(void)createDefaultFolder;
-(void)upload:(NSString *)aFilePath fileName:(NSString *)aFileName;
-(void)updateFile:(NSString*)aFilePath fileName:(NSString*)aFileName oldFile:(NSString *)aOldFile;


-(void)getData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;


@end
