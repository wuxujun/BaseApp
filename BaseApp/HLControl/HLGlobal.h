//
//  HLGlobal.h
//  UniCust
//
//  Created by 吴旭俊 on 11-5-13.
//  Copyright 2011 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HLBUNDLE(_URL) [HLGlobal fullBundlePath:_URL]

@interface HLGlobal : NSObject 

+ (NSString*) fullBundlePath:(NSString*)bundlePath;

@end
