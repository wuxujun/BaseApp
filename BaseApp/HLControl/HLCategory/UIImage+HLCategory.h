//
//  UIImage+HLCategory.h
//  UniCust
//
//  Created by 吴旭俊 on 11-5-12.
//  Copyright 2011 huawei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (HLCategory)

- (UIImage *) imageCroppedToRect:(CGRect)rect;
- (UIImage *) squareImage;
- (UIImage *) scaleToSize:(CGSize)size;



- (void) drawInRect:(CGRect)rect withImageMask:(UIImage*)mask;

- (void) drawMaskedColorInRect:(CGRect)rect withColor:(UIColor*)color;
- (void) drawMaskedGradientInRect:(CGRect)rect withColors:(NSArray*)colors;


+ (UIImage*) imageNamedTK:(NSString*)path;

//视图保存到图片
+ (UIImage*)imageFromView:(UIView*)view;
@end
