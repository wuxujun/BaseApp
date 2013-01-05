//
//  DDataViewCell.m
//  NetGrid
//
//  Created by 吴旭俊 on 12-9-29.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "DDataViewCell.h"
#import "ColorUtils.h"


@implementation DDataViewCell
@synthesize  titleLabel,rowIndex,columnIndex,maxColumns,maxRows;

- (id)initWithReuseIdentifier:(NSString *)identifier
{
    if (!(self==[super initWithReuseIdentifier:identifier])) {
        // Initialization code
        return nil;
    }
    titleLabel=[[UILabel alloc]init];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.textColor=[UIColor blackColor];
    backgroud=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    backgroud.image=[UIImage imageNamed:@"top_m.png"];
    backgroud.contentMode=UIViewContentModeScaleToFill;
    
    return self;
}

-(void)setRowIndex:(int)aIndex
{
    rowIndex=aIndex;
    if (aIndex>0) {
        self.titleLabel.font=[UIFont systemFontOfSize:12.0f];
        self.titleLabel.contentMode=UIViewContentModeScaleToFill;
    }else{
        self.titleLabel.backgroundColor=[UIColor homeBackground];
        self.titleLabel.font=[UIFont boldSystemFontOfSize:14.0f];
    }
    [self setNeedsDisplay];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)prepareForReuse
{
    self.frame=CGRectZero;
}

-(void)drawRect:(CGRect)rect
{
    int x=1,y=1,w=self.frame.size.width-1,h=self.frame.size.height-1;
    if (rowIndex==maxRows-1) {
        h=self.frame.size.height-2*y;
    }
    if (columnIndex==maxColumns-1) {
        w=self.frame.size.width-2*x;
    }
    self.titleLabel.frame=CGRectMake(x, y, w, h);
    [self addSubview:self.titleLabel];
    [self layoutSubviews];
}

@end
