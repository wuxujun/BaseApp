//
//  MConfigPreference.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCommonReturn.h"

@interface MConfigPreference : MCommonReturn
{
    NSString        *autoGetLocation;
    NSString        *updateOnlyWifi;
    NSString        *sessionMillis;
    NSString        *reportPolicy;
}
@property (nonatomic,strong) NSString        *autoGetLocation;
@property (nonatomic,strong) NSString        *updateOnlyWifi;
@property (nonatomic,strong) NSString        *sessionMillis;
@property (nonatomic,strong) NSString        *reportPolicy;


@end
