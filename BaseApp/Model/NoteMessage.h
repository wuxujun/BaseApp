//
//  NoteMessage.h
//  SAnalysis
//
//  Created by xujun wu on 12-11-5.
//  Copyright (c) 2012年 吴旭俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteMessage : NSObject
{
    int                 mId;
    NSString            *title;
    NSString            *content;
    
    time_t              createTime;
    time_t              changeTime;
    
    NSString            *imgUrl;
    
    BOOL                isSync;

}
@property (nonatomic,assign)int             mId;
@property (nonatomic,strong)NSString        *title;
@property (nonatomic,strong)NSString        *content;
@property (nonatomic,strong)NSString        *imgUrl;

@property (nonatomic, assign) time_t        createTime;
@property (nonatomic, assign) time_t        changeTime;
@property (nonatomic, assign) BOOL          isSync;

@end
