//
//  HLDataViewCell.m
//  GrpCust
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HLDataViewCell.h"
#import "HLDataView.h"

@interface HLDataViewCell()

-(HLDataView*)dataView;

@end

@implementation HLDataViewCell
@dynamic delegate;
@synthesize xPosition,yPosition,identifier,selected,highlighted,isHeader,isOrder;

- (id)initWithReuseIdentifier:(NSString *)aIdentifier
{
    if (![super initWithFrame:CGRectZero])
        return nil;
    identifier=[aIdentifier copy];
    
    return self;
}

-(void)awakeFromNib{
    identifier=nil;
}

-(void)prepareForReuse
{
    self.selected=NO;
    self.highlighted=NO;
    self.isHeader=NO;
    self.isOrder=0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted=YES;
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted=NO;
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted=NO;
    [[self dataView] selectRow:self.yPosition column:self.xPosition scrollPosition:HLDataViewScrollPositionNone animated:YES];
	[self.delegate dataViewCellWasTouched:self];
    [super touchesEnded:touches withEvent:event];
}


-(HLDataView*)dataView
{
    UIResponder *r=[self nextResponder];
    if (![r isKindOfClass:[HLDataView class]]) {
        return nil;
    }
    return (HLDataView*)r;
}

@end
