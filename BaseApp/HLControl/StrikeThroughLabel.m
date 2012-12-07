//
//  StrikeThroughLabel.m
//  BaseApp
//
//  Created by xujun wu on 12-11-22.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "StrikeThroughLabel.h"

@implementation StrikeThroughLabel
@synthesize strikeThroughEnabled=_strikeThroughEnabled;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
    
    CGSize textSize = [[self text] sizeWithFont:[self font]];
    CGFloat strikeWidth = textSize.width;
    CGRect lineRect;
    
    if ([self textAlignment] == UITextAlignmentRight) {
        lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2, strikeWidth, 1);
    } else if ([self textAlignment] == UITextAlignmentCenter) {
        lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2, strikeWidth, 1);
    } else {
        lineRect = CGRectMake(0, rect.size.height/2, strikeWidth, 1);
    }
    
    if (_strikeThroughEnabled) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, lineRect);
    }
}

-(void)setStrikeThroughEnabled:(BOOL)strikeThroughEnabled
{
    _strikeThroughEnabled=strikeThroughEnabled;
    NSString *tmpText=[self.text copy];
    self.text=@"";
    self.text=tmpText;
}

@end
