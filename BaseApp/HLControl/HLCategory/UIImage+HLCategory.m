//
//  UIImage+HLCategory.m
//  UniCust
//
//  Created by 吴旭俊 on 11-5-12.
//  Copyright 2011 huawei. All rights reserved.
//

#import "UIImage+HLCategory.h"
#import "UIView+HLCategory.h"
#import "HLGlobal.h"


@implementation UIImage (HLCategory)

+(UIImage*)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.layer.contentsScale);
    
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*) imageNamedTK:(NSString*)str{
	
	CGFloat s = 1.0;
	if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
		//s=[[UIScreen mainScreen] scale];
	}
	
	NSString *path = [NSString stringWithFormat:@"%@%@.png",str,s > 1 ? @"@2x":@""];
	return [UIImage imageWithCGImage:[UIImage imageWithContentsOfFile:HLBUNDLE(path)].CGImage scale:s orientation:UIImageOrientationUp];
	
}

- (UIImage *) imageCroppedToRect:(CGRect)rect{
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return cropped; // autoreleased
}

- (UIImage *) squareImage{
	CGFloat shortestSide = self.size.width <= self.size.height ? self.size.width : self.size.height;	
	return [self imageCroppedToRect:CGRectMake(0.0, 0.0, shortestSide, shortestSide)];
}


-(UIImage*)scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context 
    // 并把它设置成为当前正在使用的context 
    UIGraphicsBeginImageContext(size); 
    // 绘制改变大小的图片 
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)]; 
    // 从当前context中创建一个改变大小后的图片 
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext(); 
    // 使当前的context出堆栈 
    UIGraphicsEndImageContext(); 
    // 返回新的改变大小后的图片 
    return scaledImage; 
}

- (void) drawInRect:(CGRect)rect withImageMask:(UIImage*)mask{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	
	CGContextClipToMask(context, rect, mask.CGImage);
	//CGContextSetRGBFillColor(context, color[0], color[1], color[2], color[3]);
	//CGContextFillRect(context, rect);
	CGContextDrawImage(context,rect,self.CGImage);
	
	
	CGContextRestoreGState(context);
}

- (void) drawMaskedColorInRect:(CGRect)rect withColor:(UIColor*)color{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	
	CGContextSetFillColorWithColor(context, color.CGColor);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	rect.origin.y = rect.origin.y * -1;
	
	
	CGContextClipToMask(context, rect, self.CGImage);
	CGContextFillRect(context, rect);
	
	CGContextRestoreGState(context);
	
}
- (void) drawMaskedGradientInRect:(CGRect)rect withColors:(NSArray*)colors{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	
	CGContextClipToMask(context, rect, self.CGImage);
	
	[UIView drawGradientInRect:rect withColors:colors];
	
	CGContextRestoreGState(context);
}

@end
