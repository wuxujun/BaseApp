//
//  LiveConnSession.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-30.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "LiveConnSession.h"

@implementation LiveConnSession
@synthesize accessToken=_accessToken,authenticationToken=_authenticationToken,refreshToken=_refreshToken,scopes=_scopes,expires=_expires;

-(id)initWithAccessToken:(NSString *)accessToken authenticationToken:(NSString *)authenticationToken refreshToken:(NSString *)refreshToken scopes:(NSArray *)scopes expires:(NSDate *)expires
{
    self=[super init];
    if (self) {
        _accessToken=accessToken;
        _authenticationToken=authenticationToken;
        _refreshToken=refreshToken;
        _scopes=scopes;
        _expires=expires;
        
    }
    return self;
}
@end
