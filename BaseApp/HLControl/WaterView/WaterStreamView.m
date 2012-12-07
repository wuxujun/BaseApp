//
//  WaterStreamView.m
//  BaseApp
//
//  Created by xujun wu on 12-12-7.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "WaterStreamView.h"

#define kDefaultWaterCount 3
#define kMaxWaterCount     5

@interface WaterStreamView()

@property (nonatomic,strong)UIScrollView        *scrollView;
@property (nonatomic,assign)NSUInteger          elementCount;
@property (nonatomic,strong)NSMutableDictionary *visibleViewDict;

@property (nonatomic,assign)HRange              visibleRange;

@property (nonatomic,strong)NSMutableArray      *columnElementArray;
@property (nonatomic,strong)NSMutableDictionary *elementRectDict;
@property (nonatomic,strong)NSMutableDictionary *reuseDict;

-(void)relayoutSubViews;

@end

@implementation WaterStreamView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.columnCount=3;
        self.columnElementArray=[NSMutableArray arrayWithCapacity:3];
        self.elementRectDict=[NSMutableDictionary dictionaryWithCapacity:10];
        self.visibleViewDict=[NSMutableDictionary dictionaryWithCapacity:10];
        
        self.reuseDict=[NSMutableDictionary dictionaryWithCapacity:5];
        CGSize size=frame.size;
        
        _height=size.height;
        
        self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.scrollView.contentOffset=CGPointZero;
        self.scrollView.delegate=self;
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidTap:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self.scrollView addGestureRecognizer:tapGestureRecognizer];
        
        [self addSubview:self.scrollView];
        
        _selectedIndex = -1;
        _separatorColor = [UIColor grayColor];

        
    }
    return self;
}

-(void)setDataSource:(id<WaterStreamViewDataSource>)dataSource
{
    _dataSource=dataSource;
}

-(void)setHeaderView:(UIView *)headerView
{
    [_headerView removeFromSuperview];
    _headerView=headerView;
}

-(void)setFooterView:(UIView *)footerView
{
    [footerView removeFromSuperview];
    _footerView=footerView;
}

-(void)reloadData
{
    [self.visibleViewDict enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
        WaterStreamViewCell *cell=(WaterStreamViewCell*)obj;
        [self inqueueReusableWithView:cell];
    }];
    
    [self.visibleViewDict removeAllObjects];
    [self.elementRectDict removeAllObjects];
    
    self.elementCount=[self.dataSource numberOfElementsInWaterView:self];
    if (self.elementCount<=0) {
        return;
    }

    if([self.dataSource respondsToSelector:@selector(numberOfWatersInWaterView:)]){
        self.columnCount=[self.dataSource numberOfWatersInWaterView:self];
    }

    CGFloat top=0.0f;
    if (self.headerView) {
        self.headerView.frame=CGRectMake(0, top, 320, self.headerView.frame.size.height);
        [self.scrollView addSubview:self.headerView];
        top+=self.headerView.frame.size.height;
    }
    
    NSMutableArray  *bottomOffset=[NSMutableArray arrayWithCapacity:self.columnCount];
    for (int i=0; i<self.columnCount; i++) {
        [bottomOffset addObject:@(top)];
        
        NSMutableArray *array=[NSMutableArray arrayWithCapacity:5];
        [self.columnElementArray addObject:array];
    }
    
    CGFloat sWidth=self.frame.size.width/self.columnCount;
    for (int elementIndex=0; elementIndex<self.elementCount; elementIndex++) {
        NSInteger column=0;
        CGFloat minBottom=[[bottomOffset objectAtIndex:0]floatValue];
        for (int i=1; i<bottomOffset.count; i++) {
            CGFloat bottom=[[bottomOffset objectAtIndex:i] floatValue];
            if (bottom<minBottom) {
                minBottom=bottom;
                column=i;
            }
        }
        
        CGFloat x=column*sWidth;
        CGFloat y=minBottom;
        CGFloat width=sWidth;
        CGFloat height;
        if ([self.dataSource respondsToSelector:@selector(waterView:heightForRowAtIndex:basedWidth:)]) {
            height=[self.dataSource waterView:self heightForRowAtIndex:elementIndex basedWidth:sWidth];
        }else{
            height=sWidth;
        }
        CGRect rect=CGRectMake(x,y, width, height);
        
        [self.elementRectDict setValue:NSStringFromCGRect(rect) forKey:[NSString stringWithFormat:@"%d",elementIndex]];
        [bottomOffset replaceObjectAtIndex:column withObject:@(y+height)];
    }
    
    for (NSNumber *columnHeight in bottomOffset) {
        top=(top<[columnHeight floatValue])?[columnHeight floatValue]:top;
    }
    
    if (self.footerView) {
        self.footerView.frame=CGRectMake(0, top, 320, self.footerView.frame.size.height);
        [self.scrollView addSubview:self.footerView];
        top+=self.footerView.frame.size.height;
    }
    
    self.scrollView.contentSize=CGSizeMake(self.scrollView.frame.size.width, top);
    [self relayoutSubViews];
}

-(void)relayoutSubViews
{
    if (self.elementCount==0) {
        return;
    }
    
    CGRect visibleRect = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    NSMutableArray *unUsedArray=[NSMutableArray arrayWithCapacity:5];
    [self.visibleViewDict enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
        WaterStreamViewCell *cell=(WaterStreamViewCell*)obj;
        CGRect rect=cell.frame;
        if (!CGRectIntersectsRect(visibleRect,rect)) {
            [self inqueueReusableWithView:cell];
            [unUsedArray addObject:key];
        }
    }];
    
    
    [self.visibleViewDict removeObjectsForKeys:unUsedArray];
    
    if (self.visibleViewDict.count==0) {
        self.visibleRange=HRangeMake(0, self.elementCount);
    }else{
        NSArray *tmpArray=[[self.visibleViewDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2){
            if ([obj1 integerValue]<[obj2 integerValue]) {
                return NSOrderedAscending;
            }else if([obj1 integerValue]>[obj2 integerValue]){
                return NSOrderedDescending;
            }else{
                return NSOrderedSame;
            }
        }];
        
        int start=[[tmpArray objectAtIndex:0] intValue],end=[[tmpArray lastObject] intValue];
        start=MAX(start-5, 0);
        end=MIN(end+5, self.elementCount);
        self.visibleRange=HRangeMake(start, end);
    }
    
    for(int index=self.visibleRange.start;index<self.visibleRange.end;index++){
        NSString    *indexKey=[NSString stringWithFormat:@"%d",index];
        CGRect rect=CGRectFromString([self.elementRectDict objectForKey:indexKey]);
        WaterStreamViewCell *cell=[self.visibleViewDict objectForKey:indexKey];
        if(!cell &&CGRectIntersectsRect(visibleRect, rect)){
            cell=[self.dataSource waterView:self cellForCellAtIndex:index];
            cell.frame=rect;
            
            [self.scrollView addSubview:cell];
            [self.visibleViewDict setValue:cell forKey:indexKey];
        }
    }
}

-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    WaterStreamViewCell *cell=nil;
    NSMutableSet *reuseCells=[self.reuseDict objectForKey:identifier];
    if (reuseCells.count>0) {
        cell=[reuseCells anyObject];
        [reuseCells removeObject:cell];
    }
    return cell;
}

- (void) inqueueReusableWithView:(WaterStreamViewCell *) reuseView {
    NSString * identifier = reuseView.reuseIdentifier;
    if (!self.reuseDict) {
        self.reuseDict = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    NSMutableSet * cells = [self.reuseDict valueForKey:identifier];
    if (!cells) {
        cells  = [NSMutableSet setWithCapacity:5];
        [self.reuseDict setValue:cells forKey:identifier];
    }
    reuseView.selected = NO;
    [cells addObject:reuseView];
    [reuseView removeFromSuperview];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self relayoutSubViews];
}

-(void)scrollViewDidTap:(UITapGestureRecognizer*)sender
{
    CGPoint touchPoint=[sender locationInView:self.scrollView];
    [self.visibleViewDict enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
        WaterStreamViewCell *cell=(WaterStreamViewCell*)obj;
        CGRect frame=cell.frame;
        if (CGPointInRect(touchPoint, frame)) {
            [self didSelectedWaterCell:cell index:[key intValue]];
            *stop=YES;
        }
    }];
}

-(void)didSelectedWaterCell:(WaterStreamViewCell*)waterCell index:(NSInteger)index
{
    waterCell.selected=YES;
    if ([_delegate respondsToSelector:@selector(waterView:didSelectWaterCell:atIndex:)]) {
        [_delegate waterView:self didSelectWaterCell:waterCell atIndex:index];
    }
    if (InRange(_visibleRange, _selectedIndex)) {
        int i=_selectedIndex-_visibleRange.start;
        WaterStreamViewCell *cell=[self.visibleViewDict objectForKey:[NSString stringWithFormat:@"%d",i]];
        cell.selected=NO;
    }
    _selectedIndex=index;
}

-(UITableViewCell*)cellAtIndex:(NSUInteger)index
{
    return nil;
}

-(UITableViewCell*)cellAtIndexPath:(NSUInteger)indexPath
{
    return nil;
}

@end
