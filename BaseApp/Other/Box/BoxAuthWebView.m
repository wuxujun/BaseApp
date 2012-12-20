//
//  BoxAuthWebView.m
//  BaseApp
//
//  Created by xujun wu on 12-11-26.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "BoxAuthWebView.h"
#import "BoxRequest.h"
#import "BoxManager.h"

@interface BoxAuthWebView ()<UIWebViewDelegate,BoxRequestDelegate>

@end

@implementation BoxAuthWebView
@synthesize webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title=@"Box用户登陆";
    
    self.navigationItem.hidesBackButton=YES;
    
    
    UIBarButtonItem  *clearBtn=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clearAction:)];
    self.navigationItem.rightBarButtonItem=clearBtn;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:true] forKey:@"OAuthStatus"];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:BOX_USER_STORE_AUTH_TOKEN];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:BOX_USER_STORE_AUTH_TICKET];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    loading=[[MBProgressHUD alloc]initWithView:self.view];
    loading.delegate=self;
    loading.labelText=@"登录请求中.请稍候...";
    
    webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate=self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadData:) name:BOXRequestTicketFinished object:nil];
    
    [[BoxManager getInstance] getTicket];   
    [self.view addSubview:webView];
    [self.view addSubview:loading];
    [loading show:YES];
}

-(void)loadData:(NSNotification*)sender
{
    NSLog(@"%@",sender.object);
    [loading removeFromSuperview];
    NSURL *url=[[BoxManager getInstance] getOAuthCodeUrl:sender.object];
    NSMutableURLRequest     *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clearAction:(id)sender
{
    //    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:IS_WEIBO];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
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
//    UIApplication *app=[UIApplication sharedApplication];
//    UIWindow *window = nil;
//    for (UIWindow *win in app.windows) {
//        if (win.tag == 1) {
//            window = win;
//            window.windowLevel = UIWindowLevelNormal;
//        }
//        if (win.tag == 0) {
//            [win makeKeyAndVisible];
//        }
//    }
//    
	NSURL *url = [request URL];
    NSLog(@"webview's url = %@",url);
	NSArray *array = [[url absoluteString] componentsSeparatedByString:@"?"];
	if ([array count]>1) {
		[self dialogDidSucceed:url];
		return NO;
	}
    
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"========webViewDidStartLoad =======");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [loading removeFromSuperview];
    NSLog(@"===============webViewDidFinishLoad=========");
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
    token=[self getStringFromUrl:q needle:@"auth_token="];
    
    NSString *errorCode=[self getStringFromUrl:q needle:@"error="];
    if (errorCode!=nil&&[errorCode isEqualToString:@"21330"]) {
        NSLog(@"OAuth canceled");
    }
    
    NSString *ticket  = [self getStringFromUrl:q needle:@"ticket="];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:BOX_USER_STORE_AUTH_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:ticket forKey:BOX_USER_STORE_AUTH_TICKET];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (token) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DID_GET_TOKEN_IN_WEB_VIEW object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark MBProgressHUDDeleagate
-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [loading removeFromSuperview];
    loading=nil;
}

@end
