//
//  ChartViewr.h
//  GrpCust
//
//  Created by  on 11-11-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLChartView.h"
#import "UIViewExtention.h"
#import "OverlayView.h"
#import "ASIHTTPRequest.h"

@protocol ChartViewDelegate;

@interface ChartView : UIViewExtention{
    
    ASIHTTPRequest      *_request;
    OverlayView         *overlayView;
    
    
    int             curRecord;
   
}
@property (nonatomic,retain)NSMutableArray     *dataArray;
@property (nonatomic,retain)NSMutableArray     *headerArray;

@property (nonatomic,assign)int         curRecord;
@property (nonatomic,retain)HLChartView         *chartView;
@property (nonatomic,assign)HLChartViewStyle    chartStyle;
@property (nonatomic,retain)NSString            *requestUrl;
@property (nonatomic,retain)id<ChartViewDelegate> delegate;

-(void)setChartViewTitle:(NSString*)title isTouch:(BOOL)touch showLegend:(BOOL)isLegend;

-(void)loadData;
-(void)reloadData;
-(void)parserData:(NSData*)data;

@end


@protocol ChartViewDelegate <NSObject>

@optional

-(void)chartDidLoadFinish:(BOOL)flag;

@end
