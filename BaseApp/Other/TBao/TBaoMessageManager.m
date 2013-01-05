//
//  TBaoMessageManager.m
//  SAnalysis
//
//  Created by xujun wu on 12-11-2.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "TBaoMessageManager.h"

static TBaoMessageManager       *instance=nil;

@implementation TBaoMessageManager
@synthesize tbRequest;

#pragma mark - init

-(id)init
{
    self=[super init];
    if (self) {
        tbRequest=[[TBaoRequest alloc]init];
        [tbRequest start];
    }
    return self;
}

+(TBaoMessageManager*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[TBaoMessageManager alloc]init];
        }
    }
    return instance;
}

- (BOOL)isNeedToRefreshTheToken
{
    NSDate *expirationDate = [[NSUserDefaults standardUserDefaults]objectForKey:TB_STORE_EXPIRATION_DATE];
    if (expirationDate == nil)  return YES;
    
    BOOL boolValue1 = !(NSOrderedDescending == [expirationDate compare:[NSDate date]]);
    BOOL boolValue2 = (expirationDate != nil);
    return (boolValue1 && boolValue2);
}

#pragma mark - Http Methods
//留给webview用
-(NSURL*)getOAuthCodeUrl
{
    return [tbRequest getOAuthCodeUrl];
}


#pragma mark - 
#pragma mark TBaoRequestDelegate
-(void)didGetUserInfo:(NSString *)userId
{

}

@end
