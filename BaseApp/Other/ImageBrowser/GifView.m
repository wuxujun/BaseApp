//
//  GifView.m
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "GifView.h"
#import <QuartzCore/QuartzCore.h>


@implementation GifView

- (id)initWithFrame:(CGRect)frame filePath:(NSString *)_filePath{
    
    self = [super initWithFrame:frame];
    if (self) {
        
		gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
													 forKey:(NSString *)kCGImagePropertyGIFDictionary];
		gif = CGImageSourceCreateWithURL((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:_filePath]), (CFDictionaryRef)CFBridgingRetain(gifProperties));
		count =CGImageSourceGetCount(gif);
		timer = [NSTimer scheduledTimerWithTimeInterval:0.12 target:self selector:@selector(play) userInfo:nil repeats:YES];
		[timer fire];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame data:(NSData *)_data{
    
    self = [super initWithFrame:frame];
    if (self) {
        
		gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
													 forKey:(NSString *)kCGImagePropertyGIFDictionary];
        //		gif = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:_filePath], (CFDictionaryRef)gifProperties);
        gif = CGImageSourceCreateWithData((CFDataRef)CFBridgingRetain(_data), (CFDictionaryRef)CFBridgingRetain(gifProperties));
		count =CGImageSourceGetCount(gif);
		timer = [NSTimer scheduledTimerWithTimeInterval:0.12 target:self selector:@selector(play) userInfo:nil repeats:YES];
		[timer fire];
    }
    return self;
}

-(void)play
{
	index ++;
	index = index%count;
	CGImageRef ref = CGImageSourceCreateImageAtIndex(gif, index, (CFDictionaryRef)CFBridgingRetain(gifProperties));
	self.layer.contents = (id)CFBridgingRelease(ref);
    CFRelease(ref);
}
-(void)removeFromSuperview
{
	NSLog(@"removeFromSuperview");
	[timer invalidate];
	timer = nil;
	[super removeFromSuperview];
}

@end
