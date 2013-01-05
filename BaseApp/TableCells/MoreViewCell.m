//
//  MoreViewCell.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-31.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "MoreViewCell.h"

@implementation MoreViewCell
@synthesize title,desc,isLogin;
@synthesize delegate;

-(id)initWithFrame:(CGRect)frame type:(int)aType
{
    self=[super initWithFrame:frame];
    if (self) {
        type=aType;
        [self initializeFields];
    }
    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    [contentView setBackgroundColor:[UIColor clearColor]];
    contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    titleLabel=[[UILabel alloc]init];
    titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:titleLabel];
    
    descLabel=[[UILabel alloc]init];
    descLabel.font=[UIFont fontWithName:@"Helvetica" size:12.0f];
    [descLabel setTextColor:[UIColor blackColor]];
    [descLabel setBackgroundColor:[UIColor clearColor]];
    
    onButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [onButton addTarget:self action:@selector(didButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (type==1){
        [contentView addSubview:descLabel];
        [contentView addSubview:onButton];
    }
    [self addSubview:contentView];
    [self reAdjustLayout];
}

-(void)setTitle:(NSString *)aTitle
{
    [titleLabel setText:[NSString stringWithFormat:@"%@",aTitle]];
    [self setNeedsDisplay];
}

-(void)setDesc:(NSString *)aDesc
{
    [descLabel setText:[NSString  stringWithFormat:@"%@",aDesc]];
    [self setNeedsDisplay];
}

-(void)setIsLogin:(BOOL)isLogin
{
    if (isLogin) {
        [onButton setTitle:@"注销" forState:UIControlStateNormal];
    }else{
        [onButton setTitle:@"登录" forState:UIControlStateNormal];
    }
}

-(IBAction)didButtonClicked:(id)sender
{
    [delegate onButtonClicked:self];
}

-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    [contentView setFrame:CGRectMake(5, 0, self.frame.size.width-10, self.frame.size.height)];

    CGSize contentViewArea=CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    [titleLabel sizeToFit];
    if (type==0) {
        [titleLabel setFrame:CGRectMake(10, 0, contentViewArea.width, contentViewArea.height) ];
    }else{
        [titleLabel setFrame:CGRectMake(10, 5, contentViewArea.width, 35)];
    }
    [descLabel setFrame:CGRectMake(10, 35, contentViewArea.width, 25)];
    [onButton setFrame:CGRectMake(contentViewArea.width-90, (contentViewArea.height-30)/2, 80, 35)];
}


@end
