//
//  MEvent.m
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "MEvent.h"

@implementation MEvent
@synthesize eventId,time,acc,activity,label,version;
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.eventId=[aDecoder decodeObjectForKey:@"event_id"];
        self.label=[aDecoder decodeObjectForKey:@"label"];
        self.time=[aDecoder decodeObjectForKey:@"time"];
        self.activity=[aDecoder decodeObjectForKey:@"activity"];
        self.acc=[aDecoder decodeInt32ForKey:@"acc"];
        self.version=[aDecoder decodeObjectForKey:@"version"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:eventId forKey:@"event_id"];
    [aCoder encodeObject:label forKey:@"label"];
    [aCoder encodeObject:time  forKey:@"time"];
    [aCoder encodeObject:activity forKey:@"activity"];
    [aCoder encodeObject:version forKey:@"version"];
    [aCoder encodeInt:acc forKey:@"acc"];
}

@end
