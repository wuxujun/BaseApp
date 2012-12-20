//
//  MCommonReturn.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCommonReturn : NSObject
{
    int             flag;
    NSString        *msg;
}

@property (nonatomic)int    flag;
@property (nonatomic,strong)NSString    *msg;

@end
