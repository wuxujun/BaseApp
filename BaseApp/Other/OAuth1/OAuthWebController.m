//
//  OAuthWebController.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-26.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "OAuthWebController.h"
#import "RequestManager.h"

@interface OAuthWebController ()<UIWebViewDelegate>{
    RequestManager      *oauthRequest;

}
@end

@implementation OAuthWebController
@synthesize webView;
@synthesize oauthId=_oauthId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"应用授权";
	// Do any additional setup after loading the view.
    webView=[[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.delegate=self;
    
    UIBarButtonItem  *clearBtn=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clearAction:)];
    self.navigationItem.rightBarButtonItem=clearBtn;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishToken:) name:RequestOAuthToken object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishAccessToken:) name:RequestOAuthAccessToken object:nil];
    
    oauthRequest=[RequestManager getInstance];
    [oauthRequest getOAuthToken:self.oauthId];
    
    [self.view addSubview:webView];
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

-(void)didFinishToken:(NSNotification*)sender
{
    NSLog(@"%@",sender.object);
    
    NSMutableURLRequest     *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://login.dbank.com/oauth1/authorize?oauth_token=%@",sender.object]]];
    [webView loadRequest:request];
}

-(void)didFinishAccessToken:(NSNotification*)sender
{
    NSLog(@"accessToken:%@",sender.object);
    
    NSNotification *notification =[NSNotification notificationWithName:OAuthRequestFinish object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self.navigationController popViewControllerAnimated:YES];
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
    
	NSURL *url = [request URL];
    NSLog(@"webview's url = %@",url);
    NSArray *array = [[url absoluteString] componentsSeparatedByString:@"oauth_verifier"];
	if ([array count]>1) {
        NSString *q=[url absoluteString];
        NSString *token=[self getStringFromUrl:q needle:@"oauth_token="];
        NSString *oauthVerifier  = [self getStringFromUrl:q needle:@"oauth_verifier="];
        [oauthRequest getOAuthAccessToken:1 token:token verifier:oauthVerifier];
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

}


@end
