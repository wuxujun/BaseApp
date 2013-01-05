//
//  ImageCacheManager.m
//  BaseApp
//
//  Created by xujun wu on 12-12-12.
//  Copyright (c) 2012年 xujun wu. All rights reserved.
//

#import "ImageCacheManager.h"
#import "CoreDataManager.h"
#import "Images.h"

@interface ImageCacheManager()
@end

static   ImageCacheManager   *instance;

@implementation ImageCacheManager
@synthesize CDManager=_CDManager;

-(id)init
{
    self=[super init];
    if (self) {
        cacheDict=[[NSMutableDictionary alloc]init];
        cacheArray=[[NSMutableArray alloc]init];
        self.CDManager=[CoreDataManager getInstance];
    }
    return self;
}

+(ImageCacheManager*)getInstance
{
    @synchronized(self){
        if (instance==nil) {
            instance=[[ImageCacheManager alloc]init];
        }
    }
    return instance;
}

-(void)sendNotificationWithKey:(NSString*)url data:(NSData*)aData index:(NSNumber*)aIndex
{
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:url,ImageCacheURLKey,aData,ImageCacheData,aIndex,ImageCacheIndex, nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:ImageCacheNotification object:dic];
}


-(void)getDataWithURL:(NSString *)aUrl withIndex:(NSInteger)aIndex
{
    if (aUrl==nil||[aUrl length]==0) {
        return;
    }
    @synchronized(self){
        Images *image=[_CDManager readImageFromCD:aUrl];
        if(image!=nil&&![image isEqual:[NSNull null]]){
            NSNumber *indexNumber=[NSNumber numberWithInt:aIndex];
            [self sendNotificationWithKey:aUrl data:image.data index:indexNumber];
        }else{
            ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:aUrl]];
            [request setDelegate:self];
            if(aIndex>0){
                NSNumber *indexNumber=[NSNumber numberWithInt:aIndex];
                [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:aUrl,@"url",indexNumber,@"index", nil]];
            }else{
                [request setUserInfo:[NSDictionary dictionaryWithObject:aUrl forKey:@"url"]];
            }
            [request startAsynchronous];
        }
    }
}
-(void)getDataWithURL:(NSString *)aUrl
{
    [self getDataWithURL:aUrl withIndex:-1];
}

-(void)freeMemory
{
    @synchronized(self){
        [cacheArray removeAllObjects];
        [cacheDict removeAllObjects];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *url=[request.userInfo objectForKey:@"url"];
    NSNumber *indexNumber=[request.userInfo objectForKey:@"index"];
    NSData *data=[request responseData];
    [_CDManager insertImageToCD:data url:url];
    [self sendNotificationWithKey:url data:data index:indexNumber];
}

@end
