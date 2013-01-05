//
//  TBaoWebViewController.m
//  SAnalysis
//
//  Created by xujun wu on 12-11-2.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "TBaoWebViewController.h"
#import "TBaoRequest.h"


@interface TBaoWebViewController ()<UIWebViewDelegate>

@end

@implementation TBaoWebViewController
@synthesize	webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title=@"淘宝帐号登录";
	self.navigationItem.hidesBackButton=YES;
	
	webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
	webView.delegate=self;
    TBaoRequest *manager=[[TBaoRequest alloc]initWithDelegate:self];
    NSURL   *url=[manager getOAuthCodeUrl];
    NSMutableURLRequest     *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [webView loadRequest:request];
	
	[self.view addSubview:webView];
}

-(void)viewDidUnload
{
	[self setWebView:nil];
	[super viewDidUnload];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    UIApplication *app=[UIApplication sharedApplication];
    UIWindow *window = nil;
    for (UIWindow *win in app.windows) {
        if (win.tag == 1) {
            window = win;
            window.windowLevel = UIWindowLevelNormal;
        }
        if (win.tag == 0) {
            [win makeKeyAndVisible];
        }
    }
    
	NSURL *url = [request URL];
    NSLog(@"webview's url = %@",url);
	NSArray *array = [[url absoluteString] componentsSeparatedByString:@"#"];
	if ([array count]>1) {
		[self dialogDidSucceed:url];
		return NO;
	}
    
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{

}

-(NSString*)getStringFromUrl:(NSString*)url needle:(NSString*)needle
{
    NSString    *str=nil;
    NSRange  start=[url rangeOfString:needle];
    if (start.location!=NSNotFound) {
        NSRange end=[[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger  offset=start.location+start.length;
        str=end.location==NSNotFound?[url substringFromIndex:offset]:[url substringWithRange:NSMakeRange(offset, end.location)];
        str=[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return str;
}

-(void)dialogDidSucceed:(NSURL*)url
{
    NSString *q=[url absoluteString];
    token=[self getStringFromUrl:q needle:@"access_token="];
    
    NSString *errorCode=[self getStringFromUrl:q needle:@"error_code="];
    if (errorCode!=nil&&[errorCode isEqualToString:@"21330"]) {
        NSLog(@"OAuth canceled");
    }
    
    NSString *refreshToken  = [self getStringFromUrl:q needle:@"refresh_token="];
    NSString *expTime       = [self getStringFromUrl:q needle:@"expires_in="];
    NSString *uid           = [self getStringFromUrl:q needle:@"uid="];
    NSString *remindIn      = [self getStringFromUrl:q needle:@"remind_in="];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:TB_STORE_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:TB_STORE_USER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSDate *expirationDate =nil;
    NSLog(@"jtone \n\ntoken=%@\nrefreshToken=%@\nexpTime=%@\nuid=%@\nremindIn=%@\n\n",token,refreshToken,expTime,uid,remindIn);
    if (expTime != nil) {
        int expVal = [expTime intValue]-3600;
        if (expVal == 0)
        {
            
        } else {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
//            [[NSUserDefaults standardUserDefaults]setObject:expirationDate forKey:USER_STORE_EXPIRATION_DATE];
//            [[NSUserDefaults standardUserDefaults] synchronize];
			NSLog(@"jtone time = %@",expirationDate);
        }
    }
    if (token) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_GET_TOKEN_IN_WEB_VIEW object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }   
}

@end
