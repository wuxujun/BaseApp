//
//  HImageViewCell.h
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-19.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WaterFlowView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HImageViewCell : WaterFlowCell
{
    UIImageView     *imageView;
}

-(void)setImageWithURL:(NSURL*)imageUrl;
-(void)setImage:(UIImage*)image;
-(void)relayoutViews;
@end
