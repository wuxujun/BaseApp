//
//  ImageBrowser.m
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "ImageBrowser.h"
#import "ImageCacheManager.h"
#import "GifView.h"

@implementation ImageBrowser
@synthesize image,imageView,aScrollView,bigImageURL,viewTitle,delegate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        aScrollView=[[ImageScrollView alloc]initWithFrame:frame];
        imageView=[[UIImageView alloc]initWithFrame:frame];
        aScrollView.userInteractionEnabled=YES;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [imageView addGestureRecognizer:tap];
        imageView.userInteractionEnabled=YES;
        [self addSubview:aScrollView];
        [aScrollView addSubview:imageView];
    }
    return self;
}

-(void)dismiss
{
    for (UIView *view in self.subviews) {
        if (view.tag==GIF_VIEW_TAG) {
            [view removeFromSuperview];
        }
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ImageCacheNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"tapClicked" object:nil];
    [UIApplication sharedApplication].statusBarHidden=NO;
    CGRect  frame=[[UIScreen mainScreen] bounds];
    NSLog(@"%@:%@  %f  %f",[self class],NSStringFromSelector(_cmd),frame.size.width,frame.size.height);
    aScrollView.contentSize=CGSizeMake(frame.size.width, frame.size.height);
    [self removeFromSuperview];
}

-(void)saveImage
{
    if (!imageView.image) {
        return;
    }
    UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"ImageSaveSucced" delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:nil];
    [alert show];
}

-(void)zoomToFit
{
    CGRect  rect=[[UIScreen mainScreen] bounds];
    
    CGFloat zoom=rect.size.width/imageView.image.size.width;
    CGSize size=CGSizeMake(rect.size.width, imageView.image.size.height*zoom);
    CGRect frame=imageView.frame;
    frame.size=size;
    frame.origin.x=0;
    CGFloat y=(rect.size.height-size.height)/2.0;
    frame.origin.y =y>=0?y:0;
    imageView.frame=frame;
    
    if (self.imageView.frame.size.height>rect.size.height) {
        aScrollView.contentSize=CGSizeMake(rect.size.width, self.imageView.frame.size.height);
    }else{
        aScrollView.contentSize=CGSizeMake(rect.size.width, rect.size.height);
    }
}

-(void)loadImage
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getOriginImage:) name:ImageCacheNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismiss) name:@"tapClicked" object:nil];
    aScrollView.zoomScale=1.0;
    [imageView setImage:image];
    [self zoomToFit];
    if (bigImageURL!=nil) {
        [[ImageCacheManager getInstance]getDataWithURL:bigImageURL];
    }
}


-(void)setup
{
    aScrollView.minimumZoomScale=1.0;
    aScrollView.maximumZoomScale=50.0;
    aScrollView.delegate=self;
    aScrollView.backgroundColor=[UIColor blackColor];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
}

-(void)doubelClicked
{
    if (aScrollView.zoomScale==1.0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [aScrollView zoomToRect:CGRectMake(aScrollView.touchedPoint.x-50, aScrollView.touchedPoint.y-50, 100, 100) animated:YES];
        [UIView commitAnimations];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationBeginsFromCurrentState:YES];
        aScrollView.zoomScale=1.0;
        [UIView commitAnimations];
    }
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

-(void)getOriginImage:(NSNotification*)sender
{
    NSDictionary *dic=sender.object;
    if (delegate&&[delegate respondsToSelector:@selector(browserDidGetOriginImage:)]) {
        [delegate browserDidGetOriginImage:dic];
    }
}


@end
