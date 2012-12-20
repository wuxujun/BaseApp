//
//  BDAuthWebView.h
//  BaseApp
//
//  Created by xujun wu on 12-11-26.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDAuthWebView : UIViewController
{
    UIWebView           *webView;
    NSString            *token;
}
@property (nonatomic,strong)IBOutlet        UIWebView       *webView;

@end
