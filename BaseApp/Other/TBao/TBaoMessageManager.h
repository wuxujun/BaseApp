//
//  TBaoMessageManager.h
//  SAnalysis
//
//  Created by xujun wu on 12-11-2.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBaoRequest.h"

@interface TBaoMessageManager : NSObject<TBaoRequestDelegate>
{
    TBaoRequest             *tbRequest;
}
@property (nonatomic,strong)TBaoRequest     *tbRequest;


+(TBaoMessageManager*)getInstance;

-(NSURL*)getOAuthCodeUrl;
//查看Token 是否过期
-(BOOL)isNeedToRefreshTheToken;


@end
