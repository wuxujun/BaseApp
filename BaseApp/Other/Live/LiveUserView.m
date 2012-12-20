//
//  LiveUserView.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-31.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "LiveUserView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation LiveUserView
@synthesize name,iconUrl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeFields];
    }
    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    [contentView setBackgroundColor:[UIColor clearColor]];
    contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    nameLabel=[[UILabel alloc]init];
    nameLabel.font=[UIFont boldSystemFontOfSize:16.0f];
    [nameLabel setContentMode:UIViewContentModeTop];
    [nameLabel setTextColor:[UIColor blackColor]];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:nameLabel];
    
    iconView=[[UIImageView alloc]init];
    
    [contentView addSubview:iconView];
    [self addSubview:contentView];
    [self reAdjustLayout];

}
-(void)setName:(NSString *)aName
{
    [nameLabel setText:[NSString stringWithFormat:@"姓名:%@",aName]];
    [self setNeedsDisplay];
}

-(void)setIconUrl:(NSString *)aIconUrl
{
    [iconView setImageWithURL:[NSURL URLWithString:aIconUrl]];
    [self setNeedsDisplay];
}

-(void)reAdjustLayout
{
    [contentView setFrame:CGRectMake(5, 0, self.frame.size.width-10, self.frame.size.height)];
    CGSize contentViewArea=CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    [nameLabel setFrame:CGRectMake(110, 10, contentViewArea.width-120, contentViewArea.height) ];
    [iconView setFrame:CGRectMake(5, 5, 100, 100)];
}

@end
