//
//  DBankRequest.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-27.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "DBankRequest.h"
#import <CommonCrypto/CommonHMAC.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSStringAdditions.h"
#import "NSURLAdditions.h"
#import "SBJson.h"
#import "StringUtil.h"

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

@implementation DBankRequest
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

- (void)setGetUserInfo:(ASIHTTPRequest *)request withRequestType:(HWRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:HW_USER_REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(HWRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:HW_USER_REQUEST_TYPE];
    [request setUserInfo:dict];
}


-(void)getOAuthToken
{
    NSString *hMothed=@"GET";
    NSString *queryString = nil;
	NSString *oauthUrl = [self	getOAuthUrl:HW_API_REQUEST_TOKEN
                                httpMethod:hMothed
                               consumerKey:HW_APP_KEY
                            consumerSecret:HW_APP_SECRET
                                  tokenKey:nil
                               tokenSecret:nil
                                    verify:nil
                               callbackUrl:@"http://xujun"
                                parameters:nil
                               queryString:&queryString];
    NSURL    *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",oauthUrl,queryString]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:HW_OAUTH_CODE];
    [requestQueue addOperation:request];
}

-(void)getOAuthAccessToken:(NSString *)aToken secret:(NSString *)aSecret verifier:(NSString *)aVerifier
{
    NSString *queryString = nil;
	NSString *oauthUrl = [self	getOAuthUrl:HW_API_ACCESS_TOKEN
                                httpMethod:@"GET"
                               consumerKey:HW_APP_KEY
                            consumerSecret:HW_APP_SECRET
                                  tokenKey:aToken
                               tokenSecret:aSecret
                                    verify:aVerifier
                               callbackUrl:@"http://xujun"
                                parameters:nil
                               queryString:&queryString];
    NSURL    *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",oauthUrl,queryString]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    NSLog(@"url=%@",url);
    [self setGetUserInfo:request withRequestType:HW_OAUTH_ACCESS_TOKEN];
    [requestQueue addOperation:request];
}

#pragma mark - 网盘接口
#pragma mark - getGetData
-(NSString*)getGetData:(NSMutableDictionary*)dict
{
    if (tokenSecret==nil) {
        tokenSecret=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN_SECRET];
    }
    NSString    *result=@"";
    NSString    *md5Str=tokenSecret;
    NSArray     *keys=[[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    id key,val;
    for (int i=0;i<[dict count];i++) {
        key=[keys objectAtIndex:i];
        val=[dict objectForKey:key];
        md5Str=[md5Str stringByAppendingString:key];
        md5Str=[md5Str stringByAppendingString:val];
        result=[result stringByAppendingFormat:@"%@=%@&",key,[val encodeAsURIComponent]];
    }
    result=[result stringByAppendingString:@"nsp_key"];
    result=[result stringByAppendingString:@"="];
    result=[result stringByAppendingString:[[md5Str md5Hash]uppercaseString]];
    
//    NSLog(@"request param :%@",result);
    return result;
}

-(NSString*)getNSPKey:(NSString*)sec with:(NSMutableDictionary*)aDict
{
    NSString *md5Str=[NSString stringWithString:sec];
    int count=[aDict count];
    NSArray *keys=[[aDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    id key,val;
    for (int i=0; i<count; i++) {
        key=[keys objectAtIndex:i];
        val=[aDict objectForKey:key];
        NSString *k=[NSString stringWithFormat:@"%@",key];
        NSString *v=[NSString stringWithFormat:@"%@",val];
        md5Str=[md5Str stringByAppendingString:k];
        md5Str=[md5Str stringByAppendingString:v];
    }
    return [[md5Str md5] uppercaseString];
}

-(NSData*)getPostData:(NSMutableDictionary*)dict
{
    NSString    *result=@"";
    NSArray     *keys=[[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    id key,val;
    for (int i=0;i<[dict count];i++) {
        key=[keys objectAtIndex:i];
        val=[dict objectForKey:key];
        result=[result stringByAppendingFormat:@"%@=%@",key,val];
        if ((i+1)==[dict count]) {
            
        }else{
            result=[result stringByAppendingString:@"&"];
        }
    }
    return [result dataUsingEncoding:NSUTF8StringEncoding];
}

-(void)getUserInfo
{
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    NSArray *uParam=[NSArray arrayWithObjects:@"user.username",@"product.spacecapacity",@"profile.usedspacecapacity",@"product.fileuploadsize",@"profile.dbank_avatar",@"profile.spaceextcapacity",nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"nsp_sid"];
    [dict setObject:[uParam JSONRepresentation] forKey:@"attrs"];
    [dict setObject:@"nsp.user.getInfo" forKey:@"nsp_svc"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [dict setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:dict]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"%@",requestUrl);
    [self setGetUserInfo:request withRequestType:HW_USER_GETINFO];
    [requestQueue addOperation:request];
}
-(void)getUserAccounts
{
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"nsp_sid"];
    [dict setObject:@"1" forKey:@"type"];
    [dict setObject:@"nsp.user.getAccounts" forKey:@"nsp_svc"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [dict setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:dict]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    //    NSLog(@"%@",requestUrl);
    [self setGetUserInfo:request withRequestType:HW_USER_GETINFO];
    [requestQueue addOperation:request];
}

#pragma mark getData 
-(void)getData:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [aParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN] forKey:@"nsp_sid"];
    [aParams setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [aParams setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:aParams]];
    NSLog(@"HWDbank getData url= %@",requestUrl);
     NSMutableDictionary *headers=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/x-www-form-urlencoded",@"Content-Type", nil];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    [request setRequestHeaders:headers];
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
    
}

-(void)postData:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [aParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN] forKey:@"nsp_sid"];
    [aParams setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [aParams setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@",HW_NSP_URL];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"postData:%@",requestUrl);
    [request appendPostData:[self getPostData:aParams]];
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
}


-(void)getVFSlsDir:(NSString*)folderName
{
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    NSArray *uParam=[NSArray arrayWithObjects:@"name",@"size",@"url",@"md5",@"type", @"dirCount", @"fileCount", @"dbank_systemType",@"dbank_isShared", @"createTime",@"modifyTime",nil];
//    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:@"3",@"type", nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"nsp_sid"];
    if (folderName) {
        [dict setObject:[NSString stringWithFormat:@"/Netdisk/%@",folderName] forKey:@"path"];
    }else{
        [dict setObject:@"/Netdisk" forKey:@"path"];
    }
//    [dict setObject:[dic JSONRepresentation] forKey:@"options"];
    [dict setObject:[uParam JSONRepresentation] forKey:@"fields"];
    [dict setObject:@"nsp.vfs.lsdir" forKey:@"nsp_svc"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [dict setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:dict]];
    NSMutableDictionary *headers=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/x-www-form-urlencoded",@"Content-Type", nil];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"%@",requestUrl);
    [request setRequestHeaders:headers];
    [self setGetUserInfo:request withRequestType:HW_VFS_LSDIR];
    [requestQueue addOperation:request];
}

-(void)getVFSlsDir
{
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    NSArray *uParam=[NSArray arrayWithObjects:@"name",@"size",@"url",@"md5",@"type", @"dirCount", @"fileCount", @"dbank_systemType",@"dbank_isShared", @"createTime",@"modifyTime",nil];
//    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:@"3",@"type", nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"nsp_sid"];
    [dict setObject:@"/Netdisk" forKey:@"path"];
    [dict setObject:[uParam JSONRepresentation] forKey:@"fields"];
    [dict setObject:@"nsp.vfs.lsdir" forKey:@"nsp_svc"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [dict setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:dict]];
    NSMutableDictionary *headers=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/x-www-form-urlencoded",@"Content-Type", nil];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"%@",requestUrl);
    [request setRequestHeaders:headers];
    [self setGetUserInfo:request withRequestType:HW_VFS_LSDIR_ROOT];
    [requestQueue addOperation:request];
}


-(void)createDefaultFolder
{
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:@"我的记事本",@"name",@"Directory",@"type", nil];
    NSArray *uParam=[NSArray arrayWithObjects:dic,nil];
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"nsp_sid"];
    [dict setObject:@"/Netdisk" forKey:@"path"];
    [dict setObject:[uParam JSONRepresentation] forKey:@"files"];
    [dict setObject:@"nsp.vfs.mkfile" forKey:@"nsp_svc"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [dict setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:dict]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"%@",requestUrl);
    [self setGetUserInfo:request withRequestType:HW_VFS_MKDIR_DEF];
    [requestQueue addOperation:request];
}

-(void)uploadFile:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    [[NSUserDefaults standardUserDefaults] setObject:aFilePath forKey:@"currentUploadFilePath"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self getVFSUpauth];
}

-(void)uploadFile:(NSDictionary*)aDict
{
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[aDict objectForKey:@"nsp_tapp"] forKey:HW_NSP_APP];
    [dict setObject:@"JSON" forKey:HW_NSP_FMT];
    [dict setObject:[aDict objectForKey:@"nsp_tstr"] forKey:HW_NSP_TSTR];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:HW_NSP_TS];
    [dict setObject:[self getNSPKey:[aDict objectForKey:@"secret"] with:dict] forKey:HW_NSP_KEY];
    
    NSString *requestUrl =[NSString stringWithFormat:@"http://%@/upload/up.php",[aDict objectForKey:@"nsp_host"]];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"%@",requestUrl);
    NSArray *keys=[dict allKeys];
    id key,val;
    for (int i=0; i<[keys count]; i++) {
        key=[keys objectAtIndex:i];
        val=[dict objectForKey:key];
        [request setPostValue:val forKey:key];
    }
    
    [request setFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUploadFilePath"] forKey:@"Filedata"];
    [self setPostUserInfo:request withRequestType:HW_VFS_UPLOAD_FILE];
    [requestQueue addOperation:request];
}
-(void)mkdirFile:(NSDictionary*)aDict
{
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    NSMutableDictionary *dc=[[NSMutableDictionary alloc]init];
    [dc setObject:[aDict objectForKey:@"name"] forKey:@"name"];
    [dc setObject:@"File" forKey:@"type"];
    [dc setObject:[aDict objectForKey:@"path"] forKey:@"url"];
    [dc setObject:[aDict objectForKey:@"size"] forKey:@"size"];
    [dc setObject:[aDict objectForKey:@"nsp_fid"] forKey:@"md5"];
    [dc setObject:[aDict objectForKey:@"sig"] forKey:@"sig"];
    [dc setObject:[aDict objectForKey:@"ts"] forKey:@"ts"];
    
    NSArray *uParam=[NSArray arrayWithObjects:dc,nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"nsp_sid"];
    [dict setObject:@"/Netdisk/我的记事本" forKey:@"path"];
    [dict setObject:[uParam JSONRepresentation] forKey:@"files"];
    [dict setObject:@"nsp.vfs.mkfile" forKey:@"nsp_svc"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [dict setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:dict]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"%@",requestUrl);
    [self setGetUserInfo:request withRequestType:HW_VFS_MKFILE];
    [requestQueue addOperation:request];
}

-(void)getVFSUpauth
{
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"nsp_sid"];
    [dict setObject:@"nsp.vfs.upauth" forKey:@"nsp_svc"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [dict setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:dict]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"getVFSUpauth %@",requestUrl);
    [self setGetUserInfo:request withRequestType:HW_VFS_UPAUTH];
    [requestQueue addOperation:request];
}

-(void)downloadFile:(NSString *)aUrl fileName:(NSString *)aFileName
{
    NSString    *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filePath=[NSString stringWithFormat:@"%@/%@",downPath,aFileName];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:aUrl]];
    if ([self isFileExist:filePath]) {
        NSNotification *notification =[NSNotification notificationWithName:DOWNLOAD_SUCCEED object:filePath];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return;
    }
    [request setTimeOutSeconds:60];
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",downPath,aFileName]];
    [self setGetUserInfo:request withRequestType:HW_VFS_DOWNLOAD];
    [requestQueue addOperation:request];
}

-(BOOL)isFileExist:(NSString*)filePath
{
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isExist=[manager fileExistsAtPath:filePath];
    return  isExist;
}

#pragma mark - 更新文件
-(void)updateFile:(NSString *)aFilePath fileName:(NSString *)aFileName oldFile:(NSString *)aOldFile
{
    [[NSUserDefaults standardUserDefaults] setObject:aFilePath forKey:@"currentUploadFilePath"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if (token==nil) {
        token=[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_AUTH_TOKEN];
    }
    
    NSString *fPath=[NSString stringWithFormat:@"/Netdisk/我的记事本/%@",aOldFile];
    NSArray *uParam=[NSArray arrayWithObjects:fPath,nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"nsp_sid"];
    [dict setObject:@"true" forKey:@"reserve"];
    [dict setObject:[uParam JSONRepresentation] forKey:@"files"];
    [dict setObject:@"nsp.vfs.rmfile" forKey:@"nsp_svc"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"nsp_ts"];
    [dict setObject:@"JSON" forKey:@"nsp_fmt"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@?%@",HW_NSP_URL,[self getGetData:dict]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"%@",requestUrl);
    [self setGetUserInfo:request withRequestType:HW_VFS_DELFILE];
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
    if ([delegate respondsToSelector:@selector(didGetDataFalied:userInfo:)]) {
        [delegate didGetDataFalied:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"error",@"网络连接失败",@"errorMsg", nil] userInfo:[request userInfo]];
    }
}

//成功
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *userInformation = [request userInfo];
    HWRequestType requestType = [[userInformation objectForKey:HW_USER_REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    NSLog(@"responseString  %d= %@",requestType,responseString);
    
    if (requestType==HW_VFS_DOWNLOAD) {
        NSNotification *notification =[NSNotification notificationWithName:DOWNLOAD_SUCCEED object:request.downloadDestinationPath userInfo:userInformation];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return;
    }
    
    //认证失败
    //{"error":"auth faild!","error_code":21301,"request":"/2/statuses/home_timeline.json"}
    SBJsonParser    *parser     = [[SBJsonParser alloc] init];
    id  returnObject = [parser objectWithString:responseString];
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        NSString *errorString = [returnObject  objectForKey:@"error"];
        if (errorString != nil && ([errorString isEqualToString:@"auth faild!"] ||
                                   [errorString isEqualToString:@"expired_token"] ||
                                   [errorString isEqualToString:@"invalid_access_token"])) {
            NSLog(@"detected auth faild!");
        }
    }
    
    NSDictionary *uInfo = nil;
    NSArray *userArr = nil;
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        uInfo = (NSDictionary*)returnObject;
    }
    else if ([returnObject isKindOfClass:[NSArray class]]) {
        userArr = (NSArray*)returnObject;
    }
    else {
        return;
    }
    
    //获取TokenCode
    if (requestType == HW_OAUTH_CODE) {
        if ([delegate respondsToSelector:@selector(getOAuthTokenSuccess:result:)]) {
            [delegate getOAuthTokenSuccess:self result:uInfo];
        }
        return;
    }
    
    if (requestType==HW_OAUTH_ACCESS_TOKEN) {
        NSString *oauthToken=[uInfo objectForKey:@"oauth_token"];
        NSString *oauthTokenSecret=[uInfo objectForKey:@"oauth_token_secret"];
        [[NSUserDefaults standardUserDefaults]setObject:oauthToken forKey:HW_USER_AUTH_TOKEN];
        [[NSUserDefaults standardUserDefaults]setObject:oauthTokenSecret forKey:HW_USER_AUTH_TOKEN_SECRET];
        [[NSUserDefaults standardUserDefaults]synchronize];
        if ([delegate respondsToSelector:@selector(getAccessTokenSuccess:result:)]) {
            [delegate getAccessTokenSuccess:self result:uInfo];
        }
        return;
    }
    
    //获取用户信息
    if (requestType == HW_USER_GETINFO) {
        [[NSUserDefaults standardUserDefaults]setObject:[uInfo objectForKey:@"user.username"] forKey:@"NetbankUserName"];
        float total=[[uInfo objectForKey:@"product.spacecapacity"] floatValue];
        float other=[[uInfo objectForKey:@"profile.spaceextcapacity"] floatValue];
        float usedSpace=[[uInfo objectForKey:@"profile.usedspacecapacity"] floatValue];
        NSLog(@"============== %f  %f",(total+other),(total+other-usedSpace));
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:(total+other)] forKey:@"NetbankQuota"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:(total+other-usedSpace)] forKey:@"NetbankAvailable"];
        
        BOOL isInit=[[[NSUserDefaults standardUserDefaults] objectForKey:HW_USER_INIT] boolValue];
        if (!isInit) {
            //查询要目录我的记事本是否存在
            [self getVFSlsDir];
        }
        [[NSUserDefaults standardUserDefaults]synchronize];
        return;
    }
    
    if (requestType==HW_VFS_LSDIR_ROOT) {
        if (uInfo!=nil) {
            NSArray *array=[uInfo objectForKey:@"childList"];
            BOOL isExist=FALSE;
            NSString *folder=nil;
            for (int i=0; i<[array count]; i++) {
                NSDictionary *dic=[array objectAtIndex:i];
                if (dic&&[[dic objectForKey:@"type"] isEqualToString:@"Directory"]) {
                    folder=[dic objectForKey:@"name"];
                    if ([folder isEqualToString:@"我的记事本"]) {
                        isExist=TRUE;
                    }
                }
            }
            if (!isExist) {
                [self createDefaultFolder];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:HW_USER_INIT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self getVFSlsDir:@"我的记事本"];
            }
        }
    }else  if(requestType==HW_VFS_MKDIR_DEF){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true]  forKey:HW_USER_INIT];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else if (requestType==HW_VFS_UPAUTH) {
        //取得临时token后，上传文件
        [self uploadFile:uInfo];
    }else if (requestType==HW_VFS_UPLOAD_FILE) { //提示文件名及上传文件返回的文件信息
        NSDictionary *dc=[uInfo objectForKey:@"Filedata"];
        if (dc) {
            [self mkdirFile:dc];
        }
    }else if (requestType==HW_VFS_MKFILE) {   //文件上传成功后，取所有文件
        [self getVFSlsDir:@"我的记事本"];
    }else if (requestType==HW_VFS_DELFILE) {
        //删除成功后，取验证码再上传 文件
        [self getVFSUpauth];
    }else{
        //默认
        NSString *aView=[userInformation objectForKey:@"ViewController"];
        if ([aView isEqualToString:@"Root"]) {
            NSArray *array=[uInfo objectForKey:@"childList"];
            NSString  *fPath=nil;
            for (int i=0; i<[array count]; i++) {
                NSDictionary *dic=[array objectAtIndex:i];
                fPath=[dic objectForKey:@"name"];
                [self downloadFile:[dic objectForKey:@"url"] fileName:fPath];
            }
        }
        
        if ([delegate respondsToSelector:@selector(didGetDataFinished:userInfo:)]) {
            [delegate didGetDataFinished:uInfo userInfo:userInformation];
        }
    }
    
    
}

//跳转
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    NSLog(@"request will redirect");
}



@end
