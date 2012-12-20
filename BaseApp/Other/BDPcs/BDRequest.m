//
//  BDRequest.m
//  BaseApp
//
//  Created by xujun wu on 12-11-26.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "BDRequest.h"
#import "BDManager.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "StringUtil.h"
#import "SBJson.h"

@implementation BDRequest
@synthesize requestQueue,delegate;

-(id)initWithDelegate:(id<BDRequestDelegate>)aDelegate
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

- (void)setGetUserInfo:(ASIHTTPRequest *)request withRequestType:(BDRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:BD_USER_INFO_REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(BDRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:BD_USER_INFO_REQUEST_TYPE];
    [request setUserInfo:dict];
}

-(NSData*)getPostData:(NSMutableDictionary*)dict
{
    NSString    *result=@"";
    NSArray     *keys=[[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    id key,val;
    for (int i=0;i<[dict count];i++) {
        key=[keys objectAtIndex:i];
        val=[dict objectForKey:key];
        result=[result stringByAppendingFormat:@"%@=%@",key,[val encodeAsURIComponent]];
        if ((i+1)==[dict count]) {
            
        }else{
            result=[result stringByAppendingString:@"&"];
        }
    }
    NSLog(@"result :%@",result);
    
    return [result dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                            NULL, /* allocator */
                                                                                                            (CFStringRef)value,
                                                                                                            NULL, /* charactersToLeaveUnescaped */
                                                                                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                            kCFStringEncodingUTF8));
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [value encodeAsURIComponent]]];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        NSLog(@"============%@",url);
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

-(NSURL*)getOAuthCodeUrl
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   BD_APP_KEY,@"client_id",       //申请的appkey
								   @"token",@"response_type",   //access_token
								   @"oob",@"redirect_uri",    //申请时的重定向地址
								   @"touch",@"display",         //web页面的显示方式
                                   @"netdisk",@"scope",//个人网盘权限
                                   nil];
    NSURL   *url=[self generateURL:BD_API_AUTHORIZE params:params];
    NSLog(@"oauth url=%@",url);
    return url;
}

-(void)createDefaultFolder
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:BD_USER_STORE_ACCESS_TOKEN] forKey:@"access_token"];
    [dict setObject:@"mkdir" forKey:@"method"];
    [dict setObject:[NSString stringWithFormat:@"%@/我的记事本",BD_FOLDER_NAME] forKey:@"path"];
    NSString *requestUrl =[NSString stringWithFormat:@"%@/file",BD_API_DOMAIN];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[self generateURL:requestUrl params:dict]];
    NSLog(@"postData:%@",requestUrl);
    [self setGetUserInfo:request withRequestType:BDCreateFolder];
    [requestQueue addOperation:request];
}

-(void)upload:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:BD_USER_STORE_ACCESS_TOKEN] forKey:@"access_token"];
    [dict setObject:@"upload" forKey:@"method"];
    [dict setObject:[NSString stringWithFormat:@"%@/我的记事本/%@",BD_FOLDER_NAME,aFileName] forKey:@"path"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@/file",BD_API_DOMAIN];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[self generateURL:requestUrl params:dict]];
    NSLog(@"postData:%@",requestUrl);
    [request setFile:aFilePath forKey:@"file"];
    [self setPostUserInfo:request withRequestType:BDUploadFile];
    [requestQueue addOperation:request];
}
-(void)updateFile:(NSString*)aFilePath fileName:(NSString*)aFileName oldFile:(NSString *)aOldFile
{
    //先删除再上传
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:BD_USER_STORE_ACCESS_TOKEN] forKey:@"access_token"];
    [dict setObject:@"delete" forKey:@"method"];
    [dict setObject:aOldFile forKey:@"path"];
    
    NSString *requestUrl =[NSString stringWithFormat:@"%@/file",BD_API_DOMAIN];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[self generateURL:requestUrl params:dict]];
    NSLog(@"delete postData:%@",requestUrl);
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:BDDeleteFile],BD_USER_INFO_REQUEST_TYPE,aFilePath,@"filePath",aFileName,@"fileName", nil]];
    [requestQueue addOperation:request];
}

-(void)downloadFile:(NSString *)aFilePath pageView:(NSString*)aPageView
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:BD_USER_STORE_ACCESS_TOKEN] forKey:@"access_token"];
    [dict setObject:@"download" forKey:@"method"];
    [dict setObject:[NSString stringWithFormat:@"%@",aFilePath] forKey:@"path"];
    NSString *requestUrl =[NSString stringWithFormat:@"%@/file",BD_API_DOMAIN];
    NSString *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *fileName=nil;
    NSRange range=[aFilePath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.length>0&&range.location>0) {
        fileName=[aFilePath substringFromIndex:range.location+range.length];
    }
    if ([self isFileExist:[NSString stringWithFormat:@"%@/%@",downPath,fileName]]) {
        return;
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[self generateURL:requestUrl params:dict]];
    NSLog(@"BDRequest downloadFile %@",requestUrl);
    [request setTimeOutSeconds:60];
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",downPath,fileName]];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:BDUploadFile],BD_USER_INFO_REQUEST_TYPE,aPageView,@"ViewController", nil]];
    [requestQueue addOperation:request];
}

#pragma mark getData aMethod 百度方法
-(void)getData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [aParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:BD_USER_STORE_ACCESS_TOKEN] forKey:@"access_token"];
    NSString *requestUrl =[NSString stringWithFormat:@"%@/%@",BD_API_DOMAIN,aMethod];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[self generateURL:requestUrl params:aParams]];
    NSLog(@"BDRequest getData %@",requestUrl);
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];

}

-(void)postData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [aParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:BD_USER_STORE_ACCESS_TOKEN] forKey:@"access_token"];
    NSString *requestUrl =[NSString stringWithFormat:@"%@/%@",BD_API_DOMAIN,aMethod];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"postData:%@",requestUrl);
    [request appendPostData:[self getPostData:aParams]];
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
}

-(BOOL)isFileExist:(NSString*)filePath
{
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isExist=[manager fileExistsAtPath:filePath];
    return  isExist;
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
        [delegate didGetDataFalied:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"error",@"网络连接失败,请重试!",@"errorMsg", nil] userInfo:[request userInfo]];
    }
}

//成功
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *userInformation = [request userInfo];
    BDRequestType requestType = [[userInformation objectForKey:BD_USER_INFO_REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    NSLog(@"requestFinished requestType=%d responseString = %@",requestType,responseString);
    
    if (requestType==BDDownloadFile) {
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
    NSArray *uArr = nil;
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        uInfo = (NSDictionary*)returnObject;
    }
    else if ([returnObject isKindOfClass:[NSArray class]]) {
        uArr = (NSArray*)returnObject;
    }
    else {
        return;
    }
    if (requestType==BDGetUserQuota) {
        if (uInfo) {
            [[NSUserDefaults standardUserDefaults]  setObject:[uInfo objectForKey:@"quota"] forKey:BD_USER_SPACE_AMOUNT];
            [[NSUserDefaults standardUserDefaults] setObject:[uInfo objectForKey:@"used"] forKey:BD_USER_SPACE_USED];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }else if(requestType==BDCreateFolder){
        if (uInfo) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:TRUE] forKey:BD_USER_INIT];
            [[NSUserDefaults standardUserDefaults] setObject:[uInfo objectForKey:@"fs_id"] forKey:BD_DEFAULT_FOLDER_ID];
            [[NSUserDefaults standardUserDefaults] setObject:[uInfo objectForKey:@"path"] forKey:BD_DEFAULT_FOLDER_PATH];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSDictionary *uInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:BDGetAllFiles],BD_USER_INFO_REQUEST_TYPE,@"Root",@"ViewController", nil];
            [self getData:@"file" params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:BD_DEFAULT_FOLDER_PATH],@"path",@"list",@"method", nil] userInfo:uInfo];
        }
    }else if(requestType==BDUploadFile){
        if (uInfo) {
            NSDictionary *uInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:BDGetAllFiles],BD_USER_INFO_REQUEST_TYPE,@"Root",@"ViewController", nil];
            [self getData:@"file" params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:BD_DEFAULT_FOLDER_PATH],@"path",@"list",@"method", nil] userInfo:uInfo];
        }
    }else if(requestType==BDDeleteFile){
        if (uInfo) {
            NSLog(@"BDDeleteFile requestType: %@",userInformation);
            [self upload:[userInformation objectForKey:@"filePath"] fileName:[userInformation objectForKey:@"fileName"]];
        }
    } else{
        BOOL isInit=[[[NSUserDefaults standardUserDefaults] objectForKey:BD_USER_INIT] boolValue];
        if (!isInit) {
            if (uInfo) {
                NSArray *array=[uInfo objectForKey:@"list"];
                BOOL isExist=FALSE;
                NSString  *fPath=nil;
                for (int i=0; i<[array count]; i++) {
                    NSDictionary *dic=[array objectAtIndex:i];
                    int isdir=[[dic objectForKey:@"isdir"] intValue];
                    NSString    *path=[dic objectForKey:@"path"];
                    if (isdir==1) {
                        NSRange range=[path rangeOfString:@"我的记事本" options:NSBackwardsSearch];
                        if (range.length>0) {
                            fPath=[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]];
                            isExist=TRUE;
                        }
                    }
                }
                if (!isExist) {
                    [self createDefaultFolder];
                }else{
                    [[NSUserDefaults standardUserDefaults]setObject:fPath forKey:BD_DEFAULT_FOLDER_PATH];
                    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:true] forKey:BD_USER_INIT];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSDictionary *uInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:BDGetAllFiles],BD_USER_INFO_REQUEST_TYPE,@"Root",@"ViewController", nil];
                        
                    [self getData:@"file" params:[NSMutableDictionary dictionaryWithObjectsAndKeys:fPath,@"path",@"list",@"method", nil] userInfo:uInfo];
                }
            }
        }else{
            NSString *aView=[userInformation objectForKey:@"ViewController"];
            if ([aView isEqualToString:@"Root"]) {
                NSArray *array=[uInfo objectForKey:@"list"];
                NSString  *fPath=nil;
                for (int i=0; i<[array count]; i++) {
                    NSDictionary *dic=[array objectAtIndex:i];
                    fPath=[dic objectForKey:@"path"];
                    [self downloadFile:fPath pageView:@"Root"];
                }
            }
//            else if([aView isEqualToString:@"Photo"]){
//                NSArray *array=[uInfo objectForKey:@"list"];
//                NSString  *fPath=nil;
//                for (int i=0; i<[array count]; i++) {
//                    NSDictionary *dic=[array objectAtIndex:i];
//                    fPath=[dic objectForKey:@"path"];
//                    NSRange range=[fPath rangeOfString:@"/" options:NSBackwardsSearch];
//                    if (range.location>0&&range.length>0) {
//                        NSString *fName=[fPath substringFromIndex:range.location+range.length];
//                        range=[fName rangeOfString:@"." options:NSBackwardsSearch];
//                        if (range.location>0&&range.length>0) {
//                            NSString *ext=[fName substringFromIndex:range.location+range.length];
//                            if ([ext isEqualToString:@"png"]||[ext isEqualToString:@"jpg"]||[ext isEqualToString:@"jpeg"]) {
//                                NSString *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//                                if (![self isFileExist:[NSString stringWithFormat:@"%@/%@",downPath,fName]]) {
//                                    [self downloadFile:fPath pageView:@"Photo"];
//                                }
//                            }
//                        }
//                        
//                    }
//                }
//            }

            if ([delegate respondsToSelector:@selector(didGetDataFinished:userInfo:)]) {
                [delegate didGetDataFinished:uInfo userInfo:userInformation];
            }
        }

    }
}

//跳转
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    NSLog(@"request will redirect");
    NSNotification *notification = [NSNotification notificationWithName:BDRequestFailed object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
@end
