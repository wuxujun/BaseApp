//
//  WaterFlowView.m
//  WaterFlowDisplay
//
//  Created by 吴旭俊 on 12-10-19.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "WaterFlowView.h"
#import "LoadingMoreFooterView.h"
#import "EGORefreshTableHeaderView.h"

#define LOADINGVIEW_HEIGHT 44
#define REFRESHINGVIEW_HEIGHT 88
#define MAX_PAGE 10

@interface WaterFlowView() <EGORefreshTableHeaderDelegate>
- (void)initialize;
- (void)reloadData;
- (void)recycleCellIntoReusableQueue:(WaterFlowCell*)cell;
- (void)pageScroll;
- (void)cellSelected:(NSNotification*)notification;

@property(nonatomic,retain) LoadingMoreFooterView *loadFooterView;
@property(nonatomic,readwrite) BOOL loadingmore;

@property(nonatomic, retain) EGORefreshTableHeaderView * refreshHeaderView;
@property(nonatomic, readwrite) BOOL isRefreshing;
@end

@implementation WaterFlowView
@synthesize cellHeight=_cellHeight,visibleCells=_visibleCells,reusableCells=_reusedCells,cellIndex=_cellIndex;
@synthesize flowDelegate=_flowDelegate,flowDatasource=_flowDatasource;
@synthesize loadFooterView=_loadFooterView,loadingmore=_loadingmore;
@synthesize refreshHeaderView=_refreshHeaderView,isRefreshing=_isRefreshing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
		self.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cellSelected:)
                                                     name:@"CellSelected"
                                                   object:nil];
        
        
        self.loadFooterView = [[LoadingMoreFooterView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.f)];
        self.loadingmore = NO;
        [self addSubview:self.loadFooterView];
        
        currentPage = 1;
        [self initialize];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"CellSelected"
                                                  object:nil];
    
    self.cellHeight = nil;
    self.visibleCells = nil;
    self.reusableCells = nil;
    self.flowDatasource = nil;
    self.flowDelegate = nil;
    self.loadFooterView = nil;
    [super dealloc];
}

- (void)setFlowDatasource:(id<WaterFlowViewDatasource>)aFlowDatasource
{
    _flowDatasource = aFlowDatasource;
    [self initialize];
}

- (void)setFlowDelegate:(id<WaterFlowViewDelegate>)aFlowDelegate
{
    _flowDelegate = aFlowDelegate;
    [self initialize];
}

#pragma mark-
#pragma mark- process notification
- (void)cellSelected:(NSNotification *)notification
{
    //    if ([self.flowdelegate respondsToSelector:@selector(flowView:didSelectRowAtIndexPath:)])
    //    {
    //        [self.flowdelegate flowView:self didSelectRowAtIndexPath:((WaterFlowCell*)notification.object).indexPath];
    //    }
    if ([self.flowDelegate respondsToSelector:@selector(flowView:didSelectAtCell:ForIndex:)])
    {
        int index = [[[self.cellIndex objectAtIndex:((WaterFlowCell*)notification.object).indexPath.section]objectAtIndex:((WaterFlowCell*)notification.object).indexPath.row] intValue];
        [self.flowDelegate flowView:self didSelectAtCell:((WaterFlowCell*)notification.object) ForIndex:index];
    }
}

#pragma mark-
#pragma mark - manage and reuse cells
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (!identifier || identifier == 0 ) return nil;
    
    NSArray *cellsWithIndentifier = [NSArray arrayWithArray:[self.reusableCells objectForKey:identifier]];
    if (cellsWithIndentifier &&  cellsWithIndentifier.count > 0)
    {
        WaterFlowCell *cell = [cellsWithIndentifier lastObject];
        [[cell retain] autorelease];
        [[self.reusableCells objectForKey:identifier] removeLastObject];
        return cell;
    }
    return nil;
}

- (void)recycleCellIntoReusableQueue:(WaterFlowCell *)cell
{
    if(!self.reusableCells)
    {
        self.reusableCells = [NSMutableDictionary dictionary];
        
        NSMutableArray *array = [NSMutableArray arrayWithObject:cell];
        [self.reusableCells setObject:array forKey:cell.reuseIdentifier];
    }
    
    else
    {
        if (![self.reusableCells objectForKey:cell.reuseIdentifier])
        {
            NSMutableArray *array = [NSMutableArray arrayWithObject:cell];
            [self.reusableCells setObject:array forKey:cell.reuseIdentifier];
        }
        else
        {
            [[self.reusableCells objectForKey:cell.reuseIdentifier] addObject:cell];
        }
    }
    
}

#pragma mark-
#pragma mark- methods
- (void)initialize
{
    numberOfColumns = [self.flowDatasource numberOfColumnsInFlowView:self];
    
    self.reusableCells = [NSMutableDictionary dictionary];
    self.cellHeight = [NSMutableArray arrayWithCapacity:numberOfColumns];
    self.cellIndex = [NSMutableArray arrayWithCapacity:numberOfColumns];
    self.visibleCells = [NSMutableArray arrayWithCapacity:numberOfColumns];
    
    CGFloat scrollHeight = 0.f;
    
    /////
    for (int i = 0; i<numberOfColumns; i++)
    {
        [self.visibleCells addObject:[NSMutableArray array]];
    }
    CGFloat minHeight = 0.f;
    NSInteger minHeightAtColumn = 0;
    for (int i = 0; i< numberOfColumns*[_flowDatasource flowView:self numberOfRowsInColumn:i]*currentPage ; i++)
    {
        //the first pics
        if(self.cellHeight.count < numberOfColumns)
        {
            [self.cellHeight addObject:[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:[self.flowDelegate flowView:self heightForCellAtIndex:i]]]];
            [self.cellIndex addObject:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:i]]];
            minHeight = [self.flowDelegate flowView:self heightForCellAtIndex:i];
            continue;
        }
        
        //find the column with the shortest height and insert the cell height into self.cellHeight[column]
        for (int j = 0; j< numberOfColumns; j++)
        {
            NSMutableArray *cellHeightInPresentColumn = [NSMutableArray arrayWithArray:[self.cellHeight objectAtIndex:j]];
            if (floor([[cellHeightInPresentColumn lastObject]floatValue]) <= minHeight)
            {
                minHeight = [[cellHeightInPresentColumn lastObject]floatValue];
                minHeightAtColumn = j;
            }
        }
        [[self.cellHeight objectAtIndex:minHeightAtColumn] addObject:[NSNumber numberWithFloat:minHeight+=[self.flowDelegate flowView:self heightForCellAtIndex:i]]];
        [[self.cellIndex objectAtIndex:minHeightAtColumn]addObject:[NSNumber numberWithInt:i]];
    }
    for (int j = 0; j< numberOfColumns; j++)
    {
        if(self.cellHeight.count < numberOfColumns ||self.cellHeight.count == 0) break;
        CGFloat columnHeight = [[[self.cellHeight objectAtIndex:j] lastObject] floatValue];
        scrollHeight = scrollHeight>columnHeight?scrollHeight:columnHeight;
    }
    ///////
    
    /*
     ////put height of cells per column into an array, then add this array into self.cellHeight
     for (int i = 0; i< numberOfColumns; i++)
     {
     [self.visibleCells addObject:[NSMutableArray array]];
     
     NSMutableArray *cellHeightInOneColume = [NSMutableArray array];
     NSInteger rows = [_flowdatasource flowView:self numberOfRowsInColumn:i] * currentPage;
     
     CGFloat columHeight = 0.f;
     for (int j =0; j < rows; j++)
     {
     CGFloat height = [_flowdelegate flowView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
     columHeight += height;
     [cellHeightInOneColume addObject:[NSNumber numberWithFloat:columHeight]];
     }
     
     [self.cellHeight addObject:cellHeightInOneColume];
     scrollHeight = (columHeight >= scrollHeight)?columHeight:scrollHeight;
     }
     */
    
    self.contentSize = CGSizeMake(self.frame.size.width, scrollHeight + LOADINGVIEW_HEIGHT);
    
    self.loadFooterView.frame = CGRectMake(0, scrollHeight, self.frame.size.width, LOADINGVIEW_HEIGHT);
    
    
    [self pageScroll];
}

- (void)reloadData
{
    //remove and recycle all visible cells
    for (int i = 0; i < numberOfColumns; i++)
    {
        NSMutableArray *array = [self.visibleCells objectAtIndex:i];
        for (id cell in array)
        {
            [self recycleCellIntoReusableQueue:(WaterFlowCell*)cell];
            [cell removeFromSuperview];
        }
    }
    
    if(self.loadingmore)
    {
        self.loadingmore = NO;
        self.loadFooterView.showActivityIndicator = NO;
    }
    [self initialize];
}

- (void)pageScroll
{
    //CGPoint offset = self.contentOffset;
    
    NSLog(@"%d",numberOfColumns);
    for (int i = 0 ; i< numberOfColumns; i++)
    {
        float origin_x = i * (self.frame.size.width / numberOfColumns);
		float width = self.frame.size.width / numberOfColumns;
        
        WaterFlowCell *cell = nil;
        
        if ([self.visibleCells objectAtIndex:i] == nil || ((NSArray*)[self.visibleCells objectAtIndex:i]).count == 0) //everytime reloadData is called and no cells in visibleCellArray
        {
            int rowToDisplay = 0;
			for( int j = 0; j < [[self.cellHeight objectAtIndex:i] count] - 1; j++)  //calculate which row to display in this column
			{
				float everyCellHeight = [[[self.cellHeight objectAtIndex:i] objectAtIndex:j] floatValue];
				if(everyCellHeight < self.contentOffset.y)
				{
					rowToDisplay ++;
				}
			}
			
#ifdef DEBUG
			NSLog(@"row to display %d", rowToDisplay);
#endif
            
			float origin_y = 0;
			float height = 0;
			if(rowToDisplay == 0)
			{
				origin_y = 0;
				height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay] floatValue];
			}
			else if(rowToDisplay < [[self.cellHeight objectAtIndex:i] count])
            {
				origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay - 1] floatValue];
				height  = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay ] floatValue] - origin_y;
			}
            
			cell = [_flowDatasource flowView:self cellForRowAtIndex:[[[self.cellIndex objectAtIndex:i]objectAtIndex:rowToDisplay]intValue]];
			cell.indexPath = [NSIndexPath indexPathForRow: rowToDisplay inSection:i];
			cell.frame = CGRectMake(origin_x, origin_y, width, height);
			[self addSubview:cell];
			[[self.visibleCells objectAtIndex:i] insertObject:cell atIndex:0];
        }
        else   //there are cells in visibelCellArray
        {
            cell = [[self.visibleCells objectAtIndex:i] objectAtIndex:0];
        }
        
        //base on this cell at rowToDisplay and process the other cells
        //1. add cell above this basic cell if there's margin between basic cell and top
        while ( cell && ((cell.frame.origin.y - self.contentOffset.y) > 0.0001))
        {
            float origin_y = 0;
			float height = 0;
            int rowToDisplay = cell.indexPath.row;
            
            if(rowToDisplay == 0)
            {
                cell = nil;
                break;
            }
            else if (rowToDisplay == 1)
            {
                origin_y = 0;
                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay  -1] floatValue];
            }
            else if (cell.indexPath.row < [[self.cellHeight objectAtIndex:i] count])
            {
                origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay -2] floatValue];
                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay - 1] floatValue] - origin_y;
            }
            
            cell = [self.flowDatasource flowView:self cellForRowAtIndex:[[[self.cellIndex objectAtIndex:i]objectAtIndex:rowToDisplay > 0 ? (rowToDisplay  - 1) : 0]intValue]];
            cell.indexPath = [NSIndexPath indexPathForRow: rowToDisplay > 0 ? (rowToDisplay - 1) : 0 inSection:i];
            cell.frame = CGRectMake(origin_x,origin_y , width, height);
            [[self.visibleCells objectAtIndex:i] insertObject:cell atIndex:0];
            
            [self addSubview:cell];
        }
        //2. remove cell above this basic cell if there's no margin between basic cell and top
        while (cell &&  ((cell.frame.origin.y + cell.frame.size.height  - self.contentOffset.y) <  0.0001))
		{
			[cell removeFromSuperview];
			[self recycleCellIntoReusableQueue:cell];
			[[self.visibleCells objectAtIndex:i] removeObject:cell];
			
			if(((NSMutableArray*)[self.visibleCells objectAtIndex:i]).count > 0)
			{
				cell = [[self.visibleCells objectAtIndex:i] objectAtIndex:0];
			}
			else
            {
				cell = nil;
			}
		}
        //3. add cells below this basic cell if there's margin between basic cell and bottom
        cell = [[self.visibleCells objectAtIndex:i] lastObject];
        while (cell &&  ((cell.frame.origin.y + cell.frame.size.height - self.frame.size.height - self.contentOffset.y) <  0.0001))
		{
            //NSLog(@"self.offset %@, self.frame %@, cell.frame %@, cell.indexpath %@",NSStringFromCGPoint(self.contentOffset),NSStringFromCGRect(self.frame),NSStringFromCGRect(cell.frame),cell.indexPath);
            float origin_y = 0;
			float height = 0;
            int rowToDisplay = cell.indexPath.row;
            
            if(rowToDisplay == [[self.cellHeight objectAtIndex:i] count] - 1)
			{
				origin_y = 0;
				cell = nil;
				break;;
			}
            else
            {
                origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay] floatValue];
                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay + 1] floatValue] -  origin_y;
            }
            
            cell = [self.flowDatasource flowView:self cellForRowAtIndex:[[[self.cellIndex objectAtIndex:i]objectAtIndex:rowToDisplay+1]intValue]];
            cell.indexPath = [NSIndexPath indexPathForRow:rowToDisplay + 1 inSection:i];
            cell.frame = CGRectMake(origin_x, origin_y, width, height);
            [[self.visibleCells objectAtIndex:i] addObject:cell];
            
            [self addSubview:cell];
        }
        //4. remove cells below this basic cell if there's no margin between basic cell and bottom
        while (cell &&  ((cell.frame.origin.y - self.frame.size.height - self.contentOffset.y) > 0.0001))
		{
			[cell removeFromSuperview];
			[self recycleCellIntoReusableQueue:cell];
			[[self.visibleCells objectAtIndex:i] removeObject:cell];
			
			if(((NSMutableArray*)[self.visibleCells objectAtIndex:i]).count > 0)
			{
				cell = [[self.visibleCells objectAtIndex:i] lastObject];
			}
			else
            {
				cell = nil;
			}
		}
    }
}

#pragma mark-
#pragma mark- UIScrollViewDelegate
- (void)loadMoreImages
{
    if (self.loadingmore) return;
    
    if (currentPage == MAX_PAGE)
    {
        NSLog(@"last page!");
        //toast view
        return;
    }
    
    NSLog(@"load more");
    self.loadingmore = YES;
    self.loadFooterView.showActivityIndicator = YES;
    
    currentPage ++;
    if ([self.flowDelegate respondsToSelector:@selector(flowView:willLoadData:)])
    {
        [self.flowDelegate flowView:self willLoadData:currentPage];  //reloadData in delegate
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self pageScroll];
    
    /*//alternative for firing immediately
     //if scrollview reaches bottom
     CGPoint offset = scrollView.contentOffset;
     CGRect bounds = scrollView.bounds;
     CGSize size = scrollView.contentSize;
     UIEdgeInsets inset = scrollView.contentInset;
     float y = offset.y + bounds.size.height - inset.bottom;
     float h = size.height;
     
     float reload_distance = 10;
     if(y > h + reload_distance)
     {
     NSLog(@"load more rows");
     [self loadMoreImages];
     
     }
     */
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >=  floor(scrollView.contentSize.height) )
    {
        [self loadMoreImages];
        //[self performSelector:@selector(reloadData) withObject:self afterDelay:1.0f]; //make a delay to show loading process for a while
    }
}

@end

//===================================================================
//
//*************************WaterflowCell*****************************
//
//===================================================================
@implementation WaterFlowCell
@synthesize indexPath = _indexPath;
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super init])
	{
		self.reuseIdentifier = reuseIdentifier;
	}
	
	return self;
}

- (void)dealloc
{
    self.indexPath = nil;
    self.reuseIdentifier = nil;
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CellSelected"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self,@"cell",self.indexPath,@"indexPath",nil]];
    
}

@end