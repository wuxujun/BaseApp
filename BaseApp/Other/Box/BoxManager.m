//
//  BoxManager.m
//  WBMuster
//
//  Created by xujun wu on 12-11-9.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "BoxManager.h"

static BoxManager *instance=nil;

@implementation BoxManager
@synthesize boxRequest;
-(id)init
{
    self=[super init];
    if (self) {
        boxRequest=[[BoxRequest alloc]initWithDelegate:self];
        [boxRequest start];
    }
    return self;
}

+(BoxManager*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[BoxManager alloc]init];
        }
    }
    return instance;
}

-(NSURL*)getOAuthCodeUrl:(NSString*)ticket
{
    return [boxRequest getOAuthCodeUrl:ticket];
}

-(void)getTicket
{
    [boxRequest getTicket];
}

-(void)getAuthToken
{
    [boxRequest getAuthToken];
}
-(void)didGetTicket:(NSString *)aTicket
{
    NSNotification *notification=[NSNotification notificationWithName:BOXRequestTicketFinished object:aTicket];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

-(void)getAllFiles
{
    [boxRequest getAllFiles];
}
-(void)didGetUserInfo
{
    
}

-(void)getData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [boxRequest getData:aMethod params:aParams userInfo:aUserInfo];
}

-(void)postData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [boxRequest  postData:aMethod params:aParams userInfo:aUserInfo];
}


-(void)didGetDataFalied:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification=[NSNotification notificationWithName:BOXRequestFailed object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter]postNotification:notification];
}

-(void)didGetDataFinished:(NSDictionary *)aDict userInfo:(NSDictionary *)aUserInfo
{
    NSNotification *notification=[NSNotification notificationWithName:BOXRequestDataFinished object:aDict userInfo:aUserInfo];
    [[NSNotificationCenter defaultCenter]postNotification:notification];

}


@end
