//
//  ExceptionHandler.h
//  NetGrid
//
//  Created by 吴旭俊 on 12-10-10.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExceptionHandler : NSObject


+(void)setDefaultHandler;
+(NSUncaughtExceptionHandler*)getHandler;

@end
