//
//  DBankAuthWebView.h
//  BaseApp
//
//  Created by xujun wu on 12-11-30.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define  DBankRequestFinish  @"DBankRequestFinish"

@interface DBankAuthWebView : UIViewController
{
    MBProgressHUD               *loading;
    UIWebView                   *webView;
}
@property (nonatomic,strong)IBOutlet  UIWebView     *webView;

@end
