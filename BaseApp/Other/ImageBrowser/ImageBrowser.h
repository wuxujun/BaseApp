//
//  ImageBrowser.h
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageScrollView.h"

#define GIF_VIEW_TAG    9999

@protocol ImageBrowserDelegate <NSObject>

-(void)browserDidGetOriginImage:(NSDictionary*)aDict;

@end
@interface ImageBrowser : UIView<UIScrollViewDelegate>
{
    UIImageView             *imageView;
    ImageScrollView         *ScrollView;
    
    UIImage                 *image;
    NSString                *bigImageURL;
    NSString                *viewTitle;

   __unsafe_unretained id<ImageBrowserDelegate>            delegate;
}
@property (nonatomic,strong)UIImage *image;
@property (nonatomic,strong)UIImageView     *imageView;
@property (nonatomic,strong)ImageScrollView     *aScrollView;
@property (nonatomic,strong)NSString        *bigImageURL;
@property (nonatomic,strong)NSString        *viewTitle;

@property (nonatomic,assign)id<ImageBrowserDelegate>        delegate;

-(void)setup;
-(void)loadImage;
-(void)didmiss;
-(void)zoomToFit;

@end
