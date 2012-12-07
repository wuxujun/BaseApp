//
//  HLQuickLook.m
//  TelCust
//
//  Created by 吴旭俊 on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HLQuickLook.h"


@implementation HLQuickLook
@synthesize paths;

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return [paths count];
}

-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSLog(@"%d  %@",index,[paths objectAtIndex:index]);
    NSURL *url=[NSURL fileURLWithPath:[paths objectAtIndex:index]];
    return url;
}

@end
