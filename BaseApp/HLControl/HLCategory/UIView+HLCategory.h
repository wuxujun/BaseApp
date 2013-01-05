//
//  UIView+HLCategory.h
//  UniCust
//
//  Created by 吴旭俊 on 11-5-12.
//  Copyright 2011 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIView (HLCategory)


@property (nonatomic,readonly)CGFloat   inCenterX;
@property (nonatomic,readonly)CGFloat   inCenterY;
@property (nonatomic,readonly)CGPoint   inCenter;
@property (nonatomic)CGFloat            left;
@property (nonatomic)CGFloat            top;
@property (nonatomic)CGFloat            right;
@property (nonatomic)CGFloat            bottom;
@property (nonatomic)CGFloat            width;
@property (nonatomic)CGFloat            height;

@property (nonatomic,readonly)CGFloat       b_width;
@property (nonatomic,readonly)CGFloat       b_height;

@property (nonatomic)CGFloat            centerX;
@property (nonatomic)CGFloat            centerY;

@property (nonatomic)CGPoint            origin;
@property (nonatomic)CGSize             size;


// DRAW GRADIENT
+ (void) drawGradientInRect:(CGRect)rect withColors:(NSArray*)colors;
+ (void) drawLinearGradientInRect:(CGRect)rect colors:(CGFloat[])colors;


// DRAW ROUNDED RECTANGLE
+ (void) drawRoundRectangleInRect:(CGRect)rect withRadius:(CGFloat)radius color:(UIColor*)color;

// DRAW LINE
+ (void) drawLineInRect:(CGRect)rect red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (void) drawLineInRect:(CGRect)rect colors:(CGFloat[])colors;
+ (void) drawLineInRect:(CGRect)rect colors:(CGFloat[])colors width:(CGFloat)lineWidth cap:(CGLineCap)cap;

@end
