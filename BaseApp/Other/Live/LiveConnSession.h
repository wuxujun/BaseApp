//
//  LiveConnSession.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-30.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveConnSession : NSObject

@property (nonatomic,readonly)NSString  *accessToken;
@property (nonatomic,readonly)NSString  *authenticationToken;
@property (nonatomic,readonly)NSString  *refreshToken;
@property (nonatomic,readonly)NSArray  *scopes;
@property (nonatomic, readonly) NSDate *expires;

- (id) initWithAccessToken:(NSString *)accessToken
       authenticationToken:(NSString *)authenticationToken
              refreshToken:(NSString *)refreshToken
                    scopes:(NSArray *)scopes
                   expires:(NSDate *)expires;


@end
