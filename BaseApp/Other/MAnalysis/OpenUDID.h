//
//  OpenUDID.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOpenUDIDErrorNone          0
#define kOpenUDIDErrorOptedOut      1
#define kOpenUDIDErrorCompromised   2

@interface OpenUDID : NSObject{
    
}

+(NSString*)value;
+(NSString*)valueWithError:(NSError*)error;
+(void)setOptOut:(BOOL)optOutValue;

@end
