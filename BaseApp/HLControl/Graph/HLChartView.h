//
//  HLChartView.h
//  GrpCust
//
//  Created by  on 11-12-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum{
    HLChartViewStyleBar,
    HLChartViewStyleLine,
    HLChartViewStylePie,
    HLChartViewStyleMixed
}HLChartViewStyle;


@class CAMediaTimingFunction;

@protocol HLChartViewDataSource;
@protocol HLChartViewDelegate;

@interface HLChartView : UIView{
}


@property (nonatomic,strong)id<HLChartViewDelegate> delegate;
@property (nonatomic,strong)id<HLChartViewDataSource> dataSource;
@property (nonatomic,assign)NSInteger itemTitleHeight;
@property (nonatomic,assign)CGFloat animationSpeed;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,assign)BOOL    isTouch;
@property (nonatomic,assign)BOOL    isShowLegend;
@property (nonatomic,assign)CGFloat legendHeight;
@property (nonatomic,assign)HLChartViewStyle chartStyle;

-(id)initWithFrame:(CGRect)frame style:(HLChartViewStyle)style;

-(void)reloadData;

@end
@protocol HLChartViewDataSource <NSObject>

//几条线或几组
-(NSInteger)numberOfSectionsInChartView:(HLChartView*)chartView;


//每条线上点数或每组数量
-(NSInteger)chartView:(HLChartView *)chartView numberOfRowsInSection:(NSInteger)section;
//每条线标签内容
-(NSString*)chartView:(HLChartView*)chartView legendOfTitleInSection:(NSInteger)section;
//每条线 各节点值 
-(float)chartView:(HLChartView*)chartView valueForChartViewAtIndex:(NSInteger)index section:(NSInteger)section;
-(float)chartView:(HLChartView *)chartView value2ForChartViewAtIndex:(NSInteger)index section:(NSInteger)section;
//每条记录 类型  值为  line  或bar
-(NSString*)chartView:(HLChartView*)chartView typeForChartView:(NSInteger)index;


-(float)maxVerticalValueInChartView:(HLChartView*)chartView filter:(NSMutableArray*)aDict;
//根据类型取最大值
-(NSInteger)numberOfSectionsInChartView:(HLChartView*)chartView type:(NSString*)type;
-(float)maxVerticalValueInChartView:(HLChartView*)chartView filter:(NSMutableArray*)aDict type:(NSString*)type;
-(float)chartView:(HLChartView *)chartView valueForChartViewAtIndex:(NSInteger)index section:(NSInteger)section type:(NSString*)type;


-(float)minVerticalValueInChartView:(HLChartView*)chartView filter:(NSMutableArray*)aDict;
-(float)maxHorizontalValueInChartView:(HLChartView*)chartView;


//每块值
-(CGFloat)chartView:(HLChartView*)chartView valueForChartView:(NSInteger)index;

@optional

-(NSString*)chartView:(HLChartView*)chartView titleForChartView:(NSInteger)index;
-(UIColor*)chartView:(HLChartView*)chartView colorForChartView:(NSInteger)index;
//X轴坐标值 
-(NSString*)chartView:(HLChartView *)chartView scaleXTitleForChartView:(NSInteger)section;

@end


@protocol HLChartViewDelegate <NSObject>

@optional

-(void)clickCharkView:(HLChartView*)chartView;
-(void)chartView:(HLChartView*)chartView willSelectAtIndex:(NSInteger)index;
-(void)chartView:(HLChartView*)chartView didSelectAtIndex:(NSInteger)index;
-(void)chartView:(HLChartView*)chartView willDeselectAtIndex:(NSInteger)index;
-(void)chartView:(HLChartView *)chartView didDeselectAtIndex:(NSInteger)index;
-(void)chartDidLoadFinish:(BOOL)flag;

@end