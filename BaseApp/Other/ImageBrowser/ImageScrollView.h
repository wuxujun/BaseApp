//
//  ImageScrollView.h
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView
{
    bool        doubleClicked;
    CGPoint     touchedPoint;
}

@property (readwrite)   bool    doubleClicked;
@property (nonatomic)   CGPoint touchedPoint;

@end
