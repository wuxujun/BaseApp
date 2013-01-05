//
//  TBaoWebViewController.h
//  SAnalysis
//
//  Created by xujun wu on 12-11-2.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBaoWebViewController : UIViewController
{
	UIWebView				*webView;
	NSString				*token;
}
@property(nonatomic,strong)IBOutlet		UIWebView		*webView;

@end
