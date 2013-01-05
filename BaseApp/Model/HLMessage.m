//
//  HLMessage.m
//  NetGrid
//
//  Created by 吴旭俊 on 12-9-22.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import "HLMessage.h"

@implementation HLMessage
@synthesize mId,supId,type,title,desc,status,createAt,imageUrl,dataUrl,isHidden;
@synthesize desc2,createTime,limits;

-(id)initWithMessageObject:(NSDictionary *)dic
{
    if (self==[super init]) {
        self.mId=(NSInteger)[[dic objectForKey:@"id"] intValue];
        self.supId=(NSInteger)[[dic objectForKey:@"supid"] intValue];
        self.type=[[dic objectForKey:@"type"] intValue];
        self.title=[dic objectForKey:@"title"];
        self.desc=[dic   objectForKey:@"desc"];
        self.desc2=[dic   objectForKey:@"desc2"];
        self.createTime=[dic   objectForKey:@"createTime"];
        self.imageUrl=[dic   objectForKey:@"image"];
        self.dataUrl=[dic objectForKey:@"data_url"];
        self.status=[[dic  objectForKey:@"status"]intValue];
        self.isHidden=[[dic objectForKey:@"is_hidden"] intValue];
        self.limits=[dic objectForKey:@"limits"];
        if ([limits count]>0) {
            [self saveLimitsToFile];
        }
        //   self.createAt=[dic objectForKey:@"createAt"];
    }
    return  self;
}

-(void)saveLimitsToFile
{
    if (!self.limits) {
        return;
    }
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory=[paths objectAtIndex:0];
    if (!docDirectory) {
        NSLog(@"Documents directory not found");
        return;
    }
    NSString *appFile=[docDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"limits_%d",self.mId]];
    [self.limits writeToFile:appFile atomically:YES];
}

-(void)changeLimitsToFile:(NSArray *)array
{
    if (!self.mId) {
        return;
    }
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory=[paths objectAtIndex:0];
    if (!docDirectory) {
        NSLog(@"Documents directory not found");
        return;
    }
    NSString *appFile=[docDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"limits_%d",self.mId]];
    [array writeToFile:appFile atomically:YES];
}

-(NSArray*)limitsFromFile
{
    if (!self.mId) {
        return nil;
    }
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory=[paths objectAtIndex:0];
    NSString *appFile=[docDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"limits_%d",self.mId]];
    NSArray *myData=[NSArray arrayWithContentsOfFile:appFile];
    return myData;
}



@end
