//
//  MClientData.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MClientData : NSObject<NSCoding>
{
    NSString *platform;
    NSString *osVersion;
    NSString *language;
    NSString *resolution;
    NSString *deviceid;
    NSString *mccmnc;
    NSString *version;
    NSString *network;
    NSString *devicename;
    NSString *modulename;
    NSString *time;
    NSString *isJailbroken;
}

@property (nonatomic,strong) NSString *platform;
@property (nonatomic,strong) NSString *osVersion;
@property (nonatomic,strong) NSString *language;
@property (nonatomic,strong) NSString *resolution;
@property (nonatomic,strong) NSString *deviceid;
@property (nonatomic,strong) NSString *mccmnc;
@property (nonatomic,strong) NSString *version;
@property (nonatomic,strong) NSString *network;
@property (nonatomic,strong) NSString *devicename;
@property (nonatomic,strong) NSString *modulename;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) NSString *isJailbroken;

@end
