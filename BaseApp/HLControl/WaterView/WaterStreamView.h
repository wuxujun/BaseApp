//
//  WaterStreamView.h
//  BaseApp
//
//  Created by xujun wu on 12-12-7.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterStreamViewCell.h"

@class WaterStreamView;

@protocol  WaterStreamViewDelegate <NSObject,UIScrollViewDelegate>

-(void)waterView:(WaterStreamView*)waterView didSelectWaterCell:(WaterStreamViewCell*)viewCell atIndex:(NSInteger)index;

@end

@protocol WaterStreamViewDataSource <NSObject>

@required

/**
 * 共多少个元素
 */
-(NSInteger)numberOfElementsInWaterView:(WaterStreamView*)waterView;

@optional

/**
 * 共多少个瀑布
 *
 */
-(NSInteger)numberOfWatersInWaterView:(WaterStreamView*)waterView;

/**
 *一行有多高
 */
-(CGFloat)waterView:(WaterStreamView*)waterView heightForRowAtIndex:(NSInteger)index basedWidth:(CGFloat)width;

/**
 * 每行显示内容
 *
 */
-(WaterStreamViewCell*)waterView:(WaterStreamView*)waterView cellForCellAtIndex:(int)index;

@end

@interface WaterStreamView : UIView<NSCoding ,UIScrollViewDelegate>
{
    NSInteger       _columns;
    UIScrollView        *_scrollView;
    CGFloat             _height;
    NSMutableArray      *_columnRects;
    
    CGRect              _visibleRect;
    NSMutableArray      *_visibleListCells;
    
    NSMutableDictionary     *_reusableListCells;
    
    NSInteger               _selectedIndex;
}

@property (nonatomic,strong)UIView      *headerView;
@property (nonatomic,strong)UIView      *footerView;

@property (nonatomic,assign)NSUInteger      columnCount;
@property (nonatomic,strong)UIColor         *separatorColor;

@property (nonatomic,assign)id<WaterStreamViewDelegate> delegate;
@property (nonatomic,assign)id<WaterStreamViewDataSource>   dataSource;

-(void)reloadData;

-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
-(UITableViewCell*)cellAtIndex:(NSUInteger)index;
-(UITableViewCell*)cellAtIndexPath:(NSUInteger)indexPath;

@end
