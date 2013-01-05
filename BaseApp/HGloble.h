//
//  HGloble.h
//  SAnalysis
//
//  Created by 吴旭俊 on 12-10-22.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//



#define DID_GET_TOKEN_IN_WEB_VIEW   @"didGetTokenInWebView"
#define DOWNLOAD_SUCCEED            @"downloadSucceed"
#define OAUTH_REQUEST_FINISHED      @"OAuthRequestFinished"


#ifdef DEBUG
#define HLog(format,...) NSLog([NSString stringWithFormat:@"\n%sLine%d:\n%@",__FUNCTION__,__LINE__,format],## __VA_ARGS__)
#define HLogRect(rect)   HLog(@"%@",NSStringFormCGRect(rect));
#else
#define HLog(format,...)
#define HLogRect(rect)
#endif

/**
 * 定义结构体，用来表示区间 表示一个从几到几的
 **/
typedef struct _HRange{
    NSInteger   start;
    NSInteger   end;
} HRange;


/**
 * @brief 创建结构体 HRange 结构体中保存start,end
 * @param start 范围开始
 * @param end 范围结束
 * @return 返回该范围
 */
NS_INLINE HRange HRangeMake(NSInteger start,NSInteger end){
    HRange      range;
    range.start=start;
    range.end=end;
    return range;
}

/**
 * 该 int 数是否在HRange 区间内
 * @param r 整形区间
 * @param i 要比较的数
 * @return i在区间 r 内, 返回YES 否则 返回NO
 */
NS_INLINE BOOL  InRange(HRange r,NSInteger i){
    return (r.start<=i)&&(r.end>=i);
}

/**
 * 该点是否在某一rect区间内
 *@param p 点
 *@param r 矩形
 */
NS_INLINE BOOL CGPointInRect (CGPoint p,CGRect r){
     return p.x > r.origin.x && p.x < (r.origin.x + r.size.width) && p.y > r.origin.y && p.y < (r.origin.y + r.size.height);
}