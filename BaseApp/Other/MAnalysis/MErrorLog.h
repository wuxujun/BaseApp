//
//  MErrorLog.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MErrorLog : NSObject<NSCoding>
{
    NSString *stackTrace;
    NSString *time;
    NSString *activity;
    NSString *appKey;
    NSString *osVersion;
    NSString *deviceID;
    NSString *version;
}

@property (nonatomic,strong) NSString *stackTrace;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *activity;
@property (nonatomic,strong) NSString *appKey;
@property (nonatomic,strong) NSString *osVersion;
@property (nonatomic,strong) NSString *deviceID;
@property (nonatomic,strong) NSString *version;

@end
