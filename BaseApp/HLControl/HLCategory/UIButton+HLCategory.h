//
//  UIButton+HLCategory.h
//  UniCms
//
//  Created by 吴旭俊 on 11-7-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIButton(HLCategory)

+ (id) buttonWithFrame:(CGRect)frame;
+ (id) buttonWithFrame:(CGRect)frame title:(NSString*)title;
+ (id) buttonWithFrame:(CGRect)frame title:(NSString*)title backgroundImage:(UIImage*)backgroundImage;
+ (id) buttonWithFrame:(CGRect)frame title:(NSString*)title backgroundImage:(UIImage*)backgroundImage highlightedBackgroundImage:(UIImage*)highlightedBackgroundImage;
+ (id) buttonWithFrame:(CGRect)frame image:(UIImage*)image;
+ (id) buttonWithFrame:(CGRect)frame image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage;

@end
