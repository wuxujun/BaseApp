//
//  OAuthRequest.m
//  SAnalysis
//  OAuth 1.0  Request manager
//  Created by xujun wu on 12-10-26.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "OAuthRequest.h"
#import <stdlib.h>
#import <CommonCrypto/CommonHMAC.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSStringAdditions.h"
#import "NSDataAdditions.h"
#import "NSURLAdditions.h"
#import "SBJson.h"

extern BOOL g_isSohuSharingPicture;

#pragma mark -
#pragma mark Constants

#define OAuthVersion @"1.0"
#define OAuthParameterPrefix @"oauth_"
#define OAuthConsumerKeyKey @"oauth_consumer_key"
#define OAuthCallbackKey @"oauth_callback"
#define OAuthVersionKey @"oauth_version"
#define OAuthSignatureMethodKey @"oauth_signature_method"
#define OAuthSignatureKey @"oauth_signature"
#define OAuthTimestampKey @"oauth_timestamp"
#define OAuthNonceKey @"oauth_nonce"
#define OAuthTokenKey @"oauth_token"
#define oAauthVerifier @"oauth_verifier"
#define OAuthTokenSecretKey @"oauth_token_secret"
#define HMACSHA1SignatureType @"HMAC-SHA1"

#pragma mark -
#pragma mark Static methods

static NSInteger SortParameter(NSString *key1, NSString *key2, void *context) {
	NSComparisonResult r = [key1 compare:key2];
	if(r == NSOrderedSame) { // compare by value in this case
		NSDictionary *dict = ( NSDictionary *)CFBridgingRelease(context);
		NSString *value1 = [dict objectForKey:key1];
		NSString *value2 = [dict objectForKey:key2];
		return [value1 compare:value2];
	}
	return r;
}

static NSData *HMAC_SHA1(NSString *data, NSString *key) {
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [data UTF8String], [data length], buf);
	return [NSData dataWithBytes:buf length:CC_SHA1_DIGEST_LENGTH];
}


@implementation OAuthRequest
@synthesize requestQueue;
@synthesize delegate;

-(id)initWithDelegate:(id)aDelegate
{
    self=[super init];
    if (self) {
        requestQueue=[[ASINetworkQueue alloc]init];
        [requestQueue setDelegate:self];
        [requestQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [requestQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        [requestQueue setRequestWillRedirectSelector:@selector(request:willRedirectToURL:)];
        [requestQueue setShouldCancelAllRequestsOnFailure:NO];
        [requestQueue setShowAccurateProgress:YES];
        self.delegate=aDelegate;
    }
    return self;
}


-(NSString*)getOAuthType:(enum OAuthId)oauthId suffix:(NSString*)aSuffix
{
    NSString    *result=nil;
    switch (oauthId) {
        case DBANK_HW:
            result=[NSString stringWithFormat:@"DBankHW_%@",aSuffix];
            break;
        case DROPBOX:
            result=[NSString stringWithFormat:@"Dropbox_%@",aSuffix];
            break;
        default:
            
            break;
    }
    return result;
}

-(NSString*)getOAuthUrl:(enum OAuthId)oauthId suffix:(NSString*)aSuffix
{
    NSString    *result=nil;
    switch (oauthId) {
        case DBANK_HW:
            result=[NSString stringWithFormat:@"http://login.dbank.com/oauth1/%@",aSuffix];
            break;
        case BOX:
            result=[NSString stringWithFormat:@"%@",aSuffix];
            break;
        case DROPBOX:
            result=[NSString stringWithFormat:@"https://api.dropbox.com/1/oauth/%@",aSuffix];
            break;
        default:
            break;
    }
    return result;
}

//type  0 AppKey   1  APP SECRET
-(NSString*)getOauthAppKeyOrSecret:(enum OAuthId)oauthId type:(int)aType
{
    NSString *result=nil;
    if (aType==0) {
        switch (oauthId) {
            case DBANK_HW:
                result=@"55942";//微记
                break;
            case BOX: //app key
                result=@"amqd9wtcfos3hykertti0fgi5nkdd40p";
                break;
            case DROPBOX:
                result=@"kmncmtdrpql5hiu";
                break;
            default:
                break;
        }
    }else{
        switch (oauthId) {
            case DBANK_HW:
                result=@"72P3oTsbFPBRnXkfOUPFTgMCEvacvdz3";
                break;
            case BOX:
                result=@"";
                break;
            case DROPBOX://app secret
                result=@"1lt8gk16y2e22dq";
                break;
            default:
                break;
        }
    }
    return result;
}

#pragma mark - 
#pragma mark Private methos

- (NSString *)normalizedRequestParameters:(NSDictionary *)aParameters {
	
	NSMutableArray *parametersArray = [NSMutableArray array];
	for (NSString *key in aParameters) {
		[parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, [aParameters valueForKey:key]]];
	}
	return [parametersArray componentsJoinedByString:@"&"];
}
#pragma mark - Generate the timestamp for the signature.
- (NSString *)generateTimeStamp {
	
	return [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
}

- (NSString *)generateNonce {
	// Just a simple implementation of a random number between 123400 and 9999999
	return [NSString stringWithFormat:@"%u", arc4random() % (9999999 - 123400) + 123400];
}
#pragma mark - Generate the signature base that is used to produce the signature

- (NSString *)generateSignatureBaseWithUrl:(NSURL *)aUrl
								httpMethod:(NSString *)aHttpMethod
								parameters:(NSDictionary *)aParameters
							 normalizedUrl:(NSString **)aNormalizedUrl
			   normalizedRequestParameters:(NSString **)aNormalizedRequestParameters {
	
	*aNormalizedUrl = nil;
	*aNormalizedRequestParameters = nil;
	
	if ([aUrl port]) {
		*aNormalizedUrl = [NSString stringWithFormat:@"%@:%@//%@%@", [aUrl scheme], [aUrl port], [aUrl host], [aUrl path]];
	} else {
		*aNormalizedUrl = [NSString stringWithFormat:@"%@://%@%@", [aUrl scheme], [aUrl host], [aUrl path]];
	}
	
	NSMutableArray *parametersArray = [NSMutableArray array];
    //NSMutableArray *parametersArray2 = [NSMutableArray array];
	NSArray *sortedKeys = [[aParameters allKeys] sortedArrayUsingFunction:SortParameter context:(__bridge void *)(aParameters)];
	for (NSString *key in sortedKeys) {
		NSString *value = [aParameters valueForKey:key];
		[parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, [value URLEncodedString]]];
        //[parametersArray2 addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
	}
	*aNormalizedRequestParameters = [parametersArray componentsJoinedByString:@"&"];
	//NSString *parametersString = [parametersArray2 componentsJoinedByString:@"&"];
    
	NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@",
									 aHttpMethod, [*aNormalizedUrl URLEncodedString], [*aNormalizedRequestParameters URLEncodedString]];
    
	return signatureBaseString;
}

//Generates a signature using the HMAC-SHA1 algorithm
- (NSString *)generateSignatureWithUrl:(NSURL *)aUrl
						 customeSecret:(NSString *)aConsumerSecret
						   tokenSecret:(NSString *)aTokenSecret
							httpMethod:(NSString *)aHttpMethod
							parameters:(NSDictionary *)aPatameters
						 normalizedUrl:(NSString **)aNormalizedUrl
		   normalizedRequestParameters:(NSString **)aNormalizedRequestParameters {
	
	NSString *signatureBase = [self generateSignatureBaseWithUrl:aUrl
													  httpMethod:aHttpMethod
													  parameters:aPatameters
												   normalizedUrl:aNormalizedUrl
									 normalizedRequestParameters: aNormalizedRequestParameters];
	NSString *signatureKey = [NSString stringWithFormat:@"%@&%@", [aConsumerSecret URLEncodedString], aTokenSecret ? [aTokenSecret URLEncodedString] : @""];
	NSData *signature = HMAC_SHA1(signatureBase, signatureKey);
	NSString *base64Signature = [signature base64Encoding];
	return base64Signature;
}

#pragma mark - OAuth instance methods

-(NSString*)getOAuthUrl:(NSString *)aUrl httpMethod:(NSString *)aHttpMethod consumerKey:(NSString *)aConsumerKey consumerSecret:(NSString *)aConsumerSecret tokenKey:(NSString *)aTokenKey tokenSecret:(NSString *)aTokenSecret verify:(NSString *)aVerify callbackUrl:(NSString *)aCallbackUrl parameters:(NSDictionary *)aParameters queryString:(NSString *__autoreleasing *)aQueryString
{
    NSString *parameterString = [self normalizedRequestParameters:aParameters];
	NSMutableString *urlWithParameter = [[NSMutableString alloc] initWithString:aUrl];
	if (parameterString && ![parameterString isEqualToString:@""]) {
		[urlWithParameter appendFormat:@"?%@", parameterString];
	}
	
	NSString *encodedUrl = [urlWithParameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL smartURLForString:encodedUrl];
	NSString *nonce = [self generateNonce];
	NSString *timeStamp = [self generateTimeStamp];
	
	NSMutableDictionary *allParameters;
	if (aParameters) {
		allParameters = [aParameters mutableCopy];
	} else {
		allParameters = [NSMutableDictionary dictionary];
	}
    
	[allParameters setObject:nonce forKey:OAuthNonceKey];
	[allParameters setObject:timeStamp forKey:OAuthTimestampKey];
	[allParameters setObject:OAuthVersion forKey:OAuthVersionKey];
	[allParameters setObject:HMACSHA1SignatureType forKey:OAuthSignatureMethodKey];
	[allParameters setObject:aConsumerKey forKey:OAuthConsumerKeyKey];
	if (aTokenKey) {
		[allParameters setObject:aTokenKey forKey:OAuthTokenKey];
	}
	if (aVerify) {
		[allParameters setObject:aVerify forKey:oAauthVerifier];
	}
	if (aCallbackUrl) {
		[allParameters setObject:aCallbackUrl forKey:OAuthCallbackKey];
	}
	
	NSString *normalizedURL = nil;
	NSMutableString *queryString = nil;
	NSString *signature = [self generateSignatureWithUrl:url
										   customeSecret:aConsumerSecret
											 tokenSecret:aTokenSecret
											  httpMethod:aHttpMethod
											  parameters:allParameters
										   normalizedUrl:&normalizedURL
							 normalizedRequestParameters:&queryString];
	[queryString appendFormat:@"&oauth_signature=%@", [signature URLEncodedString]];
	*aQueryString = [[NSString alloc] initWithString:queryString];
	
	return normalizedURL;
}

- (void)setGetUserInfo:(ASIHTTPRequest *)request withRequestType:(RequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:USER_REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(RequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:USER_REQUEST_TYPE];
    [request setUserInfo:dict];
}

-(void)getOAuthToken:(enum OAuthId)oauthId
{
    NSString *hMothed=@"GET";
    if (oauthId==DROPBOX) {
        hMothed=@"POST";
    }
    
    NSString *queryString = nil;
	NSString *oauthUrl = [self	getOAuthUrl:[self getOAuthUrl:oauthId suffix:@"request_token"]
								 httpMethod:hMothed
								consumerKey:[self getOauthAppKeyOrSecret:oauthId type:0]
							 consumerSecret:[self getOauthAppKeyOrSecret:oauthId type:1]
								   tokenKey:nil
								tokenSecret:nil
									 verify:nil
								callbackUrl:@"http://xujun"
								 parameters:nil
								queryString:&queryString];
    NSURL    *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",oauthUrl,queryString]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:GET_OAUTH_CODE];
    [requestQueue addOperation:request];
}

-(void)getOAuthAccessToken:(enum OAuthId)oauthId token:(NSString *)aToken secret:(NSString *)aSecret verifier:(NSString *)aVerifier
{
    NSString *queryString = nil;
	NSString *oauthUrl = [self	getOAuthUrl:[self getOAuthUrl:oauthId suffix:@"access_token"]
                                httpMethod:@"GET"
                               consumerKey:[self getOauthAppKeyOrSecret:oauthId type:0]
                            consumerSecret:[self getOauthAppKeyOrSecret:oauthId type:1]
                                  tokenKey:aToken
                               tokenSecret:aSecret
                                    verify:aVerifier
                               callbackUrl:@"http://xujun"
                                parameters:nil
                               queryString:&queryString];
    NSURL    *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",oauthUrl,queryString]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:GET_OAUTH_ACCESS_TOKEN];
    [requestQueue addOperation:request];
}

#pragma mark - Operate queue
- (BOOL)isRunning
{
	return ![requestQueue isSuspended];
}

- (void)start
{
	if( [requestQueue isSuspended] )
		[requestQueue go];
}

- (void)pause
{
	[requestQueue setSuspended:YES];
}

- (void)resume
{
	[requestQueue setSuspended:NO];
}

- (void)cancel
{
	[requestQueue cancelAllOperations];
}

#pragma mark - ASINetworkQueueDelegate
//失败
- (void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"requestFailed:%@,%@,",request.responseString,[request.error localizedDescription]);
}

//成功
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *userInformation = [request userInfo];
    RequestType requestType = [[userInformation objectForKey:USER_REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    NSLog(@"responseString = %@",responseString);
    
    //认证失败
    //{"error":"auth faild!","error_code":21301,"request":"/2/statuses/home_timeline.json"}
    SBJsonParser    *parser     = [[SBJsonParser alloc] init];
    id  returnObject = [parser objectWithString:responseString];
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        NSString *errorString = [returnObject  objectForKey:@"error"];
        if (errorString != nil && ([errorString isEqualToString:@"auth faild!"] ||
                                   [errorString isEqualToString:@"expired_token"] ||
                                   [errorString isEqualToString:@"invalid_access_token"])) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NeedToReLogin object:nil];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"];
            NSLog(@"detected auth faild!");
        }
    }
    
    NSDictionary *userInfo = nil;
    NSArray *userArr = nil;
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        userInfo = (NSDictionary*)returnObject;
    }
    else if ([returnObject isKindOfClass:[NSArray class]]) {
        userArr = (NSArray*)returnObject;
    }
    else {
        return;
    }

    //获取TokenCode
    if (requestType == GET_OAUTH_CODE) {
        if ([delegate respondsToSelector:@selector(getOAuthTokenSuccess:result:)]) {
            [delegate getOAuthTokenSuccess:self result:userInfo];
        }
    }
    
    if (requestType==GET_OAUTH_ACCESS_TOKEN) {
        NSString *oauthToken=[userInfo objectForKey:@"oauth_token"];
        NSString *oauthTokenSecret=[userInfo objectForKey:@"oauth_token_secret"];
        [[NSUserDefaults standardUserDefaults]setObject:oauthToken forKey:[self getOAuthType:1 suffix:@"OAuthToken"]];
        [[NSUserDefaults standardUserDefaults]setObject:oauthTokenSecret forKey:[self getOAuthType:1 suffix:@"OAuthTokenSecret"]];
        if ([delegate respondsToSelector:@selector(getAccessTokenSuccess:result:)]) {
            [delegate getAccessTokenSuccess:self result:userInfo];
        }
    }
}

//跳转
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    NSLog(@"request will redirect");
    NSNotification *notification = [NSNotification notificationWithName:RequestFailed object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
