//
//  RequestManager.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-27.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthRequest.h"


#define RequestOAuthToken @"RequestOAuthToken"
#define RequestOAuthAccessToken @"RequestOAuthAccessToken"

@interface RequestManager : NSObject<OAuthRequestDelegate>{
    OAuthRequest        *oauthRequest;
    
    NSString            *tokenSecret;
}

@property (nonatomic,strong)OAuthRequest        *oauthRequest;
@property (nonatomic,strong)NSString            *tokenSecret;

+(RequestManager*)getInstance;

-(void)getOAuthToken:(enum OAuthId)oauthId;

-(void)getOAuthAccessToken:(enum OAuthId)oauthId token:(NSString*)aToken verifier:(NSString *)aVerifier;

@end
