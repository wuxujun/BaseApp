//
//  LiveAuthRequest.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-30.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "LiveAuthRequest.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "LiveConnSession.h"

@implementation LiveAuthRequest
@synthesize requestQueue,authCode,authToken,accessToken;
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

- (void)setGetUserInfo:(ASIHTTPRequest *)request withRequestType:(LIVERequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:LIVE_REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(LIVERequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:LIVE_REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
    if (params.count<=0) {
        return [NSURL URLWithString:baseURL];
    }
    NSRange range=[baseURL rangeOfString:@"?"];
    NSString *joinChar=(range.location==NSNotFound)?@"?":@"&";
    NSString *query=[self encoderUrlParameters:params];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",baseURL,joinChar,query]];
}

-(NSString*)encoderUrlParameters:(NSDictionary*)params
{
    NSMutableArray *entryList=[NSMutableArray array];
    for (NSString *key in params.keyEnumerator) {
        id value=[params valueForKey:key];
        id kvStr=[NSString stringWithFormat:@"%@=%@",key,[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [entryList addObject:kvStr];
    }
    return [entryList componentsJoinedByString:@"&"];
}

-(NSURL*)getAuthCodeUrl
{
    NSString *language=[[NSLocale preferredLanguages] objectAtIndex:0];
    NSArray  *arr=[NSArray arrayWithObjects:@"wl.signin",@"wl.basic",@"wl.skydrive",@"wl.offline_access",@"wl.skydrive_update",  nil];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   APP_KEY,@"client_id",       //申请的appkey
								   @"code",@"response_type",   //access_token
								   CALL_BACK_URL,@"redirect_uri",    //申请时的重定向地址
								   @"ios_phone",@"display",
                                   [arr componentsJoinedByString:@" "],@"scope",
                                   language,@"locale",
                                   nil];
    NSURL   *url=[self generateURL:LIVE_API_AUTHORIZE params:params];
//    NSLog(@"oauth url=%@",url);
    return url;
}

#pragma mark - Post
-(NSURL*)getRetrieveTokenUrl
{
    return [NSURL URLWithString:LIVE_API_ACCESS_TOKEN];
}

-(void)retrieveToken
{
    NSURL *url=[self getRetrieveTokenUrl];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:LIVE_TOKEN_CODE] forKey:LIVE_AUTH_CODE];
    [dict setObject:CALL_BACK_URL forKey:LIVE_AUTH_REDIRECT_URI];
    [dict setObject:APP_SECRET forKey:@"client_secret"];
    [dict setObject:@"authorization_code" forKey:LIVE_AUTH_GRANT_TYPE];
    [dict setObject:APP_KEY forKey:LIVE_AUTH_CLIENTID];
    [dict setObject:@"zh-hans" forKey:@"locale"];
    
    
    NSMutableDictionary *headers=[NSMutableDictionary dictionaryWithObjectsAndKeys:LIVE_AUTH_POST_CONTENT_TYPE,@"Content-Type", nil];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request appendPostData:[self getPostData:dict]];
    [request setRequestMethod:@"POST"];
    [request setRequestHeaders:headers];
    [self setPostUserInfo:request withRequestType:LIVE_RETRIEVE_TOKEN];
    [requestQueue addOperation:request];
}

-(void)refreshToken
{
    NSURL *url=[self getRetrieveTokenUrl];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:LIVE_AUTH_REFRESH_TOKEN] forKey:LIVE_AUTH_REFRESH_TOKEN];
    [dict setObject:CALL_BACK_URL forKey:LIVE_AUTH_REDIRECT_URI];
    [dict setObject:APP_SECRET forKey:@"client_secret"];
    [dict setObject:@"refresh_token" forKey:LIVE_AUTH_GRANT_TYPE];
    [dict setObject:APP_KEY forKey:LIVE_AUTH_CLIENTID];
    [dict setObject:@"zh-hans" forKey:@"locale"];
    
    NSMutableDictionary *headers=[NSMutableDictionary dictionaryWithObjectsAndKeys:LIVE_AUTH_POST_CONTENT_TYPE,@"Content-Type", nil];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request appendPostData:[self getPostData:dict]];
    [request setRequestMethod:@"POST"];
    [request setRequestHeaders:headers];
    [self setPostUserInfo:request withRequestType:LIVE_RETRIEVE_TOKEN];
    [requestQueue addOperation:request];
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
//    NSLog(@"result :%@",result);
    
    return [result dataUsingEncoding:NSUTF8StringEncoding];
}

+(BOOL)isSessionValid:(LiveConnSession *)session
{
    //NSLog(@"%f",[session.expires timeIntervalSinceNow]);
    return ([session.expires timeIntervalSinceNow]>=3);
}

#pragma mark - 取存储空间
-(void)queryQuota
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (accessToken==nil) {
        accessToken=[[NSUserDefaults standardUserDefaults]objectForKey:LIVE_USER_ACCESS_TOKEN];
    }
    [dict setObject:accessToken forKey:@"access_token"];
    
    NSURL   *url=[self generateURL:@"https://apis.live.net/v5.0/me/skydrive/quota" params:dict];
    //    NSLog(@"oauth url=%@",url);
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [self setGetUserInfo:request withRequestType:LIVE_QUERY_QUOTA];
    [request setTimeOutSeconds:30];
    [requestQueue addOperation:request];
}

#pragma mark - 取用户信息
-(void)getUser
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (accessToken==nil) {
        accessToken=[[NSUserDefaults standardUserDefaults]objectForKey:LIVE_USER_ACCESS_TOKEN];
    }
    [dict setObject:accessToken forKey:@"access_token"];
    
    NSURL   *url=[self generateURL:@"https://apis.live.net/v5.0/me" params:dict];
//    NSLog(@"oauth url=%@",url);
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [self setGetUserInfo:request withRequestType:LIVE_GET_USER];
    [request setTimeOutSeconds:30];
    [requestQueue addOperation:request];
}

-(void)getHome
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (accessToken==nil) {
        accessToken=[[NSUserDefaults standardUserDefaults]objectForKey:LIVE_USER_ACCESS_TOKEN];
    }
    [dict setObject:accessToken forKey:@"access_token"];
    
    NSURL   *url=[self generateURL:@"https://apis.live.net/v5.0/me/skydrive" params:dict];
//    NSLog(@"oauth url=%@",url);
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [self setGetUserInfo:request withRequestType:LIVE_GET_HOME];
    [request setTimeOutSeconds:60];
    [requestQueue addOperation:request];
}


#pragma mark getData aMethod 百度方法
-(void)getData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [aParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:LIVE_USER_ACCESS_TOKEN] forKey:@"access_token"];
    NSString *requestUrl =[NSString stringWithFormat:@"%@/%@",LIVE_DOMAIN,aMethod];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[self generateURL:requestUrl params:aParams]];
    NSLog(@"LiveRequest getData %@",requestUrl);
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
    
}

-(void)postData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    [aParams setObject:[[NSUserDefaults standardUserDefaults] objectForKey:LIVE_USER_ACCESS_TOKEN] forKey:@"access_token"];
    NSString *requestUrl =[NSString stringWithFormat:@"%@/%@",LIVE_DOMAIN,aMethod];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    NSLog(@"postData:%@",requestUrl);
    [request appendPostData:[self getPostData:aParams]];
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
}

#pragma mark - 取根目录下所有文件
-(void)getFiles:(NSString*)aUrl
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (accessToken==nil) {
        accessToken=[[NSUserDefaults standardUserDefaults]objectForKey:LIVE_USER_ACCESS_TOKEN];
    }
    [dict setObject:accessToken forKey:@"access_token"];
    
    NSURL   *url=[self generateURL:[aUrl stringByReplacingOccurrencesOfString:@"files" withString:@"files/"] params:dict];
//    NSLog(@"getFiles url=%@?accessToken=%@",url,accessToken);
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [self setGetUserInfo:request withRequestType:LIVE_GET_FILES];
    [request setTimeOutSeconds:60];
    [requestQueue addOperation:request];
}

#pragma mark - 取 Url 文件夹下所有文件
//sort_by:  created,updated,name,size,default
//sort_order:  descending ascending
//filter:   photos,videos,audio,folders,albums
//limit: 2  offset=3

-(void)getAllFiles:(NSString *)aUrl
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (accessToken==nil) {
        accessToken=[[NSUserDefaults standardUserDefaults]objectForKey:LIVE_USER_ACCESS_TOKEN];
    }
    [dict setObject:accessToken forKey:@"access_token"];
    [dict setObject:@"updated" forKey:@"sort_by"];
    [dict setObject:@"descending" forKey:@"sort_order"];
    
    NSURL   *url=[self generateURL:[NSString   stringWithFormat:@"https://apis.live.net/v5.0/%@/files",aUrl] params:dict];
//    NSLog(@"getFiles url=%@?accessToken=%@",url,accessToken);
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:LIVE_GET_ALLFILES],LIVE_REQUEST_TYPE,@"Root",@"ViewController", nil]];
    [request setTimeOutSeconds:60];
    [requestQueue addOperation:request];
}

#pragma mark - 创建文件夹
-(void)createFolder:(NSString*)folderName
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:accessToken forKey:@"access_token"];
    [dict setObject:folderName forKey:@"name"];
    [dict setObject:@"我的记事本" forKey:@"description"];
    [dict setObject:@"folder" forKey:@"type"];
    NSURL   *url=[self generateURL:@"https://apis.live.net/v5.0/me/skydrive" params:dict];
//    NSLog(@"createFolder url=%@?accessToken=%@",url,accessToken);
    
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
//    NSLog(@"body data:%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSMutableDictionary *headers=[NSMutableDictionary dictionaryWithObjectsAndKeys:LIVE_API_HEADER_CONTENTTYPE_JSON,@"Content-Type", nil];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request appendPostData:jsonData];
    [request setRequestMethod:@"POST"];
    [request setRequestHeaders:headers];
    [self setPostUserInfo:request withRequestType:LIVE_CREATE_FOLDER];
    [requestQueue addOperation:request];
}

#pragma mark - 上传文件
-(void)uploadFile:(NSString*)aFilePath fileName:(NSString*)aFileName
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (accessToken==nil) {
        accessToken=[[NSUserDefaults standardUserDefaults]objectForKey:LIVE_USER_ACCESS_TOKEN];
    }
    [dict setObject:accessToken forKey:@"access_token"];
    NSString  *urlStr=@"https://apis.live.net/v5.0/me/skydrive/files";
    NSString  *noteFolder=[[NSUserDefaults standardUserDefaults]objectForKey:@"LiveNoteFolder"];
    if (noteFolder) {
        urlStr=[NSString stringWithFormat:@"https://apis.live.net/v5.0/%@/files",noteFolder];
    }
    NSURL   *url=[self generateURL:urlStr params:dict];
//    NSLog(@"uploadFile url=%@?accessToken=%@",url,accessToken);
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    
    [request setFile:[NSString stringWithFormat:@"%@",aFilePath] withFileName:aFileName andContentType:@"text/plain" forKey:@"file"];
    [request setTimeOutSeconds:60];
    [self setPostUserInfo:request withRequestType:LIVE_UPLOAD_FILE];
    [requestQueue addOperation:request];
}

-(void)updateFile:(NSString *)aFileId path:(NSString *)aFilePath fileName:(NSString *)aFileName
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (accessToken==nil) {
        accessToken=[[NSUserDefaults standardUserDefaults]objectForKey:LIVE_USER_ACCESS_TOKEN];
    }
    [dict setObject:accessToken forKey:@"access_token"];
    [dict setObject:@"MyNewFileState" forKey:@"state"];
    [dict setObject:@"https://pay.xujun.local/callback.php" forKey:@"redirect_uri"];
    NSString  *urlStr=@"https://apis.live.net/v5.0/me/skydrive/files";
    NSString  *noteFolder=[[NSUserDefaults standardUserDefaults]objectForKey:@"LiveNoteFolder"];
    if (noteFolder) {
        urlStr=[NSString stringWithFormat:@"https://apis.live.net/v5.0/%@/files",noteFolder];
    }
    NSURL   *url=[self generateURL:urlStr params:dict];
//    NSLog(@"updateFile %@",[url description]);
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    
    [request setFile:[NSString stringWithFormat:@"%@",aFilePath] withFileName:aFileName andContentType:@"text/plain" forKey:@"file"];
    [request setTimeOutSeconds:60];
    [self setPostUserInfo:request withRequestType:LIVE_UPLOAD_FILE];
    [requestQueue addOperation:request];
}

#pragma mark － 下载文件
-(void)downloadFile:(NSString *)aId fileName:(NSString *)aFileName userInfo:(NSDictionary *)aUserInfo
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (accessToken==nil) {
        accessToken=[[NSUserDefaults standardUserDefaults]objectForKey:LIVE_USER_ACCESS_TOKEN];
    }
    [dict setObject:accessToken forKey:@"access_token"];
    [dict setObject:@"true" forKey:@"download"];
    [dict setObject:@"true" forKey:@"suppress_redirects"];
    
//    NSURL   *url=[self generateURL:[NSString stringWithFormat:@"https://apis.live.net/v5.0/%@/content",aId] params:dict];
    NSURL *url=[NSURL URLWithString:aId];
    
//    NSLog(@"%@",[url description]);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    NSString    *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath=[NSString stringWithFormat:@"%@/%@",downPath,aFileName];
    if ([self isFileExist:filePath]) {
        NSNotification *notification =[NSNotification notificationWithName:@"downloadSucceed" object:filePath];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return;
    }
    [request setTimeOutSeconds:60];
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",downPath,aFileName]];
//    [self setGetUserInfo:request withRequestType:LIVE_DOWNLOAD_FILE];
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
}

-(BOOL)isFileExist:(NSString*)filePath
{
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isExist=[manager fileExistsAtPath:filePath];
    return  isExist;
}

-(void)downloadFile:(NSURL*)url path:(NSString *)aFilePath userInfo:(NSDictionary*)aUserInfo
{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request setDownloadDestinationPath:aFilePath];
    [request setTimeOutSeconds:60];
//    [self setGetUserInfo:request withRequestType:LIVE_DOWNLOAD_FILE];
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:LIVE_DOWNLOAD_FILE],LIVE_REQUEST_TYPE,[aUserInfo objectForKey:@"ViewController"],@"ViewController", nil]];
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
    NSDictionary *userInformation = [request userInfo];
    LIVERequestType requestType = [[userInformation objectForKey:LIVE_REQUEST_TYPE] intValue];
    if ([[request.error localizedDescription] isEqualToString:@"Authentication needed"]) {
        [self refreshToken];
    }else {
        if ([delegate respondsToSelector:@selector(didGetDataFalied:userInfo:)]) {
            [delegate didGetDataFalied:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"error",@"网络连接失败,请重试!",@"errorMsg", nil] userInfo:[request userInfo]];
        }
    }
    NSLog(@"requestFailed %d:%@,%@,",requestType,request.responseString,[request.error localizedDescription]);
}

//成功
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *userInformation = [request userInfo];
    LIVERequestType requestType = [[userInformation objectForKey:LIVE_REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    NSLog(@"responseString %d= %@",requestType,userInformation);
    
    if (requestType==LIVE_DOWNLOAD_FILE) {
        NSLog(@"down success  %@",[request downloadDestinationPath]);
        NSNotification *notification =[NSNotification notificationWithName:@"downloadSucceed" object:[request downloadDestinationPath] userInfo:userInformation];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return;
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
    
    if (requestType==LIVE_RETRIEVE_TOKEN) {
        NSString *accessToken = [uInfo  objectForKey:LIVE_AUTH_ACCESS_TOKEN];
        NSString *refreshToken=[uInfo objectForKey:LIVE_AUTH_REFRESH_TOKEN];
        NSString *expiresInStr=[uInfo objectForKey:LIVE_AUTH_EXPIRES_IN];
        NSTimeInterval  expiresIn=[expiresInStr doubleValue];
        NSDate *expires=[NSDate dateWithTimeIntervalSinceNow:expiresIn];
        
        NSString *authenticationToken=[uInfo objectForKey:LIVE_AUTH_AUTHENTICATION_TOKEN];
        NSArray  *scopes=[[uInfo objectForKey:LIVE_AUTH_SCOPE] componentsSeparatedByString:@" "];
        
        [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:LIVE_USER_ACCESS_TOKEN];
        [[NSUserDefaults standardUserDefaults]setObject:refreshToken forKey:LIVE_AUTH_REFRESH_TOKEN];
        [[NSUserDefaults standardUserDefaults]setObject:expiresInStr forKey:LIVE_AUTH_EXPIRES_IN];
        [[NSUserDefaults standardUserDefaults]setObject:authenticationToken forKey:LIVE_AUTH_AUTHENTICATION_TOKEN];
        [[NSUserDefaults standardUserDefaults]setObject:[uInfo objectForKey:LIVE_AUTH_SCOPE] forKey:LIVE_AUTH_SCOPE];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        LiveConnSession *session=[[LiveConnSession alloc]initWithAccessToken:accessToken authenticationToken:authenticationToken refreshToken:refreshToken scopes:scopes expires:expires];
        
        NSNotification *notification =[NSNotification notificationWithName:LIVA_AUTH_TOKEN_REQUEST_SUCCEED object:session];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }else if (requestType==LIVE_QUERY_QUOTA) {
        [[NSUserDefaults standardUserDefaults]setObject:[uInfo objectForKey:@"quota"] forKey:@"NetbankQuota"];
        [[NSUserDefaults standardUserDefaults]setObject:[uInfo objectForKey:@"available"] forKey:@"NetbankAvailable"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else if (requestType==LIVE_GET_USER) {
        [[NSUserDefaults standardUserDefaults]setObject:[uInfo objectForKey:@"name"] forKey:@"NetbankUserName"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else if (requestType==LIVE_GET_HOME) {
        NSLog(@"%@",[uInfo objectForKey:@"upload_location"]);
        [self getFiles:[uInfo objectForKey:@"upload_location"]];
    }else if (requestType==LIVE_GET_FILES) {
        if (uInfo!=nil) {
            NSArray *arr=[uInfo objectForKey:@"data"];
            BOOL isExist=FALSE;
            NSString *folder=nil;
            for (int i=0; i<[arr count]; i++) {
                NSDictionary *dic=(NSDictionary*)[arr objectAtIndex:i];
                if (dic&&[[dic objectForKey:@"type"] isEqualToString:@"folder"]) {
                    NSString *folderName=[dic objectForKey:@"name"];
                    if ([folderName isEqualToString:LIVE_NOTE_FOLDER]) {
                        [[NSUserDefaults standardUserDefaults] setObject:[dic  objectForKey:@"id"] forKey:@"LiveNoteFolder"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        folder=[dic objectForKey:@"id"];
                        isExist=TRUE;
                    }
                }
            }
            if (!isExist) {
                [self createFolder:LIVE_NOTE_FOLDER];
            }else{
                [self getAllFiles:folder];
            }
        }
    }else if (requestType==LIVE_UPLOAD_FILE) {
       [self getAllFiles:[[NSUserDefaults standardUserDefaults] objectForKey:@"LiveNoteFolder"]];
    }else if (requestType==LIVE_CREATE_FOLDER) {
        [[NSUserDefaults standardUserDefaults]setObject:[uInfo objectForKey:@"id"] forKey:@"LiveNoteFolder"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else{
        [self queryQuota];
        NSString *aView=[userInformation objectForKey:@"ViewController"];
        if ([aView isEqualToString:@"Root"]) {
            NSArray *array=[uInfo objectForKey:@"data"];
            NSString  *fPath=nil;
            for (int i=0; i<[array count]; i++) {
                NSDictionary *dic=[array objectAtIndex:i];
                fPath=[dic objectForKey:@"name"];
                NSString *downPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
                if (![self isFileExist:[NSString stringWithFormat:@"%@/%@",downPath,fPath]]) {
                     [self downloadFile:[dic objectForKey:@"source"] fileName:fPath userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:LIVE_DOWNLOAD_FILE],LIVE_REQUEST_TYPE,@"Root",@"ViewController", nil]];
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
    NSDictionary *userInformation = [request userInfo];
    LIVERequestType requestType = [[userInformation objectForKey:LIVE_REQUEST_TYPE] intValue];
    
    if (requestType==LIVE_DOWNLOAD_FILE) {
        [self downloadFile:newURL path:[request downloadDestinationPath] userInfo:[request userInfo]];
    }
    NSLog(@"request will redirect %@ %@",[newURL description],[request downloadDestinationPath]);
}

@end
