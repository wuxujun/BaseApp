//
//  VDiskAuthView.m
//  BaseApp
//
//  Created by xujun wu on 12-12-4.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "VDiskAuthView.h"
#import <QuartzCore/QuartzCore.h>

@interface VDiskAuthView()

@property (nonatomic,strong)UITableView     *mTableView;

-(void)orientationDidChange:(NSNotification*)notification;

@end

@implementation VDiskAuthView
@synthesize mTableView;
@synthesize phoneField,pwdField;


-(id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles
{
    if (self=[super initWithTitle:title message:@"\n\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil]) {
        [self addSubview:self.phoneField];
        
        mTableView=[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.scrollEnabled=NO;
        mTableView.opaque=NO;
        mTableView.layer.cornerRadius=3.0f;
        mTableView.editing=YES;
        mTableView.rowHeight=35.0f;
        
        [self addSubview:mTableView];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
    }
    return self;
}
-(void)layoutSubviews
{
    if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            self.center=CGPointMake(160.0f, (460-216)/2+12);
            self.mTableView.frame=CGRectMake(15.0f, 51.0f, 255.0f, 70);
        }else{
            self.center=CGPointMake(240.0f, (300-162.0f)/2+12.0f);
            self.mTableView.frame=CGRectMake(15.0f, 35.0f, 255, 70);
        }
    }
}

-(void)orientationDidChange:(NSNotification *)notification
{
    [self setNeedsLayout];
}

-(UITextField*)phoneField
{
    if (!phoneField) {
        phoneField=[[UITextField alloc]initWithFrame:CGRectMake(5.0f, 0.0f, 255.0f, 35.0f)];
        phoneField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        phoneField.clearButtonMode=UITextFieldViewModeWhileEditing;
        phoneField.placeholder=@"请输入微盘帐号";
        phoneField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    }
    return phoneField;
}

-(UITextField*)pwdField
{
    if (!pwdField) {
        pwdField=[[UITextField alloc]initWithFrame:CGRectMake(5.0f, 0.0f, 255.0f, 35.0f)];
        pwdField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        pwdField.secureTextEntry=YES;
        pwdField.clearButtonMode=UITextFieldViewModeWhileEditing;
        pwdField.placeholder=@"请输入密码";
        pwdField.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    }
    return pwdField;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"VDiskLoginViewCell";
    UITableViewCell *cell=(UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row==0) {
        [cell.contentView addSubview:self.phoneField];
    }else{
        [cell.contentView addSubview:self.pwdField];
    }
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

@end
