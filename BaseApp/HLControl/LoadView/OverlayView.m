//
//  OverlayView.m
//  GrpCust
//
//  Created by 吴旭俊 on 11-9-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "OverlayView.h"
#import <QuartzCore/QuartzCore.h>


@implementation OverlayView
@synthesize mode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.hidden=true;
    
    spinner=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    NSLog(@"%f,%f",self.frame.size.height,frame.size.height);
    spinner.frame=CGRectMake((self.frame.size.width-20)/2, (self.frame.size.height-20)/2, 20, 20);
    spinner.hidesWhenStopped=YES;
    [self addSubview:spinner];
    
    return self;
}

-(void)setMode:(OverlayViewMode)aMode
{
    mode=aMode;
    [spinner stopAnimating];
    switch (mode) {
        case OVERLAY_MODE_HIDDEN:
            self.hidden=true;
            break;
        case OVERLAY_MODE_DARKEN:
            self.alpha=1.0;
            self.opaque=false;
            self.hidden=false;
            self.backgroundColor=[UIColor clearColor];
            break;
        case OVERLAY_MODE_SHADOW:
            self.backgroundColor=[UIColor clearColor];
            self.opaque=false;
            self.hidden=false;
            self.alpha=1.0;
            break;
    }

    [self setNeedsDisplay];
}

-(void)setMessage:(NSString *)aMessage spinner:(BOOL)flag
{
    message=aMessage;
    if (flag) {
        [spinner startAnimating];
    }else{
        [spinner stopAnimating];
    }
    mode=OVERLAY_MODE_MESSAGE;
    self.backgroundColor=[UIColor clearColor];
    self.opaque=true;
    self.hidden=false;
    self.alpha=1.0;
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame
{
    spinner.frame=CGRectMake((frame.size.width-20)/2, (frame.size.height-20)/2, 20, 20);
    [self setNeedsLayout];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (mode==OVERLAY_MODE_SHADOW) {
        rect.size.height=13;
        
    }else if(mode==OVERLAY_MODE_MESSAGE){
        CGContextRef context=UIGraphicsGetCurrentContext();
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [[UIColor whiteColor]CGColor]);
        [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]set];
        CGSize result=[message drawInRect:CGRectMake(0, (self.frame.size.height-20)/2, self.frame.size.width, 20) withFont:[UIFont systemFontOfSize:14.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
        CGRect r=spinner.frame;
        r.origin.x=((self.frame.size.width-result.width)/2)-25;
        spinner.frame=r;
    }else{
        [super drawRect:rect];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mode==OVERLAY_MODE_SHADOW) {
        NSLog(@"@#");
    }
    UITouch *t=[touches anyObject];
    point=[t locationInView:self];
    moved=NO;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (moved==OVERLAY_MODE_SHADOW) {
        NSLog(@"!@#");
    }
    UITouch *t=[touches anyObject];
    CGPoint pt=[t locationInView:self];
    if (point.x!=pt.x||point.y!=pt.y) {
        moved=YES;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (moved==OVERLAY_MODE_SHADOW) {
        NSLog(@"00000");
    }
    UITouch *t=[touches anyObject];
    CGPoint pt=[t locationInView:self];
    if (point.x!=pt.x||point.y!=pt.y) {
        moved=YES;
    }
    if (!moved) {
        if (self.mode==OVERLAY_MODE_DARKEN||self.mode==OVERLAY_MODE_SHADOW) {
			CATransition *animation=[CATransition animation];
			[animation setType:kCATransitionFade];
			[animation setDuration:0.4];
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			[[self layer]addAnimation:animation forKey:@"fadeout"];
			self.mode=OVERLAY_MODE_HIDDEN;
			//[searchBar resignFirstResponder];
		}
    }
}


@end
