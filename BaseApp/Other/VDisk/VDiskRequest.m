//
//  VDiskRequest.m
//  SAnalysis
//  新浪微盘 接口
//  Created by xujun wu on 12-10-27.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "VDiskRequest.h"
#import <CommonCrypto/CommonHMAC.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Base64.h"
#import "SBJson.h"
#import "StringUtil.h"
#import "NSDataAdditions.h"


static NSString *HMAC_SHA256(NSString *data, NSString *key) {
    const char *ckey=[key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cdata=[data cStringUsingEncoding:NSUTF8StringEncoding];
	unsigned char buf[CC_SHA256_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA256, ckey, strlen(ckey), cdata, strlen(cdata), buf);
    NSData *outd=[NSData dataWithBytes:buf length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[outd description];
    hash=[hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash=[hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash=[hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

@implementation VDiskRequest
@synthesize requestQueue,token,delegate;

-(id)initWithDelegage:(id<VDiskRequestDelegate>)aDelegate
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

- (void)setGetUserInfo:(ASIHTTPRequest *)request withRequestType:(VDiskRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:VDISK_USER_REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(VDiskRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:VDISK_USER_REQUEST_TYPE];
    [request setUserInfo:dict];
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
        NSRange range=[baseURL rangeOfString:@"?"];
        NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        if (range.length>0) {
            url=[NSString stringWithFormat:@"%@&%@",baseURL,query];
        }
		NSLog(@"============%@",url);
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

#pragma mark - GetPostData

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
    NSLog(@"result :%@",result);
    return [result dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData*)getAuthPostData:(NSMutableDictionary*)dict
{
    NSString    *result=@"";
    NSString    *hashStr=@"";
    NSArray     *keys=[[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    id key,val;
    for (int i=0;i<[dict count];i++) {
        key=[keys objectAtIndex:i];
        val=[dict objectForKey:key];
        hashStr=[result stringByAppendingFormat:@"%@=%@",key,val];
        if ((i+1)==[dict count]) {
            
        }else{
            hashStr=[hashStr stringByAppendingString:@"&"];
        }
        result=[result stringByAppendingFormat:@"%@=%@&",key,val];
    }
    result=[result stringByAppendingString:@"signature"];
    result=[result stringByAppendingString:@"="];
    NSString *signature = HMAC_SHA256(hashStr, APP_SECRET);
    result=[result stringByAppendingString:signature];
    result=[result stringByAppendingString:@"&app_type=sinat"];
    NSLog(@"result :%@",result);
    return [result dataUsingEncoding:NSUTF8StringEncoding];
}

-(void)getToken:(NSString*)uId pwd:(NSString *)aPwd
{
     NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:uId forKey:@"account"];
    [dict setObject:aPwd forKey:@"password"];
    [dict setObject:APP_KEY forKey:@"appkey"];
    [dict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:VDISK_URL_GET_TOKEN]];
    [request appendPostData:[self getAuthPostData:dict]];
    [self setPostUserInfo:request withRequestType:VD_GET_TOKEN];
    [requestQueue addOperation:request];
}

-(void)keepToken
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:token forKey:@"token"];

    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:VDISK_URL_KEEP_TOKEN]];
    [request appendPostData:[self getPostData:dict]];
    [self setPostUserInfo:request withRequestType:VD_KEEP_TOKEN];
    [requestQueue addOperation:request];
}

-(void)createDefaultFolder
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:VDISK_USER_STORE_ACCESS_TOKEN] forKey:@"token"];
    [dict setObject:@"0" forKey:@"parent_id"];
    [dict setObject:@"我的记事本" forKey:@"create_name"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:VDISK_URL_CREATE_DIR]];
    [request appendPostData:[self getPostData:dict]];
    [self setPostUserInfo:request withRequestType:VD_CREATE_DIR];
    [requestQueue addOperation:request];
}

-(void)getList
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:VDISK_USER_STORE_ACCESS_TOKEN] forKey:@"token"];
    [dict setObject:[NSNumber numberWithInt:0] forKey:@"dir_id"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:VDISK_URL_GET_LIST]];
    [request appendPostData:[self getPostData:dict]];
    [self setPostUserInfo:request withRequestType:VD_GET_ROOT_LIST];
    [requestQueue addOperation:request];
}

-(void)getFileInfo:(NSString*)fid pageView:(NSString*)aPageView;
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:VDISK_USER_STORE_ACCESS_TOKEN] forKey:@"token"];
    [dict setObject:fid forKey:@"fid"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:VDISK_URL_GET_FILE_INFO]];
    [request appendPostData:[self getPostData:dict]];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:VD_GET_FILE_INFO],VDISK_USER_REQUEST_TYPE,aPageView,@"ViewController", nil]];
    [requestQueue addOperation:request];
}

-(void)upload:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:VDISK_USER_STORE_ACCESS_TOKEN] forKey:@"token"];
    [dict setObject:@"yes" forKey:@"cover"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:VDISK_USER_DEFAULT_FOLDER_ID] forKey:@"dir_id"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:VDISK_URL_UPLOAD_FILE]];
    NSArray *keys=[dict allKeys];
    id key,val;
    for (int i=0; i<[keys count]; i++) {
        key=[keys objectAtIndex:i];
        val=[dict objectForKey:key];
        [request setPostValue:val forKey:key];
    }
    [request setFile:aFilePath forKey:@"file"];
    [self setPostUserInfo:request withRequestType:VD_UPLOAD_FILE];
    [requestQueue addOperation:request];
}


#pragma mark getData aMethod
-(void)getData:(NSString *)aUrl params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [aParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:VDISK_USER_STORE_ACCESS_TOKEN] forKey:@"token"];
   
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[self generateURL:aUrl params:aParams]];
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
    
}

-(void)postData:(NSString *)aUrl params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [aParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:VDISK_USER_STORE_ACCESS_TOKEN] forKey:@"token"];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:aUrl]];
    [request appendPostData:[self getPostData:aParams]];
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
}

-(void)downloadFile:(NSString*)aUrl fileName:(NSString *)aFileName pageView:(NSString*)aPageView
{
    NSString *requestUrl =[NSString stringWithFormat:@"%@",aUrl];
    NSString *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    if ([self isFileExist:[NSString stringWithFormat:@"%@/%@",downPath,aFileName]]) {
        return;
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:aUrl]];
    NSLog(@"BDRequest downloadFile %@",requestUrl);
    [request setTimeOutSeconds:60];
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",downPath,aFileName]];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:VD_DOWNLOAD_FILE],VDISK_USER_REQUEST_TYPE,aPageView,@"ViewController", nil]];
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
    VDiskRequestType requestType = [[userInformation objectForKey:VDISK_USER_REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    NSLog(@"responseString  %d= %@",requestType,responseString);
    if (requestType==VD_DOWNLOAD_FILE) {
        NSNotification *notification =[NSNotification notificationWithName:DOWNLOAD_SUCCEED object:request.downloadDestinationPath userInfo:userInformation];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    //认证失败
    //{"error":"auth faild!","error_code":21301,"request":"/2/statuses/home_timeline.json"}
    SBJsonParser    *parser     = [[SBJsonParser alloc] init];
    id  returnObject = [parser objectWithString:responseString];
    if ([returnObject isKindOfClass:[NSDictionary class]]) {
        NSString *errorString = [returnObject  objectForKey:@"err_msg"];
        if (errorString != nil && (![errorString isEqualToString:@"success"])) {
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
    
    if (requestType==VD_GET_TOKEN) {
        if ([[uInfo objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result=(NSDictionary*)[uInfo objectForKey:@"data"];
            token=[result objectForKey:@"token"];
            [[NSUserDefaults standardUserDefaults]setObject:token forKey:VDISK_USER_STORE_ACCESS_TOKEN];
            [[NSUserDefaults standardUserDefaults]synchronize];
            NSLog(@"token:%@",[result objectForKey:@"token"]);
            [self getList];
        }
    }else if(requestType==VD_CREATE_DIR){
        if ([[uInfo objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result=(NSDictionary*)[uInfo objectForKey:@"data"];
            [[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"dir_id"] forKey:VDISK_USER_DEFAULT_FOLDER_ID];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:true] forKey:VDISK_USER_INIT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSDictionary *uInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:VD_GET_LIST],VDISK_USER_REQUEST_TYPE,@"Root",@"ViewController", nil];
            
            [self postData:VDISK_URL_GET_LIST params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[result objectForKey:@"dir_id"],@"dir_id", nil] userInfo:uInfo];
        }
    }else if (requestType==VD_GET_ROOT_LIST) {
        NSArray *array=(NSArray*)[uInfo objectForKey:@"data"];
        NSLog(@"====== %d",[array count]);
        BOOL isExist=FALSE;
        NSInteger  dirId=0;
        for (int i=0; i<[array count]; i++) {
            NSDictionary *dc=(NSDictionary*)[array objectAtIndex:i];
            int pid=[[dc objectForKey:@"pid"] intValue];
            NSString *name=[dc objectForKey:@"name"];
            NSRange range=[name rangeOfString:@"我的记事本" options:NSBackwardsSearch];
            if (pid==0&&range.length>0) {
                isExist=TRUE;
                dirId=[[dc objectForKey:@"id"] integerValue];
            }
        }
        if (!isExist) {
            [self createDefaultFolder];
        }else{
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:dirId] forKey:VDISK_USER_DEFAULT_FOLDER_ID];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:true] forKey:VDISK_USER_INIT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSDictionary *uInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:VD_GET_LIST],VDISK_USER_REQUEST_TYPE,@"Root",@"ViewController", nil];
            
            [self postData:VDISK_URL_GET_LIST params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:dirId],@"dir_id", nil] userInfo:uInfo];
        }
        
    }else if(requestType==VD_UPLOAD_FILE){
        
        NSDictionary *uInfo=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:VD_GET_LIST],VDISK_USER_REQUEST_TYPE,@"Root",@"ViewController", nil];
        [self postData:VDISK_URL_GET_LIST params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[[[NSUserDefaults  standardUserDefaults] objectForKey:VDISK_USER_DEFAULT_FOLDER_ID] integerValue]],@"dir_id", nil] userInfo:uInfo];
    } else if (requestType==VD_GET_FILE_INFO) {
        if ([[uInfo objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *result=(NSDictionary*)[uInfo objectForKey:@"data"];
            NSLog(@"filaName:%@ url:%@",[result objectForKey:@"name"],[result objectForKey:@"s3_url"]);
            [self downloadFile:[result objectForKey:@"s3_url"] fileName:[result objectForKey:@"name"] pageView:[userInformation objectForKey:@"ViewController"]];
        }
    }else{
        NSString *aView=[userInformation objectForKey:@"ViewController"];
        if ([aView isEqualToString:@"Root"]) {
            NSArray *array=[uInfo objectForKey:@"data"];
            NSString  *fPath=nil;
            for (int i=0; i<[array count]; i++) {
                NSDictionary *dic=[array objectAtIndex:i];
                fPath=[dic objectForKey:@"id"];
                NSString *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
                if (![self isFileExist:[NSString stringWithFormat:@"%@/%@",downPath,[dic objectForKey:@"name"]]]) {
                    [self getFileInfo:fPath pageView:@"Root"];
                }
            }
        }
        if ([aView isEqualToString:@"Photo"]) {
            NSArray *array=[uInfo objectForKey:@"data"];
            NSString  *fPath=nil;
            NSString  *fName=nil;
            for (int i=0; i<[array count]; i++) {
                NSDictionary *dic=[array objectAtIndex:i];
                fPath=[dic objectForKey:@"id"];
                fName=[dic objectForKey:@"name"];
                NSRange range=[fName rangeOfString:@"." options:NSBackwardsSearch];
                if (range.location>0&&range.length>0) {
                    NSString *ext=[fName substringFromIndex:range.location+range.length];
                    if ([ext isEqualToString:@"png"]||[ext isEqualToString:@"jpg"]||[ext isEqualToString:@"jpeg"]) {
                        NSString *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
                        if (![self isFileExist:[NSString stringWithFormat:@"%@/%@",downPath,fName]]) {
                            [self getFileInfo:fPath pageView:@"Photo"];
                        }
                    }
                }
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
