//
//  UIBarButtonItem+HLCategory.h
//  UniCms
//
//  Created by 吴旭俊 on 11-7-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIBarButtonItem(HLCategory)
+(UIBarButtonItem*)barButtonItemWithTitle:(NSString *)title backgroundImage:(UIImage*)backgroundImage highlightedBackgroundImage:(UIImage*)highlighedBackgroundImage target:(id)target selector:(SEL)selector;


+ (UIBarButtonItem*) barButtonItemWithImage:(UIImage*)image
							backgroundImage:(UIImage*)backgroundImage 
				 highlightedBackgroundImage:(UIImage*)highlighedBackgroundImage 
									 target:(id)target selector:(SEL)selector;

@end
