//
//  MCheckUpdateReturn.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCommonReturn.h"

@interface MCheckUpdateReturn : MCommonReturn
{
    NSString        *description;
    NSString        *time;
    NSString        *fileUrl;
    NSString        *forceUpdate;
    NSString        *version;
}

@property (nonatomic,strong)NSString        *description;
@property(nonatomic,strong) NSString        *time;
@property(nonatomic,strong) NSString        *fileUrl;
@property(nonatomic,strong) NSString        *forceUpdate;
@property(nonatomic,strong) NSString        *version;

@end
