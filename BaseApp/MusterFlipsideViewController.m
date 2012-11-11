//
//  MusterFlipsideViewController.m
//  BaseApp
//
//  Created by xujun wu on 12-11-11.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MusterFlipsideViewController.h"

@interface MusterFlipsideViewController ()

@end

@implementation MusterFlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
