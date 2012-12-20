//
//  MClientData.m
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MClientData.h"

@implementation MClientData
@synthesize deviceid;
@synthesize devicename;
@synthesize isJailbroken;
@synthesize language;
@synthesize mccmnc;
@synthesize modulename;
@synthesize network;
@synthesize osVersion;
@synthesize platform;
@synthesize resolution;
@synthesize time;
@synthesize version;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self =[super init]) {
        self.deviceid = [aDecoder decodeObjectForKey:@"deviceid"];
        self.devicename = [aDecoder decodeObjectForKey:@"devicename"];
        self.isJailbroken = [aDecoder decodeObjectForKey:@"isjailbroken"];
        self.language = [aDecoder decodeObjectForKey:@"language"];
        self.mccmnc = [aDecoder decodeObjectForKey:@"mccmnc"];
        self.modulename = [aDecoder decodeObjectForKey:@"modulename"];
        self.network = [aDecoder decodeObjectForKey:@"network"];
        self.osVersion = [aDecoder decodeObjectForKey:@"os_version"];
        self.platform = [aDecoder decodeObjectForKey:@"platform"];
        self.resolution = [aDecoder decodeObjectForKey:@"resolution"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.version = [aDecoder decodeObjectForKey:@"version"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:deviceid forKey:@"deviceid"];
    [aCoder encodeObject:devicename forKey:@"devicename"];
    [aCoder encodeObject:isJailbroken forKey:@"isjailbroken"];
    [aCoder encodeObject:language forKey:@"language"];
    [aCoder encodeObject:mccmnc forKey:@"mccmnc"];
    [aCoder encodeObject:modulename forKey:@"modulename"];
    [aCoder encodeObject:network forKey:@"network"];
    [aCoder encodeObject:osVersion forKey:@"os_version"];
    [aCoder encodeObject:platform forKey:@"platform"];
    [aCoder encodeObject:resolution forKey:@"resolution"];
    [aCoder encodeObject:time forKey:@"time"];
    [aCoder encodeObject:version forKey:@"version"];
}

@end
