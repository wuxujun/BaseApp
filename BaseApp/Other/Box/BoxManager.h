//
//  BoxManager.h
//  WBMuster
//
//  Created by xujun wu on 12-11-9.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoxRequest.h"

#define BOXRequestTicketFinished          @"BoxRequestTicketFinished"

@interface BoxManager : NSObject<BoxRequestDelegate>
{
    BoxRequest          *boxRequest;
}
@property (nonatomic,strong)BoxRequest          *boxRequest;

+(BoxManager*)getInstance;

-(void)getTicket;
-(void)getAuthToken;
-(NSURL*)getOAuthCodeUrl:(NSString*)ticket;


-(void)getAllFiles;

-(void)getData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;
-(void)postData:(NSString*)aMethod params:(NSMutableDictionary*)aParams userInfo:(NSDictionary*)aUserInfo;


@end
