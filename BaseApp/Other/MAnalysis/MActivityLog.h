//
//  MActivityLog.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MActivityLog : NSObject<NSCoding>
{
    NSString    *sessionMils;
    NSString    *startMils;
    NSString    *endMils;
    NSString    *duration;
    NSString    *activity;
    NSString    *version;
}
@property (nonatomic,strong) NSString    *sessionMils;
@property (nonatomic,strong) NSString    *startMils;
@property (nonatomic,strong) NSString    *endMils;
@property (nonatomic,strong) NSString    *duration;
@property (nonatomic,strong) NSString    *activity;
@property (nonatomic,strong) NSString    *version;


@end
