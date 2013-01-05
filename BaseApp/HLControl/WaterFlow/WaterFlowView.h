//
//  WaterFlowView.h
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-19.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaterFlowView;

@interface WaterFlowCell:UIView
{
    NSIndexPath         *_indexPath;
    NSString            *_reuseIdentifier;
}
@property (nonatomic,strong)NSIndexPath     *indexPath;
@property (nonatomic,strong)NSString        *reuseIdentifier;

-(id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end


#pragma  mark - 代理方式
////DataSource and Delegate
@protocol WaterFlowViewDatasource <NSObject>
@required
- (NSInteger)numberOfColumnsInFlowView:(WaterFlowView*)flowView;
- (NSInteger)flowView:(WaterFlowView *)flowView numberOfRowsInColumn:(NSInteger)column;
- (WaterFlowCell *)flowView:(WaterFlowView *)flowView cellForRowAtIndex:(NSInteger)index;
- (WaterFlowCell *)flowView:(WaterFlowView *)flowView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol WaterFlowViewDelegate <NSObject>
@required
- (CGFloat)flowView:(WaterFlowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)flowView:(WaterFlowView *)flowView heightForCellAtIndex:(NSInteger)index;
@optional
- (void)flowView:(WaterFlowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)flowView:(WaterFlowView *)flowView didSelectAtCell:(WaterFlowCell*)cell ForIndex:(int)index;
- (void)flowView:(WaterFlowView *)flowView willLoadData:(int)page;
@end


@interface WaterFlowView : UIScrollView<UIScrollViewDelegate>
{
    NSInteger numberOfColumns ;
    NSInteger currentPage;
	
	NSMutableArray *_cellHeight;
	NSMutableArray *_visibleCells;
	NSMutableDictionary *_reusedCells;
	
	__unsafe_unretained id <WaterFlowViewDelegate> _flowDelegate;
    __unsafe_unretained id <WaterFlowViewDatasource> _flowDatasource;
}

- (void)reloadData;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@property (nonatomic, retain) NSMutableArray *cellHeight; //array of cells height arrays, count = numberofcolumns, and elements in each single child array represents is a total height from this cell to the top
@property (nonatomic, retain) NSMutableArray *cellIndex; //array of cells index arrays, count = numberofcolumns
@property (nonatomic, retain) NSMutableArray *visibleCells;  //array of visible cell arrays, count = numberofcolumns
@property (nonatomic, retain) NSMutableDictionary *reusableCells;  //key- identifier, value- array of cells
@property (nonatomic, assign) id <WaterFlowViewDelegate> flowDelegate;
@property (nonatomic, assign) id <WaterFlowViewDatasource> flowDatasource;

@end