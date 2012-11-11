//
//  MusterMainViewController.h
//  BaseApp
//
//  Created by xujun wu on 12-11-11.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MusterFlipsideViewController.h"

@interface MusterMainViewController : UIViewController <MusterFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
