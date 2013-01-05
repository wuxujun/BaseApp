//
//  UIButton+HLCategory.m
//  UniCms
//
//  Created by 吴旭俊 on 11-7-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIButton+HLCategory.h"


@implementation UIButton(HLCategory)

+ (id) buttonWithFrame:(CGRect)frame{
	return [UIButton buttonWithFrame:frame title:nil];
}
+ (id) buttonWithFrame:(CGRect)frame title:(NSString*)title{
	return [UIButton buttonWithFrame:frame title:title backgroundImage:nil];
}
+ (id) buttonWithFrame:(CGRect)frame title:(NSString*)title backgroundImage:(UIImage*)backgroundImage{
	return [UIButton buttonWithFrame:frame title:title backgroundImage:backgroundImage highlightedBackgroundImage:nil];
}
+ (id) buttonWithFrame:(CGRect)frame title:(NSString*)title backgroundImage:(UIImage*)backgroundImage highlightedBackgroundImage:(UIImage*)highlightedBackgroundImage{
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = frame;
	if(title!=nil) [btn setTitle:title forState:UIControlStateNormal];
	if(backgroundImage!=nil) [btn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	if(highlightedBackgroundImage!=nil) [btn setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
	return btn;
}

+ (id) buttonWithFrame:(CGRect)frame image:(UIImage*)image{
	return [UIButton buttonWithFrame:frame image:image highlightedImage:nil];
}
+ (id) buttonWithFrame:(CGRect)frame image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage{
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = frame;
	if(image!=nil) [btn setImage:image forState:UIControlStateNormal];
	if(highlightedImage!=nil) [btn setImage:image forState:UIControlStateHighlighted];
	return btn;
}


@end
