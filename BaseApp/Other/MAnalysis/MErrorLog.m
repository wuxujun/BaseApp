//
//  MErrorLog.m
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MErrorLog.h"

@implementation MErrorLog
@synthesize activity;
@synthesize time;
@synthesize stackTrace;
@synthesize appKey;
@synthesize version;
@synthesize osVersion;
@synthesize deviceID;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self =[super init]) {
        self.activity = [aDecoder decodeObjectForKey:@"activity"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.stackTrace = [aDecoder decodeObjectForKey:@"stacktrace"];
        self.appKey = [aDecoder decodeObjectForKey:@"appkey"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
        self.osVersion = [aDecoder decodeObjectForKey:@"os_version"];
        self.deviceID = [aDecoder decodeObjectForKey:@"deviceID"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:activity forKey:@"activity"];
    [aCoder encodeObject:time forKey:@"time"];
    [aCoder encodeObject:stackTrace forKey:@"stacktrace"];
    [aCoder encodeObject:appKey forKey:@"appkey"];
    [aCoder encodeObject:version forKey:@"version"];
    [aCoder encodeObject:osVersion forKey:@"os_version"];
    [aCoder encodeObject:deviceID forKey:@"deviceID"];
}

@end
