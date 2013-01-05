//
//  HomeItemView.h
//  FindAD
//
//  Created by  on 11-12-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerticallyAlignedLabel.h"
#import "UIViewExtention.h"
#import "HLMessage.h"
#import "ChartView.h"

@protocol HomeItemViewDelegate;

@interface HomeItemView : UIViewExtention{

    UIView                  *contentView;
    UILabel                 *titleLabel;
    UIImageView             *imageView;
    
    id<HomeItemViewDelegate>    delegate;
    
    UIView                  *touchBackView;
    ChartView               *chartView;
    
}
@property (nonatomic,strong)HLMessage             *message;
@property (nonatomic,strong)ChartView           *chartView;

@property (nonatomic,strong)NSString    *title;
@property (nonatomic,strong)NSString    *dataUrl;
@property (nonatomic,strong)UIView  *touchBackView;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializeFields;

@end


@protocol HomeItemViewDelegate <NSObject>

@optional
-(void)onItemClicked:(HomeItemView*)view;

@end