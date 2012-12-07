//
//  HKeyboardControls.h
//  SAnalysis
//  自定义键盘上方  视图
//  Created by xujun wu on 12-11-1.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    KeyboardControlsDirectionPrevious,
    KeyboardControlsDirectionNext
}KeyboardControlsDirection;

@protocol HKeyboardControlsDelegate;

@interface HKeyboardControls : UIView

@property (nonatomic,strong)id<HKeyboardControlsDelegate> delegate;
@property (nonatomic,strong)NSArray     *textFields;

@property (nonatomic,assign)UIBarStyle      barStyle;


@end


@protocol HKeyboardControlsDelegate <NSObject>

@required
-(void)keyboardControlsClicked:(HKeyboardControls*)controls withDirection:(KeyboardControlsDirection) direction;

@end
