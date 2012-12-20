//
//  MActivityLog.m
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MActivityLog.h"

@implementation MActivityLog
@synthesize sessionMils,startMils,endMils,duration,activity,version;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.sessionMils=[aDecoder decodeObjectForKey:@"sessionmils"];
        self.startMils=[aDecoder decodeObjectForKey:@"startmils"];
        self.endMils=[aDecoder decodeObjectForKey:@"endmils"];
        self.duration=[aDecoder decodeObjectForKey:@"duration"];
        self.activity=[aDecoder decodeObjectForKey:@"activity"];
        self.version=[aDecoder decodeObjectForKey:@"version"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:sessionMils forKey:@"sessionmils"];
    [aCoder encodeObject:startMils forKey:@"startmils"];
    [aCoder encodeObject:endMils forKey:@"endmils"];
    [aCoder encodeObject:duration forKey:@"duration"];
    [aCoder encodeObject:activity forKey:@"activity"];
    [aCoder encodeObject:version forKey:@"version"];
}

@end
