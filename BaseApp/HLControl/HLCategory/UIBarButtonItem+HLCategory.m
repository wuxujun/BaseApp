//
//  UIBarButtonItem+HLCategory.m
//  UniCms
//
//  Created by 吴旭俊 on 11-7-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItem+HLCategory.h"
#import "UIButton+HLCategory.h"

@implementation UIBarButtonItem(HLCategory)
/*
-(void)drawRect:(CGRect)rect
{
    UIImage *barImage=[UIImage imageNamed:@"ipad-bg3.png"];
    [barImage drawInRect:rect];
}
*/

+(UIBarButtonItem*)barButtonItemWithImage:(UIImage *)img backgroundImage:(UIImage *)backgroundImage highlightedBackgroundImage:(UIImage *)highlighedBackgroundImage target:(id)tget selector:(SEL)seld  
{
    UIButton *btn = [UIButton buttonWithFrame:CGRectMake(0,0,52,44) image:img];
	[btn addTarget:tget action:seld  forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	item.target = tget;
	item.action = seld;
	return item;
    
}

+(UIBarButtonItem*)barButtonItemWithTitle:(NSString *)tile backgroundImage:(UIImage *)backgroundImage highlightedBackgroundImage:(UIImage *)highlighedBackgroundImage target:(id)tget selector:(SEL)seld
{
    UIButton *btn=[UIButton buttonWithFrame:CGRectMake(0, 0, 52, 44) title:tile];
    [btn addTarget:tget action:seld forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	item.target = tget;
	item.action = seld;
	return item;
}
@end
