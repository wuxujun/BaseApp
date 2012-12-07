//
//  HLPopTipView.h
//  BaseApp
//  提示框内容
//  Created by xujun wu on 12-11-29.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    PointDirectionUp=0,
    PointDirectionDown
}PointDirection;

typedef enum{
    HLPopTipAnimationSlide=0,
    HLPopTipAnimationPop
} HLPopTipAnimation;


@protocol HLPopTipViewDelegate;

@interface HLPopTipView : UIView{
    UIColor         *backgroundColor;
    __unsafe_unretained id<HLPopTipViewDelegate>        delegate;
    NSString        *message;
    id              targetObject;
    UIColor         *textColor;
    UIFont          *textFont;
    HLPopTipAnimation       animation;
    @private
    CGSize          bubbleSize;
    CGFloat         cornerRadius;
    BOOL            highlight;
    CGFloat         sidePadding;
    CGFloat         topMargin;
    PointDirection      pointDirection;
    CGFloat         pointerSize;
    CGPoint         targetPoint;
}

@property (nonatomic,strong)UIColor         *backgroundColor;
@property (nonatomic, assign)		id<HLPopTipViewDelegate>	delegate;
@property (nonatomic, assign)			BOOL					disableTapToDismiss;
@property (nonatomic, strong)			NSString				*message;
@property (nonatomic, strong)           UIView	                *customView;
@property (nonatomic, strong, readonly)	id						targetObject;
@property (nonatomic, strong)			UIColor					*textColor;
@property (nonatomic, strong)			UIFont					*textFont;
@property (nonatomic, assign)			UITextAlignment			textAlignment;
@property (nonatomic, assign)           HLPopTipAnimation       animation;
@property (nonatomic, assign)           CGFloat                 maxWidth;


-(id)initWithMessage:(NSString*)messageToShow;
-(id)initWithCustomView:(UIView*)aView;

-(void)presentPointingAtView:(UIView*)targetView inView:(UIView*)containerView  animated:(BOOL)animated;
- (void)presentPointingAtBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

- (PointDirection) getPointDirection;


@end


@protocol HLPopTipViewDelegate <NSObject>

-(void)popTipViewWasDismissedByUser:(HLPopTipView*)popTipView;

@end
