//
//  NSURLAdditions.m
//  SAnalysis
//
//  Created by xujun wu on 12-10-26.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "NSURLAdditions.h"
#import "HMacros.h"

TT_FIX_CATEGORY_BUG(NSURLAdditions)
@implementation NSURL (Additions)

+(NSDictionary*)parseURLQueryString:(NSString *)aString
{
    NSMutableDictionary  *dict=[NSMutableDictionary dictionary];
    NSArray     *pairs=[aString componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray     *keyValue=[pair componentsSeparatedByString:@"="];
        if ([keyValue count]==2) {
            NSString *key=[keyValue objectAtIndex:0];
            NSString *value=[keyValue objectAtIndex:1];
            value=[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (key&&value) {
                [dict setObject:value forKey:key];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

+(NSURL*)smartURLForString:(NSString *)aString
{
    NSURL   *result;
    NSString        *trimmedStr;
    NSRange         schemeMarkerRange;
    NSString        *scheme;
    
    assert(aString!=nil);
    result=nil;
    trimmedStr=[aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ((trimmedStr!=nil)&&(trimmedStr.length!=0)) {
        schemeMarkerRange =[trimmedStr rangeOfString:@"://"];
		if (schemeMarkerRange.location==NSNotFound) {
            result=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",trimmedStr]];
        }else{
            scheme=[trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme!=nil);
            
            if (([scheme compare:@"http" options:NSCaseInsensitiveSearch]==NSOrderedSame)||([scheme compare:@"https" options:NSCaseInsensitiveSearch]==NSOrderedSame)) {
                result=[NSURL URLWithString:trimmedStr];
            }else {
				// It looks like this is some unsupported URL scheme.
			}
        }
    }
    return result;
}
@end
