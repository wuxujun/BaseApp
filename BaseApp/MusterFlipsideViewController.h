//
//  MusterFlipsideViewController.h
//  BaseApp
//
//  Created by xujun wu on 12-11-11.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusterFlipsideViewController;

@protocol MusterFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(MusterFlipsideViewController *)controller;
@end

@interface MusterFlipsideViewController : UIViewController

@property (weak, nonatomic) id <MusterFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
