//
//  OAuthWebController.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-26.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthRequest.h"

#define  OAuthRequestFinish  @"OAuthRequestFinish"

@interface OAuthWebController: UIViewController
{
    UIWebView           *webView;

}

@property (nonatomic,strong)IBOutlet    UIWebView   *webView;
@property (nonatomic)enum OAuthId    oauthId;

@end
