//
//  ChartView.m
//  GrpCust
//
//  Created by  on 11-11-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ChartView.h"
#import "ColorUtils.h"
#import "SBJSON.h"
#import "DBConnection.h"
#import "StringUtil.h"

static NSInteger sortByMaxValue(id a,id b,void *context){
    double aD=[a doubleValue];
    double bD=[b doubleValue];
    
    int diff=aD-bD;
    if (diff>0) {
        return 0;
    }else if(diff<0){
        return 2;
    }else{
        return 1;
    }
}

@interface ChartView()<HLChartViewDataSource,HLChartViewDelegate> {

    NSMutableArray  *slices;
    
    NSMutableArray  *_allValues;
    
    BOOL            _showTitle;
    
}
-(void)loadData;

@end

@implementation ChartView
@synthesize headerArray,dataArray;
@synthesize curRecord;
@synthesize chartStyle=_chartStyle;
@synthesize chartView=_chartView;
@synthesize requestUrl=_requestUrl;
@synthesize delegate=_delegate;

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    dataArray=[[NSMutableArray  alloc]init];
    headerArray=[[NSMutableArray alloc]init];
    slices=[[NSMutableArray alloc]init];
    
    _allValues=[[NSMutableArray alloc]init];
    
    overlayView=[[OverlayView alloc]initWithFrame:frame];
    [overlayView setMessage:@"" spinner:false];
    
    _showTitle=YES;
    return self;
}

-(void)setChartViewTitle:(NSString *)title isTouch:(BOOL)touch showLegend:(BOOL)isLegend
{
     NSLog(@"%@:%@  w:%f  h:%f",[self class],NSStringFromSelector(_cmd),self.frame.size.width,self.frame.size.height);
    if (title==nil) {
        _showTitle=NO;
    }
    _chartView=[[HLChartView alloc]initWithFrame:self.frame style:HLChartViewStyleBar];
    _chartView.delegate=self;
    _chartView.dataSource=self;
    _chartView.title=title;
    _chartView.isTouch=touch;
    [self addSubview:_chartView];
    _chartView.isShowLegend=isLegend;
    //[_chartView reloadData];
  
    [overlayView setFrame:self.frame];
//    [self loadData];
}


-(void)setChartStyle:(HLChartViewStyle)chartStyle
{
    _chartStyle=chartStyle;
    _chartView.chartStyle=chartStyle;
}

-(void)loadData
{
    if (_requestUrl==nil) {
        _requestUrl=@"http://hlterm.oicp.net/iosweb/bar_dark.txt";
    }else{
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"J20GS001" forKey:@"user_id"];
        [dict setObject:[[UIDevice currentDevice]uniqueIdentifier] forKey:@"imei"];
        [dict setObject:@"0" forKey:@"type"];
        [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"jurisdiction"] forKey:@"jurisdiction"];
        NSError *error=nil;
        NSData *djson=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *params=[[NSString alloc]initWithData:djson encoding:NSUTF8StringEncoding];
        NSRange rang=[_requestUrl rangeOfString:@"?"];
        if (rang.length==0) {
            _requestUrl=[_requestUrl stringByAppendingFormat:@"?params=%@",[params encodeAsURIComponent]];
        }
    }
    NSData *data=[DBConnection getJsonData:_requestUrl pdate:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"] flag:false];
    if (data) {
        [self parserData:data];
        return;
    }
    [overlayView setMessage:@"正努力加载中..." spinner:true];
    [self addSubview:overlayView];
    
    NSLog(@"chartView loadData %@   %@",_requestUrl,_chartView.title);
    _request=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:_requestUrl]];
    [_request setTimeOutSeconds:120];
    _request.delegate=self;
    [_request startAsynchronous];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [overlayView removeFromSuperview];
    [DBConnection insertJsonData:_requestUrl pdate:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"] json:[request responseData] filter:[request responseData]];
    [self parserData:[request responseData]];
   
//    [self reAdjustLayout];
}

-(void)parserData:(NSData *)data
{
    NSString *result=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"%@",result);
    SBJsonParser    *parser     = [[SBJsonParser alloc] init];
    id  obj = [parser objectWithString:result];
    
    [slices removeAllObjects];
    [headerArray removeAllObjects];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic=(NSDictionary*)obj;
        NSArray *array=(NSArray*)[dic objectForKey:@"graphset"];
        for (int i=0; i<[array count]; ++i) {
            NSDictionary *dc=(NSDictionary*)[array objectAtIndex:i];
            if (![dc isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            NSString *type=[dc objectForKey:@"type"];
            id titleDict=[dc objectForKey:@"title"];
            if ([titleDict isKindOfClass:[NSDictionary class]]) {
                if (_showTitle)
                    _chartView.title=[NSString stringWithFormat:@"%@",[titleDict objectForKey:@"text"]];
            }
            // NSLog(@"%@",type);
            NSArray *series=(NSArray*)[dc objectForKey:@"series"];
            for (int j=0; j<[series count]; j++) {
                NSDictionary *dd=(NSDictionary*)[series objectAtIndex:j];
                if (![dd isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                [slices addObject:dd];
            }
            
            NSDictionary *scale=[dc objectForKey:@"scale-x"];
            if (![scale isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            NSArray *scaleX=(NSArray*)[scale objectForKey:@"values"];
            for (int k=0; k<[scaleX count]; k++) {
                [headerArray addObject:[scaleX objectAtIndex:k]];
            }
            
            if ([type isEqualToString:@"line"]) {
                _chartView.chartStyle=HLChartViewStyleLine;
            }else if([type isEqualToString:@"bar"]){
                _chartView.chartStyle=HLChartViewStyleBar;
            }else if([type isEqualToString:@"mixed"]){
                _chartView.chartStyle=HLChartViewStyleMixed;
            }else{
                _chartView.chartStyle=HLChartViewStylePie;
            }
        }
    }
    _chartView.frame=self.frame;
    NSLog(@"%@:%@  w:%f  h:%f   %f  %f",[self class],NSStringFromSelector(_cmd),_chartView.frame.size.width,_chartView.frame.size.height,self.frame.size.width,self.frame.size.height);

    [self reloadData];
}

-(void)reloadData
{
    if ([slices count]>0) {
        [_allValues removeAllObjects];
        for (int i=0; i<[slices count]; i++) {
            NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:i];
            if ([dic isKindOfClass:[NSDictionary class]]) {
                NSArray *vs=(NSArray*)[dic objectForKey:@"values"];
                for (int j=0; j<[vs count]; j++) {
                   [_allValues addObject:[vs objectAtIndex:j]];
                }
            }
        }
        [_allValues sortUsingFunction:sortByMaxValue context:nil];
        
        [_chartView reloadData];
    }else{
        [self loadData];
    }
}

#pragma mark - HLCharViewDataSource

-(CGFloat)chartView:(HLChartView *)chartView valueForChartView:(NSInteger)index
{
    double  result=0.0;
    NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:index];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSArray *vs=(NSArray*)[dic objectForKey:@"values"];
        for (int i=0; i<[vs count]; i++) {
            result=result+[[vs objectAtIndex:i] doubleValue];
        }
    }
    return result;
  //  return [[slices objectAtIndex:index]doubleValue];
}

-(UIColor*)chartView:(HLChartView *)pieView colorForChartView:(NSInteger)index
{
    NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:index];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString  *color=[dic objectForKey:@"line-color"];
        if ([color length]>0) {
            return [UIColor colorWithHexString:color];
        }
        color=[dic objectForKey:@"background-color"];
        if ([color length]>0) {
            return [UIColor colorWithHexString:color];
        }
    }
    return [UIColor blackColor];
}

-(NSInteger)numberOfSectionsInChartView:(HLChartView *)chartView
{
    return [slices count];
}

-(NSInteger)numberOfSectionsInChartView:(HLChartView *)chartView type:(NSString *)type
{
    NSInteger index=0;
    for (NSDictionary *dic in slices) {
        if ([[dic objectForKey:@"type"] isEqualToString:type]) {
            index++;
        }
    }
    return index;
}



-(float)maxVerticalValueInChartView:(HLChartView *)chartView filter:(NSMutableArray *)aDict
{
    [self filterValues:aDict];
    if ([_allValues count]>0) {
        return [[_allValues objectAtIndex:0]floatValue ]+5;
    }

    return 50.0;
}

-(float)maxVerticalValueInChartView:(HLChartView *)chartView filter:(NSMutableArray *)aDict type:(NSString *)type
{
    [self filterValues:aDict type:type];
    if ([_allValues count]>0) {
        return [[_allValues objectAtIndex:0]floatValue ]+5;
    }
    return 50.0;
}

-(float)minVerticalValueInChartView:(HLChartView *)chartView filter:(NSMutableArray*)aDict
{
    [self filterValues:aDict];
    if ([_allValues count]>0) {
        NSInteger num=[_allValues count];
        return [[_allValues objectAtIndex:num-1] floatValue];
    }
    return 0.0;
}

-(float)maxHorizontalValueInChartView:(HLChartView *)chartView
{
    return [headerArray count];
}

-(float)chartView:(HLChartView *)chartView valueForChartViewAtIndex:(NSInteger)index section:(NSInteger)section
{
    NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:section];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSArray *vs=(NSArray*)[dic objectForKey:@"values"];
        NSLog(@"valueForChartViewAtIndex %d  %d  %f",index,section,[[vs objectAtIndex:index] floatValue]);
        return [[vs objectAtIndex:index] floatValue];
    }
    return 0.0;
}

-(float)chartView:(HLChartView *)chartView value2ForChartViewAtIndex:(NSInteger)index section:(NSInteger)section
{
    NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:section];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSArray *vs=(NSArray*)[dic objectForKey:@"values2"];
        NSLog(@"value2ForChartViewAtIndex %d  %d  %f",index,section,[[vs objectAtIndex:index] floatValue]);
        return [[vs objectAtIndex:index] floatValue];
    }
    return 0.0;
}

-(CGFloat)chartView:(HLChartView *)chartView valueForChartViewAtIndex:(NSInteger)index section:(NSInteger)section type:(NSString *)type
{
    NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:section];
    if ([[dic objectForKey:@"type"] isEqualToString:type]) {
        NSArray *vs=(NSArray*)[dic objectForKey:@"values"];
//        NSLog(@"valueForChartViewAtIndex %d  %d %@ %f",index,section,type,[[vs objectAtIndex:index] floatValue]);
        return [[vs objectAtIndex:index] floatValue];
    }
    return 0.0;
}

-(NSString*)chartView:(HLChartView *)chartView typeForChartView:(NSInteger)index
{
    NSString   *type=@"line";
    NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:index];
    type=[dic objectForKey:@"type"];
    return type;
}

-(NSInteger)chartView:(HLChartView *)chartView numberOfRowsInSection:(NSInteger)section
{
    return [headerArray count];
}

-(NSString*)chartView:(HLChartView *)chartView legendOfTitleInSection:(NSInteger)section
{
    NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:section];
    if ([dic isKindOfClass:[NSDictionary class]]) {
       NSString  *val=(NSString*)[dic objectForKey:@"text"];
        return val;
    }
    return @"";

}
//底部X轴标签值

-(NSString*)chartView:(HLChartView *)chartView scaleXTitleForChartView:(NSInteger)section
{
    return [headerArray objectAtIndex:section];
}

#pragma mark - HLChartViewDelegate
-(void)chartView:(HLChartView *)chartView didDeselectAtIndex:(NSInteger)index
{
    // NSLog(@"didDeselectAtIndex: %d", index);
}
-(void)chartView:(HLChartView *)chartView didSelectAtIndex:(NSInteger)index
{
    //NSLog(@"didSelectAtIndex: %d", index);
}
-(void)chartView:(HLChartView *)chartView willDeselectAtIndex:(NSInteger)index
{
    //NSLog(@"willDeselectAtIndex: %d", index);
}
-(void)chartView:(HLChartView *)pieView willSelectAtIndex:(NSInteger)index
{
     //NSLog(@"WillSelectAtIndex: %d", index);
}


-(void)clickCharkView:(HLChartView *)chartView
{
    NSLog(@"%@",[chartView title]);
}

-(void)chartDidLoadFinish:(BOOL)flag
{
    [_delegate chartDidLoadFinish:flag];
}

#pragma mark - 过滤数据
-(void)filterValues:(NSMutableArray*)aDict
{
    [_allValues removeAllObjects];
    for (int i=0; i<[slices count]; i++) {
        NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:i];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *title=[dic objectForKey:@"text"];
            BOOL isExist=[self isHideValue:title filter:aDict];
            if (!isExist) {
                NSArray *vs=(NSArray*)[dic objectForKey:@"values"];
                for (int j=0; j<[vs count]; j++) {
                    [_allValues addObject:[vs objectAtIndex:j]];
                }
            }
        }
    }
    [_allValues sortUsingFunction:sortByMaxValue context:nil];
}

-(void)filterValues:(NSMutableArray*)aDict type:(NSString*)type
{
    [_allValues removeAllObjects];
    for (int i=0; i<[slices count]; i++) {
        NSDictionary *dic=(NSDictionary*)[slices objectAtIndex:i];
        if ([[dic objectForKey:@"type"] isEqualToString:type]) {
            NSString *title=[dic objectForKey:@"text"];
            BOOL isExist=[self isHideValue:title filter:aDict];
            if (!isExist) {
                NSArray *vs=(NSArray*)[dic objectForKey:@"values"];
                for (int j=0; j<[vs count]; j++) {
                    [_allValues addObject:[vs objectAtIndex:j]];
                }
            }
        }
    }
    [_allValues sortUsingFunction:sortByMaxValue context:nil];
}

-(BOOL)isHideValue:(NSString*)aTitle filter:(NSMutableArray*)aDict
{
    BOOL    isExist=false;
    for (id obj in aDict) {
        NSDictionary *dic=(NSDictionary*)obj;
        if ([[dic objectForKey:@"title"] isEqualToString:aTitle]) {
            isExist=true;
            continue;
        }
    }
    return isExist;
}

-(void)reAdjustLayout
{
    [_chartView setFrame:CGRectMake(0.0, 0.0, 480.0, 320.0)];
//    NSLog(@"new: %f %f %f %f height:%f",_chartView.frame.origin.x,_chartView.frame.origin.y,_chartView.frame.size.width,_chartView.frame.size.height,self.frame.size.height);
}

@end
