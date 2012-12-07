//
//  HLDialog.m
//  UniCust
//
//  Created by 吴旭俊 on 11-5-13.
//  Copyright 2011 huawei. All rights reserved.
//

#import "HLDialog.h"


@implementation HLDialog


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	/*NSURL* url = request.URL;
	if ([url.scheme isEqualToString:@"connect"]) {
		if ([url.resourceSpecifier isEqualToString:@"cancel"]) {
			[self dismissWithSuccess:NO animated:YES];
		} else {
			[self dialogDidSucceed:url];
		}
		return NO;
	} else if ([_loadingURL isEqual:url]) {
		return YES;
	} else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		if ([_delegate respondsToSelector:@selector(dialog:shouldOpenURLInExternalBrowser:)]) {
			if (![_delegate dialog:self shouldOpenURLInExternalBrowser:url]) {
				return NO;
			}
		}
		
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	} else {
		return YES;
	}*/
    return YES;
}


@end
