//
//  HKeyboardControls.m
//  SAnalysis
//
//  Created by xujun wu on 12-11-1.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "HKeyboardControls.h"

enum{
    KeyboardControlsIndexPrevious,
    KeyboardControlsIndexNext
};

@interface HKeyboardControls()

@property (nonatomic,strong)UIToolbar   *toolbar;
@property (nonatomic,strong)UISegmentedControl *segmentedPreviousNext;
@property (nonatomic,strong)UIBarButtonItem *buttonDone;


@end

@implementation HKeyboardControls
@synthesize delegate;
@synthesize textFields;
@synthesize toolbar;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        CGRect  frame=CGRectMake(0, 0, 320, 44);
        self.frame=frame;
        
        self.barStyle=UIBarStyleBlackTranslucent;
        
    
        self.toolbar=[[UIToolbar alloc] initWithFrame:self.frame];
        self.toolbar.barStyle=self.barStyle;
        self.toolbar.backgroundColor=[UIColor clearColor];
        
        
        self.toolbar.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.toolbar];
    }
    
    return self;
}

-(void)setBarStyle:(UIBarStyle)barStyle
{
    barStyle=_barStyle;
    self.toolbar.barStyle=self.barStyle;
}

@end
