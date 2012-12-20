//
//  ImageScrollView.m
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "ImageScrollView.h"

@implementation ImageScrollView
@synthesize doubleClicked,touchedPoint;

-(void)postTapNotif
{
    if (!doubleClicked) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tapClicked" object:self];
    }
}

@end
