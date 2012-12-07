//
//  VHTableView.m
//  BaseApp
//  上下左右滚动  tableView
//  Created by xujun wu on 12-11-23.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "VHTableView.h"

#define ANIMATION_DURATION              0.30


@interface VHTableView(PrivateMethods)

- (void)createTableWithOrientation:(VHTableViewOrientation)orientation;
- (void)prepareRotatedView:(UIView *)rotatedView;
- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation VHTableView
@synthesize delegate,cellBackgroundColor;
@synthesize selectedIndexPath=_selectedIndexPath;
@synthesize orientation=_orientation;
@synthesize numberOfCells=_numItems;


#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numCells ofWidth:(CGFloat)cellWidth
{
    if ( self = [super initWithFrame:frame]) {
        // Initialization code
        _numItems=numCells;
        _cellWidthOrHeight=cellWidth;
        
        [self createTableWithOrientation:VHTableViewOrientationHorizontal];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numCells ofHeight:(CGFloat)cellHeight
{
    if ( self = [super initWithFrame:frame]) {
        // Initialization code
        _numItems=numCells;
        _cellWidthOrHeight=cellHeight;
        
        [self createTableWithOrientation:VHTableViewOrientationVertical];
    }
    return self;
}

-(void)createTableWithOrientation:(VHTableViewOrientation)orientation
{
    _orientation=orientation;
    UITableView      *tableView;
    if (orientation==VHTableViewOrientationHorizontal) {
        int xOrign=(self.bounds.size.width-self.bounds.size.height)/2;
        int yOrign=(self.bounds.size.height-self.bounds.size.width)/2;
        tableView=[[UITableView alloc]initWithFrame:CGRectMake(xOrign, yOrign, self.bounds.size.height, self.bounds.size.width)];
        
    }else{
        tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    }
    tableView.tag=TABLEVIEW_TAG;
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    if (orientation==VHTableViewOrientationHorizontal) {
        tableView.transform=CGAffineTransformMakeRotation(-M_PI/2);
    }
    tableView.showsVerticalScrollIndicator=NO;
    tableView.showsHorizontalScrollIndicator=NO;
    
    [self addSubview:tableView];
}


#pragma mark - Properties
-(UITableView*)tableView
{
    return (UITableView*)[self viewWithTag:TABLEVIEW_TAG];
}

-(NSArray*)visibleViews
{
    NSArray *visibleCells=[self.tableView visibleCells];
    NSMutableArray *visibleViews=[NSMutableArray arrayWithCapacity:[visibleCells count]];
    for (UIView *aView in visibleCells) {
        [visibleViews addObject:[aView viewWithTag:CELL_CONTENT_TAG]];
    }
    return visibleViews;
}

-(CGPoint)contentOffset
{
    CGPoint offset=self.tableView.contentOffset;
    if (_orientation==VHTableViewOrientationHorizontal) {
        offset=CGPointMake(offset.y, offset.x);
    }
    return offset;
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    if (_orientation==VHTableViewOrientationHorizontal) {
        self.tableView.contentOffset=CGPointMake(contentOffset.y, contentOffset.x);
    }else{
        self.tableView.contentOffset    =contentOffset;
    }
}

-(void)setContentOffset:(CGPoint)offset animated:(BOOL)animated
{
    CGPoint newPoint;
    if (_orientation==VHTableViewOrientationHorizontal){
        newPoint=CGPointMake(offset.y, offset.x);
    }else{
        newPoint=offset;
    }
    [self.tableView setContentOffset:newPoint animated:animated];
}

#pragma mark - Selection
-(void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    self.selectedIndexPath=indexPath;
    CGPoint defaultPoint=CGPointMake(0, indexPath.row*_cellWidthOrHeight);
    [self.tableView setContentOffset:defaultPoint animated:animated];
}

- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
	if (![_selectedIndexPath isEqual:indexPath]) {
		NSIndexPath *oldIndexPath = [_selectedIndexPath copy];
		
		_selectedIndexPath = indexPath;
		
		UITableViewCell *deselectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:oldIndexPath];
		UITableViewCell *selectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
		
		if ([delegate respondsToSelector:@selector(vhTableView:selectedView:atIndexPath:deselectedView:)]) {
			UIView *selectedView = [selectedCell viewWithTag:CELL_CONTENT_TAG];
			UIView *deselectedView = [deselectedCell viewWithTag:CELL_CONTENT_TAG];
			[delegate vhTableView:self  selectedView:selectedView atIndexPath:_selectedIndexPath deselectedView:deselectedView];
		}
	}
}


#pragma mark Multiple Sections

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(vhTableView:viewForHeaderInSection:)]) {
        UIView *headerView = [delegate vhTableView:self viewForHeaderInSection:section];
		if (_orientation == VHTableViewOrientationHorizontal)
			return headerView.frame.size.width;
		else
			return headerView.frame.size.height;
    }
    return 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(vhTableView:viewForFooterInSection:)]) {
        UIView *footerView = [delegate vhTableView:self viewForFooterInSection:section];
		if (_orientation == VHTableViewOrientationHorizontal)
			return footerView.frame.size.width;
		else
			return footerView.frame.size.height;
    }
    return 0.0;
}

- (UIView *)viewToHoldSectionView:(UIView *)sectionView {
	// Enforce proper section header/footer view height abd origin. This is required because
	// of the way UITableView resizes section views on orientation changes.
	if (_orientation == VHTableViewOrientationHorizontal)
		sectionView.frame = CGRectMake(0, 0, sectionView.frame.size.width, self.frame.size.height);
        
        UIView *rotatedView = [[UIView alloc] initWithFrame:sectionView.frame];
        
        if (_orientation == VHTableViewOrientationHorizontal) {
            rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
            sectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        }
        else {
            sectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
	[rotatedView addSubview:sectionView];
	return rotatedView;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(vhTableView:viewForHeaderInSection:)]) {
		UIView *sectionView = [delegate vhTableView:self viewForHeaderInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(vhTableView:viewForFooterInSection:)]) {
		UIView *sectionView = [delegate vhTableView:self viewForFooterInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([delegate respondsToSelector:@selector(numberOfSectionsInVHTableView:)]) {
        return [delegate numberOfSectionsInVHTableView:self];
    }
    return 1;
}

#pragma mark -
#pragma mark Location and Paths

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath {
	UIView *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	return [cell viewWithTag:CELL_CONTENT_TAG];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
	NSArray *visibleCells = [self.tableView visibleCells];
	
	__block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UITableViewCell *cell = obj;
        
		if ([cell viewWithTag:CELL_CONTENT_TAG] == view) {
            indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
		}
	}];
	return indexPath;
}

- (CGPoint)offsetForView:(UIView *)view {
	// Get the location of the cell
	CGPoint cellOrigin = [view convertPoint:view.frame.origin toView:self];
	
	// No need to compensate for orientation since all values are already adjusted for orientation
	return cellOrigin;
}

#pragma mark -
#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[self setSelectedIndexPath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([delegate respondsToSelector:@selector(vhTableView:heightOrWidthForCellAtIndexPath:)]) {
        return [delegate vhTableView:self heightOrWidthForCellAtIndexPath:indexPath];
    }
    return _cellWidthOrHeight;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Don't allow the currently selected cell to be selectable
	if ([_selectedIndexPath isEqual:indexPath]) {
		return nil;
	}
	return indexPath;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([delegate respondsToSelector:@selector(vhTableView:scrolledToOffset:)])
		[delegate vhTableView:self scrolledToOffset:self.contentOffset];
}


#pragma mark -
#pragma mark TableViewDataSource

- (void)setCell:(UITableViewCell *)cell boundsForOrientation:(VHTableViewOrientation)theOrientation {
	if (theOrientation == VHTableViewOrientationHorizontal) {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.height, _cellWidthOrHeight);
	}
	else {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.width, _cellWidthOrHeight);
	}
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EasyTableViewCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		[self setCell:cell boundsForOrientation:_orientation];
		
		cell.contentView.frame = cell.bounds;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// Add a view to the cell's content view that is rotated to compensate for the table view rotation
		CGRect viewRect;
		if (_orientation == VHTableViewOrientationHorizontal)
			viewRect = CGRectMake(0, 0, cell.bounds.size.height, cell.bounds.size.width);
		else
			viewRect = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
		
		UIView *rotatedView				= [[UIView alloc] initWithFrame:viewRect];
		rotatedView.tag					= TABLEVIEW_CELL_VIEW_TAG;
		rotatedView.center				= cell.contentView.center;
		rotatedView.backgroundColor		= self.cellBackgroundColor;
		
		if (_orientation == VHTableViewOrientationHorizontal) {
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		}
		else
			rotatedView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
		// We want to make sure any expanded content is not visible when the cell is deselected
		rotatedView.clipsToBounds = YES;
		
		// Prepare and add the custom subviews
		[self prepareRotatedView:rotatedView];
		
		[cell.contentView addSubview:rotatedView];
	}
	[self setCell:cell boundsForOrientation:_orientation];
	
	[self setDataForRotatedView:[cell.contentView viewWithTag:TABLEVIEW_CELL_VIEW_TAG] forIndexPath:indexPath];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger numOfItems = _numItems;
	
	if ([delegate respondsToSelector:@selector(numberOfCellsForVHTableView:inSection:)]) {
		numOfItems = [delegate numberOfCellsForVHTableView:self inSection:section];
		
		// Animate any changes in the number of items
		[tableView beginUpdates];
		[tableView endUpdates];
	}
	
    return numOfItems;
}

#pragma mark -
#pragma mark Rotation

- (void)prepareRotatedView:(UIView *)rotatedView {
	UIView *content = [delegate vhTableView:self viewForRect:rotatedView.bounds];
	
	// Add a default view if none is provided
	if (content == nil)
		content = [[UIView alloc] initWithFrame:rotatedView.bounds];
        
        content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        content.tag = CELL_CONTENT_TAG;
        [rotatedView addSubview:content];
}


- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath {
	UIView *content = [rotatedView viewWithTag:CELL_CONTENT_TAG];
	
    [delegate vhTableView:self setDataForView:content forIndexPath:indexPath];
}

-(void)reloadData{
    [self.tableView reloadData];
}


@end
