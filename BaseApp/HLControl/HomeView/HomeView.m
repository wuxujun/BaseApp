//
//  HomeView.m
//  FindAD
//
//  Created by  on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HomeView.h"
#import "HomeItemView.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "HLMessage.h"

@interface HomeView()<ASIHTTPRequestDelegate,UIScrollViewDelegate> {
    ASIFormDataRequest     *_formRequest;
    OverlayView         *overlayView;
    
    UIScrollView        *_scrollView;
    
    UIPageControl       *_pageControl;
    
    NSMutableArray      *_datas;
}

@end

@implementation HomeView
@synthesize message;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        delegate=aDelegate;
        [self initializeFields];
    }
    
    return self;
}

-(void)initializeFields
{
    if (overlayView==nil) {
        overlayView=[[OverlayView alloc]initWithFrame:self.frame];
        [overlayView setMessage:@"数据加载中..." spinner:true];
        [self addSubview:overlayView];
    }
    
    if (_datas==nil) {
        _datas=[[NSMutableArray alloc]init];
    }
    if(_scrollView==nil){
        _scrollView=[[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.pagingEnabled=YES;
        _scrollView.delegate=self;
        _scrollView.showsHorizontalScrollIndicator=NO;
        _scrollView.showsVerticalScrollIndicator=NO;
        [self addSubview:_scrollView];
    }
    if(_pageControl==nil){
        _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-20, 80, 20)];
        _pageControl.numberOfPages=4;
        _pageControl.currentPage=0;
        [self addSubview:_pageControl];
    }
    
}

-(void)loadData
{
    [self initializeFields];
   
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"supid=1" forKey:@"s"];
    [dict setObject:@"query" forKey:@"action"];
    [dict setObject:@"ios_report" forKey:@"t"];
    [dict setObject:@"1" forKey:@"tid"];
    [dict setObject:@"data" forKey:@"msg_type"];
    [dict setObject:@"form" forKey:@"msg_type"];
    
    NSString    *requestUrl=@"http://wochong.1866.co/UServer/dbt/index.php/Index/doAction";
//    NSString    *requestUrl=@"http://192.168.1.245/UServer/dbt/index.php/Index/doAction";
    
    NSString     *paramValue=[dict JSONRepresentation];
    NSLog(@"%@?params=%@",requestUrl,paramValue);
    
    _formRequest=[[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:requestUrl]];
    [_formRequest setPostValue:paramValue forKey:@"params"];
    [_formRequest setTimeOutSeconds:20];
    [_formRequest setValidatesSecureCertificate:NO];
    _formRequest.delegate=self;
    [_formRequest startAsynchronous];
    
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *result=[[NSString alloc]initWithData:[request responseData] encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",result);
    NSObject *obj=[result JSONValue];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic=(NSDictionary*)obj;
		NSString *msg=[dic objectForKey:@"isSuccess"];
		if (![msg isEqualToString:@"1"]) {
			return;
		}
        [_datas removeAllObjects];
        NSArray *array=(NSArray*)[dic objectForKey:@"root"];
        for (int i=0; i<[array count]; ++i) {
            NSDictionary *dc=(NSDictionary*)[array objectAtIndex:i];
            if (![dc isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            HLMessage  *msg=[[HLMessage alloc]initWithMessageObject:dc];
            if (msg) {
                [_datas addObject:msg];
            }
        }
    }
    [self reloadData];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@",[request error]);
    [overlayView setMessage:@"数据加载失败..." spinner:false];
}

-(void)reloadData
{
    if ([_datas count]>0) {
        HomeItemView *itemView;
        HLMessage     *msg;
        for ( int index=0; index<[_datas count]; index++) {
            msg=(HLMessage*)[_datas objectAtIndex:index];
            itemView=[[HomeItemView alloc]initWithFrame:CGRectMake(index*320, 0, self.frame.size.width, _scrollView.frame.size.height) delegate:self];
//            NSLog(@"hhhhhhhh %f %f %f %f",_pageControl.frame.size.width,_pageControl.frame.size.height,_scrollView.frame.size.width,_scrollView.frame.size.height);
            itemView.message=msg;
            itemView.tag=index;
            itemView.title=msg.title;
            itemView.dataUrl=msg.dataUrl;
            [_scrollView addSubview:itemView];
        }
        _scrollView.contentSize=CGSizeMake(self.frame.size.width*[_datas count], _scrollView.frame.size.height);
        _pageControl.numberOfPages=[_datas count];
    }
    [overlayView removeFromSuperview];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth=_scrollView.frame.size.width;
    int page=floor((_scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    _pageControl.currentPage=page;
}

-(void)onItemClicked:(HomeItemView *)view
{
    message=view.message;
    [delegate onHomeViewClicked:self];
}
@end
