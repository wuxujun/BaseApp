//
//  VHTableView.h
//  BaseApp
//
//  Created by xujun wu on 12-11-23.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TABLEVIEW_TAG           1000
#define TABLEVIEW_CELL_VIEW_TAG     1001
#define CELL_CONTENT_TAG            1002

typedef enum{
    VHTableViewOrientationVertical,
    VHTableViewOrientationHorizontal
} VHTableViewOrientation;

@class VHTableView;


@protocol VHTableViewDelegate <NSObject>

-(UIView*)vhTableView:(VHTableView*)vhTableView viewForRect:(CGRect)rect;
- (void)vhTableView:(VHTableView *)vhTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath*)indexPath;
@optional  //可选 接口
- (void)vhTableView:(VHTableView *)vhTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView;
- (void)vhTableView:(VHTableView *)vhTableView scrolledToOffset:(CGPoint)contentOffset;
- (NSUInteger)numberOfSectionsInVHTableView:(VHTableView*)vhTableView;
- (NSUInteger)numberOfCellsForVHTableView:(VHTableView *)view inSection:(NSInteger)section;
- (UIView*)vhTableView:(VHTableView*)vhTableView viewForHeaderInSection:(NSInteger)section;
- (UIView*)vhTableView:(VHTableView*)vhTableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)vhTableView:(VHTableView *)vhTableView heightOrWidthForCellAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface VHTableView : UIView <UITableViewDelegate, UITableViewDataSource> {
@private
	CGFloat		_cellWidthOrHeight;
	NSUInteger	_numItems;
}

@property (nonatomic, unsafe_unretained) id<VHTableViewDelegate> delegate;
@property (nonatomic, readonly, unsafe_unretained) UITableView *tableView;
@property (nonatomic, readonly, unsafe_unretained) NSArray *visibleViews;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) UIColor *cellBackgroundColor;
@property (nonatomic, readonly) VHTableViewOrientation orientation;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign) NSUInteger numberOfCells;

- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numCells ofWidth:(CGFloat)cellWidth;
- (id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numCells ofHeight:(CGFloat)cellHeight;
- (CGPoint)offsetForView:(UIView *)cell;
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;
- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath*)indexPathForView:(UIView *)cell;
- (void)reloadData;

@end
