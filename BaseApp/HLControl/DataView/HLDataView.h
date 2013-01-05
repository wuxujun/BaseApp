//
//  HLDataView.h
//  GrpCust
//  数据列表
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLDataViewCell.h"

typedef enum {
	HLDataViewScrollPositionNone = 0,
	HLDataViewScrollPositionTopLeft,
	HLDataViewScrollPositionTopCenter,
	HLDataViewScrollPositionTopRight,
	HLDataViewScrollPositionMiddleLeft,
	HLDataViewScrollPositionMiddleCenter,
	HLDataViewScrollPositionMiddleRight,
	HLDataViewScrollPositionBottomLeft,
	HLDataViewScrollPositionBottomCenter,
	HLDataViewScrollPositionBottomRight
} HLDataViewScrollPosition;

typedef enum {
	HLDataViewEdgeTop,
	HLDataViewEdgeBottom,
	HLDataViewEdgeLeft,
	HLDataViewEdgeRight
} HLDataViewEdge;

@protocol HLDataViewDelegate;
@protocol HLDataViewDataSource;

@interface HLDataView : UIScrollView<UIScrollViewDelegate>{
    
    CGPoint         cellOffset;
    UIEdgeInsets    outset;
    
    NSMutableArray  *dataCells;
    NSMutableArray  *freeCells;

    NSMutableArray  *cellInfoForCellsOnScreen;
    NSMutableArray  *dataRows;
    
    NSMutableArray  *rowHeights;
    NSMutableArray  *rowPositions;
    NSMutableArray  *cellsOnScreen;
    
    CGPoint         oldContentOffset;
    BOOL            hasResized;
    
    BOOL            hasLoadedData;
    NSInteger       numberOfRows;
    
    NSUInteger      rowIndexOfSelectedCell;
    NSUInteger      columnIndexOfSelectedCell;
    
    NSTimer         *decelerationTimer;
    NSTimer         *draggingTimer;
    

}

@property (nonatomic,strong)  id<HLDataViewDelegate>        delegate;
@property (nonatomic,strong)  id<HLDataViewDataSource>      dataSource;

@property (assign)CGPoint                   cellOffset;
@property (assign)UIEdgeInsets              outset;
@property (nonatomic,retain)NSMutableArray  *dataCells;
@property (nonatomic)NSInteger              numberOfRows;

- (void)didEndMoving;
- (void)didEndDragging;
- (void)didEndDecelerating;

-(CGFloat)findWidthFowRow:(NSInteger)row column:(NSInteger)column;
-(NSInteger)findNumberOfRows;
-(NSInteger)findNumberOfColumnsForRow:(NSInteger)row;

-(CGFloat)findHeightForRow:(NSInteger)row;

-(HLDataViewCell*)findViewForRow:(NSInteger)row column:(NSInteger)colnum;

-(HLDataViewCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier;

-(HLDataViewCell*)cellForView:(NSInteger)rowIndex column:(NSInteger)columnIndex;

-(void)scrollViewToRow:(NSUInteger)rowIndex column:(NSUInteger)colunmIndex scrollPosition:(HLDataViewScrollPosition)position animated:(BOOL)animated;

-(void)selectRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(HLDataViewScrollPosition)position animated:(BOOL)animated;

-(void)didLoad;
-(void)reloadData;

@end

@protocol HLDataViewDelegate <UIScrollViewDelegate>

@optional
-(void)dataViewDidLoad:(HLDataView*)dataView;
-(void)dataView:(HLDataView*)dataView selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
-(void)dataView:(HLDataView *)dataView scrolledToEdge:(HLDataViewEdge)edge;
-(void)pagedDataView:(HLDataView*)dataView didScrollToRow:(NSInteger)rowIndex column:(NSInteger)colunmIndex;
-(void)dataView:(HLDataView*)dataView didProgrammaticallyScrollToRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;

@end


@protocol HLDataViewDataSource <NSObject>

@optional
-(NSInteger)numberOfRowsInDataView:(HLDataView*)dataView;
-(NSInteger)numberOfColumnsInDataView:(HLDataView*)dataView forRowWithIndex:(NSInteger)index;
-(CGFloat)dataView:(HLDataView*)dataView heightForRow:(NSInteger)rowIndex;
-(CGFloat)dataView:(HLDataView *)dataView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
-(HLDataViewCell*)dataView:(HLDataView*)dataView viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;

@end
