//
//  HImageViewCell.m
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-19.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "HImageViewCell.h"

#define TOP_MARGIN 8.0f
#define LEFT_MARGIN 8.0f

#define IMAGE_VIEW_BG [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];

@implementation HImageViewCell

-(id)initWithIdentifier:(NSString *)indentifier
{
    if (self=[super initWithReuseIdentifier:indentifier]) {

    }
    return self;
}

-(void)setImageWithURL:(NSURL *)imageUrl
{
    [imageView setImageWithURL:imageUrl];
}

-(void)setImage:(UIImage *)image
{
    imageView.image=image;
}

@end
