//
//  OAuthKey.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-26.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthKey : NSObject

@property (nonatomic,strong) NSString            *consumerKey;
@property (nonatomic,strong) NSString            *consumerSecret;
@property (nonatomic,strong) NSString            *tokenKey;
@property (nonatomic,strong) NSString            *tokenSecret;
@property (nonatomic,strong) NSString            *verify;
@property (nonatomic,strong) NSString            *callbackUrl;


@end
