//
//  BoxAuthWebView.h
//  BaseApp
//
//  Created by xujun wu on 12-11-26.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface BoxAuthWebView : UIViewController<MBProgressHUDDelegate>
{
    MBProgressHUD       *loading;
    UIWebView           *webView;
    NSString            *token;
}
@property (nonatomic,strong)IBOutlet    UIWebView   *webView;
@end
