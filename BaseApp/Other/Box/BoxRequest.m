//
//  BoxRequest.m
//  WBMuster
//
//  Created by xujun wu on 12-11-9.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "BoxRequest.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "StringUtil.h"


@implementation BoxRequest
@synthesize requestQueue,delegate,currentProperty;

-(id)initWithDelegate:(id<BoxRequestDelegate>)aDelegate
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

- (void)setGetUserInfo:(ASIHTTPRequest *)request withRequestType:(BOXRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:BOX_USER_INFO_REQUEST_TYPE];
    [request setUserInfo:dict];
}

- (void)setPostUserInfo:(ASIFormDataRequest *)request withRequestType:(BOXRequestType)requestType {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:requestType] forKey:BOX_USER_INFO_REQUEST_TYPE];
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
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

-(void)getTicket
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:BOX_APP_KEY forKey:@"api_key"];
    [dict setObject:@"get_ticket" forKey:@"action"];
    
    NSURL   *url=[self generateURL:BOX_GET_TICKET params:dict];
    
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    //    NSLog(@"%@",requestUrl);
    [self setGetUserInfo:request withRequestType:BOXGetTicket];
    [requestQueue addOperation:request];
}

-(NSURL*)getOAuthCodeUrl:(NSString*)ticket
{
    NSURL   *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BOX_API_AUTH,ticket]];
    NSLog(@"oauth url=%@",url);
    return url;
}

#pragma mark - 包括用户信息
-(void)getAuthToken
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"get_auth_token" forKey:@"action"];
    [dict setObject:BOX_APP_KEY forKey:@"api_key"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:BOX_USER_STORE_AUTH_TICKET] forKey:@"ticket"];
    NSURL   *url=[self generateURL:BOX_GET_TICKET params:dict];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    NSLog(@"BOXGetAuthToken url:%@",url);
    [self setGetUserInfo:request withRequestType:BOXGetAuthToken];
    [requestQueue addOperation:request];
}

-(void)getAllFiles
{
    NSURL   *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@/folders/0",BOX_API_DOMAIN]];
    NSString *hs=[NSString stringWithFormat:@"BoxAuth api_key=%@&auth_token=%@",BOX_APP_KEY,[[NSUserDefaults standardUserDefaults] objectForKey:BOX_USER_STORE_AUTH_TOKEN]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request setAuthenticationScheme:(NSString*)kCFHTTPAuthenticationSchemeBasic];
    [request setShouldPresentCredentialsBeforeChallenge:YES];
    [request addRequestHeader:@"Authorization" value:hs];
    
    NSLog(@"getAllFiles url:%@   %@",url,[request requestHeaders]);
    [self setGetUserInfo:request withRequestType:BoxGetAllFiles];
    [requestQueue addOperation:request];   
}


#pragma mark getData aMethod 百度方法
-(void)getData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    NSString *header=[NSString stringWithFormat:@"BoxAuth api_key=%@&auth_token=%@",BOX_APP_KEY,[[NSUserDefaults standardUserDefaults] objectForKey:BOX_USER_STORE_AUTH_TOKEN]];
    NSString *requestUrl =[NSString stringWithFormat:@"%@/%@",BOX_API_DOMAIN,aMethod];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[self generateURL:requestUrl params:aParams]];
    [request setAuthenticationScheme:(NSString*)kCFHTTPAuthenticationSchemeBasic];
    [request setShouldPresentCredentialsBeforeChallenge:YES];
    [request addRequestHeader:@"Authorization" value:header];
    [request setUserInfo:aUserInfo];
    [requestQueue addOperation:request];
    
}

-(void)postData:(NSString *)aMethod params:(NSMutableDictionary *)aParams userInfo:(NSDictionary *)aUserInfo
{
    NSString *header=[NSString stringWithFormat:@"BoxAuth api_key=%@&auth_token=%@",BOX_APP_KEY,[[NSUserDefaults standardUserDefaults] objectForKey:BOX_USER_STORE_AUTH_TOKEN]];
    NSString *requestUrl =[NSString stringWithFormat:@"%@/%@",BOX_API_DOMAIN,aMethod];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    [request setAuthenticationScheme:(NSString*)kCFHTTPAuthenticationSchemeBasic];
    [request setShouldPresentCredentialsBeforeChallenge:YES];
    [request addRequestHeader:@"Authorization" value:header];
    NSLog(@"postData:%@",requestUrl);
//    [request appendPostData:[self getPostData:aParams]];
    [request setUserInfo:aUserInfo];
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
    BOXRequestType requestType = [[userInformation objectForKey:BOX_USER_INFO_REQUEST_TYPE] intValue];
    NSString * responseString = [request responseString];
    NSLog(@"responseString = %@",responseString);
    
    if (requestType==BOXGetTicket) {
        NSRange statusBRang=[responseString rangeOfString:@"<status>"];
        NSRange ticketBRang=[responseString rangeOfString:@"<ticket>"];
        
        NSString *status=[responseString substringFromIndex:statusBRang.location+statusBRang.length];
        NSRange statusERang=[status rangeOfString:@"</status>"];
        status=[status substringToIndex:statusERang.location];
        NSString *ticket=[responseString substringFromIndex:ticketBRang.location+ticketBRang.length];
        NSRange ticketERang=[ticket rangeOfString:@"</ticket>"];
        ticket=[ticket substringToIndex:ticketERang.location];
        if ([status isEqualToString:@"get_ticket_ok"]) {
            if ([delegate respondsToSelector:@selector(didGetTicket:)]) {
                [delegate didGetTicket:ticket];
            }
        }
        return;
    }
    
    if (requestType==BOXGetAuthToken) {
        [self parserXMLData:[request responseData]];
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
    
    if ([delegate respondsToSelector:@selector(didGetDataFinished:userInfo:)]) {
        [delegate didGetDataFinished:uInfo userInfo:userInformation];
    }
   

}

//跳转
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    NSLog(@"request will redirect");
    NSNotification *notification = [NSNotification notificationWithName:BOXRequestFailed object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
-(void)parserXMLData:(NSData*)aData
{
    NSXMLParser *parser=[[NSXMLParser alloc]initWithData:aData];
    parser.delegate=self;
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName=qName;
    }
    if ([elementName isEqualToString:@"status"]||[elementName isEqualToString:@"auth_token"]||[elementName isEqualToString:@"login"]||[elementName isEqualToString:@"access_id"]||[elementName isEqualToString:@"user_id"]||[elementName isEqualToString:@"space_amount"]||[elementName isEqualToString:@"space_used"]||[elementName isEqualToString:@"max_upload_size"]){
        self.currentProperty=[[NSMutableString alloc]init];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (!self.currentProperty) {
        NSLog(@"无数据...");
        return;
    }
    if ([elementName isEqualToString:@"status"]) {
        NSLog(@"status:%@",currentProperty);
    }else if([elementName isEqualToString:@"auth_token"]){
        [[NSUserDefaults standardUserDefaults] setObject:self.currentProperty forKey:BOX_USER_STORE_AUTH_TOKEN];
        NSLog(@"auth_token:%@",self.currentProperty);
    }else if([elementName isEqualToString:@"login"]){
        
        [[NSUserDefaults standardUserDefaults] setObject:self.currentProperty forKey:BOX_USER_LOGIN];
        NSLog(@" NetbankUserName login:%@",self.currentProperty);
    }else if([elementName isEqualToString:@"access_id"]){
        
        [[NSUserDefaults standardUserDefaults] setObject:self.currentProperty forKey:BOX_USER_ACCESS_ID];
        NSLog(@"access_id:%@",self.currentProperty);
    }else if([elementName isEqualToString:@"user_id"]){
        [[NSUserDefaults standardUserDefaults] setObject:self.currentProperty forKey:BOX_USER_ID];
        NSLog(@"user_id:%@",self.currentProperty);
    }else if([elementName isEqualToString:@"space_amount"]){
        
        [[NSUserDefaults standardUserDefaults] setObject:self.currentProperty forKey:BOX_USER_SPACE_AMOUNT];
        NSLog(@"NetbankQuota  space_amount:%@",self.currentProperty);
    }else if([elementName isEqualToString:@"space_used"]){
        [[NSUserDefaults standardUserDefaults] setObject:self.currentProperty forKey:BOX_USER_SPACE_USED];
        NSLog(@"NetbankAvailable space_used:%@",self.currentProperty);
    }else if([elementName isEqualToString:@"max_upload_size"]){
        
        NSLog(@"max_upload_size:%@",self.currentProperty);
        [[NSUserDefaults standardUserDefaults]setObject:self.currentProperty forKey:BOX_USER_MAX_UPLOAD_SIZE];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    currentProperty=nil;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.currentProperty&&string&&[string length]>0) {
        [currentProperty appendString:string];
    }
}

@end
