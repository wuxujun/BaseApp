//
//  UINavigationBar+HLCategory.m
//  UniCms
//
//  Created by 吴旭俊 on 11-7-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+HLCategory.h"


@implementation UINavigationBar(HLCategory)


-(void)drawRect:(CGRect)rect
{
    UIImage *barImage=[UIImage imageNamed:@"copymove-cell-bg"];
    [barImage drawInRect:rect];
}

@end
