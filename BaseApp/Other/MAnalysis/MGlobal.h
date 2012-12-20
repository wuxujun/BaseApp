//
//  MGlobal.h
//  BaseApp
//
//  Created by xujun wu on 12-11-19.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGlobal : NSObject

+(void)showAlertView:(NSString*)aTitle message:(NSString*)aMessage delegate:(id)aDelegate buttonTitle:(NSString*)aButtonTitle cancelButtonTitle:(NSString*)aCancelButtonTitle;
+(void)setBaseURL:(NSString*)baseURL;
+(NSString*)getBaseURL;

@end
