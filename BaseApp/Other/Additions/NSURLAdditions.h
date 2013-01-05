//
//  NSURLAdditions.h
//  SAnalysis
//
//  Created by xujun wu on 12-10-26.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Additions)

+(NSDictionary*)parseURLQueryString:(NSString*)aString;
+(NSURL*)smartURLForString:(NSString*)aString;

@end
