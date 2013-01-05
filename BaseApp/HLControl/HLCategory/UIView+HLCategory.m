//
//  UIView+HLCategory.m
//  UniCust
//
//  Created by 吴旭俊 on 11-5-12.
//  Copyright 2011 huawei. All rights reserved.
//

#import "UIView+HLCategory.h"


@implementation UIView (HLCategory)


-(CGFloat)inCenterX
{
    return self.frame.size.width*0.5;
}

-(CGFloat)inCenterY
{
    return self.frame.size.height*0.5;
}

-(CGPoint)inCenter
{
    return CGPointMake(self.inCenterX, self.inCenterY);
}

-(CGFloat)left
{
    return self.frame.origin.x;
}

-(void)setLeft:(CGFloat)x
{
    CGRect frame=self.frame;
    frame.origin.x=x;
    self.frame=frame;
}

-(CGFloat)top
{
    return self.frame.origin.y;
}

-(void)setTop:(CGFloat)y
{
    CGRect frame=self.frame;
    frame.origin.y=y;
    self.frame=frame;
}

-(CGFloat)right
{
    return self.frame.origin.x+self.frame.size.width;
}

-(void)setRight:(CGFloat)right
{
    CGRect frame=self.frame;
    frame.origin.x=right-frame.size.width;
    self.frame=frame;
}

-(CGFloat)bottom
{
    return self.frame.origin.y+self.frame.size.height;
}

-(void)setBottom:(CGFloat)bottom
{
    CGRect frame=self.frame;
    frame.origin.y=bottom-frame.size.height;
    self.frame=frame;
}

-(CGFloat)centerX
{
    return self.center.x;
}

-(void)setCenterX:(CGFloat)centerX
{
    self.center=CGPointMake(centerX, self.center.y);
}

-(CGFloat)centerY
{
    return self.center.y;
}

-(void)setCenterY:(CGFloat)centerY
{
    self.center=CGPointMake(self.center.x, centerY);
}

-(CGFloat)width
{
    return self.frame.size.width;
}

-(void)setWidth:(CGFloat)width
{
    CGRect frame=self.frame;
    frame.size.width=width;
    self.frame=frame;
}

-(CGFloat)height
{
    return self.frame.size.height;
}

-(void)setHeight:(CGFloat)height
{
    CGRect frame=self.frame;
    frame.size.height=height;
    self.frame=frame;
}

-(CGFloat)b_width
{
    return self.bounds.size.width;
}

-(CGFloat)b_height
{
    return self.bounds.size.height;
}

-(CGPoint)origin
{
    return self.frame.origin;
}

-(void)setOrigin:(CGPoint)origin
{
    CGRect frame=self.frame;
    frame.origin=origin;
    self.frame=frame;
}

-(CGSize)size
{
    return self.frame.size;
}

-(void)setSize:(CGSize)size
{
    CGRect frame=self.frame;
    frame.size=size;
    self.frame=frame;
}

CGPoint demoLGStart(CGRect bounds){
	return CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height * 0.25);
}
CGPoint demoLGEnd(CGRect bounds){
	return CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height * 0.75);
}
CGPoint demoRGCenter(CGRect bounds){
	return CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}
CGFloat demoRGInnerRadius(CGRect bounds){
	CGFloat r = bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height;
	return r * 0.125;
}

+ (void) drawGradientInRect:(CGRect)rect withColors:(NSArray*)colors{
	
	NSMutableArray *ar = [NSMutableArray array];
	for(UIColor *c in colors){
		[ar addObject:(id)c.CGColor];
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	
	
	CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)ar, NULL);
	
	
	CGContextClipToRect(context, rect);
	
	CGPoint start = CGPointMake(0.0, 0.0);
	CGPoint end = CGPointMake(0.0, rect.size.height);
	
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);
	
}


+ (void) drawLinearGradientInRect:(CGRect)rect colors:(CGFloat[])colours{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colours, NULL, 2);
	CGColorSpaceRelease(rgb);
	CGPoint start, end;
	
	start = demoLGStart(rect);
	end = demoLGEnd(rect);
	
	
	
	CGContextClipToRect(context, rect);
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
	
	CGContextRestoreGState(context);
	
}


+ (void) drawRoundRectangleInRect:(CGRect)rect withRadius:(CGFloat)radius color:(UIColor *)color{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[color set];
	
	CGRect rrect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFill);
}




+ (void) drawLineInRect:(CGRect)rect colors:(CGFloat[])colors {
	
	[UIView drawLineInRect:rect colors:colors width:1 cap:kCGLineCapButt];
	
}
+ (void) drawLineInRect:(CGRect)rect red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha{
	CGFloat colors[4];
	colors[0] = red;
	colors[1] = green;
	colors[2] = blue;
	colors[3] = alpha;
	[UIView drawLineInRect:rect colors:colors];
}
+ (void) drawLineInRect:(CGRect)rect colors:(CGFloat[])colors width:(CGFloat)lineWidth cap:(CGLineCap)cap{
	
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	
	CGContextSetRGBStrokeColor(context, colors[0], colors[1], colors[2], colors[3]);
	CGContextSetLineCap(context,cap);
	CGContextSetLineWidth(context, lineWidth);
	
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
	CGContextAddLineToPoint(context,rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
	CGContextStrokePath(context);
	
	
	CGContextRestoreGState(context);
	
}

@end
