//
//  HomeItemView.m
//  FindAD
//
//  Created by  on 11-12-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HomeItemView.h"
#import "ColorUtils.h"

#import <QuartzCore/QuartzCore.h>

@interface HomeItemView()<ChartViewDelegate>{

    UILabel     *_labelForString;

}

-(UIImage*)getImage;
-(CGSize)sizeThatFitsString:(NSString *)string fontSize:(float)fSize;
-(void)updateLabelForLayer:(CAShapeLayer *)pieLayer value:(NSString*)value;


@end

@implementation HomeItemView
@synthesize chartView,message,title,dataUrl,touchBackView;


- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    if (!(self = [super initWithFrame:frame])) return nil;
    delegate=aDelegate;

    [self initializeFields];
    
    UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handelSingleTap:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapRecognizer];

    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.touchBackView=[[UIView alloc]init];
    self.touchBackView.backgroundColor=[UIColor colorWithWhite:0.9 alpha:0.5];
    self.touchBackView.hidden=YES;
    [contentView addSubview:self.touchBackView];
    
    
    imageView=[[UIImageView alloc]init];
    imageView.contentMode=UIViewContentModeScaleToFill;
    //[contentView addSubview:imageView];
    
    chartView=[[ChartView alloc]init];
    chartView.delegate=self;
    chartView.chartStyle=HLChartViewStyleLine;
    
    [contentView addSubview:chartView];
    
    titleLabel=[[UILabel alloc]init];
    titleLabel.font=[UIFont fontWithName:@"Helvetica" size:12.0f];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setBackgroundColor:[UIColor lightGrayColor]];
    if (message) {
        [titleLabel setText:[NSString stringWithFormat:@"  %@",message.title]];
    }
    [contentView addSubview:titleLabel];
    
    
    [self addSubview:contentView];
    [self reAdjustLayout];
    
}

-(void)setTitle:(NSString *)aTitle
{
    [titleLabel setText:[NSString stringWithFormat:@"  %@",aTitle]];
    [self setNeedsDisplay];
}

-(void)setDataUrl:(NSString *)aUrl
{
    dataUrl=aUrl;
    chartView.requestUrl=dataUrl;
    [chartView setChartViewTitle:NULL isTouch:NO showLegend:NO];
    [chartView loadData];
}

-(CGSize)sizeThatFitsString:(NSString *)string fontSize:(float)fSize
{
    if (_labelForString==nil) {
        _labelForString=[[UILabel alloc]init];
        [_labelForString setFont:[UIFont boldSystemFontOfSize:fSize]];
    }
    [_labelForString setText:string];
    CGSize size=[_labelForString sizeThatFits:CGSizeZero];
    [_labelForString setText:nil];
    return size;
}

-(void)updateLabelForLayer:(CAShapeLayer *)pieLayer value:(NSString*)value
{
    NSString *label=[NSString stringWithFormat:@"%@",value];
    CGSize size=[self sizeThatFitsString:label fontSize:17.0];
    CATextLayer *textLayer=[[pieLayer sublayers]objectAtIndex:0];
    [textLayer setString:label];
    [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
}

-(void)chartDidLoadFinish:(BOOL)flag
{
    if (flag) {
        [chartView removeFromSuperview];
        [contentView addSubview:chartView];
        [self setNeedsDisplay];
    }
}


-(void)handelSingleTap:(UITapGestureRecognizer*)recognizer
{
    [self performSelector:@selector(singleTap:) withObject:nil afterDelay:0.2];
}
-(void)singleTap:(id)sender
{
    [delegate onItemClicked:self];
}

-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
//    NSLog(@"HomeItemView reAdjustLayout init:%f %f %f ,%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
    [contentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-1)];
    CGSize contentViewArea=CGSizeMake((contentView.frame.size.width), (contentView.frame.size.height));
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(0, contentViewArea.height-25, contentViewArea.width, 25)];
    [imageView setFrame:CGRectMake(0, 0, contentViewArea.width, contentViewArea.height-25)];
    [chartView sizeToFit];
    [chartView setFrame:CGRectMake(0, 0, contentViewArea.width, contentViewArea.height-25)];
    [chartView rotate:currrentInterfaceOrientation animation:YES];
    self.touchBackView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchBackView.hidden=NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchBackView.hidden=YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchBackView.hidden=YES;
}

@end
