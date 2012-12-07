//
//  WaterStreamViewCell.m
//  BaseApp
//
//  Created by xujun wu on 12-12-7.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "WaterStreamViewCell.h"

#define kMinCellRect CGRectMake(0,0,50,50)
static NSString     *kUnIdentifier=@"UnIdentifier";

@interface WaterStreamViewCell()

@property (nonatomic,strong)UIImageView         *picImagerView;
@property (nonatomic,strong)UIView              *separatorView;

@end

@implementation WaterStreamViewCell
@synthesize separatorView=_separatorView1;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super init];
    if (self) {
        if (!reuseIdentifier) {
            reuseIdentifier=kUnIdentifier;
        }
        self.reuseIdentifier=reuseIdentifier;
        self.frame=kMinCellRect;
        self.picImagerView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.picImagerView.contentMode=UIViewContentModeScaleAspectFit;
        self.picImagerView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.picImagerView];
    }
    return self;
}

-(void)setPicDict:(NSDictionary *)picDict
{
    _picDict=picDict;
    NSString    *imageString=[picDict objectForKey:@"pic_url"];
    [self.picImagerView setImageWithURL:[NSURL URLWithString:imageString]];
}

@end
