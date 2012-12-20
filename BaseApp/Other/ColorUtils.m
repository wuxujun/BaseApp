//
//  ColorUtils.m
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ColorUtils.h"
#import "HMacros.h"

static UIColor *gNavigationBarColors[5];
static UIColor *gUnreadCellColors[5];

TT_FIX_CATEGORY_BUG(ColorUtils)
@implementation UIColor (UIColorUtils)

+ (void) initTwitterFonColorScheme
{
    gUnreadCellColors[0] = [UIColor colorWithRed:0.827 green:1.000 blue:1.000 alpha:1.0]; // friends
    gUnreadCellColors[1] = [UIColor colorWithRed:0.827 green:1.000 blue:0.820 alpha:1.0]; // replies
    gUnreadCellColors[2] = [UIColor colorWithRed:0.992 green:0.878 blue:0.820 alpha:1.0]; // DM
    gUnreadCellColors[3] = [UIColor colorWithRed:0.988 green:0.812 blue:0.820 alpha:1.0]; // favorites
    gUnreadCellColors[4] = [UIColor colorWithRed:0.996 green:0.929 blue:0.820 alpha:1.0]; // search
    
    // Navigation Bar Color
    gNavigationBarColors[0] = [UIColor colorWithRed:0.341 green:0.643 blue:0.859 alpha:1.0];
    gNavigationBarColors[1] = [UIColor colorWithRed:0.459 green:0.663 blue:0.557 alpha:1.0];
    gNavigationBarColors[2] = [UIColor colorWithRed:0.686 green:0.502 blue:0.447 alpha:1.0];
    gNavigationBarColors[3] = [UIColor colorWithRed:0.701 green:0.447 blue:0.459 alpha:1.0];
    gNavigationBarColors[4] = [UIColor whiteColor];
    
}

+ (UIColor*)navigationColorForTab:(int)tab
{
    return gNavigationBarColors[tab];
}

+ (UIColor*)cellColorForTab:(int)tab
{
    return gUnreadCellColors[tab];
}

+ (UIColor*)cellLabelColor
{
    return [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
}

+ (UIColor*)conversationBackground
{
    return [UIColor colorWithRed:0.859 green:0.886 blue:0.929 alpha:1.0];
}

+(UIColor*)itemBackground
{
    return [UIColor colorWithRed:0.953 green:0.953 blue:0.953 alpha:1.0];
}

+(UIColor*)fbBackground
{
    return [UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1.0];
}

+(UIColor*)itemSelectedBackground
{
     return [UIColor colorWithRed:0.773 green:0.941 blue:1.0 alpha:1.0];
}

+(UIColor*)itemSignBackground
{
     return [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.0];
}
    
+(UIColor*)headerBackground
{
     return [UIColor colorWithRed:0.923 green:0.923 blue:0.923 alpha:1.0];
}

+(UIColor*)searchBackground
{
    return [UIColor colorWithRed:0.392 green:0.392 blue:0.40 alpha:1.0];
}

+(UIColor*)colorWithHexString:(NSString *)str
{
    const char *cStr=[str cStringUsingEncoding:NSASCIIStringEncoding];
    long x=strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x];
}

+(UIColor*)colorWithHex:(UInt32)col
{
    unsigned char r,g,b;
    b=col&0xFF;
    g=(col>>8)&0xFF;
    r=(col>>16)&0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

+(UIColor*)hBackground
{
    return [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
}

+(UIColor*)lineBackground
{
    return [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
}

+(UIColor*)homeBackground
{
    return [UIColor colorWithRed:0.968 green:0.968 blue:0.968 alpha:1.0];
}


+(UIColor*)homeLabelBackground
{
    return [UIColor colorWithRed:0.05 green:0.26 blue:0.55 alpha:1.0];
}


+(UIColor*)afkPageColorAlpha0
{
    return [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0];
}
+(UIColor*)afkPageColorAlpha1
{
    return [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1];
}

@end
