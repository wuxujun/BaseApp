//
//  HLChartView.m
//  GrpCust
//
//  Created by  on 11-12-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HLChartView.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorUtils.h"
#import "HLChartGlobal.h"

NSString    *const  kHLArcLayerStartAngle=@"startAngle";
NSString    *const  kHLArcLayerEndAngle=@"endAngle";
NSString    *const  kHLLineLayerPoints=@"linePoints";
NSString    *const  kHLLineLayerLastIndex=@"lastIndex";

NSString    *const  kHLChartViewItemName=@"itemName";
NSString    *const  kHLChartViewScaleX=@"scaleX";
NSString    *const  kHLChartViewItemValue=@"itemValue";
NSString    *const  kHLChartViewItemIndex=@"itemIndex";
NSString    *const  kHLChartViewSectionNums=@"sectionNums";
NSString    *const  kHLChartViewPointX=@"pointX";
NSString    *const  kHLChartViewPointY=@"pointY";


static NSInteger layerSortByPointY(id a,id b,void *context){
    CAShapeLayer *aLayer=(CAShapeLayer*)a;
    CAShapeLayer *bLayer=(CAShapeLayer*)b;
    
    int diff=[[aLayer valueForKey:kHLChartViewPointY] floatValue]-[[bLayer valueForKey:kHLChartViewPointY] floatValue];
    if (diff>0) {
        return 2;
    }else if(diff<0){
        return 0;
    }else{
        return 1;
    }
}

@interface HLArcLayerDefaultAnimationDelegate : NSObject

@property (nonatomic,assign)HLChartView         *chartView;

@end

@interface HLArcLayerAddAnimationDelegate : NSObject

@property (nonatomic,assign)HLChartView     *chartView;

@end

@interface HLChartView(){
    
    
    NSInteger   _selectedIndex;
    NSTimer     *_animationTimer;
    NSTimer     *_addPieDataTimer;
    int         _curRecord;
    NSMutableArray      *_animations;
    
    NSMutableArray      *_sortLayers;
    
    NSMutableArray      *_hideDatas;
    
    HLArcLayerDefaultAnimationDelegate  *_defaultAnimationDelegate;
    HLArcLayerAddAnimationDelegate      *_addAnimationDelegate;
    
    CGPoint             _center;
    CGFloat             _radius;
    UILabel             *_labelForString;
        
    float               _chartTitleHeight;
    float               _legendFontSize;
}
-(void)addPieData;
-(void)reloadBarData;
-(void)reloadLineData;
-(void)reloadPieData;

-(void)updateTimerFired:(NSTimer*)timer;

-(CAShapeLayer*)createPieLayerWithColor:(UIColor*)color;
-(CGSize)sizeThatFitsString:(NSString*)string fontSize:(float)fSize;
-(void)updateLabelForLayer:(CAShapeLayer*)pieLayer value:(CGFloat)value;

-(void)maybeNotifyDelegateOfSelectionChangeFrom:(NSInteger)previousSelection to:(NSUInteger)newSelection;

-(void)drawHorizontalLines;
-(void)drawGridLines:(CGContextRef)context;
-(void)drawVerticalGridLines;
-(void)drawLegend;
-(void)drawTopItemValue:(NSInteger)index point:(CGPoint)point;


-(CGPoint)calculateForVertivalHeight:(float)vHeight withNumberOfSection:(NSInteger)section atRowIndex:(NSInteger)index;
//计算柱
-(CGRect)calculateBarRectForHeight:(float)barHeight withNumberOfSection:(NSInteger)section atRowIndex:(NSInteger)index;
-(CAShapeLayer*)createBarLayerWithColor:(UIColor*)color itemRect:(CGRect)rect;
-(CAShapeLayer*)createTextLayer:(NSString*)value inRect:(CGRect)rect fontSize:(float)fSize;

@end


@implementation HLChartView

static NSInteger kDefaultSliceZOrder=100;

@synthesize dataSource=_dataSource,delegate=_delegate;
@synthesize animationSpeed=_animationSpeed;
@synthesize itemTitleHeight;
@synthesize title,isTouch,chartStyle=_chartStyle;
@synthesize isShowLegend=_isShowLegend;
@synthesize legendHeight=_legendHeight;

static CGPathRef  CGPathCreateArc(CGPoint center,CGFloat radius,CGFloat startAngle,CGFloat endAngle)
{
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center.x, center.y);
    CGPathAddArc(path, NULL, center.x, center.y, radius, startAngle, endAngle, 0);
    CGPathCloseSubpath(path);
    return path;
}

static CGPathRef  CGPathCreateLine(CGPoint startPoint,CGPoint endPoint)
{
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    CGPathCloseSubpath(path);
    return path;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _chartTitleHeight=CHART_TITLE_HEIGHT;
        _selectedIndex=-1;
        _animations=[[NSMutableArray alloc]init ];
        
        _sortLayers=[[NSMutableArray alloc]init ];
        _hideDatas=[[NSMutableArray alloc]init];
        
        _addAnimationDelegate=[[HLArcLayerAddAnimationDelegate alloc]init];
        [_addAnimationDelegate setChartView:self];
        
        _defaultAnimationDelegate=[[HLArcLayerDefaultAnimationDelegate alloc]init ];
        [_defaultAnimationDelegate setChartView:self];
        
        CGRect parentLayerBounds=[[self layer]bounds];
//        NSLog(@"=======%f===========%f===========%f==========%f",parentLayerBounds.size.width,parentLayerBounds.size.height,frame.size.width,frame.size.height);
        CGFloat centerX=parentLayerBounds.size.width/2;
        CGFloat centerY=(parentLayerBounds.size.height-_chartTitleHeight)/2+_chartTitleHeight;
        
        _center=CGPointMake(centerX, centerY);
        
        _radius=MIN(centerX, centerY)-_chartTitleHeight-15;
    }
    
    self.backgroundColor=[UIColor whiteColor];
    
//    NSLog(@"+++++++ %f",[UIScreen mainScreen].scale);
    
    self.itemTitleHeight=10;
    self.isTouch=YES;
    _isShowLegend=YES;
    _legendHeight=44;
    _legendFontSize=12;
    return self;
}

-(id)initWithFrame:(CGRect)frame style:(HLChartViewStyle)style
{
    self = [self initWithFrame:frame];
     _chartStyle=style;
    
    return self;
}

-(void)setChartStyle:(HLChartViewStyle)chartStyle
{
    _chartStyle=chartStyle;
}

-(void)setIsShowLegend:(BOOL)isShowLegend
{
    _isShowLegend=isShowLegend;
    if (!_isShowLegend) {
        _legendHeight=0.0;
    }
}

#pragma  mark - 刷新饼图数据
-(void)reloadPieData
{
    [self layer].sublayers=nil;
    if(_dataSource){
        [CATransaction begin];
        [CATransaction setAnimationDuration:1.25];
        CALayer *parentLayer=[self layer];
        [parentLayer setContentsScale:[UIScreen mainScreen].scale];
        NSArray *pieLayers=[parentLayer sublayers];
        
        [self setUserInteractionEnabled:NO];
        __block NSMutableArray *layersToRemove=nil;
        [CATransaction setCompletionBlock:^{
            [layersToRemove enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){[obj removeFromSuperlayer];} ];
            [layersToRemove removeAllObjects];
            [self setUserInteractionEnabled:YES];
        }];
        
        //切片数量
        NSUInteger sliceCount=[_sortLayers count];//[_dataSource numberOfSectionsInChartView:self];
        
        //切片的总和计算，要求所有切片值的数据源
        double sum=0.0;
        double values[sliceCount];
        for (int index=0; index<sliceCount; index++) {
            values[index]=[_dataSource chartView:self valueForChartView:index];
            sum+=values[index];
        }
        
        //计算每张切片的角度
        double angles[sliceCount];
        for (int index=0; index<sliceCount; index++) {
            double div=values[index]/sum;
            div=M_PI*2*div;
            angles[index]=div;
        }
        
        CGFloat startAngle=0.0;
        CGFloat endAngle=startAngle;
        
        if (sliceCount>[pieLayers count]) {
            for (int index=0; index<sliceCount; index++) {
                endAngle+=angles[index];
                CAShapeLayer *pieLayer;
//                if (index+1<sliceCount) {
//                    pieLayer=(CAShapeLayer*)[pieLayers objectAtIndex:index];
//                    [pieLayer setDelegate:_defaultAnimationDelegate];
//                }else{
                    UIColor *color=[self.dataSource chartView:self colorForChartView:index];
                    pieLayer=[self createPieLayerWithColor:color];
                    [parentLayer addSublayer:pieLayer];
//                }
                
                [self updateLabelForLayer:pieLayer value:round(values[index]/sum*10000)/100];
                
                [pieLayer setValue:[NSNumber numberWithDouble:endAngle] forKey:kHLArcLayerEndAngle];
                [pieLayer setValue:[NSNumber numberWithDouble:startAngle] forKey:kHLArcLayerStartAngle];
                NSLog(@"%f,%f",startAngle,endAngle);
                CGPathRef path=CGPathCreateArc(_center, _radius, startAngle, endAngle);
                [pieLayer setPath:path];
                CFRelease(path);
                startAngle=endAngle;
            }
        }else if(sliceCount==[pieLayers count]){
            for (int index=0; index<sliceCount; index++) {
                CAShapeLayer *pieLayer=(CAShapeLayer*)[pieLayers objectAtIndex:index];
//                [pieLayer setDelegate:_defaultAnimationDelegate];
                endAngle+=angles[index];
                [pieLayer setValue:[NSNumber numberWithDouble:startAngle] forKey:kHLArcLayerStartAngle];
                [pieLayer setValue:[NSNumber numberWithDouble:endAngle] forKey:kHLArcLayerEndAngle];
                
                [self updateLabelForLayer:pieLayer value:angles[index]];
                startAngle=endAngle;                
            }
            
        }else{
            //无数据
            NSInteger indexToRemove=_selectedIndex<0?[pieLayers count]-1:_selectedIndex;
            CAShapeLayer *pieLayer=[pieLayers objectAtIndex:indexToRemove];
            [pieLayer setDelegate:nil];
            [pieLayer setZPosition:0];
            
            layersToRemove=[[NSMutableArray alloc]initWithObjects:pieLayer, nil];
            
            if (sliceCount==0) {
                [pieLayer setOpacity:0.0];
            }else{
                for (int index=0; index<sliceCount; index++) {
                    NSInteger layerIndex=index<indexToRemove?index :index+1;
                    CAShapeLayer *pieLayer=(CAShapeLayer*)[pieLayers objectAtIndex:layerIndex];
//                    [pieLayer setDelegate:_defaultAnimationDelegate];
                    
                    endAngle+=angles[index];
                    [pieLayer setValue:[NSNumber numberWithDouble:endAngle] forKey:kHLArcLayerEndAngle];
                    [pieLayer setValue:[NSNumber numberWithDouble:startAngle] forKey:kHLArcLayerStartAngle];
                    
                    [self updateLabelForLayer:pieLayer value:values[index]];
                    startAngle=endAngle;
                }
                
            }
            [self  maybeNotifyDelegateOfSelectionChangeFrom:_selectedIndex to:-1];
        }
        [CATransaction commit];
    }
}

#pragma  mark - 刷新柱状图
-(void)reloadBarData
{
    [self layer].sublayers=nil;
    if (_dataSource) {
        
        [self drawHorizontalLines];
        //柱数量
        NSUInteger barCount=[_dataSource numberOfSectionsInChartView:self];
        
        
        for (int index=0;index<barCount;index++){
            int numberOfRows=[self.dataSource chartView:self numberOfRowsInSection:index];
            
            for (int points=0; points<numberOfRows; points++) {
                if (points+1>numberOfRows) {
                    continue;
                }
                [CATransaction begin];
                [CATransaction setAnimationDuration:1.25];
                CALayer *parentLayer=[self layer];
                [parentLayer setContentsScale:[UIScreen mainScreen].scale];
                
//                NSArray *barLayers=[parentLayer sublayers];
                
                [self setUserInteractionEnabled:NO];
                __block NSMutableArray *layersToRemove=nil;
                [CATransaction setCompletionBlock:^{
                    [layersToRemove enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){[obj removeFromSuperlayer];} ];
                    [layersToRemove removeAllObjects];
                    [self setUserInteractionEnabled:YES];
                }];
                
                CAShapeLayer *barLayer;
//                if (index+1>barCount) {
                
//                    barLayer=(CAShapeLayer*)[barLayers objectAtIndex:index];
//                    [barLayer setDelegate:_defaultAnimationDelegate];
//                }else{
//                    NSLog(@"++++++++++++++++ %d %d",index,points);
                
                    CGRect rect=[self calculateBarRectForHeight:[_dataSource chartView:self valueForChartViewAtIndex:points section:index] withNumberOfSection:index atRowIndex:points];
                  
                    UIColor *color=[self.dataSource chartView:self colorForChartView:index];
                    barLayer=[self createBarLayerWithColor:color itemRect:rect];
            
                    [barLayer setDelegate:_defaultAnimationDelegate];
                
                    [barLayer setValue:[NSNumber numberWithDouble:[_dataSource chartView:self valueForChartViewAtIndex:points section:index]] forKey:kHLChartViewItemValue];
                
                    [parentLayer addSublayer:barLayer];
                    
//                }
                
                [CATransaction commit];
            }
            
        }
    
        [self drawVerticalGridLines];
        if (_isShowLegend) {
            [self drawLegend];
        }  
        if (barCount>0) {
            [_delegate chartDidLoadFinish:YES];
        }
    }
}

#pragma mark - 刷新线形图
-(void)reloadLineData
{
    [self layer].sublayers=nil;
    if (_dataSource) {
        //共几条线
        [self drawHorizontalLines];
 
//        NSString* deviceType = [UIDevice currentDevice].model;
//        NSLog(@"=======%@",deviceType);
        
        NSUInteger lineCount=[_dataSource numberOfSectionsInChartView:self];
        
        for (int index=0;index<lineCount;index++){
            
            BOOL    isExist=false;
            for (id obj in _hideDatas) {
                NSDictionary *dic=(NSDictionary*)obj;
                int aIndex=[[dic objectForKey:@"index"] intValue];
                if (index==aIndex) {
                    isExist=true;
                    break;
                }
            }
            if (isExist) {
                continue;
            }
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:1.25];
            CALayer *parentLayer=[self layer];
            [parentLayer setContentsScale:[UIScreen mainScreen].scale];
            [self setUserInteractionEnabled:NO];
            __block NSMutableArray *layersToRemove=nil;
            [CATransaction setCompletionBlock:^{
                [layersToRemove enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){[obj removeFromSuperlayer];} ];
                [layersToRemove removeAllObjects];
                [self setUserInteractionEnabled:YES];
            }];
            
            int numberOfRows=[self.dataSource chartView:self numberOfRowsInSection:index];
            
            CGMutablePathRef path=CGPathCreateMutable();
            
            for (int points=0; points<numberOfRows; points++) {
//                NSLog(@"++++++++%d %d",index,points);
                CGPoint p=[self calculateForVertivalHeight:[self.dataSource chartView:self valueForChartViewAtIndex:points section:index] withNumberOfSection:index atRowIndex:points];
                if (points==0) {
                    CGPathMoveToPoint(path, NULL, p.x, p.y);
                }
                else{
                    CGPathAddLineToPoint(path, NULL, p.x, p.y);
                }
                
                UIBezierPath *pointPath;
                if (isTouch) {
                    pointPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(p.x-2, p.y-2, 4.0, 4.0) cornerRadius:2.0];
                }else{
                    pointPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(p.x-2, p.y-2, 2.0, 2.0) cornerRadius:1.0];
                }
                CAShapeLayer *pointLayer=[CAShapeLayer layer];
                [pointLayer setContentsScale:[UIScreen mainScreen].scale];
                [pointLayer setFillColor:[_dataSource chartView:self colorForChartView:index].CGColor];
                [pointLayer setPosition:CGPointMake(0, 0)];
                [pointLayer setPath:pointPath.CGPath];
                [pointLayer setStrokeColor:[_dataSource chartView:self colorForChartView:index].CGColor];
                [pointLayer setLineWidth:2.0];
                
                [pointLayer setValue:[NSNumber numberWithDouble:[_dataSource chartView:self valueForChartViewAtIndex:points section:index]] forKey:kHLChartViewItemValue];
                [pointLayer setValue:[NSNumber numberWithDouble:p.x] forKey:kHLChartViewPointX];
                [pointLayer setValue:[NSNumber numberWithDouble:p.y] forKey:kHLChartViewPointY];
                [pointLayer setValue:[NSNumber numberWithDouble:points] forKey:kHLChartViewItemIndex];
                [pointLayer setValue:[NSString stringWithFormat:@"%@:",[_dataSource chartView:self legendOfTitleInSection:index]] forKey:kHLChartViewItemName];
                [pointLayer setValue:[NSString stringWithFormat:@"%@:",[_dataSource chartView:self scaleXTitleForChartView:points]] forKey:kHLChartViewScaleX];
                pointLayer.name=[NSString stringWithFormat:@"point_%d",points];
                [parentLayer addSublayer:pointLayer];
            }
            
            CAShapeLayer *lineLayer=[CAShapeLayer layer];
            [lineLayer setContentsScale:[UIScreen mainScreen].scale];
            [lineLayer setFillColor:[UIColor clearColor].CGColor];
            [lineLayer setPosition:CGPointMake(0, 0)];
            [lineLayer setPath:path];
            [lineLayer setStrokeColor:[_dataSource chartView:self colorForChartView:index].CGColor];
            if (isTouch) {
                [lineLayer setLineWidth:1.0];
            }else{
                [lineLayer setLineWidth:1.0];
            }
            lineLayer.name=[NSString stringWithFormat:@"line_%d",index];
            [lineLayer setValue:[NSNumber numberWithInt:1] forKey:kHLLineLayerLastIndex];
            
            [parentLayer addSublayer:lineLayer];
            [CATransaction commit];
            
        }
        
        [self drawVerticalGridLines];
        if (_isShowLegend) {
            [self drawLegend];
        }
        //NSLog(@"reloadLineData");
        if (lineCount>0) {
            [_delegate chartDidLoadFinish:YES];
        }
    }
       
}

#pragma mark -  非动画pie图
-(void)reloadNewData
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CALayer  *parentLayer=[self layer];
    [parentLayer setContentsScale:[[UIScreen mainScreen] scale]];
    if (_dataSource) {
        NSUInteger sliceCount=[_dataSource numberOfSectionsInChartView:self];
      
        double sum=0.0;
        double values[sliceCount];
        for (int index=0; index<sliceCount; index++) {
            values[index]=[_dataSource chartView:self valueForChartView:index];
            sum+=values[index];
        }
        
        //计算每张切片的角度
        double angles[sliceCount];
        for (int index=0; index<sliceCount; index++) {
            double div=values[index]/sum;
            div=M_PI*2*div;
            angles[index]=div;
        }
      
        CGFloat startAngle=(CGFloat)-M_PI_2;
        CGFloat endAngle=startAngle;
        for (NSUInteger sliceIndex=0; sliceIndex<sliceCount; sliceIndex++) {
            endAngle+=angles[sliceIndex];
            CAShapeLayer *pieLayer;
            UIColor *color=[self.dataSource chartView:self colorForChartView:sliceIndex];
            pieLayer=[self createPieLayerWithColor:color];
            [parentLayer addSublayer:pieLayer];
            
            [self updateLabelForLayer:pieLayer value:round(values[sliceIndex]/sum*10000)/100];
            
            [pieLayer setValue:[NSNumber numberWithDouble:endAngle] forKey:kHLArcLayerEndAngle];
            [pieLayer setValue:[NSNumber numberWithDouble:startAngle] forKey:kHLArcLayerStartAngle];
            
            CGPathRef path=CGPathCreateArc(_center, _radius, startAngle, endAngle);
            [pieLayer setPath:path];
            CFRelease(path);
            
            CGFloat midAngle=(startAngle+endAngle)/2.0f;
            CGFloat halfRadius=_radius/2.0f;
            [[[pieLayer sublayers]objectAtIndex:0] setPosition:CGPointMake((CGFloat)(_center.x+(halfRadius*cos(midAngle))), (CGFloat)(_center.y+(halfRadius*sin(midAngle))))];
            
            startAngle=endAngle;
        }
    }
    
    [CATransaction setDisableActions:NO];
    [CATransaction commit];
    
    if (isTouch) {
        [self drawLegend];
        if ([self.title length]>0) {
            CAShapeLayer *textLayer=[self createTextLayer:self.title inRect:CGRectMake(0, Y_GRIDLINE_OFFSET, self.frame.size.width, 25) fontSize:17.0];
            [textLayer setContentsScale:[UIScreen mainScreen].scale];
            textLayer.name=@"chartTitle";
            [self.layer addSublayer:textLayer];
        }
    }
}

-(void)reloadData
{
    if (_chartStyle==HLChartViewStylePie) {
        if (!isTouch) {
            CGRect parentLayerBounds=[[self layer]bounds];
            CGFloat centerX=parentLayerBounds.size.width/2;
            CGFloat centerY=(parentLayerBounds.size.height-6)/2+6;
            _center=CGPointMake(centerX, centerY);
            _radius=MIN(centerX, centerY)-6;
        }
        [self reloadNewData];
//        _curRecord=0;
//        _addPieDataTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addPieData) userInfo:nil repeats:YES];
    }else if(_chartStyle==HLChartViewStyleLine){
        [self reloadLineData];
    }else if(_chartStyle==HLChartViewStyleMixed){
        [self reloadMixedData];// 双y轴数据
    }else{
        [self reloadBarData];
    }
}

-(void)addPieData
{
    int index=[_dataSource numberOfSectionsInChartView:self];
    if (_curRecord==index) {
        [_addPieDataTimer invalidate];
        [_delegate chartDidLoadFinish:YES];
        return;
    }
    if (index==[_sortLayers count]) {
        [_addPieDataTimer invalidate];
        //通知图表加载完成
        [_delegate chartDidLoadFinish:YES];
        return;
    }
    _curRecord=index;
//    _curRecord++;
    [_sortLayers addObject:[NSString stringWithFormat:@"%d",_curRecord]];
    [self reloadPieData];
}

#pragma mark - 柱与线图
-(void)reloadMixedData
{
    [self layer].sublayers=nil;
    if (_dataSource) {
        //共几条线
        [self drawHorizontalLines];
      
        NSUInteger lineCount=[_dataSource numberOfSectionsInChartView:self];
        
        for (int index=0;index<lineCount;index++){
            
            BOOL    isExist=false;
            for (id obj in _hideDatas) {
                NSDictionary *dic=(NSDictionary*)obj;
                int aIndex=[[dic objectForKey:@"index"] intValue];
                if (index==aIndex) {
                    isExist=true;
                    break;
                }
            }
            if (isExist) {
                continue;
            }
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:1.25];
            CALayer *parentLayer=[self layer];
            [parentLayer setContentsScale:[UIScreen mainScreen].scale];
            [self setUserInteractionEnabled:NO];
            __block NSMutableArray *layersToRemove=nil;
            [CATransaction setCompletionBlock:^{
                [layersToRemove enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){[obj removeFromSuperlayer];} ];
                [layersToRemove removeAllObjects];
                [self setUserInteractionEnabled:YES];
            }];
            int numberOfRows=[self.dataSource chartView:self numberOfRowsInSection:index];
            
            NSString *type=[self.dataSource chartView:self typeForChartView:index];
            NSLog(@"================index:%d=== numberOfRows:%d  type:%@",index,numberOfRows,type);
            
            if ([type isEqualToString:@"line"]) {
                UIColor *pColor=[_dataSource chartView:self colorForChartView:index];
                
   
                CGMutablePathRef path=CGPathCreateMutable();
                for (int points=0; points<numberOfRows; points++) {
                    CGFloat pValue=[self.dataSource chartView:self valueForChartViewAtIndex:points section:index type:type];
                    CGPoint p=[self calculateForVertivalHeight:pValue withNumberOfSection:index atRowIndex:points];
                    if (points==0) {
                        CGPathMoveToPoint(path, NULL, p.x, p.y);
                    }
                    else{
                        CGPathAddLineToPoint(path, NULL, p.x, p.y);
                    }
                    
                    UIBezierPath *pointPath;
                    if (isTouch) {
                        pointPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(p.x-2, p.y-2, 4.0, 4.0) cornerRadius:2.0];
                    }else{
                        pointPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(p.x-2, p.y-2, 2.0, 2.0) cornerRadius:1.0];
                    }
                    
                    CAShapeLayer *pointLayer=[CAShapeLayer layer];
                    [pointLayer setContentsScale:[UIScreen mainScreen].scale];
                    [pointLayer setFillColor:pColor.CGColor];
                    [pointLayer setPosition:CGPointMake(0, 0)];
                    [pointLayer setPath:pointPath.CGPath];
                    [pointLayer setStrokeColor:pColor.CGColor];
                    [pointLayer setLineWidth:2.0];
                    
                    NSString  *pLegend=[_dataSource chartView:self legendOfTitleInSection:index];
                    NSString  *pXTitle=[_dataSource chartView:self scaleXTitleForChartView:points];
                    
                    [pointLayer setValue:[NSNumber numberWithDouble:pValue] forKey:kHLChartViewItemValue];
                    [pointLayer setValue:[NSNumber numberWithDouble:p.x] forKey:kHLChartViewPointX];
                    [pointLayer setValue:[NSNumber numberWithDouble:p.y] forKey:kHLChartViewPointY];
                    [pointLayer setValue:[NSNumber numberWithDouble:points] forKey:kHLChartViewItemIndex];
                    [pointLayer setValue:[NSString stringWithFormat:@"%@:",pLegend] forKey:kHLChartViewItemName];
                    [pointLayer setValue:[NSString stringWithFormat:@"%@:",pXTitle] forKey:kHLChartViewScaleX];
                    pointLayer.name=[NSString stringWithFormat:@"point_%d",points];
                    [parentLayer addSublayer:pointLayer];
                }
                
                CAShapeLayer *lineLayer=[CAShapeLayer layer];
                [lineLayer setContentsScale:[UIScreen mainScreen].scale];
                [lineLayer setFillColor:[UIColor clearColor].CGColor];
                [lineLayer setPosition:CGPointMake(0, 0)];
                [lineLayer setPath:path];
                [lineLayer setStrokeColor:pColor.CGColor];
                if (isTouch) {
                    [lineLayer setLineWidth:1.0];
                }else{
                    [lineLayer setLineWidth:1.0];
                }
                lineLayer.name=[NSString stringWithFormat:@"line_%d",index];
                [lineLayer setValue:[NSNumber numberWithInt:1] forKey:kHLLineLayerLastIndex];
                
                [parentLayer addSublayer:lineLayer];
                
            }else{
              for (int points=0; points<numberOfRows; points++) {
                    CGFloat pValue=[self.dataSource chartView:self valueForChartViewAtIndex:points section:index type:type];
                    CGRect rect=[self calculateBarRectForHeight:pValue withNumberOfSection:index atRowIndex:points];
                
                    UIColor *color=[self.dataSource chartView:self colorForChartView:index];
                    CAShapeLayer  *barLayer=[self createBarLayerWithColor:color itemRect:rect];
                
                    [barLayer setDelegate:_defaultAnimationDelegate];
                
                    [barLayer setValue:[NSNumber numberWithDouble:pValue] forKey:kHLChartViewItemValue];
                    [parentLayer addSublayer:barLayer];
                }
            }
            
            [CATransaction commit];
            
        }
        
        [self drawVerticalGridLines];
        if (_isShowLegend) {
            [self drawLegend];
        }
        
        if (lineCount>0) {
            [_delegate chartDidLoadFinish:YES];
        }
    }
}


#pragma  mark - 画网络
-(void)drawGridLines:(CGContextRef)context
{
    //横线
    float maxHeight=[self.dataSource maxVerticalValueInChartView:self filter:_hideDatas];
    float allowableMaxHeight=self.bounds.size.height-Y_GRIDLINE_OFFSET*2-_chartTitleHeight-self.itemTitleHeight-_legendHeight;
    
    int gridLineStepValue=rint(maxHeight/NUM_OF_GRIDLINES);
    
    UIBezierPath *gridLinePath=[UIBezierPath bezierPath];
    UIColor *gridColor=[UIColor lightGrayColor];
    [gridColor setStroke];
    
    [gridLinePath moveToPoint:CGPointMake(X_GRIDLINE_OFFSET, self.bounds.size.height-Y_GRIDLINE_OFFSET-self.itemTitleHeight-_legendHeight)];
    [gridLinePath addLineToPoint:CGPointMake(self.bounds.size.width-X_GRIDLINE_OFFSET, self.bounds.size.height-Y_GRIDLINE_OFFSET-self.itemTitleHeight-_legendHeight)];
    gridLinePath.lineWidth=0.5;
    //虚线
    CGFloat dashPatern[2] = {4.0, 2.0};
    [gridLinePath setLineDash:dashPatern count:2 phase:0.0];
    NSString *itemYAxisValue=[NSString stringWithFormat:@"%d",0];
    [itemYAxisValue drawInRect:CGRectMake(10, self.bounds.size.height-Y_GRIDLINE_OFFSET-self.itemTitleHeight-_legendHeight, 8, 4) withFont:[UIFont fontWithName:@"Arial" size:8] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
    CGContextSaveGState(context);
    for (int gridLine = 1; gridLine < NUM_OF_GRIDLINES+1; gridLine ++) {
        
		CGContextTranslateCTM(context, 0, -rint(allowableMaxHeight/NUM_OF_GRIDLINES));
		[gridLinePath stroke];
        //Drawing Y Axis Legend
		itemYAxisValue = [NSString stringWithFormat:@"%d",gridLineStepValue * gridLine];
		int legendHeight = rint(allowableMaxHeight/NUM_OF_GRIDLINES);
		float yPoint = self.bounds.size.height - Y_GRIDLINE_OFFSET - self.itemTitleHeight- _legendHeight;
		[itemYAxisValue drawInRect:CGRectMake(0, yPoint, Y_GRIDLINE_LEGEND_WIDTH,legendHeight) withFont:[UIFont fontWithName:@"Arial" size:8] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentRight];
	}		
	CGContextRestoreGState(context);
    
}
#pragma mark - 粗体字
-(CAShapeLayer*)createTextLayer:(NSString *)value inRect:(CGRect)rect fontSize:(float)fSize
{
    UIBezierPath *rectPath=[UIBezierPath bezierPathWithRect:rect];
    CAShapeLayer *pLayer=[CAShapeLayer layer];
    [pLayer setContentsScale:[UIScreen mainScreen].scale];
    [pLayer   setFillColor:NULL];
    [pLayer   setStrokeColor:NULL];
    [pLayer setShadowRadius:2.0];
    [pLayer setPath:rectPath.CGPath];
    
    CATextLayer *textLayer=[CATextLayer layer];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont boldSystemFontOfSize:fSize]fontName]);
    [textLayer setFont:font];
    CFRelease(font);
    [textLayer setFontSize:fSize];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[UIColor blackColor].CGColor];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [textLayer setString:value];
    CGSize size=[self sizeThatFitsString:value fontSize:fSize];
    [textLayer setFrame:CGRectMake(0, rect.origin.y+(rect.size.height-size.height)/2, rect.size.width, size.height)];
    [pLayer addSublayer:textLayer];
    return pLayer;
}
#pragma mark - 默认字体
-(CAShapeLayer*)createDefaultTextLayer:(NSString *)value inRect:(CGRect)rect fontSize:(float)fSize
{
    UIBezierPath *rectPath=[UIBezierPath bezierPathWithRect:rect];
    CAShapeLayer *pLayer=[CAShapeLayer layer];
    [pLayer setContentsScale:[UIScreen mainScreen].scale];
    [pLayer   setFillColor:NULL];
    [pLayer   setStrokeColor:NULL];
    [pLayer setShadowRadius:2.0];
    [pLayer setPath:rectPath.CGPath];
    
    CATextLayer *textLayer=[CATextLayer layer];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont systemFontOfSize:fSize]fontName]);
    [textLayer setFont:font];
    CFRelease(font);
    [textLayer setFontSize:fSize];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[UIColor blackColor].CGColor];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [textLayer setString:value];
    CGSize size=[self sizeThatFitsString:value fontSize:fSize];
    [textLayer setFrame:CGRectMake(0, rect.origin.y+(rect.size.height-size.height)/2, rect.size.width, size.height)];
    [pLayer addSublayer:textLayer];
    return pLayer;
}

#pragma mark - 横线
-(void)drawHorizontalLines
{
    if ([self.title length]>0) {
        CAShapeLayer *textLayer=[self createTextLayer:self.title inRect:CGRectMake(0, Y_GRIDLINE_OFFSET-5, self.frame.size.width, 25) fontSize:17.0];
        [textLayer setContentsScale:[UIScreen mainScreen].scale];
        textLayer.name=@"chartTitle";
        [self.layer addSublayer:textLayer];
        //Y 轴单位
        CAShapeLayer *unitLayer=[self createDefaultTextLayer:@"单位:千" inRect:CGRectMake(5, 25, 50, 20) fontSize:10.0f];
        [unitLayer setContentsScale:[UIScreen mainScreen].scale];
        unitLayer.name=@"unitLayerY";
        [self.layer addSublayer:unitLayer];
        
        if (_chartStyle==HLChartViewStyleMixed) {
            CAShapeLayer *uLayer=[self createDefaultTextLayer:@"单位:%" inRect:CGRectMake(self.bounds.size.width-55, 25, 50, 20) fontSize:10.0f];
            [uLayer setContentsScale:[UIScreen mainScreen].scale];
            uLayer.name=@"unitLayerY2";
            [self.layer addSublayer:uLayer];
        }
        
    }else{
        _chartTitleHeight=0;
        self.itemTitleHeight=0;
    }
    int xOffset=X_GRIDLINE_OFFSET;
    int yOffset=Y_GRIDLINE_OFFSET;
    int xPadding=5;
    if (isTouch||_chartStyle==HLChartViewStyleMixed) {
        xPadding=10;
        xOffset=X_GRIDLINE_OFFSET_TOUCH;
        yOffset=Y_GRIDLINE_OFFSET_TOUCH;
    }

    
    UIBezierPath *verticalLine=[UIBezierPath bezierPath];
    [verticalLine moveToPoint:CGPointMake(xOffset, yOffset+_chartTitleHeight-xPadding)];
    [verticalLine addLineToPoint:CGPointMake(xOffset, self.bounds.size.height-Y_GRIDLINE_OFFSET-self.itemTitleHeight-_legendHeight+xPadding)];
    CAShapeLayer *verticalLayer=[CAShapeLayer layer];
    [verticalLayer setContentsScale:[UIScreen mainScreen].scale];
    [verticalLayer setFillColor:NULL];
    [verticalLayer setPosition:CGPointMake(0, 0)];
    [verticalLayer setPath:verticalLine.CGPath];
    [verticalLayer setStrokeColor:[UIColor lightGrayColor].CGColor];
    verticalLayer.name=@"verticalLayer";
    [self.layer  addSublayer:verticalLayer];
    

    UIBezierPath *horizontalLine=[UIBezierPath bezierPath];
    [horizontalLine moveToPoint:CGPointMake(xOffset-xPadding, self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight)];
    [horizontalLine addLineToPoint:CGPointMake(self.bounds.size.width-xOffset+xPadding, self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight)];
    CAShapeLayer *horizontalLayer=[CAShapeLayer layer];
    [horizontalLayer setContentsScale:[UIScreen mainScreen].scale];
    [horizontalLayer setFillColor:NULL];
    [horizontalLayer setPosition:CGPointMake(0, 0)];
    [horizontalLayer setPath:horizontalLine.CGPath];
    [horizontalLayer setStrokeColor:[UIColor lightGrayColor].CGColor];
    horizontalLayer.name=@"horizontalLayer";
    
    
    if (_chartStyle==HLChartViewStyleMixed) {
        UIBezierPath *verticalLine=[UIBezierPath bezierPath];
        [verticalLine moveToPoint:CGPointMake(self.bounds.size.width-xOffset, yOffset+_chartTitleHeight-xPadding)];
        [verticalLine addLineToPoint:CGPointMake(self.bounds.size.width-xOffset, self.bounds.size.height-Y_GRIDLINE_OFFSET-self.itemTitleHeight-_legendHeight+xPadding)];
        CAShapeLayer *verticalLayer=[CAShapeLayer layer];
        [verticalLayer setContentsScale:[UIScreen mainScreen].scale];
        [verticalLayer setFillColor:NULL];
        [verticalLayer setPosition:CGPointMake(0, 0)];
        [verticalLayer setPath:verticalLine.CGPath];
        [verticalLayer setStrokeColor:[UIColor lightGrayColor].CGColor];
        verticalLayer.name=@"verticalLayer2";
        [self.layer  addSublayer:verticalLayer];
    }
    
    CATextLayer *textLayer=[CATextLayer layer];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont systemFontOfSize:_legendFontSize]fontName]);
    [textLayer setFont:font];
    CFRelease(font);
    [textLayer setFontSize:_legendFontSize];
    [textLayer setAlignmentMode:kCAAlignmentRight];
    if (isTouch) {
        [textLayer setForegroundColor:[UIColor blackColor].CGColor];
    }else{
        [textLayer setForegroundColor:[UIColor lightGrayColor].CGColor];
    }
    
    CGSize size=[self sizeThatFitsString:@"0" fontSize:_legendFontSize];
    [textLayer setString:@"0"];
    [textLayer setFrame:CGRectMake(0, self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight-5, xOffset-12, size.height)];
    //点击时显示坐标标签
    if (isTouch||_chartStyle==HLChartViewStyleMixed) {
        [horizontalLayer addSublayer:textLayer];
    }

    [self.layer  addSublayer:horizontalLayer];
    
    float maxHeight=[self.dataSource maxVerticalValueInChartView:self filter:_hideDatas];
    if (_chartStyle==HLChartViewStyleMixed) {
        maxHeight=[self.dataSource maxVerticalValueInChartView:self filter:_hideDatas type:@"bar"];
    }
    float allowableMaxHeight=self.bounds.size.height-yOffset*2-_chartTitleHeight-self.itemTitleHeight-_legendHeight;
    
    int gridLineStepValue=rint(maxHeight/NUM_OF_GRIDLINES);
    
    for (int gridLine = 1; gridLine < NUM_OF_GRIDLINES+1; gridLine ++) {
        
        UIBezierPath *gridLinePath=[UIBezierPath bezierPath];
       
        [gridLinePath moveToPoint:CGPointMake(xOffset, self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight-gridLine*rint(allowableMaxHeight/NUM_OF_GRIDLINES))];
        [gridLinePath addLineToPoint:CGPointMake(self.bounds.size.width-xOffset, self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight-gridLine*rint(allowableMaxHeight/NUM_OF_GRIDLINES))];
        gridLinePath.lineWidth=0.5;
               
        CAShapeLayer *lineLayer=[CAShapeLayer layer];
        [lineLayer setContentsScale:[UIScreen mainScreen].scale];
        [lineLayer setFillColor:[UIColor clearColor].CGColor];
        [lineLayer setPosition:CGPointMake(0, 0)];
        [lineLayer setPath:gridLinePath.CGPath];
        [lineLayer setStrokeColor:[UIColor lightGrayColor].CGColor];
        [lineLayer setLineWidth:0.5];
        [lineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:4],[NSNumber numberWithInt:2],nil]];
        lineLayer.name=[NSString stringWithFormat:@"hor_%d",gridLine];
        
        CATextLayer *textLayer=[CATextLayer layer];
        [textLayer setContentsScale:[UIScreen mainScreen].scale];
        CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont systemFontOfSize:_legendFontSize]fontName]);
        [textLayer setFont:font];
        CFRelease(font);
        [textLayer setFontSize:_legendFontSize];
        [textLayer setAlignmentMode:kCAAlignmentRight];
        if (isTouch) {
            [textLayer setForegroundColor:[UIColor blackColor].CGColor];
        }else{
            [textLayer setForegroundColor:[UIColor lightGrayColor].CGColor];
        }

        float yPoint = self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight-gridLine*rint(allowableMaxHeight/NUM_OF_GRIDLINES)-5;
        CGSize size=[self sizeThatFitsString:[NSString stringWithFormat:@"%d",gridLineStepValue * gridLine] fontSize:_legendFontSize];
        CGFloat lValue=gridLine*gridLineStepValue;
        if (lValue>1000) {
            [textLayer setString:[NSString stringWithFormat:@"%@",[self getYLabelValue:(gridLineStepValue * gridLine)]]];
        }else{
            [textLayer setString:[NSString stringWithFormat:@"%f",lValue]];
            
        }
        [textLayer setFrame:CGRectMake(0, yPoint, xOffset-2, size.height)];
       
        if (isTouch||_chartStyle==HLChartViewStyleMixed) {
            [lineLayer addSublayer:textLayer];
        }
        [self.layer addSublayer:lineLayer];
    }
}

#pragma mark - Y坐标值
-(NSString*)getYLabelValue:(CGFloat)aValue
{
    NSString *result=[NSString stringWithFormat:@"%.1f",aValue/1000.0f];
    return result;
}

#pragma mark - 画垂直网格线
-(void)drawVerticalGridLines
{
    int xOffset=X_GRIDLINE_OFFSET;
    int yOffset=Y_GRIDLINE_OFFSET;
    int xPadding=5;
    if (isTouch||_chartStyle==HLChartViewStyleMixed) {
        xPadding=10;
        xOffset=X_GRIDLINE_OFFSET_TOUCH;
        yOffset=Y_GRIDLINE_OFFSET_TOUCH;
    }
    
    CALayer *parentLayer=[self layer];
    [parentLayer setContentsScale:[UIScreen mainScreen].scale];
    float maxRows=[self.dataSource maxHorizontalValueInChartView:self];
    float allowableMaxWidth=self.bounds.size.width-xOffset*2-maxRows*10;
   
    float gridLineStepValue=allowableMaxWidth/maxRows;
    
    if (_chartStyle==HLChartViewStyleLine) {
        gridLineStepValue=(self.bounds.size.width-xOffset*2)/(maxRows-1);
    }
    
    for (int index=1; index<maxRows+1; index++) {
        UIBezierPath *gridLinePath=[UIBezierPath bezierPath];
        UIBezierPath *touchPath;
        if (_chartStyle==HLChartViewStyleLine) {
            [gridLinePath moveToPoint:CGPointMake(xOffset+gridLineStepValue*(index-1), yOffset+_chartTitleHeight)];
            [gridLinePath addLineToPoint:CGPointMake(xOffset+gridLineStepValue*(index-1), self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight-2)];
            touchPath=[UIBezierPath bezierPathWithRect:CGRectMake(xOffset+gridLineStepValue*(index-1)-gridLineStepValue/2, yOffset+_chartTitleHeight, gridLineStepValue,self.bounds.size.height-yOffset*2-self.itemTitleHeight-_legendHeight-2-_chartTitleHeight)];
        }else{
            [gridLinePath moveToPoint:CGPointMake(xOffset+index*10+gridLineStepValue*index, yOffset+_chartTitleHeight)];
            [gridLinePath addLineToPoint:CGPointMake(xOffset+index*10+gridLineStepValue*index, self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight-2)];
        }
        //line 
        CAShapeLayer *touchLayer=[CAShapeLayer layer];
        [touchLayer setContentsScale:[UIScreen mainScreen].scale];
        if (_chartStyle==HLChartViewStyleLine) {
            touchLayer.position=CGPointMake(0, 0);
            [touchLayer setPath:touchPath.CGPath];
            [touchLayer setStrokeColor:NULL];
            [touchLayer setFillColor:NULL];
            touchLayer.name=[NSString stringWithFormat:@"touch_%d",index];
            [touchLayer setValue:[NSNumber numberWithDouble:index] forKey:kHLChartViewItemIndex];
            [touchLayer setValue:[NSNumber numberWithDouble:index] forKey:kHLChartViewItemValue];
            [touchLayer setValue:[NSNumber numberWithDouble:[_dataSource numberOfSectionsInChartView:self]] forKey:kHLChartViewSectionNums];
        }
        
        CAShapeLayer *lineLayer=[CAShapeLayer layer];
        [lineLayer setContentsScale:[UIScreen mainScreen].scale];
        [lineLayer setFillColor:[UIColor clearColor].CGColor];
        [lineLayer setPosition:CGPointMake(0, 0)];
        [lineLayer setPath:gridLinePath.CGPath];
        [lineLayer setStrokeColor:[UIColor lightGrayColor].CGColor];
        [lineLayer setLineWidth:0.5];
        [lineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:4],[NSNumber numberWithInt:2],nil]];
        lineLayer.name=[NSString stringWithFormat:@"ver_%d",index];
        
        
        //添加X轴标签
        CATextLayer *textLayer=[CATextLayer layer];
        [textLayer setContentsScale:[UIScreen mainScreen].scale];
        CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont systemFontOfSize:_legendFontSize]fontName]);
        [textLayer setFont:font];
        CFRelease(font);
        [textLayer setFontSize:_legendFontSize];
        [textLayer setAlignmentMode:kCAAlignmentCenter];
        if (isTouch) {
            [textLayer setForegroundColor:[UIColor blackColor].CGColor];
        }else{
            [textLayer setForegroundColor:[UIColor lightGrayColor].CGColor];
        }
        
        CGSize size=[self sizeThatFitsString:[_dataSource chartView:self scaleXTitleForChartView:(index-1)] fontSize:_legendFontSize];
        [textLayer setString:[_dataSource chartView:self scaleXTitleForChartView:(index-1)]];
        [textLayer setFrame:CGRectMake(0, 0, gridLineStepValue, size.height-5)];
        if (_chartStyle==HLChartViewStyleLine) {
             [textLayer setPosition:CGPointMake(xOffset+gridLineStepValue*(index-1), self.bounds.size.height-yOffset-_legendHeight+3)];
        }else{
            [textLayer setPosition:CGPointMake(xOffset+index*10+gridLineStepValue*index-gridLineStepValue+30, self.bounds.size.height-yOffset-_legendHeight+5)];
        }
        
        CGMutablePathRef path=CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, xOffset+gridLineStepValue*(index-1), self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight-2);
        CGPathAddLineToPoint(path, NULL, xOffset+gridLineStepValue*(index-1)-5, self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight+5);
        CGPathAddLineToPoint(path, NULL, xOffset+gridLineStepValue*(index-1)+5, self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight+5);
        CAShapeLayer *triangleLayer=[CAShapeLayer layer];
        [triangleLayer setContentsScale:[UIScreen mainScreen].scale];
        [triangleLayer setFillColor:NULL];
        [triangleLayer setStrokeColor:NULL];
        [triangleLayer setPath:path];
       // [triangleLayer setPosition:CGPointMake(0,0)];
        
        if (isTouch||_chartStyle==HLChartViewStyleMixed) {
            if (_chartStyle==HLChartViewStyleBar) {
                [lineLayer addSublayer:textLayer];
                [parentLayer addSublayer:lineLayer];
            }else{
                [touchLayer addSublayer:textLayer];
                [touchLayer addSublayer:lineLayer];
                [touchLayer addSublayer:triangleLayer];
            
                //线 弹出层
                [parentLayer addSublayer:touchLayer];
            }
        }else{
            //不能点
            if (_chartStyle==HLChartViewStyleBar) {
//                [lineLayer addSublayer:textLayer];
                [parentLayer addSublayer:lineLayer];
            }else{
//                [touchLayer addSublayer:textLayer];
                [touchLayer addSublayer:lineLayer];
                [touchLayer addSublayer:triangleLayer];
        
                //线 弹出层
                [parentLayer addSublayer:touchLayer];
            }
        }
    }
}

#pragma mark - 判断 数据是否在隐藏队列中
-(BOOL)isExistHideData:(int)index
{
    BOOL    isExist=false;
    for (id obj in _hideDatas) {
        NSDictionary *dic=(NSDictionary*)obj;
        int aIndex=[[dic objectForKey:@"index"] intValue];
        if (index==aIndex) {
            isExist=true;
            continue;
        }
    }
    return isExist;
}

#pragma mark - 画标签示意图
-(void)drawLegend
{
    CALayer *parentLayer=[self layer];
    [parentLayer setContentsScale:[UIScreen mainScreen].scale];
    float sectionWidth;
    float allowableMaxWidth = self.bounds.size.width-X_GRIDLINE_OFFSET*2;
    int section=[_dataSource numberOfSectionsInChartView:self];
    //共几列
    sectionWidth=allowableMaxWidth/section;
    CGRect rect;
//    NSLog(@"%f",round(section/2.0));
    int col=ceil(section/2.0);
    int colWidth=floor(allowableMaxWidth/col);
    int offY=floor(self.bounds.size.height-_legendHeight);
    for (int i=0; i<2; i++) {
        for (int j=0; j<col; j++) {
//            NSLog(@"%d col %d index %d %d %d %d 20",section,col,i*2+j,(10+j*colWidth),(offY+i*20),colWidth);
            if ((i*col+j)>=section) {
                break;
            }
            [self addLegend:(i*col+j) offX:(10+j*colWidth) offY:(offY+i*20) width:colWidth height:20];
        }
    }
    
    
//    for (int index=0; index<section; index++) {
//        rect=CGRectMake(X_GRIDLINE_OFFSET+10*(index+1)+sectionWidth*(index+1)-sectionWidth, self.bounds.size.height-23, 20, 10);
//        if (_chartStyle==HLChartViewStyleLine) {
//            rect=CGRectMake(X_GRIDLINE_OFFSET+10*(index+1)+sectionWidth*(index+1)-sectionWidth, self.bounds.size.height-20, 20, 3);
//        }
//        
//        CAShapeLayer *legendLayer=[CAShapeLayer layer];
//        [legendLayer setContentsScale:[UIScreen mainScreen].scale];
//        [legendLayer setFillColor:[_dataSource chartView:self colorForChartView:index].CGColor];
//        [legendLayer setPosition:CGPointMake(0, 0)];
//        [legendLayer setPath:[UIBezierPath bezierPathWithRect:rect].CGPath];
//        [legendLayer setStrokeColor:NULL];
//        
//        legendLayer.name=[NSString stringWithFormat:@"legend_%d",index];
//        
//        //添加Legend 内容
//        CATextLayer *textLayer=[CATextLayer layer];
//        [textLayer setContentsScale:[UIScreen mainScreen].scale];
//        CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont systemFontOfSize:_legendFontSize]fontName]);
//        [textLayer setFont:font];
//        CFRelease(font);
//        [textLayer setFontSize:_legendFontSize];
//        [textLayer setAlignmentMode:kCAAlignmentCenter];
//        [textLayer setForegroundColor:[UIColor blackColor].CGColor];
//        
//        CGSize size=[self sizeThatFitsString:[_dataSource chartView:self legendOfTitleInSection:index] fontSize:_legendFontSize];
//        [textLayer setString:[_dataSource chartView:self legendOfTitleInSection:index]];
//        [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
//        [textLayer setPosition:CGPointMake(X_GRIDLINE_OFFSET+(index+1)*10+sectionWidth*(index+1)-sectionWidth+45, self.bounds.size.height-16)];
//        
//        [legendLayer addSublayer:textLayer];
//        
//        [parentLayer addSublayer:legendLayer];
//        
//    }

}

-(void)addLegend:(int)index offX:(int)x offY:(int)y width:(int)w height:(int)h
{
    CALayer *parentLayer=[self layer];
    [parentLayer setContentsScale:[UIScreen mainScreen].scale];
    UIBezierPath *touchPath=[UIBezierPath bezierPathWithRect:CGRectMake(x, y, w,h)];
    
    NSString  *legendString=[_dataSource chartView:self legendOfTitleInSection:index];
    
    CAShapeLayer *touchLayer=[CAShapeLayer layer];
    [touchLayer setContentsScale:[UIScreen mainScreen].scale];
    if (_chartStyle==HLChartViewStyleLine) {
        touchLayer.position=CGPointMake(0, 0);
        [touchLayer setPath:touchPath.CGPath];
        [touchLayer setStrokeColor:NULL];
        [touchLayer setFillColor:NULL];
        touchLayer.name=[NSString stringWithFormat:@"touchlegend_%d",index];
        [touchLayer setValue:[NSNumber numberWithInt:index] forKey:kHLChartViewItemIndex];
        [touchLayer setValue:legendString forKey:kHLChartViewItemName];
    }

    CGRect rect=CGRectMake(x,y+2, 20, 6);
    if (_chartStyle==HLChartViewStyleLine) {
        rect=CGRectMake(x, y+3, 20, 3);
    }
    
    CAShapeLayer *legendLayer=[CAShapeLayer layer];
    [legendLayer setContentsScale:[UIScreen mainScreen].scale];
    [legendLayer setFillColor:[_dataSource chartView:self colorForChartView:index].CGColor];
    [legendLayer setPosition:CGPointMake(0, 0)];
    [legendLayer setPath:[UIBezierPath bezierPathWithRect:rect].CGPath];
    [legendLayer setStrokeColor:NULL];
    
    legendLayer.name=[NSString stringWithFormat:@"legend_%d",index];
    
    //添加Legend 内容
    CATextLayer *textLayer=[CATextLayer layer];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont systemFontOfSize:_legendFontSize]fontName]);
    [textLayer setFont:font];
    CFRelease(font);
    [textLayer setFontSize:_legendFontSize];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[UIColor blackColor].CGColor];
    BOOL isExist=[self isExistHideData:index];
    if (isExist) {
        [textLayer setForegroundColor:[UIColor lightGrayColor].CGColor];
    }
    
    textLayer.name=[NSString stringWithFormat:@"legend_text_%d_%@",index,[_dataSource chartView:self legendOfTitleInSection:index]];
    CGSize size=[self sizeThatFitsString:legendString fontSize:_legendFontSize];
    [textLayer setString:legendString];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [textLayer setPosition:CGPointMake(x+30, y+8)];
    
    [touchLayer addSublayer:textLayer];
    
    [touchLayer addSublayer:legendLayer];
    
    [parentLayer addSublayer:touchLayer];
}

//计算点位置
#pragma mark - 计算线图点位置
-(CGPoint)calculateForVertivalHeight:(float)vHeight withNumberOfSection:(NSInteger)section atRowIndex:(NSInteger)index
{
    float convertedPointHeight;
    CGPoint linePosition;
    int xOffset=X_GRIDLINE_OFFSET_TOUCH;
    int yOffset=Y_GRIDLINE_OFFSET_TOUCH;
    if (!isTouch) {
        _chartTitleHeight=0;
        self.itemTitleHeight=0;
        xOffset=X_GRIDLINE_OFFSET;
        yOffset=Y_GRIDLINE_OFFSET;
    }
    
    float maxPointHeight=[self.dataSource maxVerticalValueInChartView:self filter:_hideDatas];
    float allowableMaxHeight=self.bounds.size.height-yOffset*2-_chartTitleHeight-_legendHeight-self.itemTitleHeight;
   
    float maxPoints=[self.dataSource maxHorizontalValueInChartView:self]-1;
    float pointDistance=(self.bounds.size.width-xOffset*2)/maxPoints;
    convertedPointHeight=(vHeight*allowableMaxHeight)/maxPointHeight;
    
    linePosition.x=index*pointDistance+xOffset;
    linePosition.y=self.bounds.size.height-yOffset-self.itemTitleHeight-_legendHeight- convertedPointHeight;

//    NSLog(@"calculatePointForHeight s:%d i:%d v:%f x:%f,y:%f",section,index,convertedPointHeight,linePosition.x,linePosition.y);
    return linePosition;
}
#pragma mark - 计算柱状图位置及大小
-(CGRect)calculateBarRectForHeight:(float)barHeight withNumberOfSection:(NSInteger)section atRowIndex:(NSInteger)index
{
    int xOffset=X_GRIDLINE_OFFSET_TOUCH;
    int yOffset=Y_GRIDLINE_OFFSET_TOUCH;
    if (!isTouch) {
        _chartTitleHeight=0;
        self.itemTitleHeight=0;
        xOffset=X_GRIDLINE_OFFSET;
        yOffset=Y_GRIDLINE_OFFSET;
    }
    
    CGRect barRect;
	float convertedBarHeight;
	CGPoint barPosition;
	float barWidth;
    float sectionWidth;
    float mRows=[_dataSource maxHorizontalValueInChartView:self];
    NSInteger  sec=[_dataSource numberOfSectionsInChartView:self];
    
	//Calculating bar height
	float maxBarHeight = [self.dataSource maxVerticalValueInChartView:self filter:_hideDatas];
	float allowableMaxHeight = self.bounds.size.height - yOffset * 2-_chartTitleHeight - _legendHeight - self.itemTitleHeight;
	convertedBarHeight = (barHeight * allowableMaxHeight) / maxBarHeight;
    
	//calculataing bar width
	float allowableMaxWidth = self.bounds.size.width - xOffset * 2 - mRows*10;
    //共几列
    sectionWidth=allowableMaxWidth/mRows;
    //每列几组
	barWidth = sectionWidth /sec;
    
	barPosition.y = self.bounds.size.height - yOffset - self.itemTitleHeight - _legendHeight;
    float sepEmpt=0;
    sepEmpt=index*10;
	barPosition.x = xOffset + 5 + barWidth * section+index*sectionWidth+sepEmpt;
    
	barRect = CGRectMake(barPosition.x, barPosition.y, barWidth, convertedBarHeight);
//    NSLog(@"calculateBarRectForBarItemHeight %d,%d==%f,%f,%f,%f",section,index,barRect.origin.x,barRect.origin.y,barRect.size.width,barRect.size.height);
    
	return barRect;
}
-(CAShapeLayer*)createBarLayerWithColor:(UIColor *)color itemRect:(CGRect)rect
{
    CAShapeLayer *barLayer=[CAShapeLayer layer];
    barLayer.contentsScale=[UIScreen mainScreen].scale;
    barLayer.bounds=CGRectMake(0, 0, rect.size.width, rect.size.height);
    barLayer.anchorPoint=CGPointMake(0, 1);
    barLayer.position=rect.origin;
    
    CGRect barItemRect=CGRectMake(0, 0, barLayer.bounds.size.width, barLayer.bounds.size.height);
    UIBezierPath *barItemPath;
    barItemPath=[UIBezierPath bezierPathWithRoundedRect:barItemRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake((barItemRect.size.width / BAR_ITEM_CORNER_RADIUS_OFFSET), (barItemRect.size.width/BAR_ITEM_CORNER_RADIUS_OFFSET))];
    //barItemPath=[UIBezierPath bezierPathWithRect:barItemRect];
    barLayer.path=barItemPath.CGPath;
    
    barLayer.strokeColor=[UIColor whiteColor].CGColor;
    barLayer.fillColor=color.CGColor;
    
    //加文字
    CATextLayer *textLayer=[CATextLayer layer];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont boldSystemFontOfSize:_legendFontSize]fontName]);
    [textLayer setFont:font];
    CFRelease(font);
    
    [textLayer setFontSize:_legendFontSize];
    [textLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    CGSize size=[self sizeThatFitsString:@"N/A" fontSize:_legendFontSize];
    CGFloat halfRadius=(_radius/2);
    [CATransaction setDisableActions:YES];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [textLayer setPosition:CGPointMake(_center.x+(halfRadius*cos(0)), _center.y+(halfRadius*sin(0)))];
    [CATransaction  setDisableActions:NO];
    [barLayer addSublayer:textLayer];

    return barLayer;
}

#pragma  mark - 动画
-(void)updateTimerFired:(NSTimer *)timer
{
    CALayer *parentLayer=[self layer];
    [parentLayer setContentsScale:[UIScreen mainScreen].scale];
    NSArray *pieLayers=[parentLayer sublayers];
    
    [pieLayers enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL *stop){
        if (_chartStyle==HLChartViewStylePie) {
            NSNumber *presentationLayerStartAngle=[[obj presentationLayer]valueForKey:kHLArcLayerStartAngle];
            CGFloat interpolatedStartAngle=[presentationLayerStartAngle doubleValue];
            NSNumber *presentationLayerEndAngle=[[obj presentationLayer]valueForKey:kHLArcLayerEndAngle];
            CGFloat interpolatedEndAngle=[presentationLayerEndAngle doubleValue];
            CGPathRef path=CGPathCreateArc(_center, _radius, interpolatedStartAngle, interpolatedEndAngle);
            [obj setPath:path];
            CFRelease(path);
            {   
                CALayer *labelLayer=[[obj sublayers]objectAtIndex:0];
                CGFloat interpolatedMidAngle=(interpolatedEndAngle+interpolatedStartAngle)/2;
                CGFloat halfRadius=_radius/2;
                [CATransaction setDisableActions:YES];
                [labelLayer setPosition:CGPointMake(_center.x+(halfRadius*cos(interpolatedMidAngle)), _center.y+(halfRadius*sin(interpolatedMidAngle)))];
                [CATransaction   setDisableActions:NO];
                
            }
        }else if(_chartStyle==HLChartViewStyleLine){
            CAShapeLayer *lineLayer = (CAShapeLayer *)obj;
            NSRange substr=[lineLayer.name rangeOfString:@"line_"];
            if (substr.length==5) {
                int index=[[lineLayer valueForKey:kHLLineLayerPoints] intValue];
                int lastIndex=[[lineLayer valueForKey:kHLLineLayerLastIndex]intValue];
                int numberOfRows=[self.dataSource chartView:self numberOfRowsInSection:index];
                CGMutablePathRef path=CGPathCreateMutable();
                if (lastIndex>numberOfRows) {
                    lastIndex=numberOfRows;
                }
                for (int points=0; points<lastIndex; points++) {
                    CGPoint p=[self calculateForVertivalHeight:[self.dataSource chartView:self valueForChartViewAtIndex:points section:index] withNumberOfSection:index atRowIndex:points];
                    if (points==0) {
                        CGPathMoveToPoint(path, NULL, p.x, p.y);
                    }
                    else{
                        CGPathAddLineToPoint(path, NULL, p.x, p.y);
                    }
                }    
                
                lastIndex++;
                [lineLayer setValue:[NSNumber numberWithInt:lastIndex] forKey:kHLLineLayerLastIndex];
                [obj setPath:path];
                CFRelease(path);
            }
            
        }
    }];
    
}

-(void)animationDidStart:(CAAnimation *)anim
{
    if (_animationTimer==nil) {
        static float   timeInterval=1.0/60.0;
        _animationTimer=[NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];
    }
    [_animations addObject:anim];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_animations removeObject:anim];
    if ([_animations count]==0) {
        [_animationTimer invalidate];
        _animationTimer=nil;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!isTouch) {
        [_delegate clickCharkView:self];
        return;
    }
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    __block NSInteger   selectedIndex=-1;
    
    CGAffineTransform   transform=CGAffineTransformIdentity;
    
    __block float   itemValue=0.0;
    //隐藏数据数量
    __block  BOOL   isReloadData=false;
    
    CALayer *parentLayer=[self layer];
    NSArray *pieLayers=[parentLayer sublayers];
    [pieLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *pieLayer = (CAShapeLayer *)obj;
        CGPathRef path = [pieLayer path];
//        NSLog(@"+++++  %d %@",idx,pieLayer);
       // NSLog(@"move idx:%d %f,%f w:%f h:%f x:%f y:%f =%@",idx,pieLayer.position.x,pieLayer.position.y,pieLayer.bounds.size.width,pieLayer.bounds.size.height,point.x,point.y,pieLayer.name);
        //饼图
        if (_chartStyle==HLChartViewStylePie) {
            if (CGPathContainsPoint(path, &transform, point, 0)) {
                [pieLayer setLineWidth:2.0];
                [pieLayer setStrokeColor:[UIColor whiteColor].CGColor];
                
                [pieLayer setZPosition:MAXFLOAT];
                selectedIndex = idx;
            } else {
                [pieLayer setZPosition:kDefaultSliceZOrder];
                [pieLayer setLineWidth:0.0];
            }
        }else if(_chartStyle==HLChartViewStyleBar){
            if (point.x>pieLayer.position.x&&point.x<(pieLayer.bounds.size.width+pieLayer.position.x)&&point.y<pieLayer.position.y&&point.y>(pieLayer.position.y-pieLayer.bounds.size.height)) {
                [pieLayer setLineWidth:1.0];
                [pieLayer setStrokeColor:[UIColor lightGrayColor].CGColor];
                itemValue=[[pieLayer valueForKey:kHLChartViewItemValue] floatValue];
                selectedIndex=idx;
               
            }else{
                if (pieLayer.name) {
                    //NSLog(@"===--------00000========%@",pieLayer.name);
                }else{
                    [pieLayer setLineWidth:0.0];
                }
            }
        }else if(_chartStyle==HLChartViewStyleLine){
            if (CGPathContainsPoint(path, &transform, point, 0)) {
//                NSLog(@"move idx:%d %f,%f w:%f h:%f x:%f y:%f =%@",idx,pieLayer.position.x,pieLayer.position.y,pieLayer.bounds.size.width,pieLayer.bounds.size.height,point.x,point.y,pieLayer.name);
                NSRange substr=[pieLayer.name rangeOfString:@"touch_"];
                if (substr.length==6) {
                    CAShapeLayer *lineLayer=(CAShapeLayer*)[[pieLayer sublayers]objectAtIndex:1];
                    [lineLayer setStrokeColor:[[UIColor redColor] CGColor]];
                    [lineLayer setLineWidth:1.0];
                    [lineLayer setLineDashPattern:nil];
                    CATextLayer *textLayer=(CATextLayer*)[[pieLayer sublayers]objectAtIndex:0];
//                    CGSize size=[self sizeThatFitsString:textLayer.string fontSize:_legendFontSize];
                    [textLayer setBackgroundColor:[UIColor redColor].CGColor];
//                    NSLog(@"======++++++++++++++++====== %f  %f  %f  %f",textLayer.frame.origin.x,textLayer.frame.origin.y,textLayer.frame.size.width,textLayer.frame.size.height);
//                    [textLayer setBounds:CGRectMake(0, -2, size.width, size.height)];
                    [textLayer setCornerRadius:4.0f];
                    CAShapeLayer *tLayer=(CAShapeLayer*)[[pieLayer sublayers]objectAtIndex:2];
                    [tLayer setFillColor:[UIColor redColor].CGColor];
                    selectedIndex=idx; 
                }
                //点击legend
                substr=[pieLayer.name rangeOfString:@"touchlegend_"];
                if (substr.length==12) {
//                    NSLog(@"----------%@ %d  %@",pieLayer.name,[[pieLayer valueForKey:kHLChartViewItemIndex] integerValue],[pieLayer valueForKey:kHLChartViewItemName]);
                    [self addHideData:[[pieLayer valueForKey:kHLChartViewItemIndex] intValue] title:[pieLayer valueForKey:kHLChartViewItemName]];
                    isReloadData=YES;//重新加载数据
                    *stop=YES;
                }
                
            }else{
                NSRange substr=[pieLayer.name rangeOfString:@"touch_"];
                if (substr.length==6) {
                    CAShapeLayer *lineLayer=(CAShapeLayer*)[[pieLayer sublayers]objectAtIndex:1];
                    [lineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:4],[NSNumber numberWithInt:2],nil]];
                    [lineLayer setLineWidth:0.5];
                    [lineLayer setStrokeColor:[[UIColor lightGrayColor] CGColor]];
                    CATextLayer *textLayer=(CATextLayer*)[[pieLayer sublayers]objectAtIndex:0];
                    [textLayer setBackgroundColor:NULL];
                    CAShapeLayer *tLayer=(CAShapeLayer*)[[pieLayer sublayers]objectAtIndex:2];
                    [tLayer setFillColor:NULL];
                }
                
            }
        }
    }];
    if (isReloadData) {
        [self reloadLineData];
    }else{
        [self drawTopItemValue:selectedIndex point:point];
        [self maybeNotifyDelegateOfSelectionChangeFrom:_selectedIndex to:selectedIndex];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesCancelled:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CALayer *parentLayer=[self layer];
    NSArray *pieLayers=[parentLayer sublayers];
    if (_chartStyle==HLChartViewStylePie) {
        for (CAShapeLayer *pieLayer in pieLayers) {
            [pieLayer setZPosition:kDefaultSliceZOrder];
            [pieLayer setLineWidth:0.0];
        }
    }
}

#pragma mark - 添加隐藏数据
-(void)addHideData:(int)index title:(NSString*)aString
{
    BOOL isExist=false;
    for (id obj in _hideDatas) {
        NSDictionary *dic=(NSDictionary*)obj;
        if ([[dic objectForKey:@"title"] isEqualToString:aString]) {
            [_hideDatas removeObject:obj];
            isExist=true;
            break;
        }
    }
    if (!isExist) {
        [_hideDatas addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"index",aString,@"title", nil]];
    }
}

//排序
void sort(double array[],int zz,int yy)
{
    int z,y;
    double k;
    if(zz<yy)
    {
        z=zz;
        y=yy;
        k=array[z];
        do  {
            while((z<y)&&(array[y]>=k))
                y--;
            if(z<y)          //右边的元素小于k，移到k左
            {
                array[z]=array[y];
                z=z+1;
            }
            while((z<y)&&(array[z])<=k)
                z++; 
            if(z<y)             //左边的元素大于k，移动右边
            {
                array[y]=array[z];
            }
            
        } while(z!=y);
        array[z]=k;
        sort(array,zz,z-1);
        sort(array,z+1,yy);
    }
}

#pragma mark - 点击弹出值层
-(void)drawTopItemValue:(NSInteger)index point:(CGPoint)point
{
    if (index==-1) {
        for (CAShapeLayer *pLayer in [[self layer] sublayers]) {
            if ([pLayer.name isEqualToString:@"itemValue"]) {
                [pLayer removeFromSuperlayer];
            }
        }
        [_delegate clickCharkView:self];
    }
    
    CALayer *parentLayer=[self layer];
    [parentLayer setContentsScale:[UIScreen mainScreen].scale];
    NSArray *layers=[parentLayer sublayers];
    if (index>[layers count]) {
        return;
    }
//    NSLog(@"drawTopItemValue %d",index);
    CAShapeLayer *pieLayer=[layers objectAtIndex:index];
    float itemValue=[[pieLayer valueForKey:kHLChartViewItemValue] floatValue];
    for (CAShapeLayer *pLayer in layers) {
        if ([pLayer.name isEqualToString:@"itemValue"]) {
            [pLayer removeFromSuperlayer];
        }else{
            //竖线值还原
            NSRange substr=[pLayer.name rangeOfString:@"ver_"];
            if (substr.length==4) {
                [pLayer setLineWidth:0.5];
                CATextLayer *textLayer=[[pLayer sublayers]objectAtIndex:0];
                [textLayer setBackgroundColor:NULL];
            }
        }
    }
    if (itemValue>0) {
        if (_chartStyle==HLChartViewStyleBar) {
            CGRect rect=CGRectMake(0,0, 60, 30);
            UIBezierPath *itemPath;
            itemPath=[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5.0f];
            
            CAShapeLayer *itemLayer=[CAShapeLayer layer];
            [itemLayer setContentsScale:[UIScreen mainScreen].scale];
            [itemLayer setFillColor:[pieLayer fillColor]];
            [itemLayer setStrokeColor:NULL];
            [itemLayer setPath:itemPath.CGPath];
            [itemLayer setPosition:CGPointMake(pieLayer.position.x+pieLayer.bounds.size.width/2-30, point.y-15)];
            
            CATextLayer *textLayer=[CATextLayer layer];
            [textLayer setContentsScale:[UIScreen mainScreen].scale];
            CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont boldSystemFontOfSize:16.0]fontName]);
            [textLayer setFont:font];
            CFRelease(font);
            [textLayer setFontSize:16.0];
            [textLayer setAlignmentMode:kCAAlignmentCenter];
            [textLayer setForegroundColor:[UIColor whiteColor].CGColor];
            
            CGSize size=[self sizeThatFitsString:[NSString stringWithFormat:@"%f",itemValue] fontSize:16.0];
            [textLayer setString:[NSString stringWithFormat:@"%0.0f",itemValue]];
            [textLayer setFrame:CGRectMake(0, 0, rect.size.width, size.height)];
            [textLayer setPosition:CGPointMake(rect.size.width/2,size.height-5)];
            
            [itemLayer addSublayer:textLayer];
            itemLayer.name=@"itemValue";
            [parentLayer addSublayer:itemLayer];
        }else{
        //line值 
           // NSLog(@"====top idx:%d %f,%f w:%f h:%f =%@ px:%f py:%f %d",index,pieLayer.position.x,pieLayer.position.y,pieLayer.bounds.size.width,pieLayer.bounds.size.height,pieLayer.name,[[pieLayer valueForKey:kHLChartViewPointX] floatValue],[[pieLayer valueForKey:kHLChartViewPointY] floatValue],[[pieLayer valueForKey:kHLChartViewItemIndex] intValue]);
            //设置点为空心圆
            NSString *pIndex=[NSString stringWithFormat:@"%d",[[pieLayer valueForKey:kHLChartViewItemIndex] intValue]-1];
            [_sortLayers removeAllObjects];
            for (CAShapeLayer *pointLayer in layers) {
                if (pointLayer.name) {
                    NSRange substr=[pointLayer.name rangeOfString:@"point_"];
                    if (substr.length==6) {
                        NSString *section=[pointLayer.name substringFromIndex:substr.length];
                        if ([section isEqualToString:pIndex]) {
                            [pointLayer setFillColor:NULL];
                            [_sortLayers addObject:pointLayer];
                        }else{
                            [pointLayer setFillColor:pointLayer.strokeColor];
                        }
                    }
                }
            }
            
            [_sortLayers sortUsingFunction:layerSortByPointY context:nil];
            float yH=(self.bounds.size.height-Y_GRIDLINE_OFFSET*2-25-_legendHeight)/[_sortLayers count];
            
//            NSLog(@" 当前point 数量:%d  %f %f %f",[_sortLayers count],(self.bounds.size.height-Y_GRIDLINE_OFFSET-self.itemTitleHeight-_legendHeight),self.itemTitleHeight, yH);
            
            float x=0.0;
            float y=0.0;
            float rectY=0.0;
            float lastHeight=0.0;
            CGRect rect; 
            CAShapeLayer *itemLayer=[CAShapeLayer layer];
            [itemLayer setContentsScale:[UIScreen mainScreen].scale];
           
            for (int index=0; index<[_sortLayers count]; index++) {
                CAShapeLayer   *pLayer=(CAShapeLayer*)[_sortLayers objectAtIndex:index];
                x=[[pLayer valueForKey:kHLChartViewPointX] floatValue];
                y=[[pLayer valueForKey:kHLChartViewPointY] floatValue];
                rectY=yH*index+25+Y_GRIDLINE_OFFSET;
//                rect=CGRectMake(x+20, y-20, 100, 25);
                rect=CGRectMake(x+20, rectY, 100, 20);
                
//                NSLog(@"当前点 %d   %@ x:%f  y:%f",index,[pLayer valueForKey:kHLChartViewItemName],x,y);
                if (x>self.frame.size.width/2) {
//                    rect=CGRectMake(x-120, y-20, 100, 25);
                    rect=CGRectMake(x-120, rectY, 100, 20);
                }
                
                if (lastHeight>y-20) {
                    rect=CGRectMake(rect.origin.x, lastHeight+5, 100, 20);
                }
                
                CGMutablePathRef path=CGPathCreateMutable();
                CGPathMoveToPoint(path, NULL, x, y);
                if (x>self.frame.size.width/2) {
                    CGPathAddLineToPoint(path, NULL, x-21, rect.origin.y+10);
                    CGPathAddLineToPoint(path, NULL, x-21, rect.origin.y+15);
                }else{
                    CGPathAddLineToPoint(path, NULL, rect.origin.x+1, rect.origin.y+10);
                    CGPathAddLineToPoint(path, NULL, rect.origin.x+1, rect.origin.y+15);
                }
                CAShapeLayer *triangleLayer=[CAShapeLayer layer];
                [triangleLayer setContentsScale:[UIScreen mainScreen].scale];
                [triangleLayer setFillColor:[pLayer strokeColor]];
                [triangleLayer setStrokeColor:NULL];
                [triangleLayer setPath:path];
                [triangleLayer setPosition:CGPointMake(0,0)];
                
                
                UIBezierPath *rectPath;
                rectPath=[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:6.0];
                
                CAShapeLayer *iLayer=[CAShapeLayer layer];
                [iLayer setContentsScale:[UIScreen mainScreen].scale];
                [iLayer setFillColor:[pLayer strokeColor]];
                [iLayer setStrokeColor:NULL];
                [iLayer setPath:rectPath.CGPath];
                [iLayer setPosition:CGPointMake(0,0)];
                
                CATextLayer *textLayer=[CATextLayer layer];
                [textLayer setContentsScale:[UIScreen mainScreen].scale];
                CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont systemFontOfSize:12.0]fontName]);
                [textLayer setFont:font];
                CFRelease(font);
                [textLayer setFontSize:12.0];
                [textLayer setAlignmentMode:kCAAlignmentLeft];
                [textLayer setForegroundColor:[UIColor whiteColor].CGColor];
                
                CGSize size=[self sizeThatFitsString:[NSString stringWithFormat:@"%@%@",[pLayer valueForKey:kHLChartViewItemName],[pLayer valueForKey:kHLChartViewItemValue]] fontSize:12];
                [textLayer setString:[NSString stringWithFormat:@"%@%@",[pLayer valueForKey:kHLChartViewItemName],[pLayer valueForKey:kHLChartViewItemValue]]];
                [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
                [textLayer setPosition:CGPointMake(rect.origin.x+rect.size.width/2,rect.origin.y+rect.size.height/2+4)];
                [iLayer addSublayer:textLayer];
                
                [iLayer addSublayer:triangleLayer];
                
                [itemLayer  addSublayer:iLayer];
                
                lastHeight=rect.origin.y+rect.size.height;
            }
            
            itemLayer.name=@"itemValue";
            [parentLayer addSublayer:itemLayer];

        }
    }
}

-(void)maybeNotifyDelegateOfSelectionChangeFrom:(NSInteger)previousSelection to:(NSUInteger)newSelection
{
    if (previousSelection!=newSelection) {
        if (previousSelection!=-1) {
            [_delegate chartView:self willDeselectAtIndex:previousSelection];
        }
        _selectedIndex=newSelection;
        if (newSelection!=-1) {
            [_delegate chartView:self willSelectAtIndex:newSelection];
            if (previousSelection!=-1) {
                [_delegate chartView:self didDeselectAtIndex:previousSelection];
            }
            [_delegate chartView:self didSelectAtIndex:newSelection];
        }else{
            if (previousSelection!=-1) {
                [_delegate chartView:self didDeselectAtIndex:previousSelection];
            }
        }
    }
}

-(CAShapeLayer*)createPieLayerWithColor:(UIColor *)color
{
    CAShapeLayer *pieLayer=[CAShapeLayer layer];
    [pieLayer setContentsScale:[UIScreen mainScreen].scale];
    [pieLayer setZPosition:kDefaultSliceZOrder];
    [pieLayer setFillColor:color.CGColor];
    [pieLayer setStrokeColor:NULL];
    [pieLayer setShadowRadius:2.0];
    float fsize=17.0;
    if (!isTouch) {
        fsize=12.0;
    }
    
    CATextLayer *textLayer=[CATextLayer layer];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)[[UIFont boldSystemFontOfSize:fsize]fontName]);
    [textLayer setFont:font];
    CFRelease(font);
    
    [textLayer setFontSize:fsize];
    [textLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    CGSize size=[self sizeThatFitsString:@"N/A" fontSize:fsize];
    CGFloat halfRadius=(_radius/2);
    [CATransaction setDisableActions:YES];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [textLayer setPosition:CGPointMake(_center.x+(halfRadius*cos(0)), _center.y+(halfRadius*sin(0)))];
    [CATransaction  setDisableActions:NO];
    [pieLayer addSublayer:textLayer];
    return pieLayer;
}

-(CGSize)sizeThatFitsString:(NSString *)string fontSize:(float)fSize
{
    if (_labelForString==nil) {
        _labelForString=[[UILabel alloc]init];
        [_labelForString setFont:[UIFont boldSystemFontOfSize:fSize]];
    }
    [_labelForString setText:string];
    CGSize size=[_labelForString sizeThatFits:CGSizeZero];
    [_labelForString setText:nil];
    return size;
}

-(void)updateLabelForLayer:(CAShapeLayer *)pieLayer value:(CGFloat)value
{
    float fsize=17.0;
    if (!isTouch) {
        fsize=12.0;
    }
    NSString *label=[NSString stringWithFormat:@"%0.0f%%",value];
    CGSize size=[self sizeThatFitsString:label fontSize:fsize];
    CATextLayer *textLayer=[[pieLayer sublayers]objectAtIndex:0];
    [textLayer setString:label];
    [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
}



@end


@implementation HLArcLayerDefaultAnimationDelegate

@synthesize chartView=_chartView;

- (id<CAAction>)createArcAnimation:(CALayer *)layer withKeyPath:(NSString *)keyPath
{
    CABasicAnimation *arcAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
    
    NSNumber *modelAngle = [layer valueForKey:keyPath];
    NSNumber *currentAngle = [[layer presentationLayer] valueForKey:keyPath];
    NSComparisonResult result = [modelAngle compare:currentAngle];
    if (result != NSOrderedSame) {
        [arcAnimation setFromValue:currentAngle];
    } else {
//        NSLog(@"===== ------ ++++++ %@",[layer valueForKey:keyPath]);
        if ([layer valueForKey:keyPath])
            [arcAnimation setFromValue:[layer valueForKey:keyPath]];
    }
    
    [arcAnimation setDelegate:_chartView];
    [arcAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    return arcAnimation;
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
//    NSLog(@"actionForLayer =%@",event);
    if ([kHLArcLayerEndAngle isEqual:event]) {
        return [self createArcAnimation:layer withKeyPath:event];
    } else if ([kHLArcLayerStartAngle isEqual:event]) {
        return [self createArcAnimation:layer withKeyPath:event];
    } else if([kHLLineLayerPoints isEqual:event]){
        return [self createArcAnimation:layer withKeyPath:event];
    }else {
        return nil;
    }
}

@end


@implementation HLArcLayerAddAnimationDelegate
@synthesize chartView=_chartView;

-(id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
//    NSLog(@"actionForLayer ==  %@",event);
    if ([kHLArcLayerStartAngle isEqualToString:event]) {
        CABasicAnimation *startAngleAnimation=[CABasicAnimation  animationWithKeyPath:kHLArcLayerStartAngle];
        [startAngleAnimation setFromValue:[layer valueForKey:kHLArcLayerEndAngle]];
        [startAngleAnimation setToValue:[layer valueForKey:kHLArcLayerStartAngle]];
         
        [startAngleAnimation setDelegate:_chartView];
        [startAngleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        return startAngleAnimation;
    }else{
        return nil;
    }
}

@end
