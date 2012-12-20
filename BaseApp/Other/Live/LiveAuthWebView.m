//
//  LiveAuthWebView.m
//  BaseApp
//
//  Created by xujun wu on 12-11-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "LiveAuthWebView.h"
#import "LiveManager.h"

@interface LiveAuthWebView ()<UIWebViewDelegate>

@end

@implementation LiveAuthWebView
@synthesize webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title=@"微软SkyDrive登录";
    //隐藏返回按钮
    self.navigationItem.hidesBackButton=YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"OAuthStatus"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    UIBarButtonItem  *clearBtn=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clearAction:)];
    self.navigationItem.rightBarButtonItem=clearBtn;
    
    webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate=self;
    
    NSURL   *url=[[LiveManager getInstance] getAuthCodeUrl];
    NSMutableURLRequest     *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OAuthFinished:) name:LIVA_AUTH_TOKEN_REQUEST_SUCCEED object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    loading=[[MBProgressHUD alloc]initWithView:self.view];
    loading.labelText=@"数据请求中.请稍候...";
    loading.delegate=self;
    [self.view addSubview:loading];
    [loading show:YES];
}

-(void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clearAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"currentDBankType"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.navigationController popViewControllerAnimated:NO];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{   
	NSURL *url = [request URL];
    NSLog(@"webview's url = %@",url);
	NSArray *array = [[url absoluteString] componentsSeparatedByString:[NSString stringWithFormat:@"%@?",CALL_BACK_URL]];
	if ([array count]>1) {
        [self dialogDidSucceed:url];
		return NO;
	}
    
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"LiveAuthWebView webViewDidStartLoad....");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"LiveAuthWebView webViewDidFinishLoad....");
    [loading removeFromSuperview];
    loading=nil;
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
    token=[self getStringFromUrl:q needle:@"code="];
    
    NSString *errorCode=[self getStringFromUrl:q needle:@"error_code="];
    if (errorCode!=nil&&[errorCode isEqualToString:@"21330"]) {
        NSLog(@"OAuth canceled");
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:LIVE_TOKEN_CODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (token) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:OAUTH_REQUEST_FINISHED object:nil userInfo:[NSDictionary dictionaryWithObject:@"NetBank_LIVE" forKey:@"OAuthType"]];
//        [self.navigationController popViewControllerAnimated:YES];
        [[LiveManager getInstance] retrieveToken];
    }
}

-(void)OAuthFinished:(NSNotification*)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OAUTH_REQUEST_FINISHED object:nil userInfo:[NSDictionary dictionaryWithObject:@"NetBank_LIVE" forKey:@"OAuthType"]];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [loading removeFromSuperview];
    loading=nil;
}

@end
