//
//  MEvent.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEvent : NSObject<NSCoding>
{
    NSString        *eventId;
    NSString        *time;
    NSString        *activity;
    NSString        *label;
    int             acc;
    NSString        *version;
}
@property (nonatomic,strong)NSString    *eventId;
@property (nonatomic,strong)NSString    *time;
@property (nonatomic,strong)NSString    *activity;
@property (nonatomic,strong)NSString    *label;
@property (nonatomic)int                acc;
@property (nonatomic,strong)NSString    *version;

@end
