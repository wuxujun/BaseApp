//
//  HLGlobal.m
//  UniCust
//
//  Created by 吴旭俊 on 11-5-13.
//  Copyright 2011 huawei. All rights reserved.
//

#import "HLGlobal.h"


@implementation HLGlobal

+ (NSString*) fullBundlePath:(NSString*)bundlePath{
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundlePath];
}

@end
