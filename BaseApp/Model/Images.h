//
//  Images.h
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Images : NSManagedObject

@property (nonatomic,strong)NSDate  *createDate;
@property (nonatomic,strong)NSData  *data;
@property (nonatomic,strong)NSString    *url;
@end
