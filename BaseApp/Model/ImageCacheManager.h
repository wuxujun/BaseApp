//
//  ImageCacheManager.h
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#define MAX_CACHEBUFFER_SIZE 20
#define ImageCacheNotification  @"ImageCacheNotification"
#define ImageCacheURLKey        @"ImageCacheURLKey"
#define ImageCacheData          @"ImageCacheData"
#define ImageCacheIndex         @"ImageCacheIndex"

@class CoreDataManager;

@interface ImageCacheManager : NSObject<ASIHTTPRequestDelegate>
{
    NSMutableDictionary     *cacheDict;
    NSMutableArray          *cacheArray;
    
    CoreDataManager         *_CDManager;
}
@property (nonatomic,strong)CoreDataManager *CDManager;

-(id)init;

-(void)getDataWithURL:(NSString*)aUrl;
-(void)getDataWithURL:(NSString *)aUrl withIndex:(NSInteger)aIndex;

-(void)freeMemory;

+(ImageCacheManager*)getInstance;

@end
