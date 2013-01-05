//
//  OAuthWebViewController.h
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-22.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAuthWebViewController : UIViewController
{
    UIWebView           *webView;
    NSString            *token;
}

@property (nonatomic,strong)IBOutlet    UIWebView   *webView;

@end
