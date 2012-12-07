//
//  StrikeThroughLabel.h
//  BaseApp
//  Label 中线删除线
//  Created by xujun wu on 12-11-22.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StrikeThroughLabel : UILabel
{
    BOOL    _strikeThroughEnabled;
}
@property (nonatomic)BOOL   strikeThroughEnabled;

@end
