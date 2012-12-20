//
//  ColorUtils.h
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIColor(UIColorUtils)
+(void)initTwitterFonColorScheme;

+(UIColor*)navigationColorForTab:(int)tab;
+(UIColor*)cellColorForTab:(int)tab;
+(UIColor*)cellLabelColor;
+(UIColor*)conversationBackground;
+(UIColor*)itemBackground;
+(UIColor*)fbBackground;
+(UIColor*)itemSelectedBackground;
+(UIColor*)itemSignBackground;
+(UIColor*)headerBackground;
+(UIColor*)searchBackground;

//#FFFFFF to RGB Color
+(UIColor*)colorWithHexString:(NSString*)str;
//0x123456 
+(UIColor*)colorWithHex:(UInt32)col;

+(UIColor*)homeBackground;
+(UIColor*)hBackground;
+(UIColor*)lineBackground;

+(UIColor*)homeLabelBackground;


@end