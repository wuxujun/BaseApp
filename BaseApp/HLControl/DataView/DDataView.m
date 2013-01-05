//
//  DDataView.m
//  GrpCust
//
//  Created by  on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DDataView.h"
#import "SBJSON.h"

@interface DDataView(){

    NSMutableArray   *_dataArray;
    NSMutableArray   *_headerArray;
}
-(void)initGridView;

@end

@implementation DDataView
@synthesize gridView=_gridView;
@synthesize message;

-(id)initWithFrame:(CGRect)frame
{
    if(![super initWithFrame:frame]){
        return nil;
    }
    
    [self initGridView];
    return self;
}

-(void)awakeFromNib
{
    [self initGridView];
}

-(void)initGridView
{
    _dataArray=[[NSMutableArray alloc]init];
    _headerArray=[[NSMutableArray alloc]init];
    _gridView=[[HLDataView alloc]initWithFrame:self.bounds];
    _gridView.autoresizingMask=self.autoresizingMask;
    _gridView.backgroundColor=[UIColor whiteColor];
    _gridView.delegate=self;
    _gridView.dataSource=(id<HLDataViewDataSource>)self;
    [self addSubview:_gridView];
}

-(void)reloadData
{
    if (!message) {
        return;
    }
    NSData *data=[DBConnection getJsonData:message.dataUrl pdate:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentDate"] flag:false];
    if (data) {
        NSString *result=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        SBJsonParser    *parser     = [[SBJsonParser alloc] init];
        id  obj = [parser objectWithString:result];
        
        [_dataArray removeAllObjects];
        [_headerArray removeAllObjects];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic=(NSDictionary*)obj;
            NSArray *array=(NSArray*)[dic objectForKey:@"graphset"];
            for (int i=0; i<[array count]; ++i) {
                NSDictionary *dc=(NSDictionary*)[array objectAtIndex:i];
                if (![dc isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSString *type=[dc objectForKey:@"type"];
                // NSLog(@"%@",type);
                NSArray *series=(NSArray*)[dc objectForKey:@"series"];
                for (int j=0; j<[series count]; j++) {
                    NSDictionary *dd=(NSDictionary*)[series objectAtIndex:j];
                    if (![dd isKindOfClass:[NSDictionary class]]) {
                        continue;
                    }
                    [_dataArray addObject:dd];
                }
                
                NSDictionary *scale=[dc objectForKey:@"scale-x"];
                if (![scale isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSArray *scaleX=(NSArray*)[scale objectForKey:@"values"];
                for (int k=0; k<[scaleX count]; k++) {
                    [_headerArray addObject:[scaleX objectAtIndex:k]];
                }
                
            }
        }

    }
    
    [_gridView reloadData];
}

#pragma mark - HLDataViewDelegate
-(void)dataView:(HLDataView *)dataView selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex
{
    NSLog(@"selectionMadeAtRow %d_%d",rowIndex,columnIndex);
}

#pragma mark - HLDataViewDateSource
-(CGFloat)dataView:(HLDataView *)dataView heightForRow:(NSInteger)rowIndex
{
    return 40.0f;
}

-(CGFloat)dataView:(HLDataView *)dView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex
{
    int column=[_headerArray count];
    if ([_dataArray count]>0) {
        column=[_headerArray count]+1;
    }
    return roundf(dView.frame.size.width/column) ;
}

-(NSInteger)numberOfRowsInDataView:(HLDataView *)dataView
{
    if ([_headerArray count]>0) {
        return [_dataArray count]+1;
    }
    return [_dataArray count];
}

-(NSInteger)numberOfColumnsInDataView:(HLDataView *)dataView forRowWithIndex:(NSInteger)index
{
    if ([_dataArray count]>0) {
        return [_headerArray count]+1;
    }
    return [_headerArray count];
}

-(HLDataViewCell*)dataView:(HLDataView *)dView viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex
{
    NSString *identifier=[NSString stringWithFormat:@"cell_%d_%d",rowIndex,columnIndex];
    DDataViewCell *cell=(DDataViewCell*)[dView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[DDataViewCell alloc]initWithReuseIdentifier:identifier];
    }
    cell.rowIndex=rowIndex;
    cell.columnIndex=columnIndex;
    cell.maxRows=[_dataArray count]+1;
    cell.maxColumns=[_headerArray count]+1;
    
    if (rowIndex==0) {
        cell.isHeader=YES;
        if (columnIndex==0) {
            cell.titleLabel.text=@"类别";
        }else{
            cell.titleLabel.text=[NSString stringWithFormat:@"%@",[_headerArray objectAtIndex:(columnIndex-1)]];
        }
    }else{
        
        NSDictionary *dic=(NSDictionary*)[_dataArray objectAtIndex:(rowIndex-1)];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            if (columnIndex==0) {
                cell.titleLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"text"]];
            }else{
                NSArray *vs=(NSArray*)[dic objectForKey:@"values"];
                if ([vs count]>0) {
                    cell.titleLabel.text=[NSString stringWithFormat:@"%0.0f",[[vs objectAtIndex:(columnIndex-1)]floatValue]];
                }
            }
            
        }
        //NSLog(@"%@",[dataArray objectAtIndex:(rowIndex-1)]);
    }
    return cell;
}

@end
