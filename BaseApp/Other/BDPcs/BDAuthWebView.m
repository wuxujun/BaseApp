//
//  BDAuthWebView.m
//  BaseApp
//
//  Created by xujun wu on 12-11-26.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "BDAuthWebView.h"
#import "BDManager.h"

@interface BDAuthWebView ()<UIWebViewDelegate>

@end

@implementation BDAuthWebView
@synthesize webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title=@"百度用户登陆";
    
    self.navigationItem.hidesBackButton=YES;
    
    
    UIBarButtonItem  *clearBtn=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clearAction:)];
    self.navigationItem.rightBarButtonItem=clearBtn;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"OAuthStatus"];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:BD_USER_STORE_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:BD_USER_STORE_USER_ID];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:BD_USER_STORE_EXPIRATION_DATE];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate=self;
    
    NSURL   *url=[[BDManager getInstance] getOAuthCodeUrl];
    NSMutableURLRequest     *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clearAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CurrentNetBankType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.tabBarController.selectedIndex=0;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
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
    
    NSString *errorCode=[self getStringFromUrl:q needle:@"error="];
    if (errorCode!=nil&&[errorCode isEqualToString:@"21330"]) {
        NSLog(@"OAuth canceled");
    }
    
    NSString *sessionKey           = [self getStringFromUrl:q needle:@"session_key="];
    NSString *sessionSecret      = [self getStringFromUrl:q needle:@"session_secret="];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:BD_USER_STORE_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults]setObject:sessionKey forKey:BD_USER_STORE_SESSION_KEY];
    [[NSUserDefaults standardUserDefaults]setObject:sessionSecret forKey:BD_USER_STORE_SESSION_SECRET];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (token) {
        [[NSNotificationCenter defaultCenter] postNotificationName:OAUTH_REQUEST_FINISHED object:nil userInfo:[NSDictionary dictionaryWithObject:@"NetBank_BAIDU" forKey:@"OAuthType"]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

@end
