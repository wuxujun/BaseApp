//
//  DBankAuthWebView.m
//  BaseApp
//
//  Created by xujun wu on 12-11-30.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "DBankAuthWebView.h"
#import "DBankManager.h"

@interface DBankAuthWebView ()<UIWebViewDelegate,MBProgressHUDDelegate>

@end

@implementation DBankAuthWebView
@synthesize webView;

// 1.getOAuthToken;
// 2.输入信息
// 3.getOAuthAccessToken


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title=@"华为网盘登录";
    //隐藏返回按钮
    self.navigationItem.hidesBackButton=YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"OAuthStatus"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
	// Do any additional setup after loading the view.
    webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate=self;
    
    UIBarButtonItem  *clearBtn=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clearAction:)];
    self.navigationItem.rightBarButtonItem=clearBtn;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishToken:) name:HWRequestOAuthToken object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishAccessToken:) name:HWRequestOAuthAccessToken object:nil];
    
    [[DBankManager getInstance] getOAuthToken];
    [self.view addSubview:webView];
}

-(void)viewWillAppear:(BOOL)animated
{
    loading=[[MBProgressHUD alloc]initWithView:self.view];
    loading.delegate=self;
    loading.labelText=@"授权登录请求中.请稍候...";
    [self.view addSubview:loading];
    [loading show:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clearAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"CurrentNetBankType"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)didFinishToken:(NSNotification*)sender
{
    NSLog(@"%@",sender.object);
    
    NSMutableURLRequest     *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@",HW_API_AUTHORIZE,sender.object]]];
    [webView loadRequest:request];
}

#pragma mark - OAuth Request 完成
-(void)didFinishAccessToken:(NSNotification*)sender
{
    NSLog(@"accessToken:%@",sender.object);
    NSNotification *notification =[NSNotification notificationWithName:OAUTH_REQUEST_FINISHED object:nil userInfo:[NSDictionary dictionaryWithObject:@"NetBank_HW" forKey:@"OAuthType"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
    NSLog(@"webview's url = %@",url);
    NSArray *array = [[url absoluteString] componentsSeparatedByString:@"oauth_verifier"];
	if ([array count]>1) {
        NSString *q=[url absoluteString];
        NSString *token=[self getStringFromUrl:q needle:@"oauth_token="];
        NSString *oauthVerifier  = [self getStringFromUrl:q needle:@"oauth_verifier="];
        [[DBankManager getInstance] getOAuthAccessToken:token verifier:oauthVerifier];
        return NO;
	}
    return YES;
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
    NSString *token=[self getStringFromUrl:q needle:@"oauth_token="];
    
    NSString *errorCode=[self getStringFromUrl:q needle:@"error_code="];
    if (errorCode!=nil&&[errorCode isEqualToString:@"21330"]) {
        NSLog(@"OAuth canceled");
    }
    NSString *oauthVerifier  = [self getStringFromUrl:q needle:@"oauth_verifier="];
    if (token) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_GET_TOKEN_IN_WEB_VIEW object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [loading removeFromSuperview];
    loading=nil;
}

-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [loading removeFromSuperview];
    loading=nil;
}

@end
