//
//  MoreViewCell.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-31.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExtention.h"


@protocol MoreViewCellDelegate;

@interface MoreViewCell : UIViewExtention
{
    UIView              *contentView;
    
    UILabel             *titleLabel;
    UILabel             *descLabel;
    UIButton            *onButton;
    int                 type;
    __unsafe_unretained     id<MoreViewCellDelegate>        delegate;
}

@property (nonatomic,strong)NSString     *title;
@property (nonatomic,strong)NSString     *desc;
@property (nonatomic,assign)BOOL         isLogin;
@property (nonatomic,assign)id<MoreViewCellDelegate> delegate;

-(id)initWithFrame:(CGRect)frame type:(int)aType;

-(void)initializeFields;

@end

@protocol MoreViewCellDelegate <NSObject>

@optional
-(void)onButtonClicked:(MoreViewCell*)view;

@end

