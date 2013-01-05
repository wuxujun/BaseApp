//
//  HLMessage.h
//  NetGrid
//
//  Created by 吴旭俊 on 12-9-22.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLMessage : NSObject{

    NSInteger            mId;
    NSInteger            supId;
    int                  type;
    
    NSString            *title;
    NSString            *desc;
    NSString            *desc2;
    NSString            *createTime;
    NSString            *imageUrl;
    NSString            *dataUrl;
    NSArray             *limits;
    int                 status;
    int                 isHidden;  //0  图片和描述全显示  1 只显示图片 2 只显示描述
    NSString            *createAt;

}
-(id)initWithMessageObject:(NSDictionary*)dic;

@property (nonatomic,assign)NSInteger mId;
@property (nonatomic,assign)NSInteger   supId;
@property (nonatomic,assign)int   type;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString    *desc;
@property (nonatomic,strong)NSString    *desc2;
@property (nonatomic,strong)NSString    *createTime;
@property (nonatomic,strong)NSString    *imageUrl;
@property (nonatomic,strong)NSString    *dataUrl;
@property (nonatomic,strong)NSString    *createAt;
@property (nonatomic,assign)int         status;
@property (nonatomic,assign)int         isHidden;
@property (nonatomic,strong) NSArray     *limits;

-(NSArray*)limitsFromFile;
-(void)changeLimitsToFile:(NSArray*)array;

@end
