//
//  HomeView.h
//  FindAD
//
//  Created by  on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeItemView.h"
#import "HLMessage.h"
#import "OverlayView.h"

@protocol HomeViewDelegate;

@interface HomeView : UIView<HomeItemViewDelegate>{

    id<HomeViewDelegate>   delegate;
}
@property (nonatomic,strong)HLMessage     *message;
-(id)initWithFrame:(CGRect)frame  delegate:(id)aDelegate;
-(void)loadData;
-(void)reloadData;

@end

@protocol HomeViewDelegate <NSObject>

@optional
-(void)onHomeViewClicked:(HomeView*)view;

@end