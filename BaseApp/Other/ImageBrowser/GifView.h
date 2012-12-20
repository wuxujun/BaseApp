//
//  GifView.h
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GifView : UIView {
	CGImageSourceRef gif;
	NSDictionary *gifProperties;
	size_t index;
	size_t count;
	NSTimer *timer;
}

- (id)initWithFrame:(CGRect)frame filePath:(NSString *)_filePath;
- (id)initWithFrame:(CGRect)frame data:(NSData *)_data;

@end