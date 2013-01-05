//
//  OverlayView.h
//  GrpCust
//
//  Created by 吴旭俊 on 11-9-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    OVERLAY_MODE_HIDDEN,
    OVERLAY_MODE_DARKEN,
    OVERLAY_MODE_SHADOW,
    OVERLAY_MODE_MESSAGE,
} OverlayViewMode;

@interface OverlayView : UIView {
 
    UIActivityIndicatorView     *spinner;
    
    CGPoint                     point;
    BOOL                        moved;
    NSString                    *message;
    
    OverlayViewMode             mode;
}

@property (nonatomic,assign)OverlayViewMode mode;

-(void)setMessage:(NSString*)aMessage spinner:(BOOL)flag;



@end
