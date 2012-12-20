//
//  VDiskAuthView.h
//  BaseApp
//
//  Created by xujun wu on 12-12-4.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDiskAuthView : UIAlertView<UITableViewDataSource,UITableViewDelegate>
{
    UITableView   *mTableView;
    UITextField     *phoneField;
    UITextField     *pwdField;
}
@property (nonatomic,strong)UITextField     *phoneField;
@property (nonatomic,strong)UITextField     *pwdField;

-(id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles;

@end
