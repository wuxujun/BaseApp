//
//  HLDataView.m
//  GrpCust
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HLDataView.h"
#import "HLDataViewCellInfoProtocol.h"
NSInteger   const  HLDataViewInvalid=-1;

#pragma mark HLDataViewCellInfo
@interface HLDataViewCellInfo : NSObject<HLDataViewCellInfoProtocol> {
    NSUInteger xPosition,yPosition;
    CGRect  frame;
    CGFloat     x,y,width,height;
    
}

@property (nonatomic,assign)CGFloat  x,y,width,height;
@end

@implementation HLDataViewCellInfo
@synthesize xPosition,yPosition,x,y,width,height,frame;
-(NSString*)description{
    return [NSString stringWithFormat:@"HLDataViewCellInfo: frame=(%i %i; %i %i) x=%i, y=%i", (NSInteger)self.frame.origin.x, (NSInteger)self.frame.origin.y, (NSInteger)self.frame.size.width, (NSInteger)self.frame.size.height, self.xPosition, self.yPosition];
}

@end
#pragma mark HLDataView Private
@interface HLDataView()

@property (nonatomic,retain)NSTimer *decelerationTimer, *draggingTimer;


-(void)initSetupInternal;
-(void)loadData;
-(void)initialiseView;
-(void)checkViews;
-(void)fireEdgeScroll;

- (void)checkNewRowStartingWithCellInfo:(NSObject<HLDataViewCellInfoProtocol> *)info goingUp:(BOOL)goingUp;
- (NSObject<HLDataViewCellInfoProtocol> *)cellInfoForRow:(NSUInteger)row column:(NSUInteger)col;
- (void)checkRow:(NSInteger)row column:(NSInteger)col goingLeft:(BOOL)goingLeft;

- (void)decelerationTimer:(NSTimer *)timer;
- (void)draggingTimer:(NSTimer *)timer;


@end


@implementation HLDataView
@synthesize delegate,dataSource;
@synthesize dataCells,numberOfRows,cellOffset,outset;
@synthesize decelerationTimer,draggingTimer;


NSInteger intDataSort(id info1, id info2, void *context) {
	
	HLDataViewCellInfo *i1 = (HLDataViewCellInfo *)info1;
	HLDataViewCellInfo *i2 = (HLDataViewCellInfo *)info2;
    
    if (i1.yPosition < i2.yPosition)
        return NSOrderedAscending;
    else if (i1.yPosition > i2.yPosition)
        return NSOrderedDescending;
    else if (i1.xPosition < i2.xPosition)
		return NSOrderedAscending;
	else if (i1.xPosition > i2.xPosition)
        return NSOrderedDescending;
	else
		return NSOrderedSame;
}


- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    self.showsHorizontalScrollIndicator=NO;
    self.showsVerticalScrollIndicator=NO;
    [self initSetupInternal];
    return self;
}

-(void)awakeFromNib
{
    [self initSetupInternal];
}

-(void)initSetupInternal
{
    numberOfRows=HLDataViewInvalid;
    columnIndexOfSelectedCell=HLDataViewInvalid;
    rowIndexOfSelectedCell=HLDataViewInvalid;
    
    dataRows=[[NSMutableArray alloc]init ];
    rowPositions=[[NSMutableArray alloc]init ];
    rowHeights=[[NSMutableArray alloc]init ];
    cellsOnScreen=[[NSMutableArray alloc]init];
    
    freeCells=[[NSMutableArray  alloc]init];
    cellInfoForCellsOnScreen=[[NSMutableArray alloc]init];
}

-(void)setFrame:(CGRect)aFrame
{
    CGSize oldSize=self.frame.size;
    CGSize newSize=aFrame.size;
    if (oldSize.height!=newSize.height||oldSize.width!=newSize.width) {
        hasResized=YES;
    }
    [super setFrame:aFrame];
    if (hasResized) {
        [self setNeedsLayout];
    }
}

-(void)reloadData
{
    [self loadData];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    oldContentOffset=CGPointMake(0.0f, 0.0f);
    
    [self loadData];
    
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[HLDataViewCell class]]) {
            [v removeFromSuperview];
        }
    }
    [self initialiseView];
    [self didLoad];
    
}

-(void)didLoad
{
    if ([self.delegate respondsToSelector:@selector(dataViewDidLoad:)]) {
        [self.delegate dataViewDidLoad:self];
    }
}

-(void)didEndDragging
{
}

-(void)didEndDecelerating
{

}

-(void)didEndMoving
{

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self checkViews];
    [self fireEdgeScroll];
    
    if (!self.draggingTimer &&!self.decelerationTimer &&self.dragging) {
        self.draggingTimer=[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(draggingTimer:) userInfo:nil repeats:NO];
    }
    
    if (!self.decelerationTimer &&self.decelerating) {
        self.decelerationTimer=[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(decelerationTimer:) userInfo:nil repeats:NO];
        [self.draggingTimer invalidate];
        self.draggingTimer=nil;
    }
    
}

-(void)decelerationTimer:(NSTimer *)timer
{
    self.decelerationTimer=nil;
    [self didEndDecelerating];
    [self didEndMoving];
}

-(void)draggingTimer:(NSTimer *)timer
{
    self.draggingTimer=nil;
    [self didEndDragging];
    [self didEndMoving];
}

- (void)addCellWithInfo:(NSObject<HLDataViewCellInfoProtocol> *)info {
	
	if (![info isMemberOfClass:[HLDataViewCellInfo class]]) return;
	
	[cellInfoForCellsOnScreen addObject:info];
	
	[cellInfoForCellsOnScreen sortUsingFunction:intDataSort context:NULL];
	
	HLDataViewCell *cell = [self findViewForRow:info.yPosition column:info.xPosition];
    NSLog(@"================= %@",[cell description]);
	[cell setNeedsDisplay];
	cell.xPosition = info.xPosition;
	cell.yPosition = info.yPosition;
//	cell.delegate =(id<HLDataViewCellDelegate>)self;
	cell.frame = info.frame;
	
	if (cell.xPosition == columnIndexOfSelectedCell && cell.yPosition == rowIndexOfSelectedCell)
		cell.selected = YES;
	else
		cell.selected = NO;
	
	[[dataCells objectAtIndex:info.yPosition] replaceObjectAtIndex:info.xPosition withObject:cell];
	
	[self insertSubview:cell atIndex:0];
	
	// remove any existing view at this frame	
	for (UIView *v in self.subviews) {
		if ([v isKindOfClass:[HLDataViewCell class]] &&
			v.frame.origin.x == cell.frame.origin.x &&
			v.frame.origin.y == cell.frame.origin.y &&
			v != cell) {
			
			[v removeFromSuperview];
			break;
		}
	}
}


- (void)removeCellWithInfo:(HLDataViewCellInfo *)info {
	if (info.yPosition > [dataCells count]) return;
	NSMutableArray *row = [dataCells objectAtIndex:info.yPosition];
	if (info.xPosition > [row count]) return;
	HLDataViewCell *cell = [row objectAtIndex:info.xPosition];
	if (![cell isKindOfClass:[HLDataViewCell class]]) return;
	[cell removeFromSuperview];
	[row replaceObjectAtIndex:info.xPosition withObject:info];
	[cellInfoForCellsOnScreen removeObject:info];
	// TODO: Should this be set?
	//cell.frame = CGRectZero;
	
	[freeCells addObject:cell];
}


- (CGRect)visibleRect {
    CGRect visibleRect;
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.bounds.size;
	return visibleRect;
}

- (BOOL)rowOfCellInfoShouldBeOnShow:(NSObject<HLDataViewCellInfoProtocol> *)info {
	
	CGRect visibleRect = [self visibleRect];
	
	CGRect infoFrame = info.frame;
    
    CGFloat infoBottom = infoFrame.origin.y + infoFrame.size.height;
    CGFloat infoTop = infoFrame.origin.y;
    
    CGFloat visibleBottom = visibleRect.origin.y + visibleRect.size.height;
    CGFloat visibleTop = visibleRect.origin.y;
    
    return (infoBottom >= visibleTop &&
            infoTop <= visibleBottom);
}

- (BOOL)cellInfoShouldBeOnShow:(NSObject<HLDataViewCellInfoProtocol> *)info {
	
	if (!info || ![info isMemberOfClass:[HLDataViewCellInfo class]]) return NO;
	
    CGRect visibleRect = [self visibleRect];
    
    CGFloat infoRight = info.frame.origin.x + info.frame.size.width;
    CGFloat infoLeft = info.frame.origin.x;
    
	CGFloat visibleRight = visibleRect.origin.x + visibleRect.size.width;
    CGFloat visibleLeft = visibleRect.origin.x;
    
    if (infoRight >= visibleLeft &&
		infoLeft <=  visibleRight &&
		[self rowOfCellInfoShouldBeOnShow:info]) return YES;
	
	return NO;
}


#pragma mark finding DataSource
-(CGFloat)findWidthFowRow:(NSInteger)row column:(NSInteger)column
{
    return [self.dataSource dataView:self widthForCellAtRow:row column:column];
}

-(NSInteger)findNumberOfRows
{
    return [self.dataSource numberOfRowsInDataView:self];
}

-(NSInteger)findNumberOfColumnsForRow:(NSInteger)row
{
    return [self.dataSource numberOfColumnsInDataView:self forRowWithIndex:row];
}

-(CGFloat)findHeightForRow:(NSInteger)row
{
    return [self.dataSource dataView:self heightForRow:row];
}

-(HLDataViewCell*)findViewForRow:(NSInteger)row column:(NSInteger)colnum
{
    return [self.dataSource dataView:self viewForRow:row column:colnum];
}


#pragma mark - LoadData
-(void)loadData
{
    hasLoadedData=YES;
    if (![self.dataSource respondsToSelector:@selector(numberOfRowsInDataView:)]) {
        return;
    }
    
    self.numberOfRows=[self findNumberOfRows];
    
    if (!self.numberOfRows) {
        return;
    }
    
    [dataRows removeAllObjects];
    [rowHeights removeAllObjects];
    [rowPositions removeAllObjects];
    
    NSMutableArray *cellInfoArrayRows=[[NSMutableArray alloc]init ];
    
    CGFloat maxHeight=0;
    CGFloat maxWidth=0;
    
    for (NSInteger i=0; i<self.numberOfRows; i++) {
        NSInteger numberOfCols=[self findNumberOfColumnsForRow:i];
        NSMutableArray *cellInfoArrayCols=[[NSMutableArray alloc]init];
        for (NSInteger j=0; j<numberOfCols; j++) {
            HLDataViewCellInfo *info=[[HLDataViewCellInfo alloc]init];
            info.xPosition=j;
            info.yPosition=i;
            
            CGFloat height=[self findHeightForRow:i];
            CGFloat width=[self findWidthFowRow:i column:j];
            
            CGFloat y;
            CGFloat x;
            if (i==0) {
                y=0.0f;
            }else{
                HLDataViewCellInfo *previousCellRow=[[cellInfoArrayRows objectAtIndex:i-1] objectAtIndex:0];
                y=previousCellRow.frame.origin.y+previousCellRow.frame.size.height;
                if (cellOffset.y!=0) {
                    y+=cellOffset.y;
                }
            }
            
            if (j==0) {
                x=0.0f;
            }else{
                HLDataViewCellInfo *previousCellRow=[cellInfoArrayCols objectAtIndex:j-1];
                x=previousCellRow.frame.origin.x+previousCellRow.frame.size.width;
                if (cellOffset.x!=0) {
                    x+=cellOffset.x;
                }
            }
            if (maxHeight<y+height) {
                maxHeight=y+height;
            }
            if (maxWidth<x+width) {
                maxWidth=x+width;
            }
            
            info.frame=CGRectMake(x, y, width, height);
            [cellInfoArrayCols addObject:info];
        }
        [cellInfoArrayRows addObject:cellInfoArrayCols];
    }
    
    self.contentSize=CGSizeMake(maxWidth, maxHeight);
    self.dataCells=cellInfoArrayRows;
    
    if ([self.subviews count]>[self.dataCells count]) {
        NSSet *dataCellsSet=[NSSet setWithArray:self.dataCells];
        NSArray *subviewsCopy=[self.subviews copy];
        
        for (UIView *cell in subviewsCopy) {
            if ([cell isKindOfClass:[HLDataViewCell class]]&&![dataCellsSet member:cell]) {
                [cell removeFromSuperview];
            }
        }
    }
}

-(void)checkViews
{
    if ([cellInfoForCellsOnScreen count]==0) {
        [self initialiseView];
        return;
    }
    
    NSMutableDictionary  *leftRightCells=[[NSMutableDictionary alloc]init];
    NSArray *orderedCells=[cellInfoForCellsOnScreen copy];
    BOOL isGoingUp=NO;
    BOOL isGoingDown=NO;
    BOOL isGoingLeft=NO;
    BOOL isGoingRight=NO;
    
    if (self.contentOffset.y<oldContentOffset.y&&self.contentOffset.y>=0) {
        isGoingUp=YES;
    }else if (self.contentOffset.y > oldContentOffset.y && self.contentOffset.y + self.frame.size.height < self.contentSize.height){
		isGoingDown = YES;
    }
	else if (hasResized){
		isGoingUp = YES;
    }
	
	if (self.contentOffset.x < oldContentOffset.x && self.contentOffset.x >= 0)
		isGoingLeft = YES;
	else if (self.contentOffset.x > oldContentOffset.x && self.contentOffset.x + self.frame.size.width < self.contentSize.width)
		isGoingRight = YES;
	else if (hasResized)
		isGoingRight = YES;    
    hasResized=NO;
    oldContentOffset=self.contentOffset;
    
    
    for (HLDataViewCellInfo *info in orderedCells) {
        if (isGoingLeft) {
            if (info.xPosition>0 &&info.frame.origin.x>self.contentOffset.x) {
                if (![leftRightCells objectForKey:[NSString stringWithFormat:@"%i",info.yPosition]]) {
                    [leftRightCells setObject:info forKey:[NSString stringWithFormat:@"%i",info.yPosition]];
                }else if ([[leftRightCells objectForKey:[NSString stringWithFormat:@"%i", info.yPosition]] xPosition] > info.xPosition){
					[leftRightCells setObject:info forKey:[NSString stringWithFormat:@"%i", info.yPosition]];
                }
            }
        }else if(isGoingRight){
            if ([[self.dataCells objectAtIndex:info.yPosition] count] - 1 > info.xPosition && info.frame.origin.x + info.frame.size.width < self.contentOffset.x + self.frame.size.width) {
				if (![leftRightCells objectForKey:[NSString stringWithFormat:@"%i", info.yPosition]]){
					[leftRightCells setObject:info forKey:[NSString stringWithFormat:@"%i", info.yPosition]];
                }
				else if ([[leftRightCells objectForKey:[NSString stringWithFormat:@"%i", info.yPosition]] xPosition] < info.xPosition){
					[leftRightCells setObject:info forKey:[NSString stringWithFormat:@"%i", info.yPosition]];
                }
			}
        }
        
        if (![self cellInfoShouldBeOnShow:info]) {
            [self removeCellWithInfo:info];
        }
        
    }
    
    if (isGoingLeft) {
        for (NSString *yPos in [leftRightCells allKeys]) {
            HLDataViewCellInfo *info=[leftRightCells objectForKey:yPos];
            [self checkRow:info.yPosition column:info.xPosition goingLeft:YES];
        }
    }else if (isGoingRight) {
		for (NSString *yPos in [leftRightCells allKeys]) {
			HLDataViewCellInfo *info = [leftRightCells objectForKey:yPos];
			[self checkRow:info.yPosition column:info.xPosition goingLeft:NO];
		}
	}
    
	if (isGoingUp)
		[self checkNewRowStartingWithCellInfo:[orderedCells objectAtIndex:0] goingUp:YES];
	else if (isGoingDown)
		[self checkNewRowStartingWithCellInfo:[orderedCells lastObject] goingUp:NO];
	
}




-(void)initialiseView
{
    for (NSUInteger i=0; i<[cellInfoForCellsOnScreen count]; i++) {
        HLDataViewCellInfo *info=[cellInfoForCellsOnScreen  objectAtIndex:i];
        if (![self cellInfoShouldBeOnShow:info]) {
            [self removeCellWithInfo:info];
        }
    }
    
    for (NSUInteger i=0; i<[dataCells count]; i++) {
        NSMutableArray *row=[dataCells objectAtIndex:i];
        for (NSUInteger j=0; j<[row count]; j++) {
            id object=[row objectAtIndex:j];
            if ([object isMemberOfClass:[HLDataViewCellInfo class]]) {
                HLDataViewCellInfo *info=(HLDataViewCellInfo*)object;
                if ([self cellInfoShouldBeOnShow:info]) {
                    [self addCellWithInfo:info];
                }
            }
        }
    }
}

-(void)checkRow:(NSInteger)row column:(NSInteger)col goingLeft:(BOOL)goingLeft
{
    NSObject<HLDataViewCellInfoProtocol> *info = [self cellInfoForRow:row column:col];
	
	if (!info) return;
	
	if ([self cellInfoShouldBeOnShow:info])
		[self addCellWithInfo:info];
    
	if (goingLeft) {
		if (info.frame.origin.x > self.contentOffset.x)
			[self checkRow:row column:(col - 1) goingLeft:goingLeft];
	} else {
		if (info.frame.origin.x + info.frame.size.width < self.contentOffset.x + self.frame.size.width)
			[self checkRow:row column:(col + 1) goingLeft:goingLeft];
	}
}

-(NSObject<HLDataViewCellInfoProtocol>*)cellInfoForRow:(NSUInteger)row column:(NSUInteger)col
{
    if ([self.dataCells count]<=row) {
        return nil;
    }
    NSArray *rowArray=[self.dataCells objectAtIndex:row];
    if ([rowArray count]<=col) {
        return nil;
    }
    return (NSObject<HLDataViewCellInfoProtocol>*)[rowArray objectAtIndex:col];
}

-(void)checkNewRowStartingWithCellInfo:(NSObject<HLDataViewCellInfoProtocol> *)info goingUp:(BOOL)goingUp
{
    if (!info) return;
    
	if (![self rowOfCellInfoShouldBeOnShow:info]) return;
	
	NSObject<HLDataViewCellInfoProtocol> *infoToCheck = info;
	
	NSInteger row = info.yPosition;
	NSInteger total = [[self.dataCells objectAtIndex:row] count];
	NSInteger goingRightPosition = info.xPosition;
	NSInteger goingLeftPosition = info.xPosition;
	BOOL goingLeft = NO;
	
	while (![self cellInfoShouldBeOnShow:infoToCheck]) {
        
		goingLeft = !goingLeft;
        
		if (goingLeft)
			infoToCheck = [self cellInfoForRow:row column:--goingLeftPosition];
		else
			infoToCheck = [self cellInfoForRow:row column:++goingRightPosition];
        
		if (goingRightPosition > total)
			return;
	}
	
	if ([infoToCheck isEqual:info]) {
		[self checkRow:infoToCheck.yPosition column:infoToCheck.xPosition goingLeft:YES];
		[self checkRow:infoToCheck.yPosition column:infoToCheck.xPosition goingLeft:NO];
	} else {
		[self checkRow:infoToCheck.yPosition column:infoToCheck.xPosition goingLeft:goingLeft];
	}
    
	NSObject<HLDataViewCellInfoProtocol> *nextInfo = nil;
	
	if (goingUp)
		nextInfo = [self cellInfoForRow:info.yPosition - 1 column:info.xPosition];
	else
		nextInfo = [self cellInfoForRow:info.yPosition + 1 column:info.xPosition];
    
	if (nextInfo)
		[self checkNewRowStartingWithCellInfo:nextInfo goingUp:goingUp];
}


#pragma mark Publie metods
-(HLDataViewCell*)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    for (HLDataViewCell *v in freeCells) {
        if ([v.identifier isEqualToString:identifier]) {
            [freeCells removeObject:v];
            [v prepareForReuse];
            return v ;
        }
    }
    return nil;
}

-(HLDataViewCell*)cellForView:(NSInteger)rowIndex column:(NSInteger)columnIndex
{
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[HLDataViewCell class]]) {
            HLDataViewCell *c=(HLDataViewCell*)v;
            if (c.xPosition==columnIndex &&c.yPosition==rowIndex) {
                return c;
            }
        }
    }
}

-(void)scrollViewToRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(HLDataViewScrollPosition)position animated:(BOOL)animated
{
    CGFloat xPos = 0, yPos = 0;
	
	CGRect cellFrame = [[[self.dataCells objectAtIndex:rowIndex] objectAtIndex:columnIndex] frame];		
	
	// working out x co-ord
	
	if (position == HLDataViewScrollPositionTopLeft || position == HLDataViewScrollPositionMiddleLeft || position == HLDataViewScrollPositionBottomLeft)
		xPos = cellFrame.origin.x;
	
	else if (position == HLDataViewScrollPositionTopRight || position == HLDataViewScrollPositionMiddleRight || position == HLDataViewScrollPositionBottomRight)
		xPos = cellFrame.origin.x + cellFrame.size.width - self.frame.size.width;
	
	else if (position == HLDataViewScrollPositionTopCenter || position == HLDataViewScrollPositionMiddleCenter || position == HLDataViewScrollPositionBottomCenter)
		xPos = (cellFrame.origin.x + (cellFrame.size.width / 2)) - (self.frame.size.width / 2);
	
	else if (position == HLDataViewScrollPositionNone) {
		
		BOOL isBig = NO;
		
		if (cellFrame.size.width > self.frame.size.width)
			isBig = YES;
		
		if ((cellFrame.origin.x < self.contentOffset.x)
            && ((cellFrame.origin.x + cellFrame.size.width) > (self.contentOffset.x + self.frame.size.width)))
			xPos = self.contentOffset.x;
		
		else if (cellFrame.origin.x < self.contentOffset.x)
			if (isBig)
				xPos = (cellFrame.origin.x + cellFrame.size.width) - self.frame.size.width;
			else 
				xPos = cellFrame.origin.x;
		
			else if ((cellFrame.origin.x + cellFrame.size.width) > (self.contentOffset.x + self.frame.size.width))
				if (isBig)
					xPos = cellFrame.origin.x;
				else
					xPos = (cellFrame.origin.x + cellFrame.size.width) - self.frame.size.width;
				else
					xPos = self.contentOffset.x;
	}
	
	// working out y co-ord
	
	if (position == HLDataViewScrollPositionTopLeft || position == HLDataViewScrollPositionTopCenter || position == HLDataViewScrollPositionTopRight) {
		yPos = cellFrame.origin.y;
		
	} else if (position == HLDataViewScrollPositionBottomLeft || position == HLDataViewScrollPositionBottomCenter || position == HLDataViewScrollPositionBottomRight) {
		yPos = cellFrame.origin.y + cellFrame.size.height - self.frame.size.height;
		
	} else if (position == HLDataViewScrollPositionMiddleLeft || position == HLDataViewScrollPositionMiddleCenter || position == HLDataViewScrollPositionMiddleRight) {
		yPos = (cellFrame.origin.y + (cellFrame.size.height / 2)) - (self.frame.size.height / 2);
		
	} else if (position == HLDataViewScrollPositionNone) {
		BOOL isBig = NO;
		
		if (cellFrame.size.height > self.frame.size.height)
			isBig = YES;
		
		if ((cellFrame.origin.y < self.contentOffset.y)
            && ((cellFrame.origin.y + cellFrame.size.height) > (self.contentOffset.y + self.frame.size.height)))
			yPos = self.contentOffset.y;
		
		else if (cellFrame.origin.y < self.contentOffset.y)
			if (isBig)
				yPos = (cellFrame.origin.y + cellFrame.size.height) - self.frame.size.height;
			else
				yPos = cellFrame.origin.y;
			else if ((cellFrame.origin.y + cellFrame.size.height) > (self.contentOffset.y + self.frame.size.height))
				if (isBig)
					yPos = cellFrame.origin.y;
				else
					yPos = (cellFrame.origin.y + cellFrame.size.height) - self.frame.size.height;
				else
					yPos = self.contentOffset.y;
	}
	
	if (xPos == self.contentOffset.x && yPos == self.contentOffset.y)
		return;
	
	if (xPos > self.contentSize.width - self.frame.size.width)
		xPos = self.contentSize.width - self.frame.size.width;
	else if (xPos < 0)
		xPos = 0.0f;
	
	if (yPos > self.contentSize.height - self.frame.size.height)
		yPos = self.contentSize.height - self.frame.size.height;
	else if (yPos < 0)
		yPos = 0.0f;	
	
	[self scrollRectToVisible:CGRectMake(xPos, yPos, self.frame.size.width, self.frame.size.height) animated:animated];
	
	if (!animated)
		[self checkViews];
	
	if ([self.delegate respondsToSelector:@selector(dataView:didProgrammaticallyScrollToRow:column:)])
		[self.delegate dataView:self didProgrammaticallyScrollToRow:rowIndex column:columnIndex];
}

-(void)selectRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(HLDataViewScrollPosition)position animated:(BOOL)animated  
{
    for (UIView *v in self.subviews) {
		if ([v isKindOfClass:[HLDataViewCell class]]) {
			HLDataViewCell *c = (HLDataViewCell *)v;
			if (c.xPosition == columnIndex && c.yPosition == rowIndex)
				c.selected = YES;
			else if (c.xPosition == columnIndexOfSelectedCell && c.yPosition == rowIndexOfSelectedCell)
				c.selected = NO;
		}
	}
	rowIndexOfSelectedCell = rowIndex;
	columnIndexOfSelectedCell = columnIndex;
	
	[self scrollViewToRow:rowIndex column:columnIndex scrollPosition:position animated:animated];
}

-(void)fireEdgeScroll
{
    if (self.pagingEnabled)
		if ([self.delegate respondsToSelector:@selector(pagedDataView:didScrollToRow:column:)])
			[self.delegate pagedDataView:self didScrollToRow:((NSInteger)(self.contentOffset.y / self.frame.size.height)) column:((NSInteger)(self.contentOffset.x / self.frame.size.width))];
	
	if ([self.delegate respondsToSelector:@selector(dataView:scrolledToEdge:)]) {
		
		if (self.contentOffset.x <= 0)
			[self.delegate dataView:self scrolledToEdge:HLDataViewEdgeLeft];
		
		if (self.contentOffset.x >= self.contentSize.width - self.frame.size.width)
			[self.delegate dataView:self scrolledToEdge:HLDataViewEdgeRight];
		
		if (self.contentOffset.y <= 0)
			[self.delegate dataView:self scrolledToEdge:HLDataViewEdgeTop];
		
		if (self.contentOffset.y >= self.contentSize.height - self.frame.size.height)
			[self.delegate dataView:self scrolledToEdge:HLDataViewEdgeBottom];
	}
}

-(void)dataViewCellWasTouched:(HLDataViewCell *)dataViewCell
{
//    NSLog(@"%d",dataViewCell.isHeader);
//    [self bringSubviewToFront:dataViewCell];
//    if ([self.delegate respondsToSelector:@selector(dataView:selectionMadeAtRow:column:)]) {
//        [self.delegate dataView:self selectionMadeAtRow:dataViewCell.yPosition column:dataViewCell.xPosition];
//    }
}

-(NSInteger)numberOfRows
{
    if (numberOfRows==HLDataViewInvalid) {
        numberOfRows=[self.dataSource numberOfRowsInDataView:self];
    }
    return numberOfRows;
}
@end
