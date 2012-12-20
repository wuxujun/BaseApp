//
//  MGlobal.m
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MGlobal.h"
#import <UIKit/UIKit.h>

static NSString     *BASEURL;
@implementation MGlobal

+(void)showAlertView:(NSString *)aTitle message:(NSString *)aMessage delegate:(id)aDelegate buttonTitle:(NSString *)aButtonTitle cancelButtonTitle:(NSString *)aCancelButtonTitle
{
    UIAlertView *aView=[[UIAlertView alloc]initWithTitle:aTitle message:aMessage delegate:aDelegate cancelButtonTitle:aCancelButtonTitle otherButtonTitles:aButtonTitle, nil];
    [aView dismissWithClickedButtonIndex:0 animated:YES];
    [aView show];
}

+(void)setBaseURL:(NSString *)baseURL
{
    BASEURL=[[NSString alloc]initWithString:baseURL];
}

+(NSString*)getBaseURL
{
    return BASEURL;
}

@end
